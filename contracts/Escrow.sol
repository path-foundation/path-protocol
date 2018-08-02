/* solium-disable security/no-block-members */
pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./Deputable.sol";
import "./Certificates.sol";
import "./PublicKeys.sol";
import "./PathToken.sol";

/// @title Implements a store of requests and escrow of payments
/// @author Path Foundation
/// @dev The basic workflow would be as following:
/// 1. Seeker approves token withdrawl by the escrow in the amount 
/// equal or greater than the request price
/// 2. Optionally, Seeker may deposite an amount of tokens
/// greater than required for a request (say, 10x) by calling 'increaseAvailableBalance()' if they anticipate
/// making several requests - this will avoid the escrow having to withdraw tokens from Seeker
/// on each request thus saving the Seeker some amount of gas. 
/// Note, that the Seekr needs to approve the escrow to withdraw that amount from the Seeker
/// proior to calling `increaseAvailableBalance()` by calling `PathToken.approve(escrow_address, value)`
/// 3. Seeker calls `submitRequest`
/// Note: Seeker app should implement some way of notifying the User app about the request 
/// (e.g. via Android/iOS push notifications) - preferred; 
/// or User app should implement some sort of a periodic pull - not ideal
/// 4. User receives the request for certificate and either approves or denies it
/// 5. If denied, the request on the escrow contract is marked as Denied 
/// and the Seeker gets their tokens refunded into their available balance escrow account
/// Note: Seeker may retrieve tokens from their available balance account on the escrow contract 
/// at any time.
/// 6. If approved, User app retrieves the certificate from their cert store,
/// decrypts it and reencrypts with the Seeker's public key (retrieved from PublikKeys contract)
/// 7. User places the encrypted cert on IPFS
/// 8. User calls `userCompleteRequest`, passing the IPFS locator of the certificate; the User app 
/// notifies the Seeker app (via a push notification of sorts or a pull by Seeker app) that
/// the cert is ready to be acquired
/// 9. Seeker app pickes up the cert from IPFS, decrypts it, hashes it using sha256 algorithm, and
/// compares to the expected hash 
/// 10. If hashes don't match, the verification is a FAIL. Further behavior is stil undetermined
/// but will probably include human intervention and some sort of penalties for either side - TBD
/// 11. If hashes match, the verification is a SUCCESS. At this point, the tokens from the escrow
/// are distributed between the user and the issuer.

/// Things to consider: 
/// 1. How to deal with a failure to match cert hashes
/// 2. What if hashes match but the content of the cert doesn't match 
/// the declared achievement/degree/position etc.
contract Escrow is Deputable {
    using SafeMath for uint256;

    // Certificates contract
    Certificates public certificates;

    // Public keys contract
    PublicKeys public publicKeys;

    // PathToken contract
    PathToken public token;

    // Cost of a request in PATH tokens
    uint public tokensPerRequest; 
    // Recentage of token reward going to the issuer, in percent, like 60(%)
    uint public issuerReward;

    // Flag shows whether the escrow is enabled
    // In case of an upgrade or a discovered flaw, Escrow contract may be disabled
    // In that case, no new requests will be accepted;
    // All requests currently in flight will still be able to complete
    bool enabled;

    // Seeker's balance usable for new requests or refund
    // Seeker can top off that balance to save on gas fees for every new request
    // Also, funds from cancelled request go to this balance
    mapping (address => uint) public seekerAvailableBalance;

    // Seeker's balance for requests currently in flight
    mapping (address => uint) public seekerInflightBalance;

    constructor(PathToken _token, Certificates _certificates, PublicKeys _publicKeys) public {
        token = _token;
        certificates = _certificates;
        publicKeys = _publicKeys;
        tokensPerRequest = 25 * 10 ** uint(token.decimals()); // 25 * 10^6 

        // Issuer gets <issuerReward>%, user gets the rest
        issuerReward = 50;

        enabled = true;
    }

    /// @notice Function sets `enabled` flag
    /// @param _disable `true` to disable the contract, `false` to re-enable it
    function disable(bool _disable) public onlyOwnerOrDeputy {
        enabled = !_disable;
    }

    /// @notice Method sets the number of tokens per request
    /// @dev Only Owner or Deputy can call this mehtod
    /// @param _tokensPerRequest Number of tokens per request (in actual tokens, not display)
    function setTokensPerRequest(uint _tokensPerRequest) external onlyOwnerOrDeputy {
        tokensPerRequest = _tokensPerRequest;
    }

    /// @notice Method sets the reward percent for the issuer
    /// @dev Only Owner or Deputy can call this mehtod
    /// The amount is in percent, i.e. whole number from 1 to 100
    /// @param _issuerReward Issuer's reward in percent (1 to 100)
    function setIssuerReward(uint _issuerReward) external onlyOwnerOrDeputy {
        require (_issuerReward >= 1 && _issuerReward <= 100);

        issuerReward = _issuerReward;
    }

    /// @notice Method increases Seeker's available balance on escrow account 
    /// by transferring tokens from Seeker to escrow. The method is used for gas savings
    /// if the Seeker anticipates multiple requests
    /// @dev Seeker needs to make show they approve withdrawal of the deposit amount by the escrow address
    /// prior to making the call, by calling `PathToken.approve()` method
    /// param _amount Amount to deposit to the Seekers avail balance account on the escrow
    function increaseAvailableBalance(uint _amount) public {
        address seeker = msg.sender;
        
        // Make sure seeker allowed transferrign the tokens
        require(token.allowance(seeker, this) >= _amount);

        // transfer tokens from seeker's account
        token.transferFrom(seeker, this, _amount);

        // Increase seeker's available balance
        seekerAvailableBalance[seeker] = seekerAvailableBalance[seeker].add(_amount);
    }

    /// @notice Seeker can refund their available balance by calling this method
    function refundAvailableBalance() public {
        address seeker = msg.sender;
        uint balance = seekerAvailableBalance[seeker];
        
        require(balance > 0);

        seekerAvailableBalance[seeker] = 0;
        token.transfer(seeker, balance);
    }

    /// @notice Owner or Deputy can force refund of avail balance to a Seeker
    /// @param _seeker Seeker's address
    function refundAvailableBalanceAdmin(address _seeker) public onlyOwnerOrDeputy {
        uint balance = seekerAvailableBalance[_seeker];
        
        require(balance > 0);

        seekerAvailableBalance[_seeker] = 0;
        token.transfer(_seeker, balance);
    }

    enum RequestStatus {
        None, // 0
        // Initial status of a request
        Initial, // 1
        // Request approved by the user, at this step an IPFS locator is included in the request
        UserCompleted, // 2
        // Request is denied by the user, at this point Seeker's deposit becomes refundable
        UserDenied, // 3
        // Certificate is received by the Seeker and successfully verified against the certificate hash
        SeekerCompleted, // 4
        // Certificate is received by the Seeker, but the hash doesnt match; 
        // TODO: some remediation action is needed here
        SeekerFailed, // 5
        // Request is cancelled by the Seeker - only possible if the request status is Initial
        SeekerCancelled // 6
    }

    struct DataRequest {
        address seeker; // 20
        // Request status
        RequestStatus status; // 1
        // Certificate hash
        bytes32 hash; // 32
        // The date the request was submitted
        uint48 timestamp; // 6
        // Certificate locator, set by the user on 'UserComplete' call
        bytes32 locatorHash; // 32
    }

    // Mapping of users (address) to arrays of requests 
    mapping (address => DataRequest[]) requests;

    /// @notice Retrurn the number of requests for a provided user
    /// @param _user User address
    function getDataRequestCount(address _user) public view returns (uint) {
        return requests[_user].length;
    }

    /// @notice Retrieve a request by its index in the user's requests array
    /// @param _user User address
    /// @param _i Index of the certificate to retrieve
    function getDataRequestByIndex(address _user, uint _i) public view 
        returns (address seeker, RequestStatus status, bytes32 hash, uint48 timestamp) {
        
        DataRequest[] storage reqs = requests[_user];

        // Make sure the index is less than the length of the array
        if(reqs.length > _i) {
            seeker = reqs[_i].seeker;
            status = reqs[_i].status;
            hash = reqs[_i].hash;
            timestamp = reqs[_i].timestamp;
        }

        return;
    }

    /// @notice Retrieve request index by hash
    /// @param _user User address
    /// @param _hash Certificate hash
    /// @return index - index or the certificate in the user's array. -1 if not found
    function getDataRequestIndexByHash(address _user, bytes32 _hash) public view
        returns (int index) {
        DataRequest[] storage reqs = requests[_user];
    
        for (uint i = 0; i < reqs.length; i ++) {
            if (reqs[i].hash == _hash) {
                return int(i);
            }
        }

        return -1;
    }

    /// @notice Retrieve the request metadata by providing the certificate hash
    /// @param _user User address
    /// @param _hash Certificate hash
    /// @return seeker Seeker address
    /// @return status Request status
    /// @return timestamp Request creation timestamp (in seconds)
    function getDataRequestByHash(address _user, bytes32 _hash) public view 
        returns (address seeker, RequestStatus status, bytes32 hash, uint48 timestamp) {
        
        int i = getDataRequestIndexByHash(_user, _hash);

        if (i >= 0) {
            DataRequest storage req = requests[_user][uint(i)];

            seeker = req.seeker;
            status = req.status;
            hash = req.hash;
            timestamp = req.timestamp;
        }
    }

    event RequestSubmitted(address indexed _user, address indexed _seeker, bytes32 _hash);
    event RequestDenied(address indexed _user, address indexed _seeker, bytes32 _hash);
    event RequestCompleted(address indexed _user, address indexed _seeker, bytes32 _hash);

    /// @notice Seeker places the request for a user's certificate with provided hash.
    /// Seeker can optionally send some ETH to cover User's gas for User's interaction with the contract
    /// NOTE: Seeker can first check if the certificate is revoked (before submitting a request), 
    /// by calling `Certificates.getCertificateMetadata()`;
    /// this will save gas for the call below if the cert is revoked
    /// @param _user User address
    /// @param _hash Certificate hash
    function submitRequest(address _user, bytes32 _hash) public payable {

        // Make sure the escrow contract is enabled
        require (enabled, "Escrow is disabled and doesn't accept new requests");

        // Check to make sure the cert is not revoked
        address issuer;
        bool revoked;
        (issuer, revoked) = certificates.getCertificateMetadata(_user, _hash);
        require(revoked == false, "Requested certificate has been revoked");

        address seeker = msg.sender;

        // Seeker's public key is expected to already be in seekerPublicKeys mapping
        // It gets there when a seeker is initialized in the app, 
        // by calling addSeekerPubKey()
        require (publicKeys.publicKeyStore(seeker).length != 0, "Seeker is not registered");

        // First, check if seeker allowed this Escrow contract to transfer the payment 
        uint availableBalance = seekerAvailableBalance[seeker];
        uint allowance = token.allowance(seeker, this);
        require (availableBalance >= tokensPerRequest || allowance >= tokensPerRequest, "Insufficient balance");

        // We either take tokens from seeker's bank or transfer from their account
        if (availableBalance >= tokensPerRequest) {
            seekerAvailableBalance[seeker] = seekerAvailableBalance[seeker].sub(tokensPerRequest);
            seekerInflightBalance[seeker] = seekerInflightBalance[seeker].add(tokensPerRequest);
        } else {
            token.transferFrom(seeker, this, tokensPerRequest);
            seekerInflightBalance[seeker] = seekerInflightBalance[seeker].add(tokensPerRequest);
        }

        DataRequest memory request = DataRequest({
            seeker : seeker,
            status : RequestStatus.Initial,
            hash : _hash,
            timestamp: uint48(block.timestamp),
            locatorHash: 0
        });

        requests[_user].push(request);

        emit RequestSubmitted(_user, seeker, _hash);

        // If seeker sent some eth along the way, transfer eth to the user
        if (msg.value > 0) {
            _user.transfer(msg.value);
        }
    }

    /// @notice User denies the request
    /// @param _hash Certificate hash
    function userDenyRequest(bytes32 _hash) public {
        address user = msg.sender;

        int i = getDataRequestIndexByHash(user, _hash);

        require(i >= 0, "Data request not found for the hash provided");

        DataRequest storage req = requests[user][uint(i)];

        require(req.status == RequestStatus.Initial, "Incorrect status");

        req.status = RequestStatus.UserDenied;

        // Refund seeker tokens
        seekerInflightBalance[req.seeker] = seekerInflightBalance[req.seeker].sub(tokensPerRequest);
        seekerAvailableBalance[req.seeker] = seekerAvailableBalance[req.seeker].add(tokensPerRequest);
        
        emit RequestDenied(user, req.seeker, _hash);
    }

    /// @notice User completes the request
    /// @param _hash Certificate hash
    /// @param _locatorHash IPFS locator of the certificate
    function userCompleteRequest(bytes32 _hash, bytes32 _locatorHash) public {
        address user = msg.sender;

        int i = getDataRequestIndexByHash(user, _hash);

        require(i >= 0, "Data request not found for the hash provided");

        DataRequest storage req = requests[user][uint(i)];

        require(req.status == RequestStatus.Initial, "Incorrect status");

        req.locatorHash = _locatorHash;
        req.status = RequestStatus.UserCompleted;

        emit RequestCompleted(user, req.seeker, _hash);
    }

    /// @notice Seeker can cancel a request that is still in Initial state
    /// @param _user User address
    /// @param _hash Certificate hash
    function seekerCancelRequest(address _user, bytes32 _hash) public {
        address seeker = msg.sender;

        int i = getDataRequestIndexByHash(_user, _hash);

        require(i >= 0, "Data request not found for the hash provided");

        DataRequest storage req = requests[_user][uint(i)];

        require(req.status == RequestStatus.Initial, "Only requests in Initial state may be cancelled");

        req.status = RequestStatus.SeekerCancelled;

        require(seekerInflightBalance[seeker] >= tokensPerRequest);

        seekerInflightBalance[seeker] = seekerInflightBalance[seeker].sub(tokensPerRequest);
        seekerAvailableBalance[seeker] = seekerAvailableBalance[seeker].add(tokensPerRequest);
    }

    /// @notice Seeker received the certificate and successfully verified it against the hash
    /// @param _user User address
    /// @param _hash Certificate hash
    function seekerCompleted(address _user, bytes32 _hash) public {
        address seeker = msg.sender;

        int i = getDataRequestIndexByHash(_user, _hash);

        require(i >= 0, "Data request not found for the hash provided");

        DataRequest storage req = requests[_user][uint(i)];

        require(req.status == RequestStatus.UserCompleted, "Only requests in UserCompleted state may be completed by seeker");

        address issuer;
        bool revoked;

        (issuer, revoked) = certificates.getCertificateMetadata(_user, _hash);

        seekerInflightBalance[seeker] = seekerInflightBalance[seeker].sub(tokensPerRequest);

        uint issuerRewardTokens = tokensPerRequest.mul(issuerReward).div(100);
        uint userReward = tokensPerRequest - issuerRewardTokens;

        token.transfer(issuer, issuerReward);

        token.transfer(_user, userReward);

        req.status = RequestStatus.SeekerCompleted;
    }
}

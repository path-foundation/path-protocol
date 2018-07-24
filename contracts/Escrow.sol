/* solium-disable security/no-block-members */
pragma solidity ^0.4.24;

import "./Deputable.sol";
import "./Certificates.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


contract PathToken {
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    uint8 public decimals;
}

/**
    Contract serves as a queue of requests and an escrow of payments (or refunds).
 */
contract Escrow is Deputable {
    using SafeMath for uint256;

    // Certificates contact
    Certificates certificates;

    PathToken private token;
    constructor(PathToken _token, Certificates _certificates) public {
        token = _token;
        certificates = _certificates;
        tokensPerRequest = 25 * 10 ** uint(token.decimals()); // 25 * 10^6 
        issuerReward = 50;
    }

    uint tokensPerRequest; 
    function setTokensPerRequest(uint _tokensPerRequest) external onlyOwnerOrDeputy {
        // _tokensPerRequest is in display format (e.g. 25), i.e. has to be multiplied by 10^decimals
        tokensPerRequest = _tokensPerRequest * 10 ** uint(token.decimals());
    }

    // Recentage of token reward going to the issuer, in percent, like 60(%)
    uint issuerReward;
    function setIssuerReward(uint _issuerReward) external onlyOwnerOrDeputy {
        issuerReward = _issuerReward;
    }

    // Change the token contract address
    function setPathToken(PathToken _token) public onlyOwnerOrDeputy {
        token = _token;
    }

    // Change the Certificates contract address
    function setCertificates(Certificates _certificates) public onlyOwnerOrDeputy {
        certificates = _certificates;
    }

    // Store of seeker public keys, so that we dont need to store them for each request
    // TODO: Possibly put public keys into a separate contract
    mapping (address => bytes) seekerPublicKeys;

    // Seeker should add their public key to teh contract prior to sending any requests
    function addSeekerPublicKey(bytes _publicKey) public {
        // Make sure the seeker sends their own correct pblic key
        require(address(keccak256(_publicKey)) == msg.sender);
        seekerPublicKeys[msg.sender] = _publicKey;
    }

    // Seeker can top up their available balance
    // They could do that to save on gas - they won't need to sped gas on transferring tokens for each request
    function increaseAvailableBalance(uint amount) public {
        address seeker = msg.sender;
        
        // Make sure seeker allowed transferrign the tokens
        require(token.allowance(seeker, this) >= amount);

        // transfer tokens from seeker's account
        token.transferFrom(seeker, this, amount);

        // Increase seeker's available balance
        seekerAvailableBalance[seeker] = seekerAvailableBalance[seeker].add(amount);
    }

    // Seeker can refund their available balance 
    function refundAvailableBalance() public {
        address seeker = msg.sender;
        uint balance = seekerAvailableBalance[seeker];
        
        require(balance > 0);

        seekerAvailableBalance[seeker] = 0;
        token.transfer(seeker, balance);
    }

    function refundAvailableBalanceAdmin(address seeker) public onlyOwnerOrDeputy {
        uint balance = seekerAvailableBalance[seeker];
        
        require(balance > 0);

        seekerAvailableBalance[seeker] = 0;
        token.transfer(seeker, balance);
    }

    enum RequestStatus {
        // Initial status of a request
        Initial,
        // Request approved by the user, at this step an IPFS locator is included in the request
        UserCompleted,
        // Request is denied by the user, at this point Seeker's deposit becomes refundable
        UserDenied,
        // Certificate is received by the Seeker and successfully verified against the certificate hash
        SeekerCompleted,
        // Certificate is received by the Seeker, but the hash doesnt match; 
        // TODO: some remediation action is needed here
        SeekerFailed,
        // Request is cancelled by the Seeker - only possible if the request status is Initial
        SeekerCancelled
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

    // Retrurn the count of all requests for a user
    function getDataRequestCount(address _user) public view returns (uint) {
        return requests[_user].length;
    }

    // Retrieve a request by its index in the user's requests array
    function getDataRequestByIndex(address _user, uint i) public view 
        returns (address seeker, RequestStatus status, bytes32 hash, uint48 timestamp) {
        
        DataRequest[] storage reqs = requests[_user];

        // Make sure the index is less than the length of the array
        if(reqs.length > i) {
            seeker = reqs[i].seeker;
            status = reqs[i].status;
            hash = reqs[i].hash;
            timestamp = reqs[i].timestamp;
        }

        return;
    }

    function getDataRequestIndexByHash(address _user, bytes32 _hash) public view
        returns (int) {
        DataRequest[] storage reqs = requests[_user];
    
        for (uint i = 0; i < reqs.length; i ++) {
            if (reqs[i].hash == _hash) {
                return int(i);
            }
        }

        return -1;
    }

    // 
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

    // Seeker's balance usable for new requests or refund
    mapping (address => uint) seekerAvailableBalance;

    // Seeker's balance for requests currently in flight
    mapping (address => uint) seekerInflightBalance;

    event RequestSubmitted(address indexed _user, address indexed _seeker, bytes32 _hash);
    event RequestDenied(address indexed _user, address indexed _seeker, bytes32 _hash);
    event RequestCompleted(address indexed _user, address indexed _seeker, bytes32 _hash);

    // Seeker places the request for a user's certificate with provided hash 
    // Seeker can optionally send some ETH to cover User's gas for User's interaction with the contract
    // NOTE: Seeker can first check if the certificate is revoked (before submitting a request), 
    // by calling Certificates.getCertificateMetadata - 
    // this will save gas for the call below if the cert is revoked
    function submitRequest(address _user, bytes32 _hash) public payable {
        // Check to make sure the cert is not revoked
        address issuer;
        bool revoked;
        (issuer, revoked) = certificates.getCertificateMetadata(_user, _hash);
        require(revoked == false, "Requested certificate has been revoked");

        address seeker = msg.sender;

        // Seeker's public key is expected to already be in seekerPublicKeys mapping
        // It gets there when a seeker is initialized in the app, 
        // by calling addSeekerPubKey()
        require (seekerPublicKeys[seeker].length != 0, "Seeker is not registered");

        // First, check if seeker allowed this Escrow contract to transfer the payment 
        uint availableBalance = seekerAvailableBalance[seeker];
        uint allowance = token.allowance(seeker, this);
        require (availableBalance >= tokensPerRequest || allowance >= tokensPerRequest);

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

    // User denied the request
    function userDenyRequest(bytes32 _hash) public {
        address user = msg.sender;

        int i = getDataRequestIndexByHash(user, _hash);

        require(i >= 0, "Data request not found for the hash provided");

        DataRequest storage req = requests[user][uint(i)];

        require(req.status == RequestStatus.Initial, "Incorrect status");

        req.status = RequestStatus.UserDenied;

        emit RequestDenied(user, req.seeker, _hash);
    }

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

    // Seeker can cancel a request that is still in Initial state
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

    // Seeker received the certificate and successfully verified it against the hash
    function seekerCompleted(address _user, bytes32 _hash) public {
        address seeker = msg.sender;

        int i = getDataRequestIndexByHash(_user, _hash);

        require(i >= 0, "Data request not found for the hash provided");

        DataRequest storage req = requests[_user][uint(i)];

        require(req.status == RequestStatus.Initial, "Only requests in Initial state may be cancelled");

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

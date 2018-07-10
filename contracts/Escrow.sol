/* solium-disable security/no-block-members */
pragma solidity ^0.4.24;

import "./Deputable.sol";
import "./Certificates.sol";

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
    constructor(PathToken _token, Certificates _certificatesContract) public {
        token = _token;
        certificatesContract = _certificatesContract;
        acceptsRequests = true;
        tokensPerRequest = 25 * 10 ** uint(token.decimals()); // 25 * 10^6 
    }

    uint tokensPerRequest; 
    function setTokensPerRequest(uint _tokensPerRequest) external onlyOwnerOrDeputy {
        // _tokensPerRequest is in display format (e.g. 25), i.e. has to be multiplied by 10^decimals
        tokensPerRequest = _tokensPerRequest * 10 ** uint(token.decimals());
    }

    // We need a way to disable new requests, like in cause of a migration/upgrade
    bool acceptsRequests;
    function setAcceptsRequests(bool _accepts) public onlyOwnerOrDeputy {
        acceptsRequests = _accepts;
    }

    // Change the token contract address
    PathToken private token;
    function setPathToken(PathToken _token) public onlyOwnerOrDeputy {
        token = _token;
    }

    Certificates certificatesContract;
    function setCertificatesContract(Certificates _certificatesContract) public onlyOwnerOrDeputy {
        certificatesContract = _certificatesContract;
    }


    // Seeker posted the request
    uint8 public constant REQUEST_STATUS_PENDING = 0; 
     // User picked up the request
    uint8 public constant REQUEST_STATUS_PROCESSING = 1;
    // User processed the request and posted the cert locator
    uint8 public constant REQUEST_STATUS_PROCESSED = 2; 
    // Seeker confirmed that they have received the certificate; 
    // at this point tokens are distributed between the user and issuers
    uint8 public constant REQUEST_STATUS_CONFIRMED = 3;
    // User failed to process the request - refundable
    uint8 public constant REQUEST_STATUS_FAILED = 4; 
    // Seeker recalled the request before the user picked it up
    uint8 public constant REQUEST_STATUS_RECALLED = 5; 

    struct DataRequest {
        // Seeker, information requestor
        address seeker;
        // Seeker's public key
        bytes32 publicKey; 
        // Request status
        uint8 status; // one of the REQUEST_STATUS_*** constants
        // The date the request was submtted
        uint requestDate;
    }

    // Mapping of users (address) to arrays of requests 
    mapping (address => DataRequest[]) requests;

    // Mappign of users to the index of the next request to process in user's DataRequest[] array
    mapping (address => uint) nextRequestIndices;

    // Seeker's (address) balance (uint) on this escrow contract
    mapping (address => uint) seekerBalance;

    // 1. Seeker places a request for user's background check
    // This call has to be initiated by the seeker, i.e. msg.sender = seeker
    function submitRequestForData(address _user, bytes32 _seekerPublicKey) public {
        require(acceptsRequests);

        address seeker = msg.sender;

        // TODO: check Certification contract to see if the user has any certificates

        // First, check if seeker allowed this Escrow contract to transfer the payment 
        uint allowance = token.allowance(seeker, this);
        require (allowance >= tokensPerRequest);

        // Now, transfer the tokens from the seeker to this contract and make a note
        token.transferFrom(seeker, this, tokensPerRequest);
        // Incraese seeker's balance on the escrow
        seekerBalance[seeker] += tokensPerRequest;

        DataRequest memory request = DataRequest({
            seeker: seeker,
            publicKey: _seekerPublicKey,
            status: REQUEST_STATUS_PENDING,
            requestDate: block.timestamp
        });

        // Adding the new request
        requests[_user].push(request);
    }

    // 2. User polls for the next request - gets the seeker address, public key and request index
    // Note: this function modifies the status of the retrieved request to REQUEST_STATUS_PROCESSING
    function retrieveNextRequestForData() public returns (address, bytes32, uint) {
        address user = msg.sender;
        uint currentIndex = nextRequestIndices[user];

        DataRequest storage request = requests[user][currentIndex];
        request.status = REQUEST_STATUS_PROCESSING;

        // Bump the index to the next request
        nextRequestIndices[user] += 1;

        return (request.seeker, request.publicKey, currentIndex);
    }


    // 3. User provides the list of certificate locators encrypted with the seeker's public key
    // This changes the status of the request to REQUEST_STATUS_PROCESSED and triggers a payment
    // to all involved parties (user + issuers)
    // function submitResponse(uint requestIndex, bytes[] response) public {

    // }

}
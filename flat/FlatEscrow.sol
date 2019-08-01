
// File: contracts/Ownable.sol

pragma solidity ^0.5.1;

contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "Message sender is not contract Owner");
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0), "Unable to change the Owner to 0x0 address");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/Deputable.sol

pragma solidity ^0.5.1;


/// @title Deputable
/// @author Path Foundation
/// @notice The Deputable contract is an extension of Ownable contract that adds a deputy address.
/// @dev In general, deputy would have the same permissions as the owner, except that it can't change the owner
contract Deputable is Ownable {
    address public deputy;

    event DeputyModified(address indexed previousDeputy, address indexed newDeputy);

    /// @notice Set a new deputy
    /// @dev Only the contract owner or the current deputy can reassign the depity to someone else
    function setDeputy(address _deputy) public onlyOwnerOrDeputy {
        emit DeputyModified(deputy, _deputy);
        deputy = _deputy;
    }

    modifier onlyOwnerOrDeputy() {
        require(msg.sender == owner || msg.sender == deputy, "Only owner or deputy may execute the function");
        _;
    }
}

// File: contracts/Issuers.sol

pragma solidity ^0.5.1;


/// @title Stores certificate issuers
/// @dev Only the Owner or a Deputy can add/enable/disable an issuer
/// @author Path Foundation
contract Issuers is Deputable {
    // Whitelist of issuers mapped to their status
    mapping(address => IssuerStatus) internal issuers;

    enum IssuerStatus { None, Active, Inactive }

    event LogIssuerAdded(address indexed _issuer);

    /// @notice Add a new active issuer or reactivate inactive user
    function addIssuer(address _issuerAddress) public onlyOwnerOrDeputy {
        IssuerStatus status = getIssuerStatus(_issuerAddress);

        if (status != IssuerStatus.Active) {
            issuers[_issuerAddress] = IssuerStatus.Active;
            emit LogIssuerAdded(_issuerAddress);
        }
    }

    event LogIssuerRemoved(address indexed _issuerAddress);

    /// @notice Deactivate an active issuer
    /// @dev If the issuer does not exist or is inacive, no exceptions thrown
    function removeIssuer(address _issuerAddress) public onlyOwnerOrDeputy {
        IssuerStatus status = getIssuerStatus(_issuerAddress);

        if (status == IssuerStatus.Active) {
            issuers[_issuerAddress] = IssuerStatus.Inactive;
            emit LogIssuerRemoved(_issuerAddress);
        }
    }

    /// @notice Method returns issuer status
    /// @dev Status:
    /// 0 - issuer doesnt exists/not registered
    /// 1 - issuer is active
    /// 2 - issuer is inactive/deactivated
    function getIssuerStatus(address _issuerAddress) public view returns (IssuerStatus) {
        return issuers[_issuerAddress];
    }
}

// File: contracts/Certificates.sol

pragma solidity ^0.5.1;



/// @title The store of certificate hashes per user
/// @author Path Foundation
/// @notice The contract is used by Issuers when submitting certificates and
/// by Seekers when verifying a certificate received from a User
contract Certificates is Deputable {
    /// @notice mapping of user addresses to array of their certificates
    mapping (address => Certificate[]) public certificates;

    /// @title Array of all user addresses in the system
    address[] public users;

    /// @title Structure represents a single certificate metadata
    struct Certificate {
        // SHA256 hash of the certificate itself, used for validation of the certificate
        // by the Seeker once they receive it from the User
        // This hash is also used as the certificate id
        bytes32 hash; // 32 bytes

        address issuer; // 20 bytes

        // Issuer has control over certificates issued by them - they can revoke them
        // For example, if they found that a user was cheating on a test etc.
        bool revoked; // 1 byte
    }

    /// @notice Address of Issuers contract.
    /// We use this for getting whitelisted issuers
    Issuers public issuersContract;

    // Constructor
    constructor(Issuers _issuersContract) public {
        issuersContract = _issuersContract;
    }

    /// @notice Owner and deputy can modify Issuers contract address (for upgrades etc)
    /// @dev Can only be called by contract owner or deputy
    /// @param _issuersContract Issuers Address of Issuers contract
    function setIssuersContract(Issuers _issuersContract) public onlyOwnerOrDeputy {
        issuersContract = Issuers(_issuersContract);
    }

    event LogAddCertificate(address indexed _user, address indexed _issuerAddress, bytes32 _hash);

    /// @notice Add a certificate
    /// @dev Can only be called by active issuers (addresses in Issuers contract with status = Active)
    /// @param _user address of certificate owner
    /// @param _hash sha256 hash of the certificate text
    function addCertificate(address _user, bytes32 _hash) public
    {
        // Make sure the sender if a registered issuer
        address issuer = msg.sender;

        // Add user to users array if it's the first certificate for the user
        if (certificates[_user].length == 0) {
            users.push(_user);
        }

        // require an active issuer
        require(issuersContract.getIssuerStatus(issuer) == Issuers.IssuerStatus.Active, "Issuer is inactive");

        // Create the Certificate object
        Certificate memory cert = Certificate({
            hash: _hash,
            issuer: issuer,
            revoked: false
        });

        certificates[_user].push(cert);

        emit LogAddCertificate(_user, issuer, _hash);
    }

    /// @notice Retrieve certificate metadata
    /// @dev If the certificate with the provided user address and hash doesn't exist,
    /// then the return value of `_issuer` will be `0x0`
    /// @param _user User address
    /// @param _hash Sha256 hash of the certificate to retrieve metadata for
    /// @return _issuer Address of the certificate issuer
    /// @return _revoked Flag showing whether the certificate has been revoked by its issuer
    function getCertificateMetadata(address _user, bytes32 _hash) public view
        returns (address issuer, bool revoked) {

        // Get certificates array
        Certificate[] storage certs = certificates[_user];

        int i = getCertificateIndex(_user, _hash);

        if(i >= 0) {
            issuer = certs[uint(i)].issuer;
            revoked = certs[uint(i)].revoked;
        }
    }

    /// @notice Get the number of certificates for a given user
    /// @param _user User address
    /// @return count Number of certificates a given user has
    function getCertificateCount(address _user, bool _includeRevoked) public view returns(uint256 count) {
        if (_includeRevoked) {
            count = certificates[_user].length;
        } else {
            Certificate[] storage certs = certificates[_user];

            count = 0;
            for (uint i = 0 ; i < certs.length ; i ++) {
                if (!certs[i].revoked) {
                    count ++;
                }
            }
        }
    }

    /// @notice Get metadata of a user's certificate by its index
    /// @param _user User's address
    /// @param _index Certificate index
    /// @return hash Certificate hash
    /// @return issuer Address of the certificate issuer
    /// @return revoked Flag showing whether the certificate has been revoked by its issuer
    function getCertificateAt(address _user, uint _index) public view
        returns(bytes32 hash, address issuer, bool revoked) {

        Certificate[] storage certs = certificates[_user];

        if (certs.length > _index) {
            Certificate storage cert = certificates[_user][_index];

            hash = cert.hash;
            issuer = cert.issuer;
            revoked = cert.revoked;
        }
    }

    /// @notice Find index of a user's certificate by its hash
    /// @param _user User's address
    /// @param _hash Certificate hash
    /// @return index Indexof the certificate in the user's certificates array
    function getCertificateIndex(address _user, bytes32 _hash) public view returns (int index) {
        Certificate[] storage certs = certificates[_user];

        // Find certificate by hash
        uint count = certs.length;

        for (uint i = 0; i < count; i++) {
            if (certs[i].hash == _hash) {
                return int(i);
            }
        }

        return -1;
    }

    event LogCertificateRevoked(address indexed _user, bytes32 _hash);

    /// @notice Revoke a certificate
    /// @dev Only the issuer can revoke their own certificate
    /// @param _user User address
    /// @param _certificateIndex Index of certificate to be revoked in the user's array of certificates
    function revokeCertificate(address _user, uint _certificateIndex) public {
        address issuerAddress = msg.sender;

        // require an active issuer
        require(issuersContract.getIssuerStatus(issuerAddress) == Issuers.IssuerStatus.Active, "Issuer is not active");

        Certificate storage cert = certificates[_user][_certificateIndex];

        require(issuerAddress == cert.issuer, "Only a certificate issuer can revoke their certificate");

        cert.revoked = true;

        emit LogCertificateRevoked(_user, cert.hash);
    }
}

// File: contracts/PublicKeys.sol

pragma solidity ^0.5.1;

/// @title Contract stores a map of ethereum addresses and their associated public keys
contract PublicKeys {
    mapping (address => bytes) public publicKeyStore;

    /// @notice Adds a public key for the caller address
    /// after verifying that the sender's address derives from that public key
    function addPublicKey(bytes memory _publicKey) public {
        // Make sure the sender sends their own public key
        require(address(uint160(uint256(keccak256(_publicKey)))) == msg.sender, "Sender's address doesn't match the public key");
        publicKeyStore[msg.sender] = _publicKey;
    }
}

// File: contracts/PathToken.sol

pragma solidity ^0.5.1;


/**
    Declares an interface for functionality allowing to notify the receiving contract
    of the transfer of tokens or approval.
 */

contract TransferAndCallbackInterface {
    function transferAndCallback(address _to, uint256 _value, bytes memory _data) public returns (bool);
}

/**
 * An interface for a contract that receives tokens and gets notified after the transfer
 */
contract TransferAndCallbackReceiver {
/**
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function balanceTransferred(address _from, uint256 _value, bytes memory _data) public;
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract TransferAndCallback is ERC20Basic, TransferAndCallbackInterface {

/**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `balanceTransferred` function if the recipient is a contract.
     *      The token transfer fails if the recipient is NOT a contract
    *       or is a contract but does not implement the `balanceTransferred` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transferAndCallback(address _to, uint256 _value, bytes memory _data) public returns(bool) {

        // First make sure that _to address is a contract
        uint256 codeLength;
        /* solium-disable-next-line security/no-inline-assembly */
        assembly {
            codeLength := extcodesize(_to)
        }

        require(codeLength > 0, "'_to' address must be a contract");

        // transfer funds
        transfer(_to, _value);

        TransferAndCallbackReceiver receiver = TransferAndCallbackReceiver(_to);
        receiver.balanceTransferred(msg.sender, _value, _data);

        return true;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value), "Token transfer failed");
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value), "Token transfer failed");
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value), "Token approval failed");
  }
}

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(address(this));
    token.safeTransfer(owner, balance);
  }

}

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner,"");
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0), "Can't transfer to 0x0 address");
    require(_value <= balances[msg.sender], "Insufficient balance");

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0), "Can't transfer to 0x0 address");
    require(_value <= balances[_from], "Insufficient balance");
    require(_value <= allowed[_from][msg.sender], "Insufficient allowed balance");

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

/**
    PathToken is a standard ERC20 token with additional transfer function
    that notifies the receiving contract of the transfer.
 */
contract PathToken is StandardToken, TransferAndCallback, Claimable, CanReclaimToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor() public {
        name = "Path Token";
        symbol = "PATH";
        decimals = 6;
        totalSupply_ = 500000000 * 10 ** uint(decimals);
        balances[owner] = totalSupply_;
    }
}

// File: contracts/Escrow.sol

/* solium-disable security/no-block-members */
pragma solidity ^0.5.1;




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
    /// The amount is in percent, i.e. whole number from 0 to 100
    /// @param _issuerReward Issuer's reward in percent (0 to 100)
    function setIssuerReward(uint _issuerReward) external onlyOwnerOrDeputy {
        require (_issuerReward >= 0 && _issuerReward <= 100, "Issuer reward should be between 0% and 100%");

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

        // Make sure seeker allowed transferring the tokens
        require(token.allowance(seeker, address(this)) >= _amount, "Transfer not approved");

        require(token.balanceOf(seeker) >= _amount, "Insufficient balance");

        // transfer tokens from seeker's account
        token.transferFrom(seeker, address(this), _amount);

        // Increase seeker's available balance
        seekerAvailableBalance[seeker] = seekerAvailableBalance[seeker].add(_amount);
    }

    /// @notice Seeker can refund their available balance by calling this method
    function refundAvailableBalance() public {
        address seeker = msg.sender;
        uint balance = seekerAvailableBalance[seeker];

        require(balance > 0, "Balance is zero");

        seekerAvailableBalance[seeker] = 0;
        token.transfer(seeker, balance);
    }

    /// @notice Owner or Deputy can force refund of avail balance to a Seeker
    /// @param _seeker Seeker's address
    function refundAvailableBalanceAdmin(address _seeker) public onlyOwnerOrDeputy {
        uint balance = seekerAvailableBalance[_seeker];

        require(balance > 0, "Balance is zero");

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

        return (seeker, status, hash, timestamp);
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

        int index = getDataRequestIndexByHash(_user, _hash);

        if (index >= 0) {
            DataRequest storage req = requests[_user][uint(index)];

            seeker = req.seeker;
            status = req.status;
            hash = req.hash;
            timestamp = req.timestamp;
        }
    }

    event RequestSubmitted(address indexed _user, address indexed _seeker, bytes32 _hash, int _index);
    event RequestDenied(address indexed _user, address indexed _seeker, bytes32 _hash, int _index);
    event RequestCompleted(address indexed _user, address indexed _seeker, bytes32 _hash, int _index);

    /// @notice Seeker places the request for a user's certificate with provided hash.
    /// Seeker can optionally send some ETH to cover User's gas for User's interaction with the contract
    /// NOTE: Seeker can first check if the certificate is revoked (before submitting a request),
    /// by calling `Certificates.getCertificateMetadata()`;
    /// this will save gas for the call below if the cert is revoked
    /// @param _user User address
    /// @param _hash Certificate hash
    function submitRequest(address payable _user, bytes32 _hash) public payable {

        // Make sure the escrow contract is enabled
        require (enabled, "Escrow is disabled and doesn't accept new requests");

        // Check to make sure the cert is not revoked
        address issuer;
        bool revoked;
        (issuer, revoked) = certificates.getCertificateMetadata(_user, _hash);
        require(address(issuer) != address(0), "Requested certificate not found");
        require(revoked == false, "Requested certificate has been revoked");

        address seeker = msg.sender;

        // Seeker's public key is expected to already be in seekerPublicKeys mapping
        // It gets there when a seeker is initialized in the app,
        // by calling addSeekerPubKey()
        require (publicKeys.publicKeyStore(seeker).length != 0, "Seeker is not registered");

        // First, check if seeker allowed this Escrow contract to transfer the payment
        uint availableBalance = seekerAvailableBalance[seeker];
        uint allowance = token.allowance(seeker, address(this));
        require (availableBalance >= tokensPerRequest || allowance >= tokensPerRequest, "Insufficient balance");

        // We either take tokens from seeker's bank or transfer from their account
        if (availableBalance >= tokensPerRequest) {
            seekerAvailableBalance[seeker] = seekerAvailableBalance[seeker].sub(tokensPerRequest);
            seekerInflightBalance[seeker] = seekerInflightBalance[seeker].add(tokensPerRequest);
        } else {
            token.transferFrom(seeker, address(this), tokensPerRequest);
            seekerInflightBalance[seeker] = seekerInflightBalance[seeker].add(tokensPerRequest);
        }

        DataRequest memory request = DataRequest({
            seeker : seeker,
            status : RequestStatus.Initial,
            hash : _hash,
            timestamp: uint48(block.timestamp),
            locatorHash: 0
        });

        int index = int(requests[_user].push(request) - 1);

        emit RequestSubmitted(_user, seeker, _hash, index);

        // If seeker sent some eth along the way, transfer eth to the user
        // TODO: WHat to do in case if the user denies teh request -
        // we cant refund the seeker this eth amount
        if (msg.value > 0) {
            _user.transfer(msg.value);
        }
    }

    /// @notice User denies the request
    /// @param _hash Certificate hash
    function userDenyRequest(bytes32 _hash) public {
        address user = msg.sender;

        // TODO: Optimize by getting request index outside this transaction
        // and passing it to the function
        int index = getDataRequestIndexByHash(user, _hash);

        require(index >= 0, "Data request not found for the hash provided");

        DataRequest storage req = requests[user][uint(index)];

        require(req.status == RequestStatus.Initial, "Incorrect status");

        req.status = RequestStatus.UserDenied;

        // Refund seeker tokens
        seekerInflightBalance[req.seeker] = seekerInflightBalance[req.seeker].sub(tokensPerRequest);
        seekerAvailableBalance[req.seeker] = seekerAvailableBalance[req.seeker].add(tokensPerRequest);

        emit RequestDenied(user, req.seeker, _hash, index);
    }

    /// @notice User completes the request
    /// @param _hash Certificate hash
    /// @param _locatorHash IPFS locator of the certificate
    function userCompleteRequest(bytes32 _hash, bytes32 _locatorHash) public {
        address user = msg.sender;

        // TODO: Optimize by getting request index outside this transaction
        // and passing it to the function
        int index = getDataRequestIndexByHash(user, _hash);

        require(index >= 0, "Data request not found for the hash provided");

        DataRequest storage req = requests[user][uint(index)];

        require(req.status == RequestStatus.Initial, "Incorrect status");

        req.locatorHash = _locatorHash;
        req.status = RequestStatus.UserCompleted;

        emit RequestCompleted(user, req.seeker, _hash, index);
    }

    /// @notice Seeker can cancel a request that is still in Initial state
    /// @param _user User address
    /// @param _hash Certificate hash
    function seekerCancelRequest(address _user, bytes32 _hash) public {
        address seeker = msg.sender;

        int index = getDataRequestIndexByHash(_user, _hash);

        require(index >= 0, "Data request not found for the hash provided");

        DataRequest storage req = requests[_user][uint(index)];

        require(req.status == RequestStatus.Initial, "Only requests in Initial state may be cancelled");

        req.status = RequestStatus.SeekerCancelled;

        uint balanceToTransfer = seekerInflightBalance[seeker] >= tokensPerRequest ?
            tokensPerRequest : seekerInflightBalance[seeker];

        seekerInflightBalance[seeker] = seekerInflightBalance[seeker].sub(balanceToTransfer);
        seekerAvailableBalance[seeker] = seekerAvailableBalance[seeker].add(balanceToTransfer);
    }

    /// @notice Seeker received the certificate and successfully verified it against the hash
    /// @param _user User address
    /// @param _hash Certificate hash
    function seekerCompleted(address _user, bytes32 _hash) public {
        address seeker = msg.sender;

        int index = getDataRequestIndexByHash(_user, _hash);

        require(index >= 0, "Data request not found for the hash provided");

        DataRequest storage req = requests[_user][uint(index)];

        require(req.status == RequestStatus.UserCompleted, "Only requests in UserCompleted state may be completed by seeker");

        address issuer;
        bool revoked;

        (issuer, revoked) = certificates.getCertificateMetadata(_user, _hash);

        require(issuer > address(0), "Certificate doesn't exist");

        req.status = RequestStatus.SeekerCompleted;

        seekerInflightBalance[seeker] = seekerInflightBalance[seeker].sub(tokensPerRequest);

        uint issuerRewardTokens = tokensPerRequest.mul(issuerReward).div(100);
        uint userReward = tokensPerRequest - issuerRewardTokens;

        token.transfer(issuer, issuerReward);

        token.transfer(_user, userReward);
    }
}

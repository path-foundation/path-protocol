## Smart contracts

- ### [`Certificates`](#Certificates)
    * [**`addCertificate(address _user, bytes32 _hash)`**](#addcertificateaddress-_user-bytes32-_hash)
    * [**`deputy()`**](#deputy)
    * [**`getCertificateAt(address _user, uint256 _index)`**](#getcertificateataddress-_user-uint256-_index)
    * [**`getCertificateCount(address _user)`**](#getcertificatecountaddress-_user)
    * [**`getCertificateIndex(address _user, bytes32 _hash)`**](#getcertificateindexaddress-_user-bytes32-_hash)
    * [**`getCertificateMetadata(address _user, bytes32 _hash)`**](#getcertificatemetadataaddress-_user-bytes32-_hash)
    * [**`issuersContract()`**](#issuerscontract)
    * [**`owner()`**](#owner)
    * [**`renounceOwnership()`**](#renounceownership)
    * [**`revokeCertificate(address _user, uint256 _certificateIndex)`**](#revokecertificateaddress-_user-uint256-_certificateindex)
    * [**`setDeputy(address _deputy)`**](#setdeputyaddress-_deputy)
    * [**`setIssuersContract(address _issuersContract)`**](#setissuerscontractaddress-_issuerscontract)
    * [**`transferOwnership(address _newOwner)`**](#transferownershipaddress-_newowner)
    * [**`users(uint256 _uint256)`**](#usersuint256-_uint256)
- ### [`Escrow`](#Escrow)
    * [**`certificates()`**](#certificates)
    * [**`deputy()`**](#deputy)
    * [**`disable(bool _disable)`**](#disablebool-_disable)
    * [**`getDataRequestByHash(address _user, bytes32 _hash)`**](#getdatarequestbyhashaddress-_user-bytes32-_hash)
    * [**`getDataRequestByIndex(address _user, uint256 _i)`**](#getdatarequestbyindexaddress-_user-uint256-_i)
    * [**`getDataRequestCount(address _user)`**](#getdatarequestcountaddress-_user)
    * [**`getDataRequestIndexByHash(address _user, bytes32 _hash)`**](#getdatarequestindexbyhashaddress-_user-bytes32-_hash)
    * [**`increaseAvailableBalance(uint256 _amount)`**](#increaseavailablebalanceuint256-_amount)
    * [**`issuerReward()`**](#issuerreward)
    * [**`owner()`**](#owner)
    * [**`publicKeys()`**](#publickeys)
    * [**`refundAvailableBalance()`**](#refundavailablebalance)
    * [**`refundAvailableBalanceAdmin(address _seeker)`**](#refundavailablebalanceadminaddress-_seeker)
    * [**`renounceOwnership()`**](#renounceownership)
    * [**`seekerAvailableBalance(address _address)`**](#seekeravailablebalanceaddress-_address)
    * [**`seekerCancelRequest(address _user, bytes32 _hash)`**](#seekercancelrequestaddress-_user-bytes32-_hash)
    * [**`seekerCompleted(address _user, bytes32 _hash)`**](#seekercompletedaddress-_user-bytes32-_hash)
    * [**`seekerInflightBalance(address _address)`**](#seekerinflightbalanceaddress-_address)
    * [**`setDeputy(address _deputy)`**](#setdeputyaddress-_deputy)
    * [**`setIssuerReward(uint256 _issuerReward)`**](#setissuerrewarduint256-_issuerreward)
    * [**`setTokensPerRequest(uint256 _tokensPerRequest)`**](#settokensperrequestuint256-_tokensperrequest)
    * [**`submitRequest(address _user, bytes32 _hash)`**](#submitrequestaddress-_user-bytes32-_hash)
    * [**`token()`**](#token)
    * [**`tokensPerRequest()`**](#tokensperrequest)
    * [**`transferOwnership(address _newOwner)`**](#transferownershipaddress-_newowner)
    * [**`userCompleteRequest(bytes32 _hash, bytes32 _locatorHash)`**](#usercompleterequestbytes32-_hash-bytes32-_locatorhash)
    * [**`userDenyRequest(bytes32 _hash)`**](#userdenyrequestbytes32-_hash)
- ### [`Issuers`](#Issuers)
    * [**`addIssuer(address _issuerAddress)`**](#addissueraddress-_issueraddress)
    * [**`deputy()`**](#deputy)
    * [**`getIssuerStatus(address _issuerAddress)`**](#getissuerstatusaddress-_issueraddress)
    * [**`owner()`**](#owner)
    * [**`removeIssuer(address _issuerAddress)`**](#removeissueraddress-_issueraddress)
    * [**`renounceOwnership()`**](#renounceownership)
    * [**`setDeputy(address _deputy)`**](#setdeputyaddress-_deputy)
    * [**`transferOwnership(address _newOwner)`**](#transferownershipaddress-_newowner)
- ### [`PublicKeys`](#PublicKeys)
    * [**`addPublicKey(bytes _publicKey)`**](#addpublickeybytes-_publickey)
    * [**`publicKeyStore(address _address)`**](#publickeystoreaddress-_address)


# `Certificates`

### The store of certificate hashes per user

> #### The contract is used by Issuers when submitting certificates and
by Seekers when verifying a certificate received from a User



## **`addCertificate(address _user, bytes32 _hash)`**

### _Add a certificate_

> ##### _Can only be called by active issuers (addresses in Issuers contract with status = Active)_

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | address of certificate owner 
 *bytes32* | `_hash` | sha256 hash of the certificate text 



## **`deputy()`**




Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  


## **`getCertificateAt(address _user, uint256 _index)`**

### _Get metadata of a user&#39;s certificate by its index_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User&#39;s address 
 *uint256* | `_index` | Certificate index 

Outputs

 type | name | description
 --- | --- | --- 
 *bytes32* | `hash` | Certificate hash 
 *address* | `issuer` | Address of the certificate issuer 
 *bool* | `revoked` | Flag showing whether the certificate has been revoked by its issuer 


## **`getCertificateCount(address _user)`**

### _Get the number of certificates for a given user_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User address 

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* | `count` | Number of certificates a given user has 


## **`getCertificateIndex(address _user, bytes32 _hash)`**

### _Find index of a user&#39;s certificate by its hash_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User&#39;s address 
 *bytes32* | `_hash` | Certificate hash 

Outputs

 type | name | description
 --- | --- | --- 
 *int256* | `index` | Indexof the certificate in the user&#39;s certificates array 


## **`getCertificateMetadata(address _user, bytes32 _hash)`**

### _Retrieve certificate metadata_

> ##### _If the certificate with the provided user address and hash doesn't exist, then the return value of `_issuer` will be `0x0`_

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User address 
 *bytes32* | `_hash` | Sha256 hash of the certificate to retrieve metadata for 

Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_issuer` | Address of the certificate issuer 
 *bool* | `_revoked` | Flag showing whether the certificate has been revoked by its issuer 


## **`issuersContract()`**




Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  


## **`owner()`**




Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  


## **`renounceOwnership()`**


> ##### _Allows the current owner to relinquish control of the contract._




## **`revokeCertificate(address _user, uint256 _certificateIndex)`**

### _Revoke a certificate_

> ##### _Only the issuer can revoke their own certificate_

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User address 
 *uint256* | `_certificateIndex` | Index of certificate to be revoked in the user&#39;s array of certificates 



## **`setDeputy(address _deputy)`**

### _Set a new deputy_

> ##### _Only the contract owner or the current deputy can reassign the depity to someone else_

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_deputy` |  



## **`setIssuersContract(address _issuersContract)`**

### _Owner and deputy can modify Issuers contract address (for upgrades etc)_

> ##### _Can only be called by contract owner or deputy_

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_issuersContract` | Issuers Address of Issuers contract 



## **`transferOwnership(address _newOwner)`**


> ##### _Allows the current owner to transfer control of the contract to a newOwner._

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_newOwner` | The address to transfer ownership to. 



## **`users(uint256 _uint256)`**



Inputs

 type | name | description 
--- | --- | ---
 *uint256* | `_uint256` |  

Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  



# `Escrow`

### Implements a store of requests and escrow of payments


#### The basic workflow would be as following:
1. Seeker approves token withdrawl by the escrow in the amount
equal or greater than the request price
2. Optionally, Seeker may deposite an amount of tokens
greater than required for a request (say, 10x) by calling &#39;increaseAvailableBalance()&#39; if they anticipate
making several requests - this will avoid the escrow having to withdraw tokens from Seeker
on each request thus saving the Seeker some amount of gas.
Note, that the Seekr needs to approve the escrow to withdraw that amount from the Seeker
proior to calling &#x60;increaseAvailableBalance()&#x60; by calling &#x60;PathToken.approve(escrow_address, value)&#x60;
3. Seeker calls &#x60;submitRequest&#x60;
Note: Seeker app should implement some way of notifying the User app about the request
(e.g. via Android&#x2F;iOS push notifications) - preferred;
or User app should implement some sort of a periodic pull - not ideal
4. User receives the request for certificate and either approves or denies it
5. If denied, the request on the escrow contract is marked as Denied
and the Seeker gets their tokens refunded into their available balance escrow account
Note: Seeker may retrieve tokens from their available balance account on the escrow contract
at any time.
6. If approved, User app retrieves the certificate from their cert store,
decrypts it and reencrypts with the Seeker&#39;s public key (retrieved from PublikKeys contract)
7. User places the encrypted cert on IPFS
8. User calls &#x60;userCompleteRequest&#x60;, passing the IPFS locator of the certificate; the User app
notifies the Seeker app (via a push notification of sorts or a pull by Seeker app) that
the cert is ready to be acquired
9. Seeker app pickes up the cert from IPFS, decrypts it, hashes it using sha256 algorithm, and
compares to the expected hash
10. If hashes don&#39;t match, the verification is a FAIL. Further behavior is stil undetermined
but will probably include human intervention and some sort of penalties for either side - TBD
11. If hashes match, the verification is a SUCCESS. At this point, the tokens from the escrow
are distributed between the user and the issuer.
Things to consider:
1. How to deal with a failure to match cert hashes
2. What if hashes match but the content of the cert doesn&#39;t match
the declared achievement&#x2F;degree&#x2F;position etc.


## **`certificates()`**




Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  


## **`deputy()`**




Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  


## **`disable(bool _disable)`**

### _Function sets &#x60;enabled&#x60; flag_


Inputs

 type | name | description 
--- | --- | ---
 *bool* | `_disable` | &#x60;true&#x60; to disable the contract, &#x60;false&#x60; to re-enable it 



## **`getDataRequestByHash(address _user, bytes32 _hash)`**

### _Retrieve the request metadata by providing the certificate hash_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User address 
 *bytes32* | `_hash` | Certificate hash 

Outputs

 type | name | description
 --- | --- | --- 
 *address* | `seeker` | Seeker address 
 *uint8* | `status` | Request status 
 *bytes32* | `hash` |  
 *uint48* | `timestamp` | Request creation timestamp (in seconds) 


## **`getDataRequestByIndex(address _user, uint256 _i)`**

### _Retrieve a request by its index in the user&#39;s requests array_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User address 
 *uint256* | `_i` | Index of the certificate to retrieve 

Outputs

 type | name | description
 --- | --- | --- 
 *address* | `seeker` |  
 *uint8* | `status` |  
 *bytes32* | `hash` |  
 *uint48* | `timestamp` |  


## **`getDataRequestCount(address _user)`**

### _Retrurn the number of requests for a provided user_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User address 

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* | `_uint256` |  


## **`getDataRequestIndexByHash(address _user, bytes32 _hash)`**

### _Retrieve request index by hash_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User address 
 *bytes32* | `_hash` | Certificate hash 

Outputs

 type | name | description
 --- | --- | --- 
 *int256* | `index` | - index or the certificate in the user&#39;s array. -1 if not found 


## **`increaseAvailableBalance(uint256 _amount)`**

### _Method increases Seeker&#39;s available balance on escrow account  by transferring tokens from Seeker to escrow. The method is used for gas savings if the Seeker anticipates multiple requests_

> ##### _Seeker needs to make show they approve withdrawal of the deposit amount by the escrow address prior to making the call, by calling `PathToken.approve()` method param _amount Amount to deposit to the Seekers avail balance account on the escrow_

Inputs

 type | name | description 
--- | --- | ---
 *uint256* | `_amount` |  



## **`issuerReward()`**




Outputs

 type | name | description
 --- | --- | --- 
 *uint256* | `_uint256` |  


## **`owner()`**




Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  


## **`publicKeys()`**




Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  


## **`refundAvailableBalance()`**

### _Seeker can refund their available balance by calling this method_





## **`refundAvailableBalanceAdmin(address _seeker)`**

### _Owner or Deputy can force refund of avail balance to a Seeker_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_seeker` | Seeker&#39;s address 



## **`renounceOwnership()`**


> ##### _Allows the current owner to relinquish control of the contract._




## **`seekerAvailableBalance(address _address)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_address` |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* | `_uint256` |  


## **`seekerCancelRequest(address _user, bytes32 _hash)`**

### _Seeker can cancel a request that is still in Initial state_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User address 
 *bytes32* | `_hash` | Certificate hash 



## **`seekerCompleted(address _user, bytes32 _hash)`**

### _Seeker received the certificate and successfully verified it against the hash_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User address 
 *bytes32* | `_hash` | Certificate hash 



## **`seekerInflightBalance(address _address)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_address` |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* | `_uint256` |  


## **`setDeputy(address _deputy)`**

### _Set a new deputy_

> ##### _Only the contract owner or the current deputy can reassign the depity to someone else_

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_deputy` |  



## **`setIssuerReward(uint256 _issuerReward)`**

### _Method sets the reward percent for the issuer_

> ##### _Only Owner or Deputy can call this mehtod The amount is in percent, i.e. whole number from 1 to 100_

Inputs

 type | name | description 
--- | --- | ---
 *uint256* | `_issuerReward` | Issuer&#39;s reward in percent (1 to 100) 



## **`setTokensPerRequest(uint256 _tokensPerRequest)`**

### _Method sets the number of tokens per request_

> ##### _Only Owner or Deputy can call this mehtod_

Inputs

 type | name | description 
--- | --- | ---
 *uint256* | `_tokensPerRequest` | Number of tokens per request (in actual tokens, not display) 



## **`submitRequest(address _user, bytes32 _hash)`**

### _Seeker places the request for a user&#39;s certificate with provided hash. Seeker can optionally send some ETH to cover User&#39;s gas for User&#39;s interaction with the contract NOTE: Seeker can first check if the certificate is revoked (before submitting a request),  by calling &#x60;Certificates.getCertificateMetadata()&#x60;; this will save gas for the call below if the cert is revoked_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` | User address 
 *bytes32* | `_hash` | Certificate hash 



## **`token()`**




Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  


## **`tokensPerRequest()`**




Outputs

 type | name | description
 --- | --- | --- 
 *uint256* | `_uint256` |  


## **`transferOwnership(address _newOwner)`**


> ##### _Allows the current owner to transfer control of the contract to a newOwner._

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_newOwner` | The address to transfer ownership to. 



## **`userCompleteRequest(bytes32 _hash, bytes32 _locatorHash)`**

### _User completes the request_


Inputs

 type | name | description 
--- | --- | ---
 *bytes32* | `_hash` | Certificate hash 
 *bytes32* | `_locatorHash` | IPFS locator of the certificate 



## **`userDenyRequest(bytes32 _hash)`**

### _User denies the request_


Inputs

 type | name | description 
--- | --- | ---
 *bytes32* | `_hash` | Certificate hash 




# `Issuers`

### Stores certificate issuers


#### Only the Owner or a Deputy can add&#x2F;enable&#x2F;disable an issuer


## **`addIssuer(address _issuerAddress)`**

### _Add a new active issuer or reactivate inactive user_


Inputs

 type | name | description 
--- | --- | ---
 *address* | `_issuerAddress` |  



## **`deputy()`**




Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  


## **`getIssuerStatus(address _issuerAddress)`**

### _Method returns issuer status_

> ##### _Status: 0 - issuer doesnt exists/not registered 1 - issuer is active 2 - issuer is inactive/deactivated_

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_issuerAddress` |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint8* | `_uint8` |  


## **`owner()`**




Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  


## **`removeIssuer(address _issuerAddress)`**

### _Deactivate an active issuer_

> ##### _If the issuer does not exist or is inacive, no exceptions thrown_

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_issuerAddress` |  



## **`renounceOwnership()`**


> ##### _Allows the current owner to relinquish control of the contract._




## **`setDeputy(address _deputy)`**

### _Set a new deputy_

> ##### _Only the contract owner or the current deputy can reassign the depity to someone else_

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_deputy` |  



## **`transferOwnership(address _newOwner)`**


> ##### _Allows the current owner to transfer control of the contract to a newOwner._

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_newOwner` | The address to transfer ownership to. 




# `PublicKeys`

### Contract stores a map of ethereum addresses and their associated public keys




## **`addPublicKey(bytes _publicKey)`**

### _Adds a public key for the caller address after verifying that the sender&#39;s address derives from that public key_


Inputs

 type | name | description 
--- | --- | ---
 *bytes* | `_publicKey` |  



## **`publicKeyStore(address _address)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_address` |  

Outputs

 type | name | description
 --- | --- | --- 
 *bytes* | `_bytes` |  



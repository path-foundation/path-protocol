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
    * [**`users(uint256 )`**](#usersuint256-)
- ### [`Escrow`](#Escrow)
    * [**`certificates()`**](#certificates)
    * [**`deputy()`**](#deputy)
    * [**`getDataRequestByHash(address _user, bytes32 _hash)`**](#getdatarequestbyhashaddress-_user-bytes32-_hash)
    * [**`getDataRequestByIndex(address _user, uint256 i)`**](#getdatarequestbyindexaddress-_user-uint256-i)
    * [**`getDataRequestCount(address _user)`**](#getdatarequestcountaddress-_user)
    * [**`getDataRequestIndexByHash(address _user, bytes32 _hash)`**](#getdatarequestindexbyhashaddress-_user-bytes32-_hash)
    * [**`increaseAvailableBalance(uint256 amount)`**](#increaseavailablebalanceuint256-amount)
    * [**`issuerReward()`**](#issuerreward)
    * [**`owner()`**](#owner)
    * [**`publicKeys()`**](#publickeys)
    * [**`refundAvailableBalance()`**](#refundavailablebalance)
    * [**`refundAvailableBalanceAdmin(address seeker)`**](#refundavailablebalanceadminaddress-seeker)
    * [**`renounceOwnership()`**](#renounceownership)
    * [**`seekerAvailableBalance(address )`**](#seekeravailablebalanceaddress-)
    * [**`seekerCancelRequest(address _user, bytes32 _hash)`**](#seekercancelrequestaddress-_user-bytes32-_hash)
    * [**`seekerCompleted(address _user, bytes32 _hash)`**](#seekercompletedaddress-_user-bytes32-_hash)
    * [**`seekerInflightBalance(address )`**](#seekerinflightbalanceaddress-)
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
    * [**`publicKeyStore(address )`**](#publickeystoreaddress-)


# `Certificates`

### The store of certificate hashes per user

> #### The contract is used by Issuers when submitting certificates and by Seekers when verifying a certificate received from a User


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

### _Method returns the number of certificates for a given user_


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

> ##### _Only the contract owner or teh current deputy can reassign the depity to someone else_

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



## **`users(uint256 )`**



Inputs

 type | name | description 
--- | --- | ---
 *uint256* | `` |  

Outputs

 type | name | description
 --- | --- | --- 
 *address* | `_address` |  



# `Escrow`




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


## **`getDataRequestByHash(address _user, bytes32 _hash)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` |  
 *bytes32* | `_hash` |  

Outputs

 type | name | description
 --- | --- | --- 
 *address* | `seeker` |  
 *uint8* | `status` |  
 *bytes32* | `hash` |  
 *uint48* | `timestamp` |  


## **`getDataRequestByIndex(address _user, uint256 i)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` |  
 *uint256* | `i` |  

Outputs

 type | name | description
 --- | --- | --- 
 *address* | `seeker` |  
 *uint8* | `status` |  
 *bytes32* | `hash` |  
 *uint48* | `timestamp` |  


## **`getDataRequestCount(address _user)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* | `_uint256` |  


## **`getDataRequestIndexByHash(address _user, bytes32 _hash)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` |  
 *bytes32* | `_hash` |  

Outputs

 type | name | description
 --- | --- | --- 
 *int256* | `_int256` |  


## **`increaseAvailableBalance(uint256 amount)`**



Inputs

 type | name | description 
--- | --- | ---
 *uint256* | `amount` |  



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






## **`refundAvailableBalanceAdmin(address seeker)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `seeker` |  



## **`renounceOwnership()`**


> ##### _Allows the current owner to relinquish control of the contract._




## **`seekerAvailableBalance(address )`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `` |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* | `_uint256` |  


## **`seekerCancelRequest(address _user, bytes32 _hash)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` |  
 *bytes32* | `_hash` |  



## **`seekerCompleted(address _user, bytes32 _hash)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` |  
 *bytes32* | `_hash` |  



## **`seekerInflightBalance(address )`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `` |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* | `_uint256` |  


## **`setDeputy(address _deputy)`**

### _Set a new deputy_

> ##### _Only the contract owner or teh current deputy can reassign the depity to someone else_

Inputs

 type | name | description 
--- | --- | ---
 *address* | `_deputy` |  



## **`setIssuerReward(uint256 _issuerReward)`**



Inputs

 type | name | description 
--- | --- | ---
 *uint256* | `_issuerReward` |  



## **`setTokensPerRequest(uint256 _tokensPerRequest)`**



Inputs

 type | name | description 
--- | --- | ---
 *uint256* | `_tokensPerRequest` |  



## **`submitRequest(address _user, bytes32 _hash)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_user` |  
 *bytes32* | `_hash` |  



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



Inputs

 type | name | description 
--- | --- | ---
 *bytes32* | `_hash` |  
 *bytes32* | `_locatorHash` |  



## **`userDenyRequest(bytes32 _hash)`**



Inputs

 type | name | description 
--- | --- | ---
 *bytes32* | `_hash` |  




# `Issuers`




## **`addIssuer(address _issuerAddress)`**



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



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_issuerAddress` |  



## **`renounceOwnership()`**


> ##### _Allows the current owner to relinquish control of the contract._




## **`setDeputy(address _deputy)`**

### _Set a new deputy_

> ##### _Only the contract owner or teh current deputy can reassign the depity to someone else_

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




## **`addPublicKey(bytes _publicKey)`**



Inputs

 type | name | description 
--- | --- | ---
 *bytes* | `_publicKey` |  



## **`publicKeyStore(address )`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `` |  

Outputs

 type | name | description
 --- | --- | --- 
 *bytes* | `_bytes` |  



## Smart contracts

- ### [`Certificates`](#Certificates)
    * [**`addCertificate(address _user, bytes32 _hash)`**](#addCertificateaddress-_user-bytes32-_hash)
    * [**`deputy()`**](#deputy)
    * [**`getCertificateAt(address _user, uint256 _index)`**](#getCertificateAtaddress-_user-uint256-_index)
    * [**`getCertificateCount(address _user)`**](#getCertificateCountaddress-_user)
    * [**`getCertificateIndex(address _user, bytes32 _hash)`**](#getCertificateIndexaddress-_user-bytes32-_hash)
    * [**`getCertificateMetadata(address _user, bytes32 _hash)`**](#getCertificateMetadataaddress-_user-bytes32-_hash)
    * [**`issuersContract()`**](#issuersContract)
    * [**`owner()`**](#owner)
    * [**`renounceOwnership()`**](#renounceOwnership)
    * [**`revokeCertificate(address _user, uint256 _certificateIndex)`**](#revokeCertificateaddress-_user-uint256-_certificateIndex)
    * [**`setDeputy(address _deputy)`**](#setDeputyaddress-_deputy)
    * [**`setIssuersContract(address _issuersContract)`**](#setIssuersContractaddress-_issuersContract)
    * [**`transferOwnership(address _newOwner)`**](#transferOwnershipaddress-_newOwner)
    * [**`users(uint256 _uint256)`**](#usersuint256-_uint256)
- ### [`Escrow`](#Escrow)
    * [**`certificates()`**](#certificates)
    * [**`deputy()`**](#deputy)
    * [**`getDataRequestByHash(address _user, bytes32 _hash)`**](#getDataRequestByHashaddress-_user-bytes32-_hash)
    * [**`getDataRequestByIndex(address _user, uint256 i)`**](#getDataRequestByIndexaddress-_user-uint256-i)
    * [**`getDataRequestCount(address _user)`**](#getDataRequestCountaddress-_user)
    * [**`getDataRequestIndexByHash(address _user, bytes32 _hash)`**](#getDataRequestIndexByHashaddress-_user-bytes32-_hash)
    * [**`increaseAvailableBalance(uint256 amount)`**](#increaseAvailableBalanceuint256-amount)
    * [**`issuerReward()`**](#issuerReward)
    * [**`owner()`**](#owner)
    * [**`publicKeys()`**](#publicKeys)
    * [**`refundAvailableBalance()`**](#refundAvailableBalance)
    * [**`refundAvailableBalanceAdmin(address seeker)`**](#refundAvailableBalanceAdminaddress-seeker)
    * [**`renounceOwnership()`**](#renounceOwnership)
    * [**`seekerAvailableBalance(address _address)`**](#seekerAvailableBalanceaddress-_address)
    * [**`seekerCancelRequest(address _user, bytes32 _hash)`**](#seekerCancelRequestaddress-_user-bytes32-_hash)
    * [**`seekerCompleted(address _user, bytes32 _hash)`**](#seekerCompletedaddress-_user-bytes32-_hash)
    * [**`seekerInflightBalance(address _address)`**](#seekerInflightBalanceaddress-_address)
    * [**`setDeputy(address _deputy)`**](#setDeputyaddress-_deputy)
    * [**`setIssuerReward(uint256 _issuerReward)`**](#setIssuerRewarduint256-_issuerReward)
    * [**`setTokensPerRequest(uint256 _tokensPerRequest)`**](#setTokensPerRequestuint256-_tokensPerRequest)
    * [**`submitRequest(address _user, bytes32 _hash)`**](#submitRequestaddress-_user-bytes32-_hash)
    * [**`token()`**](#token)
    * [**`tokensPerRequest()`**](#tokensPerRequest)
    * [**`transferOwnership(address _newOwner)`**](#transferOwnershipaddress-_newOwner)
    * [**`userCompleteRequest(bytes32 _hash, bytes32 _locatorHash)`**](#userCompleteRequestbytes32-_hash-bytes32-_locatorHash)
    * [**`userDenyRequest(bytes32 _hash)`**](#userDenyRequestbytes32-_hash)
- ### [`Issuers`](#Issuers)
    * [**`addIssuer(address _issuerAddress)`**](#addIssueraddress-_issuerAddress)
    * [**`deputy()`**](#deputy)
    * [**`getIssuerStatus(address _issuerAddress)`**](#getIssuerStatusaddress-_issuerAddress)
    * [**`owner()`**](#owner)
    * [**`removeIssuer(address _issuerAddress)`**](#removeIssueraddress-_issuerAddress)
    * [**`renounceOwnership()`**](#renounceOwnership)
    * [**`setDeputy(address _deputy)`**](#setDeputyaddress-_deputy)
    * [**`transferOwnership(address _newOwner)`**](#transferOwnershipaddress-_newOwner)
- ### [`PublicKeys`](#PublicKeys)
    * [**`addPublicKey(bytes _publicKey)`**](#addPublicKeybytes-_publicKey)
    * [**`publicKeyStore(address _address)`**](#publicKeyStoreaddress-_address)


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



## **`publicKeyStore(address _address)`**



Inputs

 type | name | description 
--- | --- | ---
 *address* | `_address` |  

Outputs

 type | name | description
 --- | --- | --- 
 *bytes* | `_bytes` |  



## Smart contracts

- ### [Certificates](#Certificates)
    * [**`addCertificate(address _user, bytes32 _hash)`**](#addcertificateaddress-_user-bytes32-_hash)
    * [**`deputy()`**](#deputy)
    * [**`getCertificateAt(address _user, uint256 _index)`**](#getcertificateataddress-_user-uint256-_index)
    * [**`getCertificateCount(address _user)`**](#getcertificatecountaddress-_user)
    * [**`getCertificateIndex(address _user, bytes32 _hash)`**](#getcertificateindexaddress-_user-bytes32-_hash)
    * [**`getCertificateMetadata(address _user, bytes32 _hash)`**](#getcertificatemetadataaddress-_user-bytes32-_hash)
    * [**`issuersContract()`**](#issuerscontract)
    * [**`owner()`**](#owner)
    * [**`renounceOwnership()`**](#renounceownership)
    * [**`revokeCertificate(address _user, uint256 certificateIndex)`**](#revokecertificateaddress-_user-uint256-certificateindex)
    * [**`setDeputy(address _deputy)`**](#setdeputyaddress-_deputy)
    * [**`setIssuersContract(address _issuersContract)`**](#setissuerscontractaddress-_issuerscontract)
    * [**`transferOwnership(address _newOwner)`**](#transferownershipaddress-_newowner)
    * [**`users(uint256 )`**](#usersuint256-)
- ### [Deputable](#Deputable)
    * [**`deputy()`**](#deputy)
    * [**`owner()`**](#owner)
    * [**`renounceOwnership()`**](#renounceownership)
    * [**`setDeputy(address _deputy)`**](#setdeputyaddress-_deputy)
    * [**`transferOwnership(address _newOwner)`**](#transferownershipaddress-_newowner)
- ### [Escrow](#Escrow)
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
- ### [Issuers](#Issuers)
    * [**`addIssuer(address _issuerAddress)`**](#addissueraddress-_issueraddress)
    * [**`deputy()`**](#deputy)
    * [**`getIssuerStatus(address _issuerAddress)`**](#getissuerstatusaddress-_issueraddress)
    * [**`owner()`**](#owner)
    * [**`removeIssuer(address _issuerAddress)`**](#removeissueraddress-_issueraddress)
    * [**`renounceOwnership()`**](#renounceownership)
    * [**`setDeputy(address _deputy)`**](#setdeputyaddress-_deputy)
    * [**`transferOwnership(address _newOwner)`**](#transferownershipaddress-_newowner)
- ### [PublicKeys](#PublicKeys)
    * [**`addPublicKey(bytes _publicKey)`**](#addpublickeybytes-_publickey)
    * [**`publicKeyStore(address )`**](#publickeystoreaddress-)


# Certificates


## **`addCertificate(address _user, bytes32 _hash)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user | address of certificate owner 
 *bytes32* | _hash | sha256 hash of the certificate text 



## **`deputy()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`getCertificateAt(address _user, uint256 _index)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  
 *uint256* | _index |  

Outputs

 type | name | description
 --- | --- | --- 
 *bytes32* | hash |  
 *address* | issuer |  
 *bool* | revoked |  


## **`getCertificateCount(address _user)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* |  |  


## **`getCertificateIndex(address _user, bytes32 _hash)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  
 *bytes32* | _hash |  

Outputs

 type | name | description
 --- | --- | --- 
 *int256* |  |  


## **`getCertificateMetadata(address _user, bytes32 _hash)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  
 *bytes32* | _hash |  

Outputs

 type | name | description
 --- | --- | --- 
 *address* | _issuer |  
 *bool* | _revoked |  


## **`issuersContract()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`owner()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`renounceOwnership()`**




## **`revokeCertificate(address _user, uint256 certificateIndex)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  
 *uint256* | certificateIndex |  



## **`setDeputy(address _deputy)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _deputy |  



## **`setIssuersContract(address _issuersContract)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _issuersContract |  



## **`transferOwnership(address _newOwner)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _newOwner | The address to transfer ownership to. 



## **`users(uint256 )`**

Inputs

 type | name | description 
--- | --- | ---
 *uint256* |  |  

Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  



# Deputable


## **`deputy()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`owner()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`renounceOwnership()`**




## **`setDeputy(address _deputy)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _deputy |  



## **`transferOwnership(address _newOwner)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _newOwner | The address to transfer ownership to. 




# Escrow


## **`certificates()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`deputy()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`getDataRequestByHash(address _user, bytes32 _hash)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  
 *bytes32* | _hash |  

Outputs

 type | name | description
 --- | --- | --- 
 *address* | seeker |  
 *uint8* | status |  
 *bytes32* | hash |  
 *uint48* | timestamp |  


## **`getDataRequestByIndex(address _user, uint256 i)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  
 *uint256* | i |  

Outputs

 type | name | description
 --- | --- | --- 
 *address* | seeker |  
 *uint8* | status |  
 *bytes32* | hash |  
 *uint48* | timestamp |  


## **`getDataRequestCount(address _user)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* |  |  


## **`getDataRequestIndexByHash(address _user, bytes32 _hash)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  
 *bytes32* | _hash |  

Outputs

 type | name | description
 --- | --- | --- 
 *int256* |  |  


## **`increaseAvailableBalance(uint256 amount)`**

Inputs

 type | name | description 
--- | --- | ---
 *uint256* | amount |  



## **`issuerReward()`**


Outputs

 type | name | description
 --- | --- | --- 
 *uint256* |  |  


## **`owner()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`publicKeys()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`refundAvailableBalance()`**




## **`refundAvailableBalanceAdmin(address seeker)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | seeker |  



## **`renounceOwnership()`**




## **`seekerAvailableBalance(address )`**

Inputs

 type | name | description 
--- | --- | ---
 *address* |  |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* |  |  


## **`seekerCancelRequest(address _user, bytes32 _hash)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  
 *bytes32* | _hash |  



## **`seekerCompleted(address _user, bytes32 _hash)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  
 *bytes32* | _hash |  



## **`seekerInflightBalance(address )`**

Inputs

 type | name | description 
--- | --- | ---
 *address* |  |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint256* |  |  


## **`setDeputy(address _deputy)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _deputy |  



## **`setIssuerReward(uint256 _issuerReward)`**

Inputs

 type | name | description 
--- | --- | ---
 *uint256* | _issuerReward |  



## **`setTokensPerRequest(uint256 _tokensPerRequest)`**

Inputs

 type | name | description 
--- | --- | ---
 *uint256* | _tokensPerRequest |  



## **`submitRequest(address _user, bytes32 _hash)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _user |  
 *bytes32* | _hash |  



## **`token()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`tokensPerRequest()`**


Outputs

 type | name | description
 --- | --- | --- 
 *uint256* |  |  


## **`transferOwnership(address _newOwner)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _newOwner | The address to transfer ownership to. 



## **`userCompleteRequest(bytes32 _hash, bytes32 _locatorHash)`**

Inputs

 type | name | description 
--- | --- | ---
 *bytes32* | _hash |  
 *bytes32* | _locatorHash |  



## **`userDenyRequest(bytes32 _hash)`**

Inputs

 type | name | description 
--- | --- | ---
 *bytes32* | _hash |  




# Issuers


## **`addIssuer(address _issuerAddress)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _issuerAddress |  



## **`deputy()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`getIssuerStatus(address _issuerAddress)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _issuerAddress |  

Outputs

 type | name | description
 --- | --- | --- 
 *uint8* |  |  


## **`owner()`**


Outputs

 type | name | description
 --- | --- | --- 
 *address* |  |  


## **`removeIssuer(address _issuerAddress)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _issuerAddress |  



## **`renounceOwnership()`**




## **`setDeputy(address _deputy)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _deputy |  



## **`transferOwnership(address _newOwner)`**

Inputs

 type | name | description 
--- | --- | ---
 *address* | _newOwner | The address to transfer ownership to. 




# PublicKeys


## **`addPublicKey(bytes _publicKey)`**

Inputs

 type | name | description 
--- | --- | ---
 *bytes* | _publicKey |  



## **`publicKeyStore(address )`**

Inputs

 type | name | description 
--- | --- | ---
 *address* |  |  

Outputs

 type | name | description
 --- | --- | --- 
 *bytes* |  |  



DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR

truffle-flattener ../contracts/PathToken.sol > ./FlatPathToken.sol
truffle-flattener ../contracts/Certificates.sol > ./FlatCertificates.sol
truffle-flattener ../contracts/Escrow.sol > ./FlatEscrow.sol
truffle-flattener ../contracts/Issuers.sol > ./FlatIssuers.sol
truffle-flattener ../contracts/PublicKeys.sol > ./FlatPublicKeys.sol

cd -
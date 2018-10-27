# Publish the NPM package with contract abi
# $1 [deploy|promote] - (deploy is default) deploy a new dev version or promote from tag $2 to tag $3

PACKAGE_NAME="path-protocol-artifacts"

if [ "$1" = "deploy"  ] || [ $# -eq 0 ]; then

    CURRENT_DIR=$(pwd)
    echo "Current folder: $CURRENT_DIR"

    CONTRACT_FILES=(
        "Certificates.json"
        "Escrow.json"
        "Issuers.json"
        "PathToken.json"
        "PublicKeys.json"
    )

    # Contracts dir related to the script's dir
    CONTRACT_DIR='../build/contracts'

    # Get script's folder
    SCRIPT_DIR=$(dirname $0)
    if [ $SCRIPT_DIR = '.' ]; then SCRIPT_DIR=$(pwd); fi
    echo "Script folder: $SCRIPT_DIR"

    # Go to the root project folder
    cd "$SCRIPT_DIR/.."

    # Compile contarcts
    echo "Compiling contracts..."
    truffle compile

    # Go to teh script's folder
    cd $SCRIPT_DIR

    TEMP_DIR="./abi"
    
    # Craete temp dir if doesn't exist, or clean up if exists
    if [ -d $TEMP_DIR ]; then rm -rf $TEMP_DIR; fi;
    
    echo "Creating temp folder...";
    mkdir $TEMP_DIR

    # Copy contract abi to abi folder
    echo "Copying contract abi to deploy folder..."
    for i in "${CONTRACT_FILES[@]}"
    do
        FILE_PATH="$CONTRACT_DIR/$i"
        cp $FILE_PATH "$TEMP_DIR"
        # Extract just abi and contract name
        # node ./extract.js "$TEMP_DIR/$i"
    done

    npm version patch -m "Dev Deploy: Updating $PACKAGE_NAME npm version: %s"
    npm publish --registry https://registry.npmjs.com/ --tag "dev"

    rm -rf $TEMP_DIR

    cd $CURRENT_DIR
    echo "Done!"

elif [ "$1" = "promote" ] # promoting/retagging an existing version/tag
then
    if [ $# -eq 1 ] 
    then
        echo "Use: publish.sh promote <version>"
        exit 1
    fi
    npm dist-tag add --registry https://registry.npmjs.com/ "$PACKAGE_NAME@$2" --tag "latest"
else 
    echo "First argument should be [deploy|promote]"
fi
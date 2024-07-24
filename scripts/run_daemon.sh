#!/bin/sh

# Define variables
JAR_DIR="../daemon/build/libs"
JAR_FILE="daemon-all.jar"
BUILD_SCRIPT="./build_daemon.sh"

# Check if the JAR file exists
if [ -f "$JAR_DIR/$JAR_FILE" ]; then
    echo "$JAR_FILE exists. Proceeding to run the daemon."
else
    echo "$JAR_FILE does not exist. Running the build script."
    $BUILD_SCRIPT

    # Check again if the JAR file exists after the build
    if [ -f "$JAR_DIR/$JAR_FILE" ]; then
        echo "$JAR_FILE has been built successfully. Proceeding to run the daemon."
    else
        echo "Failed to build $JAR_FILE. Exiting."
        exit 1
    fi
fi

# Change to the directory containing the JAR file
cd "$JAR_DIR"

# Run the daemon
java -jar "$JAR_FILE" \
    --torControlPort=9077 \
    --torControlPassword=boner \
    --baseCurrencyNetwork=XMR_STAGENET \
    --useLocalhostForP2P=false \
    --useDevPrivilegeKeys=false \
    --nodePort=9999 \
    --appName=haveno-XMR_STAGENET_user1 \
    --apiPassword=apitest \
    --apiPort=3201 \
    --passwordRequired=false \
    --useNativeXmrWallet=false
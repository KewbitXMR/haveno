#!/bin/sh

# Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Clone the repository into the temporary directory
git clone https://github.com/KewbitXMR/haveno.git "$TEMP_DIR"

# Navigate into the cloned repository directory
cd "$TEMP_DIR"

# Build the shadow JAR using the Gradle Wrapper
./gradlew :daemon:shadowJar

# Check if the build was successful and the JAR file exists
JAR_FILE="$TEMP_DIR/daemon/build/libs/daemon-all.jar"
if [ -f "$JAR_FILE" ]; then
    # Copy the JAR file to the current working directory
    cp "$JAR_FILE" "$OLDPWD"
    echo "Copied $JAR_FILE to $OLDPWD"
else
    echo "Build failed or JAR file not found."
    # Clean up the temporary directory
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Clean up the temporary directory
rm -rf "$TEMP_DIR"

echo "Build and extraction complete."
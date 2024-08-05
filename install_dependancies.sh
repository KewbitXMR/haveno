#!/bin/bash
######## INSTALL JAVA ########
set -e

# Java version and URLs for different architectures
JAVA_VERSION="21.0.4+7"
JAVA_TAR_URL_AARCH64="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4%2B7/OpenJDK21U-jdk_aarch64_mac_hotspot_21.0.4_7.tar.gz"
JAVA_TAR_URL_X64="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4%2B7/OpenJDK21U-jdk_x64_mac_hotspot_21.0.4_7.tar.gz"
JAVA_INSTALL_BASE_PATH="$HOME/Library/Application Support/org.kewbit.havenoPlus/Java"
JAVA_INSTALL_PATH="$JAVA_INSTALL_BASE_PATH/$JAVA_VERSION"

error_exit() {
  echo "$1" 1>&2
  exit 1
}

# Determine the architecture
ARCH=$(uname -m)
if [ "$ARCH" == "arm64" ]; then
  JAVA_TAR_URL=$JAVA_TAR_URL_AARCH64
elif [ "$ARCH" == "x86_64" ]; then
  JAVA_TAR_URL=$JAVA_TAR_URL_X64
else
  error_exit "Unsupported architecture: $ARCH"
fi

# Check if the Java binary is already installed
JAVA_BIN="$JAVA_INSTALL_PATH/Contents/Home/bin/java"
if [ -x "$JAVA_BIN" ]; then
  echo "Java version $JAVA_VERSION is already installed at $JAVA_BIN."
else
  echo "Java version $JAVA_VERSION is not installed. Downloading and installing..."

  # Download the tar.gz file
  curl -L -o /tmp/OpenJDK21U-jdk.tar.gz "$JAVA_TAR_URL" || error_exit "Failed to download Java tar.gz file."

  # Create the installation directory if it doesn't exist
  mkdir -p "$JAVA_INSTALL_PATH" || error_exit "Failed to create installation directory."

  # Extract the tar.gz file to a temporary location
  tar -xzf /tmp/OpenJDK21U-jdk.tar.gz -C /tmp || error_exit "Failed to extract Java tar.gz file."

  # Move the extracted contents to the installation path
  mv /tmp/jdk-21.0.4+7/* "$JAVA_INSTALL_PATH" || error_exit "Failed to move Java files to installation directory."
  
  # Clean up the downloaded tar.gz file and temporary extraction directory
  rm -rf /tmp/OpenJDK21U-jdk.tar.gz /tmp/jdk-21.0.4+7 || error_exit "Failed to clean up temporary files."

  echo "Java version $JAVA_VERSION is installed at $JAVA_INSTALL_PATH."
fi

# Verify the installation
"$JAVA_BIN" -version || error_exit "Java installation verification failed."

echo "Java version $JAVA_VERSION is successfully installed and verified."

######## INSTALL HAVENO DAEMON ########
# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get the logged-in user's username
LOGGED_IN_USER=$(logname)

# Check if Homebrew is installed, install if not
#if ! command_exists brew; then
#    echo "Homebrew not found. Installing Homebrew..."
#    sudo -u "$LOGGED_IN_USER" NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "Failed to install Homebrew. Exiting."; exit 1; }
#else
#    echo "Homebrew is already installed."
#fi

# Check if Git is installed, install if not
#if ! command_exists git; then
#    echo "Git not found. Installing Git..."
#    sudo -u "$LOGGED_IN_USER" brew install git || { echo "Failed to install Git. Exiting."; exit 1; }
#else
#    echo "Git is already installed."
#fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
if [ ! -d "$TEMP_DIR" ]; then
    echo "Failed to create a temporary directory. Exiting."
    exit 1
fi

# Clone the repository into the temporary directory
echo "Cloning the repository..."
git clone https://github.com/KewbitXMR/haveno.git "$TEMP_DIR" || { echo "Failed to clone the repository. Exiting."; rm -rf "$TEMP_DIR"; exit 1; }

# Navigate into the cloned repository directory
cd "$TEMP_DIR" || { echo "Failed to navigate to the cloned repository directory. Exiting."; rm -rf "$TEMP_DIR"; exit 1; }

# Build the shadow JAR using the Gradle Wrapper with the installed Java
echo "Building the shadow JAR with the installed Java..."
"$JAVA_BIN" -version
JAVA_HOME="$JAVA_INSTALL_PATH/Contents/Home" ./gradlew :daemon:shadowJar || { echo "Failed to build the shadow JAR. Exiting."; rm -rf "$TEMP_DIR"; exit 1; }

# Check if the build was successful and the JAR file exists
JAR_FILE="$TEMP_DIR/daemon/build/libs/daemon-all.jar"
DEST_DIR="$HOME/Library/Application Support/org.kewbit.havenoPlus/Haveno Daemon"
DEST_PATH="$DEST_DIR/daemon-all.jar"

if [ -f "$JAR_FILE" ]; then
    echo "Build successful. Copying the JAR file to the destination directory..."

    # Create the destination directory if it doesn't exist
    mkdir -p "$DEST_DIR" || { echo "Failed to create the destination directory. Exiting."; rm -rf "$TEMP_DIR"; exit 1; }

    # Copy the JAR file to the destination directory
    cp "$JAR_FILE" "$DEST_PATH" || { echo "Failed to copy the JAR file. Exiting."; rm -rf "$TEMP_DIR"; exit 1; }
    echo "Copied $JAR_FILE to $DEST_PATH"
else
    echo "Build failed or JAR file not found."
    # Clean up the temporary directory
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Clean up the temporary directory
rm -rf "$TEMP_DIR"

echo "Build and extraction complete."

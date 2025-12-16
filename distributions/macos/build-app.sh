#!/bin/bash
# ============================================================================
# eMark - macOS App Bundle Builder
# TrexoLab - https://trexolab.com
# ============================================================================
#
# This script creates a single .app bundle for macOS:
#   - eMark.app (4GB max memory)
#
# Prerequisites:
#   - The JAR file at ../../target/eMark.jar
#   - The JRE at ./jre8-x64/
#
# Usage:
#   ./build-app.sh
#
# Output:
#   ./output/eMark.app
# ============================================================================

set -e

# Directories (defined first so VERSION file can be read)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
# Read version from VERSION file
APP_VERSION=$(cat "$ROOT_DIR/VERSION" 2>/dev/null | tr -d '[:space:]' || echo "1.0.0")
BUNDLE_ID_BASE="com.trexolab.emark"
BUILD_DIR="$SCRIPT_DIR/build"
OUTPUT_DIR="$SCRIPT_DIR/output"

# Clean previous build
rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

echo "============================================================================"
echo " Building eMark macOS App Bundle"
echo "============================================================================"
echo " Version: $APP_VERSION"
echo " Memory: 4GB max heap"
echo "============================================================================"

# Function to create an app bundle with a specific memory profile
create_app_bundle() {
    local APP_NAME="$1"
    local BUNDLE_ID="$2"
    local DISPLAY_NAME="$3"
    local MEMORY_PROFILE="$4"
    local XMS="$5"
    local XMX="$6"
    local APP_DIR="$BUILD_DIR/$APP_NAME.app"

    echo ""
    echo "Creating $APP_NAME.app ($MEMORY_PROFILE profile - $XMX max heap)..."

    # Create .app bundle structure
    mkdir -p "$APP_DIR/Contents/MacOS"
    mkdir -p "$APP_DIR/Contents/Resources"

    # Create Info.plist with profile-specific settings
    cat > "$APP_DIR/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>

    <key>CFBundleExecutable</key>
    <string>run-emark</string>

    <key>CFBundleIconFile</key>
    <string>emark.icns</string>

    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>

    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>

    <key>CFBundleName</key>
    <string>$DISPLAY_NAME</string>

    <key>CFBundleDisplayName</key>
    <string>$DISPLAY_NAME</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>CFBundleShortVersionString</key>
    <string>$APP_VERSION</string>

    <key>CFBundleVersion</key>
    <string>$APP_VERSION</string>

    <key>CFBundleSignature</key>
    <string>EMRK</string>

    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>

    <key>NSHighResolutionCapable</key>
    <true/>

    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>

    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>

    <key>NSHumanReadableCopyright</key>
    <string>Copyright 2024-2025 TrexoLab. All rights reserved.</string>

    <key>NSPrincipalClass</key>
    <string>NSApplication</string>

    <key>NSAppleEventsUsageDescription</key>
    <string>eMark needs to control other applications for PDF signing operations.</string>

    <key>NSDocumentsFolderUsageDescription</key>
    <string>eMark needs access to your Documents folder to open and sign PDF files.</string>

    <key>NSDownloadsFolderUsageDescription</key>
    <string>eMark needs access to your Downloads folder to open and sign PDF files.</string>

    <key>NSDesktopFolderUsageDescription</key>
    <string>eMark needs access to your Desktop folder to open and sign PDF files.</string>

    <key>NSRemovableVolumesUsageDescription</key>
    <string>eMark needs access to removable volumes to open and sign PDF files.</string>

    <key>NSNetworkVolumesUsageDescription</key>
    <string>eMark needs access to network volumes to open and sign PDF files.</string>

    <key>NSFileProviderDomainUsageDescription</key>
    <string>eMark needs access to cloud storage to open and sign PDF files.</string>

    <key>NSSystemAdministrationUsageDescription</key>
    <string>eMark needs system administration access for PKCS#11 hardware token operations.</string>

    <key>LSMultipleInstancesProhibited</key>
    <true/>
</dict>
</plist>
PLIST

    # Create PkgInfo
    echo "APPL????" > "$APP_DIR/Contents/PkgInfo"

    # Create launcher script with embedded memory settings
    cat > "$APP_DIR/Contents/MacOS/run-emark" << LAUNCHER
#!/bin/bash
# eMark - macOS Launcher ($MEMORY_PROFILE profile)
# Handles PDF file open events from Finder

# Get the directory where this script is located
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
RESOURCES_DIR="\$(cd "\$SCRIPT_DIR/../Resources" && pwd)"

# Bundled JRE location (macOS JRE structure)
JAVA_EXE="\$RESOURCES_DIR/jre8-x64/Contents/Home/bin/java"

# Fallback for standard JRE structure
if [ ! -x "\$JAVA_EXE" ]; then
    JAVA_EXE="\$RESOURCES_DIR/jre8-x64/bin/java"
fi

# JAR file location
JAR_FILE="\$RESOURCES_DIR/eMark.jar"

# Validate bundled Java runtime exists
if [ ! -x "\$JAVA_EXE" ]; then
    # Show detailed error with path information
    ERROR_MSG="Java Runtime Not Found

The bundled Java 8 runtime was not found at:
\$JAVA_EXE

This usually means the app was not built correctly.

Please download a fresh copy from:
https://github.com/testaxonatetech/emark/releases/latest

If the problem persists, please report it at:
https://github.com/testaxonatetech/emark/issues"

    osascript -e "display dialog \"\$ERROR_MSG\" buttons {\"OK\"} default button \"OK\" with icon stop with title \"eMark - Runtime Error\""
    exit 1
fi

# Validate JAR file exists
if [ ! -f "\$JAR_FILE" ]; then
    osascript -e 'display dialog "Application Not Found\n\nThe application JAR file was not found.\n\nPlease reinstall eMark." buttons {"OK"} default button "OK" with icon stop with title "eMark"'
    exit 1
fi

# Memory profile: $MEMORY_PROFILE ($XMX max heap)
JAVA_OPTS="-Xms$XMS -Xmx$XMX -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# macOS-specific Java options
JAVA_OPTS="\$JAVA_OPTS -Xdock:name=$DISPLAY_NAME"
JAVA_OPTS="\$JAVA_OPTS -Dapple.awt.application.name=$DISPLAY_NAME"
JAVA_OPTS="\$JAVA_OPTS -Dapple.laf.useScreenMenuBar=true"

# Add dock icon if available
if [ -f "\$RESOURCES_DIR/emark.icns" ]; then
    JAVA_OPTS="\$JAVA_OPTS -Xdock:icon=\$RESOURCES_DIR/emark.icns"
fi

# Launch the application with any file arguments
exec "\$JAVA_EXE" \$JAVA_OPTS -jar "\$JAR_FILE" "\$@"
LAUNCHER
    chmod +x "$APP_DIR/Contents/MacOS/run-emark"

    # Copy application files to Resources
    cp "$ROOT_DIR/target/eMark.jar" "$APP_DIR/Contents/Resources/"

    # Copy JRE
    if [ ! -d "$SCRIPT_DIR/jre8-x64" ]; then
        echo "ERROR: JRE not found at $SCRIPT_DIR/jre8-x64"
        echo "Cannot create app bundle without bundled Java runtime."
        exit 1
    fi

    echo "  Bundling JRE from $SCRIPT_DIR/jre8-x64..."
    cp -r "$SCRIPT_DIR/jre8-x64" "$APP_DIR/Contents/Resources/"

    # Make Java executables executable
    find "$APP_DIR/Contents/Resources/jre8-x64" -name "java" -o -name "java*" -type f 2>/dev/null | xargs chmod +x 2>/dev/null || true

    if [ -d "$APP_DIR/Contents/Resources/jre8-x64/Contents/Home/bin" ]; then
        chmod +x "$APP_DIR/Contents/Resources/jre8-x64/Contents/Home/bin/"* 2>/dev/null || true
    fi
    if [ -d "$APP_DIR/Contents/Resources/jre8-x64/bin" ]; then
        chmod +x "$APP_DIR/Contents/Resources/jre8-x64/bin/"* 2>/dev/null || true
    fi

    # Verify JRE was copied successfully
    if [ ! -d "$APP_DIR/Contents/Resources/jre8-x64" ]; then
        echo "ERROR: Failed to copy JRE to app bundle"
        exit 1
    fi
    echo "  JRE bundled successfully"

    # Copy branding icon
    if [ -f "$SCRIPT_DIR/emark.icns" ]; then
        cp "$SCRIPT_DIR/emark.icns" "$APP_DIR/Contents/Resources/"
    elif [ -f "$SCRIPT_DIR/emark.png" ]; then
        cp "$SCRIPT_DIR/emark.png" "$APP_DIR/Contents/Resources/"
    fi

    # Move to output
    mv "$APP_DIR" "$OUTPUT_DIR/"

    echo "  Created: $OUTPUT_DIR/$APP_NAME.app"
}

# Check prerequisites
if [ ! -f "$ROOT_DIR/target/eMark.jar" ]; then
    echo "ERROR: JAR file not found at $ROOT_DIR/target/eMark.jar"
    echo "Please build the project first with: mvn package"
    exit 1
fi

if [ ! -d "$SCRIPT_DIR/jre8-x64" ]; then
    echo "ERROR: JRE not found at $SCRIPT_DIR/jre8-x64"
    echo ""
    echo "The macOS installer requires a bundled JRE."
    echo "Please download and extract it first:"
    echo ""
    echo "  curl -L -o jre8-x64.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u432-b06/OpenJDK8U-jre_x64_mac_hotspot_8u432b06.tar.gz"
    echo "  tar -xzf jre8-x64.tar.gz"
    echo "  mv jdk8u432-b06-jre jre8-x64"
    echo ""
    exit 1
fi

# Create app bundle with 4GB memory profile
create_app_bundle "eMark" "$BUNDLE_ID_BASE" "eMark" "Standard" "512m" "4g"

# Clean up build directory
rm -rf "$BUILD_DIR"

echo ""
echo "============================================================================"
echo " App bundle built successfully!"
echo "============================================================================"
echo " Output:"
echo "   - $OUTPUT_DIR/eMark.app (4GB max memory)"
echo ""
echo " Memory Configuration:"
echo "   - Initial heap: 512MB"
echo "   - Maximum heap: 4GB"
echo "   - Suitable for PDFs up to 200MB"
echo ""
echo " To install:"
echo "   1. Drag eMark.app to /Applications"
echo "   2. Right-click and select 'Open' on first launch"
echo ""
echo " To create DMG, run: ./build-dmg.sh"
echo "============================================================================"
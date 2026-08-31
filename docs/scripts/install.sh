#!/bin/bash
#
# IBM Maximo Application Framework Local Configuration
# Automated Installation Script
#
# This script downloads and installs the latest version of the
# Maximo Developer Configuration Tools extension.
#
# Usage:
#   # Interactive mode (prompts for editor selection if multiple editors found):
#   curl -fsSL https://ibm-mas.github.io/maf-local-dev-mode/scripts/install.sh | bash
#
#   # Non-interactive mode for IBM Bob IDE:
#   curl -fsSL https://ibm-mas.github.io/maf-local-dev-mode/scripts/install.sh | bash -s bob
#
#   # Non-interactive mode for VSCode:
#   curl -fsSL https://ibm-mas.github.io/maf-local-dev-mode/scripts/install.sh | bash -s vscode
#
# Or download and run locally:
#   curl -fsSL https://ibm-mas.github.io/maf-local-dev-mode/scripts/install.sh -o install.sh
#   chmod +x install.sh
#   ./install.sh              # Interactive mode
#   ./install.sh bob          # Install for Bob IDE
#   ./install.sh vscode       # Install for VSCode
#   ./install.sh --help       # Show help
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub repository details
REPO_OWNER="ibm-mas"
REPO_NAME="maf-local-dev-mode"
EXTENSION_NAME="maximo-developer-configuration-tools"

# Editor selection
EDITOR_CLI=""
EDITOR_NAME=""

# Print functions
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo "=================================================="
    echo "  IBM Maximo Application Framework Local Configuration"
    echo "  Installer"
    echo "=================================================="
    echo ""
}

# Show help message
show_help() {
    echo "IBM Maximo Application Framework Local Configuration Installer"
    echo ""
    echo "Usage:"
    echo "  $0 [EDITOR]"
    echo ""
    echo "Arguments:"
    echo "  EDITOR    Specify editor to install into: 'bob' or 'vscode'"
    echo "            If not specified, installer will prompt interactively"
    echo ""
    echo "Examples:"
    echo "  $0              # Interactive mode"
    echo "  $0 bob          # Install for IBM Bob IDE"
    echo "  $0 vscode       # Install for VSCode"
    echo ""
    echo "Remote installation:"
    echo "  curl -fsSL https://ibm-mas.github.io/maf-local-dev-mode/scripts/install.sh | bash"
    echo "  curl -fsSL https://ibm-mas.github.io/maf-local-dev-mode/scripts/install.sh | bash -s bob"
    echo "  curl -fsSL https://ibm-mas.github.io/maf-local-dev-mode/scripts/install.sh | bash -s vscode"
    echo ""
    exit 0
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect VSCode in integrated terminal and use fallback path
detect_vscode_fallback() {
    # Check if running in VSCode integrated terminal
    if [ -n "$VSCODE_GIT_IPC_HANDLE" ] || [ -n "$VSCODE_IPC_HOOK" ] || [ "$TERM_PROGRAM" = "vscode" ]; then
        print_info "Detected VSCode integrated terminal, checking for VSCode installation..."
        
        # Try common VSCode installation paths
        local vscode_paths=(
            "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"  # macOS
            "/usr/share/code/bin/code"  # Linux
            "/usr/bin/code"  # Linux alternative
            "$HOME/.vscode/extensions/bin/code"  # User installation
        )
        
        for vscode_path in "${vscode_paths[@]}"; do
            if [ -x "$vscode_path" ]; then
                EDITOR_CLI="$vscode_path"
                EDITOR_NAME="VSCode"
                local editor_version=$("$EDITOR_CLI" --version 2>/dev/null | head -n 1)
                print_success "Found VSCode at: $vscode_path"
                if [ -n "$editor_version" ]; then
                    print_success "VSCode version: $editor_version"
                fi
                return 0
            fi
        done
    fi
    return 1
}

# Detect Bob IDE in integrated terminal and use fallback path
detect_bobide_fallback() {
    # Check if running in Bob IDE integrated terminal
    # Bob IDE is based on VSCode, so it may have similar environment variables
    if [ -n "$VSCODE_GIT_IPC_HANDLE" ] || [ -n "$VSCODE_IPC_HOOK" ] || [ "$TERM_PROGRAM" = "vscode" ]; then
        print_info "Checking for Bob IDE installation..."
        
        # Try common Bob IDE installation paths
        local bobide_paths=(
            "/Applications/Bob.app/Contents/Resources/app/bin/bobide"  # macOS
            "/usr/share/bobide/bin/bobide"  # Linux
            "/usr/bin/bobide"  # Linux alternative
            "$HOME/.bobide/bin/bobide"  # User installation
        )
        
        for bobide_path in "${bobide_paths[@]}"; do
            if [ -x "$bobide_path" ]; then
                EDITOR_CLI="$bobide_path"
                EDITOR_NAME="BobIDE"
                local editor_version=$("$EDITOR_CLI" --version 2>/dev/null | head -n 1)
                print_success "Found Bob IDE at: $bobide_path"
                if [ -n "$editor_version" ]; then
                    print_success "Bob IDE version: $editor_version"
                fi
                return 0
            fi
        done
    fi
    return 1
}

# Select editor CLI
select_editor() {
    local editor_param="$1"
    local available_editors=()
    
    # Check which editors are available
    if command_exists code; then
        available_editors+=("code:VSCode")
    fi
    
    if command_exists bobide; then
        available_editors+=("bobide:BobIDE")
    fi
    
    # If a specific editor was requested via parameter
    if [ -n "$editor_param" ]; then
        case "$editor_param" in
            bob|bobide)
                if command_exists bobide; then
                    EDITOR_CLI="bobide"
                    EDITOR_NAME="BobIDE"
                    local editor_version=$("$EDITOR_CLI" --version 2>/dev/null | head -n 1 || echo "version unknown")
                    print_success "${EDITOR_NAME} selected: $editor_version"
                    return
                elif detect_bobide_fallback; then
                    return
                else
                    print_error "BobIDE CLI (bobide) not found in PATH"
                    echo ""
                    echo "💡 TIP: If you're using Bob IDE, try pasting this command into Bob's"
                    echo "    coding assistant instead of a regular terminal."
                    echo "    The assistant can access Bob IDE's internal commands."
                    echo ""
                    echo "Otherwise, ensure the bobide CLI is available in PATH"
                    echo ""
                    exit 1
                fi
                ;;
            vscode|code)
                if command_exists code; then
                    EDITOR_CLI="code"
                    EDITOR_NAME="VSCode"
                    local editor_version=$("$EDITOR_CLI" --version 2>/dev/null | head -n 1 || echo "version unknown")
                    print_success "${EDITOR_NAME} selected: $editor_version"
                    return
                elif detect_vscode_fallback; then
                    return
                else
                    print_error "VSCode CLI (code) not found in PATH"
                    echo ""
                    echo "💡 TIP: Try one of these options:"
                    echo ""
                    echo "   Option 1 - Use Your Coding Assistant (Easiest):"
                    echo "   Paste this installation command into your coding assistant"
                    echo "   (VSCode Copilot, GitHub Copilot Chat, Bob IDE, etc.):"
                    echo ""
                    echo "   curl -fsSL https://ibm-mas.github.io/maf-local-dev-mode/scripts/install.sh | bash -s vscode"
                    echo ""
                    echo "   Option 2 - Install the 'code' Command:"
                    echo "   1. Open VSCode"
                    echo "   2. Press Cmd+Shift+P (Mac) or Ctrl+Shift+P (Windows/Linux)"
                    echo "   3. Type 'Shell Command: Install code command in PATH'"
                    echo "   4. Select and run the command"
                    echo "   5. Restart your terminal and try again"
                    echo ""
                    echo "   More info: https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line"
                    echo ""
                    exit 1
                fi
                ;;
            *)
                print_warning "Unknown editor parameter: '$editor_param'"
                print_info "Valid options are: 'bob' or 'vscode'"
                print_info "Falling back to interactive mode..."
                echo ""
                # Continue to interactive selection below
                ;;
        esac
    fi
    
    # No valid parameter provided, use interactive selection
    if [ ${#available_editors[@]} -eq 0 ]; then
        print_error "Neither VSCode CLI (code) nor BobIDE CLI (bobide) was found in PATH"
        echo ""
        echo "Please install one of the supported editors:"
        echo "  - VSCode: https://code.visualstudio.com/"
        echo "  - BobIDE: Ensure the bobide CLI is installed and available in PATH"
        echo ""
        exit 1
    fi
    
    if [ ${#available_editors[@]} -eq 1 ]; then
        EDITOR_CLI="${available_editors[0]%%:*}"
        EDITOR_NAME="${available_editors[0]#*:}"
        local editor_version=$("$EDITOR_CLI" --version 2>/dev/null | head -n 1 || echo "version unknown")
        print_success "${EDITOR_NAME} found: $editor_version"
        return
    fi
    
    print_info "Multiple supported editors detected."
    echo "Select which editor to install the extension into:"
    echo "  1) VSCode"
    echo "  2) BobIDE"
    echo ""
    
    while true; do
        read -r -p "Enter choice [1-2]: " editor_choice
        case "$editor_choice" in
            1)
                EDITOR_CLI="code"
                EDITOR_NAME="VSCode"
                break
                ;;
            2)
                EDITOR_CLI="bobide"
                EDITOR_NAME="BobIDE"
                break
                ;;
            *)
                print_warning "Invalid selection. Please enter 1 for VSCode or 2 for BobIDE."
                ;;
        esac
    done
    
    local editor_version=$("$EDITOR_CLI" --version 2>/dev/null | head -n 1 || echo "version unknown")
    print_success "${EDITOR_NAME} selected: $editor_version"
}

# Check prerequisites
check_prerequisites() {
    local editor_param="$1"
    
    print_info "Checking prerequisites..."
    
    local missing_deps=()
    
    select_editor "$editor_param"
    
    # Check for curl
    if ! command_exists curl; then
        print_error "curl not found"
        missing_deps+=("curl")
    fi
    
    # Check for Node.js (optional but recommended)
    if command_exists node; then
        local node_version=$(node --version)
        print_success "Node.js found: $node_version"
        
        # Check if version is >= 20.0.0
        local node_major=$(echo "$node_version" | sed 's/v//' | cut -d. -f1)
        if [ "$node_major" -lt 20 ]; then
            print_warning "Node.js version 20.0.0 or higher is recommended (found: $node_version)"
        fi
    else
        print_warning "Node.js not found (recommended for full functionality)"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "Please install the missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                "curl")
                    echo "  - curl: Usually pre-installed, or use your package manager"
                    ;;
            esac
        done
        echo ""
        exit 1
    fi
    
    echo ""
}

# Get latest release info from GitHub
get_latest_release() {
    print_info "Fetching latest release information..."
    
    local latest_api_url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    local releases_api_url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases"
    local release_info
    local release_source="latest stable release"
    
    if ! release_info=$(curl -fsSL "$latest_api_url" 2>&1); then
        print_warning "No stable release found. Falling back to the most recent release, including pre-releases..."
        
        if ! release_info=$(curl -fsSL "$releases_api_url" 2>&1); then
            print_error "Failed to fetch release information from GitHub"
            print_info "Latest release API URL: $latest_api_url"
            print_info "All releases API URL: $releases_api_url"
            print_info "Error: $release_info"
            echo ""
            print_info "You can manually download the extension from:"
            print_info "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases"
            exit 1
        fi
        
        release_source="most recent release or pre-release"
    fi
    
    # Extract version and download URL
    RELEASE_VERSION=$(echo "$release_info" | grep '"tag_name"' | head -n 1 | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
    DOWNLOAD_URL=$(echo "$release_info" | grep '"browser_download_url"' | grep '\.vsix"' | head -n 1 | sed -E 's/.*"browser_download_url": "([^"]+)".*/\1/')
    
    if [ -z "$RELEASE_VERSION" ] || [ -z "$DOWNLOAD_URL" ]; then
        print_error "Could not parse release information"
        print_info "Please try manual installation: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases"
        exit 1
    fi
    
    print_success "Using ${release_source}: $RELEASE_VERSION"
    echo ""
}

# Download the extension
download_extension() {
    print_info "Downloading extension..."
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    VSIX_FILE="${TEMP_DIR}/${EXTENSION_NAME}.vsix"
    
    if ! curl -fsSL -o "$VSIX_FILE" "$DOWNLOAD_URL"; then
        print_error "Failed to download extension"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Verify file was downloaded
    if [ ! -f "$VSIX_FILE" ]; then
        print_error "Downloaded file not found"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    local file_size=$(du -h "$VSIX_FILE" | cut -f1)
    print_success "Downloaded: $file_size"
    echo ""
}

# Install the extension
install_extension() {
    print_info "Installing extension into ${EDITOR_NAME}..."
    
    if "$EDITOR_CLI" --install-extension "$VSIX_FILE" --force; then
        print_success "Extension installed successfully in ${EDITOR_NAME}!"
    else
        print_error "Failed to install extension in ${EDITOR_NAME}"
        print_info "You can try installing manually:"
        print_info "  1. Open ${EDITOR_NAME}"
        print_info "  2. Go to Extensions (Ctrl+Shift+X)"
        print_info "  3. Click '...' menu → 'Install from VSIX...'"
        print_info "  4. Select: $VSIX_FILE"
        echo ""
        print_info "The downloaded file will be kept at: $VSIX_FILE"
        exit 1
    fi
    
    echo ""
}

# Cleanup
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        print_info "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
        print_success "Cleanup complete"
    fi
}

# Display next steps
show_next_steps() {
    echo ""
    echo "=================================================="
    echo "  Installation Complete!"
    echo "=================================================="
    echo ""
    echo "Next Steps:"
    echo ""
    echo "1. Restart ${EDITOR_NAME} (if currently open)"
    echo ""
    echo "2. Verify installation:"
    echo "   - Open ${EDITOR_NAME}"
    echo "   - Check Extensions panel (Ctrl+Shift+X)"
    echo "   - Look for 'Maximo Developer Configuration Tools'"
    echo ""
    echo "3. Configure authentication:"
    echo "   - For local Manage: No additional setup needed"
    echo "   - For remote MAS: Follow OIDC setup in the plugin"
    echo ""
    echo "4. Start using the extension:"
    echo "   - Open Command Palette (Ctrl+Shift+P)"
    echo "   - Type 'Maximo Dev Tools' to see available commands"
    echo ""
    echo "Documentation: https://ibm-mas.github.io/maf-local-dev-mode/"
    echo "Report issues: https://github.com/${REPO_OWNER}/${REPO_NAME}/issues"
    echo ""
}

# Main installation flow
main() {
    # Handle help flag
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
    fi
    
    print_header
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Run installation steps
    check_prerequisites "$1"
    get_latest_release
    download_extension
    install_extension
    
    # Show next steps
    show_next_steps
}

# Run main function
main "$@"

# Made with Bob

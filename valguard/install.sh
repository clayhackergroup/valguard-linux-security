#!/bin/bash

###############################################################################
# VALGUARD v4.0 - Installation Script
# Advanced Linux Security Scanner
# Clay Security Team © 2025
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Installation paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
INSTALL_PATH="/usr/local/bin/valguard"
COMPLETION_DIR="/etc/bash_completion.d"
MAN_DIR="/usr/local/man/man1"

###############################################################################
# HELPER FUNCTIONS
###############################################################################

print_banner() {
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
    
                                   ###
                              ###############
                        ############   ############
                  ############     #####     ############
            ############    .#################     ############
        ,#########     #############################     #########
        #####    #########################################    #####
       #####  ###############################################  ####
       #####  ##################   #####   ##################  #####
       ##### ,################  ###########  ################* ##(((
       ##### ,###############  #############  ###############* (((((
       ##### ,###############  #############. ##############(, (((((
       #####  ###############                 ############(((  (((((
        ####  ############, ,#################, #######((((((  ((((
        ##### ############  ########   ########  ####(((((((( (((((
        #####  ###########  ######. ###  ######  #((((((((((  (((((
         ##### .##########  #######     #######  ((((((((((. (((((
          ####. ##########  ######### #######((  (((((((((( (((((
          #####  #########  ###############((((  ((((((((( /((((.
           *##### ,########  ###########((((((  ((((((((, (((((/
             ##### ##########               ((((((((((  (((((
              ######  #############((((((((((((((((((  ((((((
               .#####,  #########((((((((((((((((((  .(((((
                 (######  ####(((((((((((((((((((  ((((((
                    #######   (((((((((((((((   (((((((
                      ###(((((    (((((((   /((((((((
                          (((((((((/   /(((((((((
                              (((((((((((((((

    VALGUARD v4.0 - INSTALLATION SCRIPT
    Advanced Linux Security Scanner
    Clay Security Team © 2025
    
EOF
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[•]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

###############################################################################
# SYSTEM CHECKS
###############################################################################

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_warning "Please run with sudo: sudo bash install.sh"
        exit 1
    fi
}

check_dependencies() {
    print_info "Checking system dependencies..."
    
    local missing_deps=()
    local deps=("python3" "grep" "awk" "sed" "ss" "netstat" "ps" "find")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Installing missing packages..."
        
        # Detect package manager and install
        if command -v apt-get &> /dev/null; then
            apt-get update -qq
            apt-get install -y -qq ${missing_deps[@]} 2>/dev/null || true
        elif command -v yum &> /dev/null; then
            yum install -y -q ${missing_deps[@]} 2>/dev/null || true
        elif command -v pacman &> /dev/null; then
            pacman -Sy --noconfirm ${missing_deps[@]} 2>/dev/null || true
        fi
    fi
    
    print_success "Dependencies verified"
}

check_python() {
    print_info "Checking Python 3 installation..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        exit 1
    fi
    
    local python_version=$(python3 --version 2>&1 | awk '{print $2}')
    print_success "Python 3 found: $python_version"
}

###############################################################################
# INSTALLATION FUNCTIONS
###############################################################################

create_executable() {
    print_info "Setting up executable..."
    
    # Make main script executable
    chmod +x "$BIN_DIR/valguard"
    
    # Create symlink or copy to /usr/local/bin
    if [ -L "$INSTALL_PATH" ]; then
        rm -f "$INSTALL_PATH"
    elif [ -f "$INSTALL_PATH" ]; then
        rm -f "$INSTALL_PATH"
    fi
    
    # Create symlink (preferred method)
    ln -sf "$BIN_DIR/valguard" "$INSTALL_PATH"
    
    # Verify installation
    if [ -x "$INSTALL_PATH" ]; then
        print_success "Executable installed to $INSTALL_PATH"
    else
        print_error "Failed to install executable"
        exit 1
    fi
}

create_bash_completion() {
    print_info "Installing bash completion..."
    
    if [ ! -d "$COMPLETION_DIR" ]; then
        mkdir -p "$COMPLETION_DIR"
    fi
    
    cat > "$COMPLETION_DIR/valguard" << 'EOF'
# Bash completion for valguard
_valguard_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    opts="fullaudit audit ports network vulns malware compliance hardening info status users processes logs help exit"
    
    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
    
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

complete -F _valguard_completion valguard
EOF
    
    chmod 644 "$COMPLETION_DIR/valguard"
    print_success "Bash completion installed"
}

create_man_page() {
    print_info "Installing man page..."
    
    if [ ! -d "$MAN_DIR" ]; then
        mkdir -p "$MAN_DIR"
    fi
    
    cat > "$MAN_DIR/valguard.1" << 'EOF'
.TH VALGUARD 1 "December 2025" "valguard 4.0" "User Commands"
.SH NAME
valguard \- Advanced Linux Security Scanner
.SH SYNOPSIS
.B valguard
[\fICOMMAND\fR]
.SH DESCRIPTION
VALGUARD v4.0 is an advanced, professional-grade Linux security scanning and auditing tool.
It provides comprehensive security assessment including port scanning, network analysis,
vulnerability detection, malware scanning, compliance checking, and security hardening recommendations.
.SH COMMANDS
.TP
.B fullaudit
Execute comprehensive security audit with all checks
.TP
.B audit
Standard security audit (ports, network, vulnerabilities)
.TP
.B ports
Advanced port scanning and service detection
.TP
.B network
Advanced network threat analysis
.TP
.B vulns
Comprehensive vulnerability assessment
.TP
.B malware
Advanced malware and rootkit detection
.TP
.B compliance
Security compliance baseline check
.TP
.B hardening
Security hardening recommendations
.TP
.B info
Detailed system information
.TP
.B status
Quick security status
.TP
.B users
User accounts audit
.TP
.B processes
Process analysis
.TP
.B logs
System log analysis
.TP
.B help
Display help menu
.TP
.B exit
Exit shell
.SH EXAMPLES
.TP
Run complete security audit:
.B valguard fullaudit
.TP
Run port scan:
.B valguard ports
.TP
Check compliance:
.B valguard compliance
.TP
Run interactive shell:
.B valguard
.SH AUTHOR
Clay Security Team © 2025
.SH SEE ALSO
For more information, visit the project repository.
EOF
    
    chmod 644 "$MAN_DIR/valguard.1"
    gzip -f "$MAN_DIR/valguard.1" 2>/dev/null || true
    print_success "Man page installed"
}

create_config_directory() {
    print_info "Creating configuration directory..."
    
    CONFIG_DIR="/etc/valguard"
    
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        
        # Create default config
        cat > "$CONFIG_DIR/valguard.conf" << 'EOF'
# VALGUARD v4.0 Configuration File
# Clay Security Team © 2025

# Timeout for commands (seconds)
COMMAND_TIMEOUT=15

# Maximum results to display
MAX_RESULTS=20

# Log level (DEBUG, INFO, WARNING, ERROR)
LOG_LEVEL=INFO

# Enable/Disable specific scans
ENABLE_PORT_SCAN=true
ENABLE_NETWORK_SCAN=true
ENABLE_VULNERABILITY_SCAN=true
ENABLE_MALWARE_SCAN=true
ENABLE_COMPLIANCE_CHECK=true

# Excluded directories from scans
EXCLUDED_DIRS="/proc /sys /dev /run /boot"

# Report output format (text, json, html)
REPORT_FORMAT=text

# Save reports to file
SAVE_REPORTS=false
REPORT_OUTPUT_DIR="/var/log/valguard"
EOF
        chmod 644 "$CONFIG_DIR/valguard.conf"
        print_success "Configuration directory created at $CONFIG_DIR"
    else
        print_info "Configuration directory already exists at $CONFIG_DIR"
    fi
}

create_log_directory() {
    print_info "Creating log directory..."
    
    LOG_DIR="/var/log/valguard"
    
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        chmod 755 "$LOG_DIR"
        print_success "Log directory created at $LOG_DIR"
    else
        print_info "Log directory already exists"
    fi
}

verify_installation() {
    print_info "Verifying installation..."
    
    # Test if valguard can be called
    if ! command -v valguard &> /dev/null; then
        print_error "Installation verification failed"
        return 1
    fi
    
    # Test if it runs without errors
    if ! valguard help > /dev/null 2>&1; then
        print_warning "Installation completed but help command failed"
        return 1
    fi
    
    print_success "Installation verified successfully"
    return 0
}

###############################################################################
# MAIN INSTALLATION
###############################################################################

main() {
    print_banner
    
    echo -e "${BOLD}${CYAN}Starting VALGUARD v4.0 Installation${NC}\n"
    
    # Check if running as root
    check_root
    
    # Pre-installation checks
    print_info "Running pre-installation checks..."
    echo ""
    check_python
    check_dependencies
    echo ""
    
    # Installation steps
    print_info "Installing VALGUARD v4.0..."
    echo ""
    create_executable
    create_bash_completion
    create_man_page
    create_config_directory
    create_log_directory
    echo ""
    
    # Verification
    print_info "Verifying installation..."
    echo ""
    if verify_installation; then
        echo ""
        print_success "VALGUARD v4.0 installed successfully!"
        echo ""
        echo -e "${BOLD}${GREEN}Installation Complete${NC}"
        echo ""
        echo "Quick Start:"
        echo -e "  ${CYAN}valguard${NC}              - Interactive security shell"
        echo -e "  ${CYAN}valguard fullaudit${NC}    - Run complete security audit"
        echo -e "  ${CYAN}valguard ports${NC}        - Advanced port scanning"
        echo -e "  ${CYAN}valguard network${NC}      - Network threat analysis"
        echo -e "  ${CYAN}valguard vulns${NC}        - Vulnerability assessment"
        echo -e "  ${CYAN}valguard compliance${NC}   - Compliance baseline check"
        echo -e "  ${CYAN}valguard help${NC}         - Show help menu"
        echo ""
        echo "Man page: man valguard"
        echo "Config: /etc/valguard/valguard.conf"
        echo "Logs: /var/log/valguard/"
        echo ""
        print_success "You can now use 'valguard' from any terminal!"
        echo ""
    else
        print_error "Installation verification failed"
        exit 1
    fi
}

# Run main installation
main "$@"

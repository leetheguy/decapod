#!/bin/bash
#
# ██╗    ██╗ █████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗ 
# ██║    ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║██╔════╝ 
# ██║ █╗ ██║███████║██████╔╝██╔██╗ ██║██║██╔██╗ ██║██║  ███╗
# ██║██╗╚██║██╔══██║██╔══██╗██║╚██╗██║██║██║╚██╗██║██║   ██║
# ╚███╔███╔╝██║  ██║██║  ██║██║ ╚████║██║██║ ╚████║╚██████╔╝
#  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 
#
# This script was AI generated without human oversight! (Even the ASCII art!)
#
#
# 
# upload_S3_structure.sh
# 
# Completely destroys and replaces all content in the Minio S3 bucket with the local S3_structure directory.
# This script creates or uses a bucket called "decapod" and completely replaces
# all files from extras/S3_structure/, DESTROYING any files in the bucket that don't exist locally.
#
# WARNING: This is a COMPLETE DESTRUCTION operation. The local directory is the source of truth.
# - All files in the bucket that don't exist locally will be PERMANENTLY DELETED
# - All files that exist in both will be overwritten with local versions
# - The bucket will be an exact mirror of the local directory structure
#
# Pipeline Architecture:
#   1. Validate prerequisites (mc, credentials, source directory)
#   2. Configure Minio connection
#   3. Ensure bucket exists
#   4. Completely destroy and replace bucket contents with local files (deletes files not in local)
#   5. Report results
#
# Usage:
#   ./upload_S3_structure.sh [minio-endpoint] [access-key] [secret-key]
#   
#   Or set environment variables:
#   MINIO_ENDPOINT=http://localhost:9000
#   MINIO_ACCESS_KEY=your_access_key
#   MINIO_SECRET_KEY=your_secret_key
#
# Exit codes:
#   0 - Success
#   1 - Prerequisites not met
#   2 - Configuration error
#   3 - Bucket operation failed
#   4 - Upload operation failed

set -euo pipefail

# ANSI color codes for warnings
RED="\033[31m"
BOLD="\033[1m"
RESET="\033[0m"

# ============================================================================
# Configuration
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly SOURCE_DIR="${PROJECT_ROOT}/extras/S3_structure"
readonly BUCKET_NAME="decapod"
readonly ALIAS_NAME="decapod-minio"

# ============================================================================
# Functions - Prerequisites
# ============================================================================

#
# Check if Minio Client (mc) is installed and available
# Returns: 0 if available, 1 otherwise
#
check_mc_available() {
    if ! command -v mc &> /dev/null; then
        echo "Error: Minio Client (mc) is not installed or not in PATH" >&2
        echo "Install it with: wget https://dl.min.io/client/mc/release/linux-amd64/mc" >&2
        return 1
    fi
    return 0
}

#
# Check if source directory exists and is readable
# Returns: 0 if valid, 1 otherwise
#
check_source_directory() {
    if [[ ! -d "${SOURCE_DIR}" ]]; then
        echo "Error: Source directory does not exist: ${SOURCE_DIR}" >&2
        return 1
    fi
    
    if [[ ! -r "${SOURCE_DIR}" ]]; then
        echo "Error: Source directory is not readable: ${SOURCE_DIR}" >&2
        return 1
    fi
    
    return 0
}

#
# Validate all prerequisites before proceeding
# Returns: 0 if all checks pass, exits with error code otherwise
#
validate_prerequisites() {
    echo "Checking prerequisites..."
    
    check_mc_available || exit 1
    check_source_directory || exit 1
    
    echo "✓ Prerequisites validated"
}

# ============================================================================
# Functions - Configuration
# ============================================================================

#
# Load Minio credentials from environment variables or .env file
# Sets: MINIO_ENDPOINT, MINIO_ACCESS_KEY, MINIO_SECRET_KEY
# Returns: 0 on success, 1 on failure
#
load_credentials() {
    local minio_env_file="${PROJECT_ROOT}/minio/.env"
    
    # Use command line arguments if provided
    if [[ $# -ge 3 ]]; then
        MINIO_ENDPOINT="${1}"
        MINIO_ACCESS_KEY="${2}"
        MINIO_SECRET_KEY="${3}"
    # Use environment variables if set
    elif [[ -n "${MINIO_ENDPOINT:-}" && -n "${MINIO_ACCESS_KEY:-}" && -n "${MINIO_SECRET_KEY:-}" ]]; then
        echo "Using credentials from environment variables"
    # Try to load from .env file
    elif [[ -f "${minio_env_file}" ]]; then
        echo "Loading credentials from ${minio_env_file}"
        # Source the .env file and extract values
        set -a
        source "${minio_env_file}"
        set +a
        
        MINIO_ENDPOINT="${MINIO_ENDPOINT:-http://localhost:9000}"
        MINIO_ACCESS_KEY="${MINIO_ROOT_USER:-}"
        MINIO_SECRET_KEY="${MINIO_ROOT_PASSWORD:-}"
    else
        echo "Error: Minio credentials not found" >&2
        echo "Provide credentials via:" >&2
        echo "  1. Command line arguments: $0 <endpoint> <access-key> <secret-key>" >&2
        echo "  2. Environment variables: MINIO_ENDPOINT, MINIO_ACCESS_KEY, MINIO_SECRET_KEY" >&2
        echo "  3. .env file: ${minio_env_file}" >&2
        return 1
    fi
    
    # Validate credentials are set
    if [[ -z "${MINIO_ENDPOINT:-}" || -z "${MINIO_ACCESS_KEY:-}" || -z "${MINIO_SECRET_KEY:-}" ]]; then
        echo "Error: Incomplete Minio credentials" >&2
        return 1
    fi
    
    echo "✓ Credentials loaded (endpoint: ${MINIO_ENDPOINT})"
    return 0
}

#
# Configure Minio Client alias
# Returns: 0 on success, 1 on failure
#
configure_mc_alias() {
    echo "Configuring Minio Client alias..."
    
    # Remove existing alias if it exists (ignore errors)
    mc alias remove "${ALIAS_NAME}" 2>/dev/null || true
    
    # Add new alias
    if mc alias set "${ALIAS_NAME}" "${MINIO_ENDPOINT}" "${MINIO_ACCESS_KEY}" "${MINIO_SECRET_KEY}"; then
        echo "✓ Minio Client alias configured"
        return 0
    else
        echo "Error: Failed to configure Minio Client alias" >&2
        return 1
    fi
}

# ============================================================================
# Functions - Bucket Operations
# ============================================================================

#
# Check if bucket exists
# Returns: 0 if exists, 1 if not
#
bucket_exists() {
    mc ls "${ALIAS_NAME}/${BUCKET_NAME}" &>/dev/null
}

#
# Create the bucket if it doesn't exist
# Returns: 0 on success, 1 on failure
#
ensure_bucket_exists() {
    echo "Ensuring bucket '${BUCKET_NAME}' exists..."
    
    if bucket_exists; then
        echo "✓ Bucket '${BUCKET_NAME}' already exists"
        return 0
    fi
    
    echo "Creating bucket '${BUCKET_NAME}'..."
    if mc mb "${ALIAS_NAME}/${BUCKET_NAME}"; then
        echo "✓ Bucket '${BUCKET_NAME}' created"
        return 0
    else
        echo "Error: Failed to create bucket '${BUCKET_NAME}'" >&2
        return 1
    fi
}

# ============================================================================
# Functions - Upload Operations
# ============================================================================

#
# Completely destroy and replace bucket contents with local files from source directory
# This will DELETE all files in the bucket that don't exist locally, and overwrite all existing files
# The bucket will become an exact mirror of the local directory
# Returns: 0 on success, 1 on failure
#
upload_files() {
    echo "Uploading files from ${SOURCE_DIR} to ${ALIAS_NAME}/${BUCKET_NAME}..."
    echo "WARNING: This will COMPLETELY DESTROY all existing files in the bucket!"
    echo "         Files in the bucket that don't exist locally will be PERMANENTLY DELETED!"
    
    # Use mc mirror with --overwrite and --remove flags
    # --overwrite: Replace existing files with local versions
    # --remove: Delete files in bucket that don't exist in local directory
    # Local S3_structure directory is the source of truth
    # This creates an exact mirror: bucket will match local directory exactly
    if mc mirror --overwrite --remove "${SOURCE_DIR}" "${ALIAS_NAME}/${BUCKET_NAME}/"; then
        echo "✓ Files uploaded successfully (bucket completely replaced with local structure)"
        return 0
    else
        echo "Error: Failed to upload files" >&2
        return 1
    fi
}

#
# Display summary of uploaded files
#
show_summary() {
    echo ""
    echo "=== Upload Summary ==="
    echo "Source: ${SOURCE_DIR}"
    echo "Destination: ${ALIAS_NAME}/${BUCKET_NAME}"
    echo ""
    echo "Files in bucket:"
    mc ls --recursive "${ALIAS_NAME}/${BUCKET_NAME}/" | head -20
    echo ""
    echo "✓ Upload complete!"
}

# ============================================================================
# Main Pipeline
# ============================================================================

main() {
    echo "=========================================="
    echo "Minio S3 Structure Upload Script"
    echo "=========================================="
    echo ""
    echo -e "${RED}${BOLD}WARNING: This script will COMPLETELY DESTROY all content in the bucket!${RESET}"
    echo -e "${RED}         - All files in bucket that don't exist locally will be DELETED${RESET}"
    echo -e "${RED}         - All existing files will be OVERWRITTEN with local versions${RESET}"
    echo -e "${RED}         - The bucket will become an exact mirror of the local directory${RESET}"
    echo -e "${RED}         This is a COMPLETE DESTRUCTION operation!${RESET}"
    echo ""
    echo -n "Press Enter to continue or Escape to cancel: "
    
    # Read a single character (without requiring Enter)
    local key
    if IFS= read -rs -n 1 key; then
        # Check if Escape key was pressed (ESC = \x1b or \e)
        if [[ "$key" == $'\e' ]]; then
            echo ""
            echo "Operation cancelled by user."
            exit 0
        fi
        # If Enter was pressed (empty/newline), continue
        if [[ -z "$key" ]]; then
            echo ""
        else
            # Any other key, consume the rest and continue
            read -rs -n 99
            echo ""
        fi
    else
        # If read failed (e.g., stdin not available), exit
        echo ""
        echo "Error: Cannot read from terminal. Exiting." >&2
        exit 1
    fi
    
    echo ""
    
    # Pipeline step 1: Validate prerequisites
    validate_prerequisites
    
    # Pipeline step 2: Load and validate configuration
    if ! load_credentials "$@"; then
        exit 2
    fi
    
    # Pipeline step 3: Configure Minio Client
    if ! configure_mc_alias; then
        exit 2
    fi
    
    # Pipeline step 4: Ensure bucket exists
    if ! ensure_bucket_exists; then
        exit 3
    fi
    
    # Pipeline step 5: Upload/overwrite files
    if ! upload_files; then
        exit 4
    fi
    
    # Pipeline step 6: Show summary
    show_summary
    
    exit 0
}

# Execute main pipeline
main "$@"

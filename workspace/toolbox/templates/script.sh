#! /usr/bin/env bash

### 
### MANUAL_PAGE
###     @{SCRIPT_NAME}
### 
### GENERAL USAGE
###     @{SCRIPT_NAME} [<option-flag> [option-value] ...] [<argument> ...]
### 
### DESCRIPTION
###     Script description goes here.
### 
### OPTIONS
###     -h|--help
###         Show this manual page.
### 
###     -e|--example-flag [<example-value>]
###         An option flag that accepts an optional value argument.
### 
###     
### ARGUMENTS
###     <example-argument>
###         An example argument.
### 
### ENVIRONMENT VARIABLES
###     N/A
### 
### EXAMPLE USAGE
###     N/A
### 
### END
### 

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

readonly INVOKED_DATE_TIME="$(date +D%Y-%m-%d_T%H-%M-%S)"
readonly THIS_SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly THIS_SCRIPT_DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
#readonly CURRENT_USER="${SUPER_USER:-${USER:-$(whoami)}}"
#readonly CURRENT_USER="{SUDO_USER:-${USER:-$(whoami)}}"
#readonly TEMP_PATH="/dev/shm/${CURRENT_USER}/${THIS_SCRIPT_NAME}/${INVOKED_DATE_TIME}"
#readonly TEMP_PATH="/tmp/${CURRENT_USER}/${THIS_SCRIPT_NAME}/${INVOKED_DATE_TIME}"
#readonly TEMP_PATH="/c/temp/${CURRENT_USER}/${THIS_SCRIPT_NAME}/${INVOKED_DATE_TIME}"

declare -A CTX
CTX[EXAMPLE_OPTION_VALUE]="123:456"

function print_manual_page()
{
    grep -E "${THIS_SCRIPT_DIR_PATH}/${THIS_SCRIPT_NAME}" |
        sed -E "s|^### ||" |
        sed -E "s|@\{SCRIPT_NAME\}|${THIS_SCRIPT_NAME}|"
}

function parse_cli()
{
    # Check for help flag.
    if $(echo "$@" | grep -Eq "(^|\s)(-h|--help)(\s|$)")
    then
        print_manual_page
    fi

    # Parse option flags.
    while [ $# -gt 0 ]
    do
        case "${1}" in
            -e|--example-flag)
                echo "Example flag!"
                if [ $# -gt 1] && [ "${2:0:1}" != "-" ]
                then
                    echo "Optional value argument!"
                    CTX[EXAMPLE_VALUE]="${2}"
                    shift
                fi
                shift
                ;;
            --)
                shift
                break
                ;;
            -?*)
                echo "-- Error: Invalid option flag '${opt}'."
                exit
                ;;
            *)
                break
                ;;
        esac
    done

    CTX[POSITIONAL_ARGUMENTS]="$@"
}

function main()
{
    echo "This is a script template!"
}

parse_cli "$@"
main

#! /usr/bin/env bash

#
# The shell options below improve the script's error detection and handling
# behavior by aborting execution when a command, function, or sub-shell
# returns a non-zero return code or when there is an attempt to use an unset
# varible. Without these options, the script may continue to execute when any
# of the above situations occur which is usually an undesirable side effect.
# Enabling these options does not prevent you from writing script code where
# you expect a command to fail or a variable to be unset. You just have to
# explicitly handle each of those scenarios with conditional checks in the
# case of non-zero return codes and the variable default value syntax in the
# case of unset variables.
#

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

#
# Sometimes it is useful to log the full command or pipe line that being
# executed for reference later. This can be done by enabling the shell option
# 'xtrace', but enabling it for the entire script makes the output very messy.
# The aliases below can be used to wrap just the commands you care to
# log to script output which will keep the script output clean. It is strongly
# recommended to not use these aliases to wrap calls to functions or other
# scripts as the trace output will include the full content of the function or
# script call.
#

shopt -s expand_aliases
alias xtrace_on='{ set -x; } 1>/dev/null 2>&1'
alias xtrace_off='{ set +x; } 1>/dev/null 2>&1'

#
# A set of 'readonly' variables that contain information useful in almost
# any script.
#

readonly MINIMUM_BASH_VERSION="4.1.0"
readonly START_EXECUTION_TIMESTAMP="$(date +%Y-%m-%d-%H-%M-%S)"
readonly THIS_SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly THIS_SCRIPT_DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

#
# A readonly variable to set a root project directory. Feel free to set this to
# a specific working location that fits your needs.
#

readonly PROJECT_DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

#
# Many times there is a need to have a temporary space to perform file
# manipulations, staging, etc. It is also desireable to have that temporary
# space automatically cleaned up by the OS incase the script is unable to
# to clean up after itself due to a failure. It is also desireable to have the
# space be non-root friendly for user level scripts. While there are probably
# many ways to achieve the above requirements, there is a simple OS mechanism
# we can take advantage of. Most Linux distributions supply a RAM backed 
# temporary file system mapped to the '/dev/shm' device. This space is limited
# to the amount of available RAM, but can be used by any script for temporary
# storage. RAM memory is lost between boot cycles ensuring that even if the
# script fails to clean up after itself, the temporary files will eventually be
# removed. We use this OS mechanism to create a script controlled temporary
# directory that is time stamped and locked down with user only permissions.
# If you choose to remove the temporary directory feature, you will have to
# refactor some of the other boiler plate functions in this script as they
# interact with and use the temporary directory.
#

readonly TEMP_DIR_PATH="/dev/shm/${THIS_SCRIPT_NAME%.*}---${START_EXECUTION_TIMESTAMP}"

#
# Automatic log saving can be very helpful for automated scripts or for
# tracking down issues with a failed script execution, but requires a dedicated
# log directory. This can be overkill for small scripts, so it is disabled by
# default. To enable it, just uncomment the following components.
#
# - 'LOG_DIR_PATH' variable.
# - 'LOG_FILE_PATH' variable.
# - 'setup_log_saving' function.
# - 'on_unhandled_error' function.
#

#readonly LOG_DIR_PATH="/dev/shm/${THIS_SCRIPT_NAME%.*}/logs"
#readonly LOG_FILE_PATH="${LOG_DIR_PATH}/log.${START_EXECUTION_TIMESTAMP}"

#
# Declaring an arguments array and an options dictionary to store parsed
# command line arguments and options in. They are global so we can avoid
# unnecessary dependency injection as many different functions will likely
# use them. Each defined option should have a default so the script can have
# a default execution path if the user does not supply any options. Both
# variables should be modified only in the 'parse_command_line' function.
# All other code should treat these variables as 'readonly'.
#

declare -a ARGUMENTS
declare -A OPTIONS
OPTIONS[NEED_HELP]="no"
OPTIONS[DEMO_OPT_A]="no"
OPTIONS[DEMO_OPT_B]=""

#
# Declaring a manual page template that can be modified to describe script
# usage. Don't forget to update this to express changes made to the options
# dictionary, argument array, or 'parse_command_line' logic.
#

MANUAL_PAGE_TEMPLATE="$(cat <<'EOF'
    MANUAL_PAGE
        @{SCRIPT_NAME}

    USAGE
        @{SCRIPT_NAME} [optons] [argument...]

    DESCRIPTION
        This is a BASH script template that can be copied and modified when
        you need to make a new script. It includes the following features.

        - Improved error detection and handling bahavior.
        - Infrastructure to parse the command line for options and arguments.
        - Logging that supports colors and the option to automatically log to
          a file.
        - Temporary storage that can be used for staging or intermediate file
          operations and is automatically cleaned when script exection finishes.
        - The ability to trace individual commands or pipe lines.
        - Early termination via an 'abort' function.
        - Demo 'main' function showing off some of the above features.

        Any feature that is not needed can easily be removed.

    OPTIONS
        -h|--help
            Show this manual page.

        -a|--demo-opt-a
            An option that represents a boolean flag.

        -b|--demo-opt-b <value>
            An option that represents a named parameter.

    ARGUMENTS
        [demo-argument...]
            An optional list of arguments.

    END
EOF
)"

#
# Modify this function to parse supported options and positional arguments.
#

function parse_command_line()
{
    #
    # Parse options.
    #

    while [ $# -gt 0 ]
    do
        local opt="${1}"

        case "${opt}" in
            -h|--help)
                shift
                OPTIONS[NEED_HELP]="yes"
                return 0
                ;;
            -a|--demo-opt-a)
                shift
                OPTIONS[DEMO_OPT_A]="yes"
                ;;
            -b|--demo-opt-b)
                shift
                if [[ $# -eq 0 ]]
                then
                    log_error "Missing parameter for option '${opt}'."
                    abort
                fi
                local param="${1}"
                shift
                OPTIONS[DEMO_OPT_B]="${param}"
                ;;
            --)
                shift
                break
                ;;
            -?*)
                log_error "Invalid option '${opt}'."
                abort
                ;;
            *)
                break
                ;;
        esac
    done

    #
    # Parse arguments.
    #

    ARGUMENTS=("$@")

    #
    # Check for required or unexpected positional arguments.
    #

    #if [[ ${#ARGUMENTS[@]} -ne 0 ]]
    #then
    #    log_error "Unexpected arguments detected."
    #    abort
    #fi
}

#
# Use these functions instead of 'echo' or 'printf' for all informational
# output. Using these functions not only helps with code readability, but
# each function is also built to work with automatic log saving if it is
# enabled. 'log_error', 'log_warning', 'log_info' can be used for error,
# warning, and info messages respectively. 'logit' can be used directly or
# wrapped in a new logging function for log messages that need one or more
# customizations (ex. specific coloring, custom prefix, etc.).
#

function logit()
{
    local message="${@:-}"
    echo -e "${message[@]}" 1>&3
    echo -e "${message[@]}" | sed -r "s/[[:cntrl:]]\[([0-9]{1,3};)*[0-9]{1,3}m//g" 1>&4
}

function log_error()
{
    local message="${@:-}"
    echo -e "${RED_ON:-}Error: ${message[@]}${COLOR_OFF:-}" 1>&3
    echo -e "Error: ${message[@]}" | sed -r "s/[[:cntrl:]]\[([0-9]{1,3};)*[0-9]{1,3}m//g" 1>&4
}

function log_warning()
{
    local message="${@:-}"
    echo -e "${YELLOW_ON:-}Warning: ${message[@]}${COLOR_OFF:-}" 1>&3
    echo -e "Warning: ${message[@]}" | sed -r "s/[[:cntrl:]]\[([0-9]{1,3};)*[0-9]{1,3}m//g" 1>&4
}

function log_info()
{
    local message="${@:-}"
    echo -e "${GREEN_ON:-}Info: ${message[@]}${COLOR_OFF:-}" 1>&3
    echo -e "Info: ${message[@]}" | sed -r "s/[[:cntrl:]]\[([0-9]{1,3};)*[0-9]{1,3}m//g" 1>&4
}

#
# Use this function to abort script execution when an unrecoverable error
# scenario is encountered.
#

function abort()
{
    local exit_code="${1:-1}"
    logit "${RED_ON:-}Aborting execution.${COLOR_OFF:-}"
    exit $(( ${exit_code} ))
}

function check_bash_version()
{
    if [[ "$(printf "${BASH_VERSION}\n${MINIMUM_BASH_VERSION}" | sort -V | head -n 1)" != "${MINIMUM_BASH_VERSION}" ]]
    then
        log_error "This script depends on BASH version ${MINIMUM_BASH_VERSION} or better."
        abort
    fi
}

function cleanup()
{
    trap - SIGINT SIGTERM ERR EXIT
    rm -rf "${TEMP_DIR_PATH}"
}

function setup_temp_dir()
{
    mkdir -p "${TEMP_DIR_PATH}"
    chmod 700 "${TEMP_DIR_PATH}"
    trap cleanup SIGINT SIGTERM ERR EXIT
}

function setup_logger_fds()
{
    exec 3>&2
    exec 4>/dev/null
}

function setup_logger_color_formatters()
{
    if [[ -t 2 ]] && [[ -z "${NO_COLOR:-}" ]] && [[ "${TERM:-}" != "dumb" ]]
    then
        COLOR_OFF="\033[0m"
        RED_ON="\033[0;31m"
        ORANGE_ON="\033[0;33m"
        YELLOW_ON="\033[1;33m"
        GREEN_ON="\033[0;32m"
        CYAN_ON="\033[0;36m"
        BLUE_ON="\033[0;34m"
        PURPLE_ON="\033[0;35m"
    else
        COLOR_OFF=""
        RED_ON=""
        ORANGE_ON=""
        YELLOW_ON=""
        GREEN_ON=""
        CYAN_ON=""
        BLUE_ON=""
        PURPLE_ON=""
    fi
}

#function on_unhandled_error()
#{
#    local line_number=${1}
#    trap - ERR
#    log_error "Unhandled error on line ${line_number}."
#    abort
#}

#function setup_log_saving()
#{
#    mkdir -p "${LOG_DIR_PATH}"
#    exec 1>"${LOG_FILE_PATH}"
#    exec 2>&1
#    exec 4>&1
#    trap 'on_unhandled_error ${LINENO}' ERR
#}

function setup_logger()
{
    setup_logger_fds
    setup_logger_color_formatters

    if declare -F "setup_log_saving" 1>/dev/null
    then
        setup_log_saving
    fi
}

function init()
{
    check_bash_version
    setup_temp_dir
    setup_logger 
}

function show_manual_page()
{
    local manual_page_path="${TEMP_DIR_PATH}/manual-page.txt"

    echo "${MANUAL_PAGE_TEMPLATE}" 1>"${manual_page_path}"

    #
    # Remove leading spaces.
    #

    sed -ri "s/^\s{4}//" "${manual_page_path}"

    #
    # Fill in template fields.
    #

    sed -ri "s/@\{SCRIPT_NAME\}/${THIS_SCRIPT_NAME}/g" "${manual_page_path}"

    cat "${manual_page_path}" 1>&3
    cat "${manual_page_path}" 1>&4
}

function main()
{
    if [[ "${OPTIONS[NEED_HELP]}" == "yes" ]]
    then
        show_manual_page
        return 0
    fi

    log_info "Hello from '${THIS_SCRIPT_NAME}'. Below are some examples of script features."

    logit "----"
    logit "Example: Manual page."
    logit "Run this script with the '-h' or '--help' option to the manual page you can modify."
    logit "----"

    logit "----"
    logit "Example: Logging with colors."
    logit "Taste the ${RED_ON}r${COLOR_OFF}${ORANGE_ON}a${COLOR_OFF}${YELLOW_ON}i${COLOR_OFF}${GREEN_ON}n${COLOR_OFF}${CYAN_ON}b${COLOR_OFF}${BLUE_ON}o${COLOR_OFF}${PURPLE_ON}w${COLOR_OFF}!"
    logit "----"

    logit "----"
    logit "Example: Tracing commands."
    xtrace_on
    pwd -P
    xtrace_off
    logit "----"

    logit "----"
    logit "Example: Using temporary storage."
    xtrace_on
    ls -1v "${TEMP_DIR_PATH}"
    touch "${TEMP_DIR_PATH}/my-file"
    ls -1v "${TEMP_DIR_PATH}"
    xtrace_off
    echo "Run 'ls -1v ${TEMP_DIR_PATH}' after script execution to verify the temp directory is gone."
    logit "----"

    logit "----"
    logit "Example: Options and arguments."
    logit "Re-run the script with various options and arguments to see how the values below change."
    logit "demo-opt-a: ${OPTIONS[DEMO_OPT_A]}"
    logit "demo-opt-b: ${OPTIONS[DEMO_OPT_B]}"
    logit "demo argument count: ${#ARGUMENTS[@]}"
    logit "demo argument list: ${ARGUMENTS[@]}"
    logit "----"
}

init
parse_command_line "$@"
main

#! /usr/bin/env bash

# The shell options below improve the script's exception detection and handling
# behavior by aborting execution when a command, function, or sub-shell
# returns a non-zero return code or attempts to use an unset varible. Without
# these shell options, the script may continue to execute when any
# of the above situations occur which is usually an undesirable side effect.
# Enabling these options does not prevent you from writing script code where
# you expect a command to fail or a variable to be unset. You just have to
# explicitly handle each of those scenarios with conditional checks in the
# case of non-zero return codes and the variable default value syntax in the
# case of unset variables.

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

# Sometimes it is useful to log the full command or pipe line that being
# executed for reference later. This can be done by enabling the shell option
# 'xtrace', but enabling it for the entire script makes the output very messy.
# The aliases below can be used to wrap just the commands you care to
# log to script output which will keep the script output clean. It is strongly
# recommended to not use these aliases to wrap calls to functions or other
# scripts as the trace output will include the full content of the function or
# script call.

shopt -s expand_aliases
alias xtrace_on='{ set -x; } 1>/dev/null 2>&1'
alias xtrace_off='{ set +x; } 1>/dev/null 2>&1'

# A set of 'readonly' variables that contain information useful in almost
# any script.

readonly MINIMUM_BASH_VERSION="4.1.0"
readonly THIS_SCRIPT_INVOKED_DATE_TIME="$(date +D%Y-%m-%d_T%H-%M-%S)"
readonly THIS_SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly THIS_SCRIPT_DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# A readonly variable to set a project directory. Feel free to set this to
# a specific working location that fits your needs.

readonly PROJECT_DIR_PATH="$(cd "${THIS_SCRIPT_DIR_PATH}/.." && pwd -P)"

# Sometimes it is useful to know which user invoked this script.
readonly THIS_SCRIPT_INVOKING_USER="{SUDO_USER:-${USER:-$(whoami)}}"

# Many times there is a need to have a temporary space to perform file
# manipulations, staging, etc. There are two filesystem paths we can
# use for temporary storage. The first is the commonly known '/tmp'
# path. It exists specifically for temporary file storage, can be resized
# if more space is needed, and eventually gets cleaned out automatically
# by the OS. The one drawback is not knowing exactly when the clean out
# will take place. It is subject to OS configuration. The second option is
# to use '/dev/shm'. It is a RAM backed temporary filesystem that is accessible
# to all users. Being RAM backed guarantees that it will be emptied after a
# system reboot. The drawback being that it can only be as big as
# the amount of RAM in your system. Either path will work, so choose one that
# suits your needs.

#readonly TEMP_DIR_PATH="/tmp/${THIS_SCRIPT_INVOKING_USER}/${THIS_SCRIPT_NAME}/${THIS_SCRIPT_INVOKED_DATE_TIME}"
readonly TEMP_DIR_PATH="/dev/shm/${THIS_SCRIPT_INVOKING_USER}/${THIS_SCRIPT_NAME}/${THIS_SCRIPT_INVOKED_DATE_TIME}"

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

# Having a global options dictionary and arguments array is useful to store
# command line arguments and options in. They are global so we can avoid
# unnecessary dependency injection since many functions will will use them.
# Each option in the options dictionary should be set to a default value so
# the script can have a default execution path. Both the options dictionary
# and the arguments array should only be modified in the 'parse_command_line'
# function. All other code should treat these variables as 'readonly'.

declare -a ARGUMENTS
declare -A OPTIONS

OPTIONS[NEED_HELP]="no"
OPTIONS[DEMO_OPT_A]="no"
OPTIONS[DEMO_OPT_B]="foo"

# Declaring a manual page template that can be modified to describe script
# usage. Don't forget to update this when options and arguments are added
# or removed in the 'parse_command_line' function.

MANUAL_PAGE_TEMPLATE="$(cat <<'EOF'
    MANUAL_PAGE
        @{SCRIPT_NAME}

    USAGE
        @{SCRIPT_NAME} [optons] [<argument> ...]

    DESCRIPTION
        Script description goes here.

    OPTIONS
        -h|--help
            Show this manual page.

        -a|--demo-opt-a
            An option that represents a boolean flag.

        -b|--demo-opt-b <value>
            An option that represents an optional parameter.

    ARGUMENTS
        <argument>
            An example argument.

    END
EOF
)"

# Modify this function to parse supported options and positional arguments.

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

# Use these functions instead of 'echo' or 'printf' for all informational
# output. Using these functions not only helps with code readability, but
# each function is also built to work with automatic log saving and terminal
# colors if you enable either of those features. 'log_error', 'log_warning',
# and 'log_info' can be used for error, warning, and info messages
# respectively. 'logit' can be used directly or wrapped in a new logging
# function to customize the output (ex. specific coloring, custom prefix, etc.).

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

# Use this function to abort script execution when an unrecoverable error
# scenario is encountered.

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

function cleanup_temp_dir()
{
    trap - SIGINT SIGTERM ERR EXIT
    rm -r "${TEMP_DIR_PATH}"
}

function setup_temp_dir()
{
    mkdir -p "${TEMP_DIR_PATH}"
    chmod 700 "$(dirname "$(dirname "${TEMP_DIR_PATH}")")"
    trap cleanup_temp_dir SIGINT SIGTERM ERR EXIT
}

function setup_logger_fds()
{
    # FD[1] = command stdout (goes to log file when automatic log saving is enabled)
    # FD[2] = command stderr (goes to log file when automatic log saving is enabled)
    # FD[3] = script stdout + stderr
    # FD[4] = script stdout + stderr to log file if automatic log saving is enabled

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
    
    # Control Sequence Introducer (CSI) bytes.
    local csi="$(printf '\e[')"

    # Select Graphics Rendition (SGR) functions.
    local text_foreground_color="${csi}38;5;%dm"
    local text_background_color="${csi}48;5;%dm"
    local color_reset="${csi}0m"

    # Specific function calls.
    local text_foreground_color_white="$(printf "${text_foreground_color}" "231")"
    local text_foreground_color_black="$(printf "${text_foreground_color}" "232")"

    # Print the colors.
    for i in {0..255}
    do
        local text_background_color_i="$(printf "${text_background_color}" "${i}")"
        printf "${text_background_color_i}${text_foreground_color_white}%03d ${text_foreground_color_black}%03d${color_reset}" "${i}" "${i}"
        printf " "

        if ((( i < 16 )) && (( i % 8 == 7 ))) || ((( i > 15 )) && (( (i-15) % 6 == 0 )))
        then
            printf "\n";
        fi
    done
}

init
parse_command_line "$@"
main

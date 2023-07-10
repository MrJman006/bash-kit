#! /usr/bin/env bash

#
# Setting the shell options below to improve the script's behavior by aborting
# script execution when a command returns a non-zero return code or when an
# unset varible is used. This can prevent undesirable side effects caused by
# commands that are not expected to fail. These options do not prevent you
# from writing script code where you expect a command to fail or a variable
# to be unset some of the time. You just have to use conditional checks with
# commands you expect to fail and the default variable value syntax
# (i.e. ${<var-name>:-[default-value]}) without passing a default value.
#

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

readonly START_EXECUTION_TIMESTAMP="$(date +%Y-%m-%d-%H-%M-%S)"
readonly THIS_SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly PROJECT_DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

#
# A temporary directory is provided in case the script needs to create and
# use temporary files and sub-directories. The base path is '/dev/shm' which
# is a tempory filesystem mount point that uses RAM as the store. This ensures
# all things put in the temporary directory will actually be temporary, at
# least between boot cycles. We still trap into a cleanup function to attempt to
# make everyting temporary between execustions as well.
#

readonly TEMP_DIR_PATH="/dev/shm/${THIS_SCRIPT_NAME%.*}/tmp/${START_EXECUTION_TIMESTAMP}"
mkdir -p "${TEMP_DIR_PATH}"

trap cleanup SIGINT SIGTERM ERR EXIT

function cleanup()
{
    trap - SIGINT SIGTERM ERR EXIT
    rm -rf "${TEMP_DIR_PATH}"
}

#
# Adding a logger function for all output that is not command output. The
# logger logs to FD[3] and FD[4] in case log saving is enabled. FD[3] points
# to STDERR because it supports colors. FD[4] points to '/dev/null' unless
# log saving is enabled in which case it will point to the log file.
#

exec 3>&2
exec 4>/dev/null

function logit()
{
    local message="${@:-}"
    echo -e "${message[@]}" 1>&3
    echo -e "${message[@]}" 1>&4
}

readonly FD_2=2

if [[ -t ${FD_2} ]] && [[ -z "${NO_COLOR:-}" ]] && [[ "${TERM:-}" != "dumb" ]]
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

#
# Call abort for all scenarios where you don't want script exectuion to
# continue.
#

function abort()
{
    local message="${1}"
    local exit_code="${2:-1}"
    logit "${message}"
    exit $(( ${exit_code} ))
}

#
# Log saving can be very helpful for automated scripts or for tracking down
# issues with a failed script execution, but requires a dedicated log directory.
# This can be overkill for small manually run scripts. Just remove the log
# saving setup below if you don't want log saving.
#

#readonly LOG_DIR_PATH="/dev/shm/${THIS_SCRIPT_NAME%.*}/logs"
#mkdir -p "${LOG_DIR_PATH}"

#readonly LOG_FILE_PATH="${LOG_DIR_PATH}/log.${START_EXECUTION_TIMESTAMP}"

#exec 1>"${LOG_FILE_PATH}"
#exec 2>"${LOG_FILE_PATH}"
#exec 4>"${LOG_FILE_PATH}"

#trap 'on_unhandled_error ${LINENO}' ERR

#function on_unhandled_error()
#{
#    local line_number=${1}
#    trap - ERR
#    abort "Error: Unhandled error on line ${line_number}."
#}

#
# Sometimes it is useful to see the full command that is being executed in the
# logs prior to command output. Wrapping a command with the 'xtrace_*' aliases
# will print the command to the log before it is executed. You should only wrap
# individual commands or individual pipe lines. It is not recommended to wrap
# function calls or large blocks of code as the output become cluttered.
# The last return code before calling 'xtrace_off' is preserved.
#

shopt -s expand_aliases

alias xtrace_on='{ set -x; } 1>/dev/null 2>&1'

alias xtrace_off='{ set +x; } 1>/dev/null 2>&1'

#
# Check that the current version of BASH is 4.1.0 or better as some of the
# features used in this script will fail on older versions of BASH.
#

if [[ "$(printf "${BASH_VERSION}\n4.1.0" | sort -V | head -n 1)" != "4.1.0" ]]
then
    abort "Error: This script depends on BASH version 4.1.x or better. Aborting execution."
fi

MANUAL_PAGE_TEMPLATE="$(cat <<'EOF'
    MANUAL_PAGE
        @{SCRIPT_NAME}

    USAGE
        @{SCRIPT_NAME} [optons] [argument...]

    DESCRIPTION
        This is a BASH script template that can be copied and modified when
        you need to make a new script. It includes the following features.

        - A set of BASH options to improve the scripts error detection bahavior.
        - Command line parsing of options and arguments.
        - Logging that supports colors and the option to save log files
          automatically.
        - Temporary storage that can be used for staging or intermediate file
          operations.
        - Command tracing capability.
        - Early termination via an 'abort' function.
        - Unhandled error notification with line number support.

    OPTIONS
        -h|--help
            Show this manual page.

        -a|--test-opt-a
            A test option that is just a flag.

        -b|--test-opt-b <value>
            A test option that accepts a parameter.

    ARGUMENTS
        [argument...]
            An optional list of arguments.

    END
EOF
)"

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

#
# Declare an options dictionary with a default value for each supported option
# and an arguments array so all code in the script can easily access both
# without dependency injection. Only the 'parse_command_line' function should
# modify these variables. All other code should treat them as 'readonly'.
#

declare -A OPTIONS

OPTIONS[NEED_HELP]="no"
OPTIONS[TEST_OPT_A]="no"
OPTIONS[TEST_OPT_B]=""

declare -a ARGUMENTS

function parse_command_line()
{
    #
    # Parse options.
    #

    while [ $# -gt 0 ]
    do
        case "${1}" in
            -h|--help)
                shift
                OPTIONS[NEED_HELP]="yes"
                return 0
                ;;
            -a|--test-opt-a)
                shift
                OPTIONS[TEST_OPT_A]="yes"
                ;;
            -b|--test-opt-b)
                shift
                OPTIONS[TEST_OPT_B]="${1}"
                shift
                ;;
            --)
                shift
                break
                ;;
            -?*)
                abort "Error: Invalid option '${1}'. Aborting execution. Need --help?"
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
    # Check for required arguments.
    #

    #if [[ ${#ARGUMENTS[@]} -ne 0 ]]
    #then
    #    abort "Error: Unexpected arguments detected. Aborting execution."
    #fi
}

function main()
{
    if [ "${OPTIONS[NEED_HELP]}" == "yes" ]
    then
        show_manual_page
        return 0
    fi

    logit "Hello from '${THIS_SCRIPT_NAME}'. Below are some examples of script features."

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
    touch "${TEMP_DIR_PATH}/my-file"
    ls -1v "${TEMP_DIR_PATH}"
    xtrace_off
    echo "Run 'ls -1v ${TEMP_DIR_PATH}' after script execution to verify the temp directory is gone."
    logit "----"

    logit "----"
    logit "Example: Options and arguments."
    logit "Re-run the script with various options and arguments to see how the values below change."
    logit "test-opt-a: ${OPTIONS[TEST_OPT_A]}"
    logit "test-opt-b: ${OPTIONS[TEST_OPT_B]}"
    logit "argument count: ${#ARGUMENTS[@]}"
    logit "argument list: ${ARGUMENTS[@]}"
    logit "----"
}

parse_command_line "$@" && main

# Verify commands before execution with !<history-number>.
shopt -s histverify

# Search the history
alias hg="history | grep -P"

# Clean history logging.
HISTCONTROL=ignorespace:erasedups

# Increase bash history file size.
export HISTFILESIZE=10000
export HISTSIZE=10000

# History logging.
function jcd_log_command()
{
    local date_invoked="$(date +%Y-%m-%d)"
    local time_invoked="$(date +%H-%M-%S)"
    local terminal_id="$(tty)"
    local working_dir_path="$(pwd -P)"
    local effective_user="${USER}"
    local real_user="${SUDO_USER:-${USER}}"
    local user_home_dir_path="$(getent passwd ${real_user} | cut -d ":" -f 6)"
    local history_log_file_path="${user_home_dir_path}/.history-log"

    #
    # Get the current command.
    #

    local current_command="$(history 1 | sed -r "s/^\s+//" | tr -s " " | cut -d " " -f 2-)"

    #
    # Skip over commands that change or list directories.
    #

    local -a skip_list
    skip_list+=("ls")
    skip_list+=("ll")
    skip_list+=("ll.*")
    skip_list+=("cd")
    skip_list+=("pushd")
    skip_list+=("popd")
    skip_list+=("goto")
    skip_list+=("pwd")

    local cmd
    for cmd in "${skip_list[@]}"
    do
        if $(echo "${current_command}" | grep -Pq "^\s") ||
            $(echo "${current_command}" | grep -Pq "(^|sudo\s)${cmd}")
        then
            return
        fi
    done

    #
    # Skip over immediately duplicated commands.
    #

    if [[ -f "${history_log_file_path}" ]]
    then
        local last_command="$(tail -n 9 "${history_log_file_path}" | head -n 1)"
        if [[ "${current_command}" == "${last_command}" ]]
        then
            return
        fi
    fi

    #
    # Log command.
    #

    echo "--"                                           1>>"${history_log_file_path}"
    echo "${current_command}"                           1>>"${history_log_file_path}"
    echo ""                                             1>>"${history_log_file_path}"
    echo "    date invoked: ${date_invoked}"            1>>"${history_log_file_path}"
    echo "    time invoked: ${time_invoked}"            1>>"${history_log_file_path}"
    echo "    terminal id: ${terminal_id}"              1>>"${history_log_file_path}"
    echo "    working directory: ${working_dir_path}"   1>>"${history_log_file_path}"
    echo "    real user: ${real_user}"                  1>>"${history_log_file_path}"
    echo "    effective user: ${effective_user}"        1>>"${history_log_file_path}"
    echo "--"                                           1>>"${history_log_file_path}"
}

if ! $(echo "${PROMPT_COMMAND}" | grep -Pq "(^|;)jcd_log_command;")
then
    export PROMPT_COMMAND="${PROMPT_COMMAND}jcd_log_command;"
fi

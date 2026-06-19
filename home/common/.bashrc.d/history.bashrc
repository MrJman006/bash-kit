# Store more history in memory and on disk.
export HISTSIZE=500000
export HISTFILESIZE=500000

# Don't overwrite history.
shopt -s histappend

# Control what gets logged.
HISTCONTROL=ignoredups
HISTIGNORE="ls:ll:lla:pwd:history:hg"
shotp -s cmdhist

# Sync history immediately and don't overwrite old history.
if ! $(type __hist_sync 1>/dev/null 2>&1)
then
    function __hist_sync()
    {
        history -a
        history -c
        history -r
    }
    export PROMPT_COMMAND="__hist_sync;${PROMPT_COMMAND}"
fi

# Timestamped history output.
HISTTIMEFORMAT="%F %T: "

# Verify commands before execution with !<history-number>.
shopt -s histverify

# Search the history
alias hg="history | grep -i"

# Custom detailed history logging.
if ! $(type __hist_sync_detailed 1>/dev/null 2>&1)
then
    function __hist_sync_detailed()
    {
        local invoked_date="$(date +%Y-%m-%d)"
        local invoked_time="$(date +%H-%M-%S)"
        local invoked_terminal="$(tty)"
        local invoked_path="$(pwd -P)"
        local invoked_effective_user="${USER}"
        local invoked_real_user="${SUDO_USER:-${USER}}"
        local detailed_history_log_file_path="${HOME}/.bash_history_detailed"

        # Get the current command.
        local current_command="$(history 1)"

        # Skip over commands that don't add value when reviewed later.
        local -a skip_list
        skip_list+=("ls")
        skip_list+=("ll")
        skip_list+=("ll.*")
        skip_list+=("cd")
        skip_list+=("pushd")
        skip_list+=("popd")
        skip_list+=("pwd")

        local cmd
        for cmd in "${skip_list[@]}"
        do
            if $(echo "${current_command}" | grep -Eq "^${cmd}\s")
            then
                return 0
            fi
        done

        # Skip over immediately duplicated commands.
        if [ -f "${detailed_history_log_file_path}" ]]
        then
            local last_command="$(tail -n 9 "${detailed_history_log_file_path}" | head -n 1)"
            if [[ "${current_command}" == "${last_command}" ]]
            then
                return 0
            fi
        fi

        # Log command.
        echo "--------"                                       1>>"${detailed_history_log_file_path}"
        echo "${current_command}"                             1>>"${detailed_history_log_file_path}"
        echo "    date invoked: ${invoked_date}"              1>>"${detailed_history_log_file_path}"
        echo "    time invoked: ${invoked_time}"              1>>"${detailed_history_log_file_path}"
        echo "    terminal id: ${invoked_terminal}"           1>>"${detailed_history_log_file_path}"
        echo "    working directory: ${invoked_path}"         1>>"${detailed_history_log_file_path}"
        echo "    real user: ${invoked_real_user}"           1>>"${detailed_history_log_file_path}"
        echo "    effective user: ${invoked_effective_user}" 1>>"${detailed_history_log_file_path}"
        echo "--------"                                       1>>"${detailed_history_log_file_path}"
    }
    export PROMPT_COMMAND="__hist_sync_detailed;${PROMPT_COMMAND}"
fi

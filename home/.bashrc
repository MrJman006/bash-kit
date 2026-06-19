#
# Source system wide settings.
#

SYSTEM_BASHRC_FILE_PATH="/etc/bashrc"
if [[ -f "${SYSTEM_BASHRC_FILE_PATH}" ]]
then
    source "${SYSTEM_BASHRC_FILE_PATH}"
fi

#
# Source user specific settings.
#

USER_BASHRC_SNIPPETS_DIR_PATH="${HOME}/.bashrc.d"
if [[ -d "${USER_BASHRC_SNIPPETS_DIR_PATH}" ]]
then
    while read BASHRC_SNIPPET
    do
        source "${BASHRC_SNIPPET}"
    done < <(find "${USER_BASHRC_SNIPPETS_DIR_PATH}" -name "*.bashrc" )
fi

#
# Source terminal startup file.
#

TERMINAL_NUMBER="$(ps -e -o pid,ppid,command | grep -P "bash$" | sed -r "s/^\s+//" | tr -s " " | cut -d " " -f 1 | sort -n | grep -n "$$" | cut -d ":" -f 1)"
TERMINAL_STARTUP_FILE_PATH="${HOME}/.terminal-startup.${TERMINAL_NUMBER}"
if [[ -f "${TERMINAL_STATUP_FILE_PATH}" ]]
then
    source "${TERMINAL_STATUP_FILE_PATH}"
    rm "${TERMINAL_STATUP_FILE_PATH}"
fi

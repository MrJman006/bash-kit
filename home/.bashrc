# Source system wide settings.
if [ -f "/etc/bashrc" ]
then
    source "/etc/bashrc"
fi

# Source user specific settings.
if [ -d "${HOME}/.bashrc.d" ]
then
    for SNIPPET in $(find "${HOME}/.bashrc.d" -type f -name "*.bash")
    do
        source "${SNIPPET}"
    done
fi

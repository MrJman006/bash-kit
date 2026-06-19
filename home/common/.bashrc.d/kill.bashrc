function jcd_kill()
{
    local target="${1}"
    local process
    local pid

    if [[ "${target}" == "" ]]
    then
        return 1
    fi

    if $(echo "${target}" | grep -Pq "^[0-9]+$")
    then
        pid="${target}"
    else
        process="$(ps -e -o pid,ppid,command | grep -P "${target}" | grep -v "grep" | head -n 1)"

        if [[ "${process}" == "" ]]
        then
            return 1
        fi

        echo "process: ${process}"
        pid="$(echo "${process}" | sed -r "s/^\s+//" | tr -s " " | cut -d " " -f 1)"
    fi

    if [[ "${pid}" != "" ]]
    then
        echo "pid: ${pid}"
        command kill -9 ${pid}
    fi
}

function jcd_killall()
{
    local -a targets
    targets=("$@")

    for target in "${targets[@]}"
    do
        local process="$(ps -e -o pid,ppid,command | grep -P "${target}" | grep -v "grep" | head -n 1)"

        while [ "${process}" != "" ]
        do
            jcd_kill "${target}"
            process="$(ps -e -o pid,ppid,command | grep -P "${target}" | grep -v "grep" | head -n 1)"
        done
    done
}

alias kill="jcd_kill"
alias killall="jcd_killall"

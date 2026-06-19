function jcd_format_seconds()
{
    local show_usage="no"

    echo "$@" | grep -Pq "(^|\s+)(-h|--help)(\s+|$)"
    if [[ $? -eq 0 ]]
    then
        show_usage="yes"
    fi

    if [[ $# -ne 1 ]]
    then
        show_usage="yes"
    fi

    if [[ "${show_usage}" == "yes" ]]
    then
        echo "usage: format_seconds [-h|--help] <seconds>"
        return 1
    fi

    local seconds=$((${1}))

    local d=$(( seconds / 60 / 60 / 24 ))
    local h=$(( seconds / 60 / 60 % 24 ))
    local m=$(( seconds /60 % 60 ))
    local s=$(( seconds % 60 ))

    [ ${d} -ne 0 ] && printf "%02dd:" $D || printf "00d:"
    [ ${h} -ne 0 ] && printf "%02dh:" $H || printf "00h:"
    [ ${m} -ne 0 ] && printf "%02dm:" $M || printf "00m:"
    [ ${s} -ne 0 ] && printf "%02ds" $S || printf "00s"
}


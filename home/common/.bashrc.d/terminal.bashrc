function set_term_title()
{
    local title="${1:-}"

    if [[ "${title}" == "" ]]
    then
        return 0
    fi

    printf "\e]0;${title}\a"
}

function jcd_file_count()
{
    #
    # Check for usage option.
    #

    local show_usage="no"
    
    if $(echo "$@" | grep -Pq "(^|\s+)(-h|--help)(\s+|$)")
    then
        show_usage="yes"
    fi

    if [[ "${show_usage}" == "yes" ]]
    then
        echo "MANUAL PAGE"
        echo "    file_count"
        echo ""
        echo "USAGE"
        echo "    file_count [options] [path]"
        echo ""
        echo "DESCRIPTION"
        echo "    file_count counts the number of files in a directory path. If no"
        echo "    directory path is supplied, the current working directory is used."
        echo ""
        echo "OPTIONS"
        echo "    -h|--help"
        echo "        Show this manual page."
        echo ""
        echo "    -r|--recursive"
        echo "        Count files recursively."
        echo ""
        echo "ARGUMENTS"
        echo "    [path]"
        echo "        A path to count files in."
        echo ""
        echo "END"

        return 1
    fi

    #
    # Parse options.
    #

    local -A options

    options[recursive]="no"

    while [ 1 ]
    do
        local token="${1}"
        case "${token}" in
            -r|--recursive)
                shift
                options[recursive]="yes"
                ;;
            --)
                shift
                ;;
            -?)
                echo "Invalid option '${token}'"
                return 1
                ;;
            *)
                break
                ;;
        esac
    done

    #
    # Parse arguments.
    #

    local arguments=("$@")

    #
    # Get the directory path.
    #

    local path

    if [[ ${#arguments[@]} -eq 0 ]]
    then
        path="$(pwd -P)"
    elif [[ ! -d "${arguments[0]}" ]]
    then
        echo "Error: The supplied directory path does not exist."
        return 1
    else
        path="$(cd "${arguments[0]}" && pwd -P)"
    fi

    #
    # Count files.
    #

    if [[ "${options[recursive]}" == "yes" ]]
    then
        printf "File Count: %d\n" $(find "${path}" -type f | wc -l)
    else
        printf "File Count: %d\n" $(find "${path}" -maxdepth 1 -type f | wc -l)
    fi
}


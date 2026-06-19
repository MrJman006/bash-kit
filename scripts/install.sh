#! /usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

readonly INVOKED_DATE_TIME="$(date +D%Y-%m-%d_T%H-%M-%S)"
readonly THIS_SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly THIS_SCRIPT_DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly CURRENT_USER="${SUPER_USER:-${USER:-$(whoami)}}"

declare -A CTX
CTX[BACKUP_DIR]=".bash-kit/${INVOKED_DATE_TIME}"

function install()
{
    local repo_module="${1}"
    local install_prefix="${2}"

    echo "-- Installing module '${repo_module}'."

    for module_item in $(git ls-files "${repo_module}" | sed "s|^${repo_module}/||")
    do
        echo "    item: ${module_item}"
        
        if(-e "${install_prefix}/${module_item}")
        then
            echo "        backing up existing item."
            mkdir -p "${install_prefix}/${CTX[BACKUP_DIR]}/$(dirname "${module_item}")"
            cp "${install_prefix}/${module_item}" "${install_prefix}/${CTX[BACKUP_DIR]}/${module_item}"
        fi

        echo "        installing item."
        mkdir -p "${install_prefix}/$(dirname "${module_item}")"
        cp "${repo_module}/${module_item}" "${install_prefix}/${module_item}"
    done
}

function main()
{
    install home/common "${HOME}"
    install workspace "${HOME}/Workspace"

    if [ -e /c/Windows ]
    then
        install home/msys2 "${HOME}"
    fi

    if [ -e /etc/os-release]
    then
        install home/linux "${HOME}"
    fi
}

main
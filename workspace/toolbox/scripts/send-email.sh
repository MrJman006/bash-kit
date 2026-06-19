#! /usr/bin/env bash

######## Variables ########

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

SMTP_SERVER_ADDRESS="smtps://smtp.gmail.com:465"

NETRC_FILE_PATH="${HOME}/.local/etc/netrc"

MANUAL_PAGE_TEMPLATE="$(cat <<'EOF'
    MANUAL PAGE
        @{SCRIPT_NAME}

        This script sends an email using the gmail account configured in
        '${HOME}/.local/etc/netrc'.

    USAGE
        @{SCRIPT_NAME} [options] <mail-content-file> <recipent-email>

    OPTIONS
        -h|--help
            Print this manual page.

    ARGUMENTS
        <mail-content-file>
            A file containing an email to send. The file must be in the format
            shown in 'EMAIL CONTENT FILE FORMAT'.

        <recipient>
            An email address to send the email to. Sending to yourself is valid.

    EMAIL CONTENT FILE FORMAT
        Email content files must have the following format.

            ---- BEGIN FORMAT - DO NOT INCLUDE THIS LINE ----
            From: "name here" <email here>
            To: "name here" <email here>
            Subject: Subject here

            Email body text here.
            More email body text here.
            ---- END FORMAT - DO NOT INCLUDE THIS LINE ----

    NETRC FILE FORMAT
        The netrc file must contain GMail login credentials. Use app passwords not your
        account password.

            ---- BEGIN FORMAT - DO NOT INCLUDE THIS LINE ----
            machine smtp.gmail.com
            login <your email here>
            password <your app password here>
            ---- END FORMAT - DO NOT INCLUDE THIS LINE ----

    END
    
EOF
)"

######## Functions ########

fn_show_manual_page()
{
    local TEMP_FILE="$(mktemp -p "/dev/shm")"
    printf "${MANUAL_PAGE_TEMPLATE}" 1>"${TEMP_FILE}"
    sed -r -i \
\
        -e "s/^\s{4}//" \
\
        -e "s/@\{SCRIPT_NAME\}/${SCRIPT_NAME}/g" \
\
        "${TEMP_FILE}"
    cat "${TEMP_FILE}"
    rm "${TEMP_FILE}"
}

fn_parse_sender_email()
{
    SNIPPET="$(cat "${HOME}/.local/etc/netrc" | grep -P "^login" | tail -n 1 | cut -d " " -f 2)"
}

fn_parse_cli()
{
    echo "$@" | grep -Pq "(-h|--help)"
    if [ $? -eq 0 ]
    then
        fn_show_manual_page
        return 1
    fi
        
    if [ $# -lt 2 ]
    then
        echo "Error: Missing arguments. Need --help?"
        return 1
    fi

    EMAIL_CONTENT_FILE_PATH="${1}"
    RECIPIENT_EMAIL="${2}"
}

fn_main()
{
    fn_parse_sender_email
    SENDER_EMAIL="${SNIPPET}"

    curl \
\
        --ssl-reqd \
\
        --url "${SMTP_SERVER_ADDRESS}" \
\
        --netrc-file "${NETRC_FILE_PATH}" \
\
        --mail-from "${SENDER_EMAIL}" \
\
        --mail-rcpt "${RECIPIENT_EMAIL}" \
\
        --upload-file "${EMAIL_CONTENT_FILE_PATH}"
}

######## Script Entry ########

fn_parse_cli "$@" || exit $?
fn_main


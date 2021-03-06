#!/bin/bash


RETRIES=0
MAXRETRIES=5
RETRYSLEEP=4

onexit() {
    return
}

checkpassword() {
    local PASS=${2//$/\\$}
    expect << EOF >/dev/null
spawn su $1 -c "exit"
expect "Password:"
send "${PASS}\r"
expect eof
catch wait result
exit [lindex \$result 3]
EOF
}

header() {
    clear
    cat ~/zsh-files/lock.textart
    echo ""
    echo ""
    echo ""
    echo ""
    if [ "${RETRIES}" -ne 0 ]; then
        echo "Locked by ${USER} (${RETRIES} failed login attempts)"
    else
        echo "Locked by ${USER}"
    fi
}

authenticate() {
    header
    local PASSWORD=""
    local RETRY=0
    while true; do
        read -s -p "Password: " PASSWORD
        echo
        checkpassword ${USER} "${PASSWORD}"
        if [ "$?" -eq 0 ]; then
            echo "Welcome back!"
            echo ""
            exit 0
        else
            RETRIES=$((RETRIES+1))
            RETRY=$((RETRY+1))
            echo "authentication failed!"
            echo ""
            if [ "${RETRY}" -ge "${MAXRETRIES}" ]; then
                RETRY=0
                echo "sleeping for ${RETRYSLEEP}"
                sleep ${RETRYSLEEP}
                header
            fi
        fi
    done
}

trap onexit 1 2 3 15 18 20 ERR
authenticate

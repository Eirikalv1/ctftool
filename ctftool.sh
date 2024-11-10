#!/usr/bin/env bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/challenges"
mkdir -p "$BASE"

CTF_FILE="/tmp/.ctftool"
touch "$CTF_FILE"

help() {
    echo -e "${CYAN}Usage Instructions:${RESET}"
    echo -e "${CYAN}  ctf new <ctfname>${RESET}                 - Create a new CTF with the specified name."
    echo -e "${CYAN}  ctf delete <ctfname>${RESET}              - Delete an existing CTF."
    echo -e "${CYAN}  ctf set <ctfname>${RESET}                 - Set the current CTF directory."
    echo -e "${CYAN}  ctf unset${RESET}                         - Unset the current CTF and challenge."
    echo -e "${CYAN}  ctf list${RESET}                          - List all CTFs available."
    echo -e "${CYAN}  ctf chal new <challenge name>${RESET}     - Create a new challenge in the current CTF."
    echo -e "${CYAN}  ctf chal delete <challenge name>${RESET}  - Delete a challenge in the current CTF."
    echo -e "${CYAN}  ctf chal set <challenge name>${RESET}     - Set the current challenge in the CTF."
    echo -e "${CYAN}  ctf chal unset${RESET}                    - Unset the current challenge in the current CTF."
    echo -e "${CYAN}  ctf chal list${RESET}                     - List all challenges in the current CTF."
}

load_current_ctf() {
    if [ -f "$CTF_FILE" ]; then
        CURRENT_CTF="$(sed -n '1p' $CTF_FILE)"
        CURRENT_CHAL="$(sed -n '2p' $CTF_FILE)"
    else
        CURRENT_CTF=""
        CURRENT_CHAL=""
    fi
}

save_current_ctf() {
    echo "$CURRENT_CTF" > $CTF_FILE
    echo "$CURRENT_CHAL" >> $CTF_FILE
}

ctf_rc() {
    if [ -d "$CURRENT_CHAL" ]; then
        cd $CURRENT_CHAL || return
        echo -e "${BLUE}Navigating to challenge: $CURRENT_CHAL${RESET}"
        return 0
    fi

    if [ -d "$CURRENT_CTF" ]; then
        cd $CURRENT_CTF || return
        echo -e "${BLUE}Navigating to CTF: $CURRENT_CTF${RESET}"
    fi
}

ctf_new() {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: Please provide a name for the new CTF.${RESET}"
        return 1
    fi

    mkdir -p "$BASE/$1"
    echo -e "${GREEN}Success: Created new CTF directory for '$1'.${RESET}"
}

ctf_delete() {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: Please provide the name of the CTF you want to delete.${RESET}"
        return 1
    fi

    if [ -d "$BASE/$1" ]; then
        rm -rfi "$BASE/$1" || return 1

        if [ "$BASE/$1" == "$CURRENT_CTF" ]; then
            CURRENT_CTF=""
            CURRENT_CHAL=""
            save_current_ctf
        fi

        echo -e "${GREEN}Success: CTF '$1' and its contents have been deleted.${RESET}"
    else
        echo -e "${RED}Error: CTF '$1' does not exist. Please check the name and try again.${RESET}"
    fi
}

ctf_set() {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: Please specify a CTF to set as the current CTF.${RESET}"
        return 1
    fi

    if [ ! -d "$BASE/$1" ]; then
        echo -e "${RED}Error: CTF '$1' does not exist. Please ensure the directory exists.${RESET}"
        return 1
    fi

    CURRENT_CTF="$BASE/$1"
    CURRENT_CHAL=""
    cd $CURRENT_CTF || return 1
    save_current_ctf
    echo -e "${GREEN}Success: Current CTF has been set to '$1'.${RESET}"
}

ctf_unset() {
    if [ -z "$CURRENT_CTF" ] && [ -z "$CURRENT_CHAL" ]; then
        echo -e "${YELLOW}No CTF or challenge is currently set. Nothing to unset.${RESET}"
        return 0
    fi

    CURRENT_CTF=""
    CURRENT_CHAL=""
    save_current_ctf
    echo -e "${GREEN}Success: Current CTF and challenge have been unset.${RESET}"
}

ctf_list() {
    echo -e "${CYAN}Listing all available CTFs:${RESET}"

    if [ "$(ls -A "$BASE")" ]; then
        for ctf in "$BASE"/*; do
            if [ -d "$ctf" ]; then
                echo -e "${GREEN}- $(basename "$ctf")${RESET}"
            fi
        done
    else
        echo -e "${YELLOW}No CTFs found in this directory.${RESET}"
    fi
}

ctf_chal_new() {
    if [ ! -d "$CURRENT_CTF" ]; then
        echo -e "${RED}Error: No CTF set. Please set a CTF first using 'ctf set <ctfname>'.${RESET}"
        return 1
    fi

    if [ -z "$1" ]; then
        echo -e "${RED}Error: Please provide a name for the new challenge.${RESET}"
        return 1
    fi

    mkdir -p "$CURRENT_CTF/$1" || return 1
    echo -e "${GREEN}Success: Created new challenge '$1' in CTF '$CURRENT_CTF'.${RESET}"
}

ctf_chal_delete() {
    if [ ! -d "$CURRENT_CTF" ]; then
        echo -e "${RED}Error: No CTF set. Please set a CTF first using 'ctf set <ctfname>'.${RESET}"
        return 1
    fi

    if [ -z "$1" ]; then
        echo -e "${RED}Error: Please provide the name of the challenge you want to delete.${RESET}"
        return 1
    fi

    if [ -d "$CURRENT_CTF/$1" ]; then
        rm -rfi "$CURRENT_CTF/$1" || return 1

        if [ "$CURRENT_CTF/$1" == "$CURRENT_CHAL" ]; then
            CURRENT_CHAL=""
            save_current_ctf
        fi

        echo -e "${GREEN}Success: Challenge '$1' has been deleted from CTF '$CURRENT_CTF'.${RESET}"
    else
        echo -e "${RED}Error: Challenge '$1' does not exist in the current CTF. Please check the name and try again.${RESET}"
    fi
}

ctf_chal_set() {
    if [ ! -d "$CURRENT_CTF" ]; then
        echo -e "${RED}Error: No CTF set. Please set a CTF first using 'ctf set <ctfname>'.${RESET}"
        return 1
    fi

    if [ -z "$1" ]; then
        echo -e "${RED}Error: Please provide the name of the challenge you want to set as the current challenge.${RESET}"
        return 1
    fi

    if [ -d "$CURRENT_CTF/$1" ]; then
        CURRENT_CHAL="$CURRENT_CTF/$1"
        cd $CURRENT_CHAL || return 1
        save_current_ctf
        echo -e "${GREEN}Success: Challenge '$1' has been set as the current challenge in CTF '$CURRENT_CTF'.${RESET}"
    else
        echo -e "${RED}Error: Challenge '$1' does not exist in the current CTF. Please check the name and try again.${RESET}"
    fi
}

ctf_chal_unset() {
    if [ -z "$CURRENT_CHAL" ]; then
        echo -e "${YELLOW}No challenge is currently set. Nothing to unset.${RESET}"
        return 0
    fi

    CURRENT_CHAL=""
    save_current_ctf
    echo -e "${GREEN}Success: Current challenge has been unset.${RESET}"
}


ctf_chal_list() {
    if [ ! -d "$CURRENT_CTF" ]; then
        echo -e "${RED}Error: No CTF set. Please set a CTF first using 'ctf set <ctfname>'.${RESET}"
        return 1
    fi

    echo -e "${CYAN}Listing challenges in CTF '$CURRENT_CTF':${RESET}"

    if [ "$(ls -A "$CURRENT_CTF")" ]; then
        for chal in "$CURRENT_CTF"/*; do
            if [ -d "$chal" ]; then
                echo -e "${GREEN}- $(basename "$chal")${RESET}"
            fi
        done
    else
        echo -e "${YELLOW}No challenges found in this CTF.${RESET}"
    fi
}

load_current_ctf

case "$1" in
    rc)
        shift
        ctf_rc
        ;;
    new)
        shift
        ctf_new "$@"
        ;;
    delete)
        shift
        ctf_delete "$@"
        ;;
    set)
        shift
        ctf_set "$@"
        ;;
    unset)
        shift
        ctf_unset
        ;;
    list)
        shift
        ctf_list
        ;;
    chal)
        shift
        case "$1" in
            new)
                shift
                ctf_chal_new "$@"
                ;;
            delete)
                shift
                ctf_chal_delete "$@"
                ;;
            set)
                shift
                ctf_chal_set "$@"
                ;;
            unset)
                shift
                ctf_chal_unset "$@"
                ;;
            list)
                shift
                ctf_chal_list
                ;;
            *)
                help
                ;;
        esac
        ;;
    *)
        help
        ;;
esac
#!/bin/sh

# ANSI colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

GLOBAL_PATH="/usr/local/bin/idev"

echo -e "${CYAN}Checking Dependencies...${RESET}"
for dep in git bash curl php; do
    if ! command -v $dep >/dev/null 2>&1; then
        echo -e "${YELLOW}$dep is not installed, do you wanna install it now? (Y/N)${RESET}"
        read answer
        case "$answer" in
            [Yy]* ) 
                echo -e "${GREEN}Installing $dep...${RESET}"
                apk add --no-cache $dep 
                ;;
            * ) 
                echo -e "${RED}Skipping $dep installation...${RESET}" 
                ;;
        esac
    else
        echo -e "${GREEN}$dep is already installed.${RESET}"
    fi
done

echo -e "${CYAN}Downloading idev...${RESET}"
curl -sSL https://raw.githubusercontent.com/serenityios/idev/refs/heads/main/trash.sh -o /tmp/idev.sh
chmod +x /tmp/idev.sh

echo -e "${CYAN}Installing idev to $GLOBAL_PATH...${RESET}"
mkdir -p "$(dirname $GLOBAL_PATH)"
cp /tmp/idev.sh "$GLOBAL_PATH"

echo -e "${GREEN}Installation complete. You can now run 'idev' from anywhere.${RESET}"

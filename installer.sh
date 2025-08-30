#!/bin/sh

GLOBAL_PATH="/usr/local/bin/idev"

echo "Checking Dependencies..."
for dep in git bash curl php; do
    if ! command -v $dep >/dev/null 2>&1; then
        echo "$dep is not installed, do you wanna install it now? (Y/N)"
        read answer
        case "$answer" in
            [Yy]* ) apk add --no-cache $dep ;;
            * ) echo "Skipping $dep installation..." ;;
        esac
    fi
done

echo "Downloading idev..."
curl -sSL https://raw.githubusercontent.com/serenityios/idev/refs/heads/main/trash.sh -o /tmp/idev.sh
chmod +x /tmp/idev.sh

echo "Installing idev to $GLOBAL_PATH..."
# Ensure the target directory exists
mkdir -p "$(dirname $GLOBAL_PATH)"
cp /tmp/idev.sh "$GLOBAL_PATH"

echo "Installation complete. You can now run 'idev' from anywhere."

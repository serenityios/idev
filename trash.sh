#!/bin/bash

Red="\033[31m"
Green="\033[32m"
Yellow="\033[33m"
Cyan="\033[36m"
Magenta="\033[35m"
Reset="\033[0m"

check_dependencies() {
    local missing=()
    for cmd in curl php; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${Red}[!] Missing dependencies: ${missing[*]}${Reset}"
        echo -ne "${Yellow}Do you want to install them now? (y/n): ${Reset}"
        read -r ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            apk add "${missing[@]}"
        else
            echo -e "${Red}[!] Cannot continue without dependencies. Exiting...${Reset}"
            exit 1
        fi
    fi
}

check_internet() {
    curl -s https://google.com > /dev/null 2>&1
    return $?
}

print_header() {
    echo -e "${Cyan}
 _  ____  _____ _    
/ \/  _ \/  __// \ |\\
| || | \||  \  | | //
| || |_/||  /_ | \// 
\_/\____/\____\\\\__/  
                     ${Reset}"
}

create_project() {
    local name="$1"
    echo -e "${Cyan}[*] Creating project: $name${Reset}"
    mkdir -p "$name/test"

    cat > "$name/test/main.go" <<EOF
package main

import "fmt"

func main() {
    fmt.Println("Hello from $name!")
}
EOF

    echo -e "${Cyan}[+] Project created at $name${Reset}"
}

build_project() {
    local name="$1"
    local build_type="$2"
    local project_path="./$name"

    if [[ ! -d "$project_path" ]]; then
        echo -e "${Red}[!] Project does not exist.${Reset}"
        return
    fi

    case "$build_type" in
        dylib)
            echo "dummy dylib content" > "$project_path/$name.dylib"
            echo -e "${Cyan}[+] .dylib built at $project_path/$name.dylib${Reset}"
            ;;
        ipa)
            echo "dummy ipa content" > "$project_path/$name.ipa"
            echo -e "${Cyan}[+] .ipa built at $project_path/$name.ipa${Reset}"
            ;;
        *)
            echo -e "${Red}[!] Unknown build type. Use 'dylib' or 'ipa'.${Reset}"
            ;;
    esac
}

open_local_code_editor() {
    local folder="$1"
    if [[ ! -d "$folder" ]]; then
        echo -e "${Red}[!] Folder does not exist.${Reset}"
        return
    fi

    echo -e "${Cyan}[*] Starting local PHP server for folder: $folder${Reset}"
    php -S 127.0.0.1:8000 -t "$folder" &
    server_pid=$!
    echo -e "${Green}[+] PHP server running at: http://127.0.0.1:8000${Reset}"
    echo -e "${Yellow}[!] Server is running in background with PID $server_pid${Reset}"
}

show_website() {
    echo -e "${Cyan}\n=== Website ===${Reset}"
    echo -e "${Cyan}Visit: ${Magenta}https://idev.pro${Reset}"
    echo -e "${Cyan}Copy the URL and open it in your browser!${Reset}"
}

# Main execution
check_dependencies

if ! check_internet; then
    echo -e "${Red}[!] No internet connection detected. Exiting...${Reset}"
    exit 1
fi

while true; do
    print_header
    echo -e "${Cyan}1.${Reset} Create Project"
    echo -e "${Cyan}2.${Reset} Build Project"
    echo -e "${Cyan}3.${Reset} Local Code Editor"
    echo -e "${Cyan}4.${Reset} Website"
    echo -e "${Cyan}5.${Reset} Exit"
    echo -ne "${Cyan}Select an option: ${Reset}"
    read -r input

    case "$input" in
        1)
            echo -ne "${Cyan}Enter project name: ${Reset}"
            read -r name
            create_project "$name"
            ;;
        2)
            echo -ne "${Cyan}Enter project name: ${Reset}"
            read -r name
            echo -ne "${Cyan}Build type (dylib/ipa): ${Reset}"
            read -r build_type
            build_project "$name" "$build_type"
            ;;
        3)
            echo -ne "${Cyan}Enter project folder for code editor: ${Reset}"
            read -r folder
            open_local_code_editor "$folder"
            ;;
        4)
            show_website
            ;;
        5)
            echo -e "${Magenta}Exiting... Goodbye!${Reset}"
            exit 0
            ;;
        *)
            echo -e "${Red}[!] Invalid option${Reset}"
            ;;
    esac
done

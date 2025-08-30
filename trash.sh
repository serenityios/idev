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

create_code_editor() {
    local folder="$1"
    
    # Create index.php as the main file
    cat > "$folder/index.php" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>iDev Code Editor</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            background: #212121;
            color: #ffffff;
            margin: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        .header {
            background: #333333;
            padding: 15px;
            border-bottom: 1px solid #555555;
        }
        
        .header h1 {
            color: #ffffff;
            font-size: 20px;
            margin: 0;
        }
        
        .container {
            display: flex;
            flex: 1;
        }
        
        .sidebar {
            width: 300px;
            background: #2a2a2a;
            border-right: 1px solid #555555;
            padding: 20px;
        }
        
        .file-list {
            list-style: none;
            margin: 0;
            padding: 0;
        }
        
        .file-item {
            padding: 10px;
            cursor: pointer;
            margin-bottom: 5px;
        }
        
        .file-item:hover {
            background: #404040;
        }
        
        .file-item.active {
            background: #555555;
        }
        
        .editor-area {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .toolbar {
            background: #333333;
            padding: 15px;
            border-bottom: 1px solid #555555;
        }
        
        .btn {
            background: #555555;
            color: white;
            border: none;
            padding: 10px 15px;
            cursor: pointer;
            margin-right: 10px;
        }
        
        .btn:hover {
            background: #666666;
        }
        
        .editor {
            flex: 1;
            background: #212121;
        }
        
        .code-editor {
            width: 100%;
            height: 100%;
            background: #212121;
            color: #ffffff;
            border: none;
            outline: none;
            font-family: monospace;
            font-size: 14px;
            padding: 20px;
            resize: none;
        }
        
        .new-file-form {
            background: #333333;
            padding: 15px;
            margin-bottom: 20px;
        }
        
        .new-file-form input {
            background: #555555;
            border: none;
            color: #ffffff;
            padding: 10px;
            width: 100%;
            margin-bottom: 10px;
        }
        
        .new-file-form button {
            background: #555555;
            color: white;
            border: none;
            padding: 10px;
            cursor: pointer;
            width: 100%;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Code Editor</h1>
    </div>
    
    <div class="container">
        <div class="sidebar">
            <div class="new-file-form">
                <input type="text" id="newFileName" placeholder="filename.txt">
                <button onclick="createNewFile()">Create File</button>
            </div>
            <ul class="file-list" id="fileList">
            </ul>
        </div>
        
        <div class="editor-area">
            <div class="toolbar">
                <button class="btn" onclick="saveFile()">Save</button>
                <button class="btn" onclick="refreshFiles()">Refresh</button>
                <button class="btn" onclick="deleteFile()">Delete</button>
            </div>
            <div class="editor">
                <textarea class="code-editor" id="codeEditor" placeholder="Select a file to edit"></textarea>
            </div>
        </div>
    </div>

    <script>
        let currentFile = null;

        function loadFiles() {
            fetch('?action=list')
                .then(response => response.json())
                .then(files => {
                    const fileList = document.getElementById('fileList');
                    fileList.innerHTML = '';
                    files.forEach(file => {
                        const li = document.createElement('li');
                        li.className = 'file-item';
                        li.textContent = file;
                        li.onclick = () => openFile(file);
                        fileList.appendChild(li);
                    });
                });
        }

        function openFile(filename) {
            fetch(`?action=read&file=${encodeURIComponent(filename)}`)
                .then(response => response.text())
                .then(content => {
                    document.getElementById('codeEditor').value = content;
                    currentFile = filename;
                    
                    document.querySelectorAll('.file-item').forEach(item => {
                        item.classList.toggle('active', item.textContent === filename);
                    });
                });
        }

        function saveFile() {
            if (!currentFile) {
                alert('No file selected');
                return;
            }

            const content = document.getElementById('codeEditor').value;
            const formData = new FormData();
            formData.append('action', 'write');
            formData.append('file', currentFile);
            formData.append('content', content);

            fetch('', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(result => {
                if (result === 'success') {
                    alert('File saved');
                } else {
                    alert('Error saving file');
                }
            });
        }

        function createNewFile() {
            const filename = document.getElementById('newFileName').value.trim();
            if (!filename) {
                alert('Enter a filename');
                return;
            }

            const formData = new FormData();
            formData.append('action', 'create');
            formData.append('file', filename);

            fetch('', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(result => {
                if (result === 'success') {
                    document.getElementById('newFileName').value = '';
                    loadFiles();
                    openFile(filename);
                } else {
                    alert('Error creating file');
                }
            });
        }

        function deleteFile() {
            if (!currentFile) {
                alert('No file selected');
                return;
            }

            if (!confirm(`Delete ${currentFile}?`)) {
                return;
            }

            const formData = new FormData();
            formData.append('action', 'delete');
            formData.append('file', currentFile);

            fetch('', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(result => {
                if (result === 'success') {
                    currentFile = null;
                    document.getElementById('codeEditor').value = '';
                    loadFiles();
                    alert('File deleted');
                } else {
                    alert('Error deleting file');
                }
            });
        }

        function refreshFiles() {
            loadFiles();
        }

        loadFiles();
    </script>
</body>
</html>

<?php
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action'])) {
    switch ($_GET['action']) {
        case 'list':
            $files = array_filter(scandir('.'), function($item) {
                return $item[0] !== '.' && is_file($item) && $item !== 'index.php';
            });
            header('Content-Type: application/json');
            echo json_encode(array_values($files));
            exit;
            
        case 'read':
            $file = $_GET['file'];
            if (file_exists($file) && is_file($file)) {
                header('Content-Type: text/plain');
                echo file_get_contents($file);
            } else {
                http_response_code(404);
                echo 'File not found';
            }
            exit;
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'];
    $file = $_POST['file'];
    
    switch ($action) {
        case 'write':
            $content = $_POST['content'];
            if (file_put_contents($file, $content) !== false) {
                echo 'success';
            } else {
                echo 'error';
            }
            exit;
            
        case 'create':
            if (!file_exists($file)) {
                if (file_put_contents($file, '') !== false) {
                    echo 'success';
                } else {
                    echo 'error';
                }
            } else {
                echo 'exists';
            }
            exit;
            
        case 'delete':
            if (file_exists($file) && unlink($file)) {
                echo 'success';
            } else {
                echo 'error';
            }
            exit;
    }
}
?>
EOF
}

open_local_code_editor() {
    local folder="$1"
    if [[ ! -d "$folder" ]]; then
        echo -e "${Red}[!] Folder does not exist.${Reset}"
        return
    fi

    echo -e "${Cyan}[*] Setting up code editor for folder: $folder${Reset}"
    
    # Create the code editor
    create_code_editor "$folder"
    
    # Start PHP server
    cd "$folder"
    echo -e "${Cyan}[*] Starting code editor server...${Reset}"
    php -S 127.0.0.1:8000 &
    server_pid=$!
    
    echo -e "${Green}[+] Code Editor is now running!${Reset}"
    echo -e "${Cyan}[+] Open your browser and go to: ${Magenta}http://127.0.0.1:8000${Reset}"
    echo -e "${Yellow}[!] Server is running in background with PID $server_pid${Reset}"
    echo -e "${Yellow}[!] Press Ctrl+C to stop the server when done${Reset}"
    
    cd - > /dev/null
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

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
    
    # Create the main editor HTML file
    cat > "$folder/editor.php" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>iDev Code Editor</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Courier New', monospace;
            background: #1e1e1e;
            color: #d4d4d4;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        .header {
            background: #252526;
            padding: 10px 20px;
            border-bottom: 1px solid #3e3e42;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .header h1 {
            color: #00d4ff;
            font-size: 18px;
        }
        
        .container {
            display: flex;
            flex: 1;
            height: calc(100vh - 60px);
        }
        
        .sidebar {
            width: 250px;
            background: #252526;
            border-right: 1px solid #3e3e42;
            padding: 10px;
            overflow-y: auto;
        }
        
        .file-list {
            list-style: none;
        }
        
        .file-item {
            padding: 5px 10px;
            cursor: pointer;
            border-radius: 3px;
            margin-bottom: 2px;
        }
        
        .file-item:hover {
            background: #2d2d30;
        }
        
        .file-item.active {
            background: #094771;
        }
        
        .editor-area {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .tabs {
            background: #2d2d30;
            display: flex;
            border-bottom: 1px solid #3e3e42;
            min-height: 35px;
        }
        
        .tab {
            background: #3e3e42;
            padding: 8px 15px;
            border-right: 1px solid #2d2d30;
            cursor: pointer;
            position: relative;
        }
        
        .tab.active {
            background: #1e1e1e;
        }
        
        .tab-close {
            margin-left: 8px;
            color: #999;
            cursor: pointer;
        }
        
        .tab-close:hover {
            color: #fff;
        }
        
        .editor {
            flex: 1;
            background: #1e1e1e;
            position: relative;
        }
        
        .code-editor {
            width: 100%;
            height: 100%;
            background: #1e1e1e;
            color: #d4d4d4;
            border: none;
            outline: none;
            font-family: 'Courier New', monospace;
            font-size: 14px;
            padding: 15px;
            resize: none;
        }
        
        .toolbar {
            background: #252526;
            padding: 8px 15px;
            border-bottom: 1px solid #3e3e42;
            display: flex;
            gap: 10px;
        }
        
        .btn {
            background: #0e639c;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 3px;
            cursor: pointer;
            font-size: 12px;
        }
        
        .btn:hover {
            background: #1177bb;
        }
        
        .btn.secondary {
            background: #5a5a5a;
        }
        
        .btn.secondary:hover {
            background: #6a6a6a;
        }
        
        .status-bar {
            background: #007acc;
            color: white;
            padding: 5px 15px;
            font-size: 12px;
            display: flex;
            justify-content: space-between;
        }
        
        .new-file-form {
            background: #2d2d30;
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 3px;
        }
        
        .new-file-form input {
            background: #3c3c3c;
            border: 1px solid #5a5a5a;
            color: #d4d4d4;
            padding: 5px;
            width: 100%;
            border-radius: 3px;
        }
        
        .new-file-form button {
            background: #0e639c;
            color: white;
            border: none;
            padding: 5px 10px;
            border-radius: 3px;
            cursor: pointer;
            margin-top: 5px;
            width: 100%;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>iDev Code Editor</h1>
        <span>Folder: <?php echo basename(getcwd()); ?></span>
    </div>
    
    <div class="container">
        <div class="sidebar">
            <div class="new-file-form">
                <input type="text" id="newFileName" placeholder="Enter filename...">
                <button onclick="createNewFile()">Create File</button>
            </div>
            <ul class="file-list" id="fileList">
                <!-- Files will be loaded here -->
            </ul>
        </div>
        
        <div class="editor-area">
            <div class="toolbar">
                <button class="btn" onclick="saveFile()">Save</button>
                <button class="btn secondary" onclick="refreshFiles()">Refresh</button>
                <button class="btn secondary" onclick="deleteFile()">Delete</button>
            </div>
            <div class="tabs" id="tabs">
                <!-- Tabs will appear here -->
            </div>
            <div class="editor">
                <textarea class="code-editor" id="codeEditor" placeholder="Select a file to start editing..."></textarea>
            </div>
        </div>
    </div>
    
    <div class="status-bar">
        <span id="statusLeft">Ready</span>
        <span id="statusRight">Select a file to edit</span>
    </div>

    <script>
        let currentFile = null;
        let openTabs = new Map();
        let unsavedChanges = new Set();

        function loadFiles() {
            fetch('editor.php?action=list')
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
            if (openTabs.has(filename)) {
                switchTab(filename);
                return;
            }

            fetch(`editor.php?action=read&file=${encodeURIComponent(filename)}`)
                .then(response => response.text())
                .then(content => {
                    openTabs.set(filename, content);
                    createTab(filename);
                    switchTab(filename);
                    updateStatus(`Opened: ${filename}`);
                });
        }

        function createTab(filename) {
            const tabs = document.getElementById('tabs');
            const tab = document.createElement('div');
            tab.className = 'tab';
            tab.innerHTML = `${filename} <span class="tab-close" onclick="closeTab('${filename}')">&times;</span>`;
            tab.onclick = (e) => {
                if (!e.target.classList.contains('tab-close')) {
                    switchTab(filename);
                }
            };
            tabs.appendChild(tab);
        }

        function switchTab(filename) {
            // Update active tab
            document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
            document.querySelectorAll('.tab').forEach(tab => {
                if (tab.textContent.includes(filename)) {
                    tab.classList.add('active');
                }
            });

            // Update active file in sidebar
            document.querySelectorAll('.file-item').forEach(item => {
                item.classList.toggle('active', item.textContent === filename);
            });

            currentFile = filename;
            document.getElementById('codeEditor').value = openTabs.get(filename) || '';
            document.getElementById('statusRight').textContent = `Editing: ${filename}`;
        }

        function closeTab(filename) {
            if (unsavedChanges.has(filename)) {
                if (!confirm(`${filename} has unsaved changes. Close anyway?`)) {
                    return;
                }
            }

            openTabs.delete(filename);
            unsavedChanges.delete(filename);
            
            // Remove tab
            document.querySelectorAll('.tab').forEach(tab => {
                if (tab.textContent.includes(filename)) {
                    tab.remove();
                }
            });

            if (currentFile === filename) {
                currentFile = null;
                document.getElementById('codeEditor').value = '';
                document.getElementById('statusRight').textContent = 'Select a file to edit';
            }
        }

        function saveFile() {
            if (!currentFile) {
                updateStatus('No file selected', true);
                return;
            }

            const content = document.getElementById('codeEditor').value;
            const formData = new FormData();
            formData.append('action', 'write');
            formData.append('file', currentFile);
            formData.append('content', content);

            fetch('editor.php', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(result => {
                if (result === 'success') {
                    openTabs.set(currentFile, content);
                    unsavedChanges.delete(currentFile);
                    updateStatus(`Saved: ${currentFile}`);
                } else {
                    updateStatus('Error saving file', true);
                }
            });
        }

        function createNewFile() {
            const filename = document.getElementById('newFileName').value.trim();
            if (!filename) {
                updateStatus('Please enter a filename', true);
                return;
            }

            const formData = new FormData();
            formData.append('action', 'create');
            formData.append('file', filename);

            fetch('editor.php', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(result => {
                if (result === 'success') {
                    document.getElementById('newFileName').value = '';
                    loadFiles();
                    openFile(filename);
                    updateStatus(`Created: ${filename}`);
                } else {
                    updateStatus('Error creating file', true);
                }
            });
        }

        function deleteFile() {
            if (!currentFile) {
                updateStatus('No file selected', true);
                return;
            }

            if (!confirm(`Are you sure you want to delete ${currentFile}?`)) {
                return;
            }

            const formData = new FormData();
            formData.append('action', 'delete');
            formData.append('file', currentFile);

            fetch('editor.php', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(result => {
                if (result === 'success') {
                    closeTab(currentFile);
                    loadFiles();
                    updateStatus(`Deleted: ${currentFile}`);
                } else {
                    updateStatus('Error deleting file', true);
                }
            });
        }

        function refreshFiles() {
            loadFiles();
            updateStatus('Files refreshed');
        }

        function updateStatus(message, isError = false) {
            const statusLeft = document.getElementById('statusLeft');
            statusLeft.textContent = message;
            statusLeft.style.color = isError ? '#f48771' : '#d4d4d4';
            setTimeout(() => {
                statusLeft.textContent = 'Ready';
                statusLeft.style.color = '#d4d4d4';
            }, 3000);
        }

        // Track changes
        document.getElementById('codeEditor').addEventListener('input', function() {
            if (currentFile) {
                const original = openTabs.get(currentFile) || '';
                if (this.value !== original) {
                    unsavedChanges.add(currentFile);
                } else {
                    unsavedChanges.delete(currentFile);
                }
            }
        });

        // Load files on startup
        loadFiles();
    </script>
</body>
</html>

<?php
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action'])) {
    switch ($_GET['action']) {
        case 'list':
            $files = array_filter(scandir('.'), function($item) {
                return $item[0] !== '.' && is_file($item) && $item !== 'editor.php';
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
    echo -e "${Cyan}[+] Open your browser and go to: ${Magenta}http://127.0.0.1:8000/editor.php${Reset}"
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

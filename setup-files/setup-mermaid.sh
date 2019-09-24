scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupMermaid()
{
    cd "$appDirectory"

    Log "Setting the up the 'Mermaid' installation."
    Log " ﹂ Checking whether 'Mermaid' is already installed..."
    
    mermaidBinaryLocation="$appDirectory/node_modules/.bin/mmdc"
    if [ -f "$mermaidBinaryLocation" ]
    then
        Log "     ﹂ 'Mermaid' is already installed. The app will continue with this installation."
        return
    fi
    
    Log " ﹂ Attempting to install Mermaid via npm..."
    
    which npm > /dev/null 2>&1
    if [ $? -ne 0 ]
    then
        Log "     ﹂ Failed to find 'npm' within the system. Please make sure that you have npm installed."
        exit 1
    fi
    
    if [ ! -z "$HTTPS_PROXY" ]
    then
        npm config set https-proxy "$HTTPS_PROXY" > /dev/null 2>&1
    fi
    
    if [ ! -z "$HTTP_PROXY" ]
    then
        npm config set proxy "$HTTP_PROXY" > /dev/null 2>&1
    fi
    
    npm install mermaid.cli > /dev/null 2>&1
    if [ $? -ne 0 ]
    then
        Log "     ﹂ Failed to install 'mermaid.cli' via npm. Please try running the command 'npm install mermaid.cli' manually for more details."
        exit 1
    fi
    
    mermaidBinaryLocation="$appDirectory/node_modules/.bin/mmdc"
    if [ ! -f "$mermaidBinaryLocation" ]
    then
        Log "     ﹂ Failed to install 'mermaid.cli'. Eventhough the installation completed succesfully, the corresponding binary was not found in '$mermaidBinaryLocation'."
        exit 1
    fi

    export DEPENDENCY_mermaidBinary="$mermaidBinaryLocation"
}
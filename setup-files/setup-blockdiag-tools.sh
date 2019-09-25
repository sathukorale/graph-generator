scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupBlockdiagTools()
{
    cd "$appDirectory"

    Log "Setting up the 'Blockdiag Tools' installation."
    
    blockDiagAppDir=`CreateDependencySubDir "blockdiag-tools"`
    pythonVersion=`python -c "import sys; print('%d.%d' % (sys.version_info.major, sys.version_info.minor));" 2>/dev/null`
    
    suggestedPackageSite="$blockDiagAppDir/lib/python${pythonVersion}/site-packages"
    defaultPackageSite=`python -m site --user-site 2>/dev/null`
    
    mkdir -p "$suggestedPackageSite" > /dev/null 2>&1
    export PYTHONPATH="$suggestedPackageSite:$defaultPackageSite:$PYTHONPATH"
    
    Log " ﹂ Installing 'webcolors' which is required by blockdiag binaries..."
	pip install --system --prefix=$blockDiagAppDir "webcolors" > /dev/null 2>&1
	
    export PATH="$blockDiagAppDir/bin:$PATH"
    
    InstallBlockdiagTool "actdiag"
    InstallBlockdiagTool "nwdiag"
    InstallBlockdiagTool "blockdiag"
    InstallBlockdiagTool "seqdiag"
    InstallBlockdiagTool "packetdiag"
    InstallBlockdiagTool "rackdiag"
}

function InstallBlockdiagTool()
{
    toolName="$1"
    blockDiagAppDir=`CreateDependencySubDir "blockdiag-tools"`
    
    Log " ﹂ Checking whether '$1' is already installed..."
    
	binaryLocation=`which "$toolName" 2>/dev/null`
	if [ $? -eq 0 ]; then
		Log "     ﹂ '$toolName' is already installed into '$binaryLocation'. The script will continue with this installation."
		return
	fi

	Log " ﹂ Attempting to install '$toolName' into '$blockDiagAppDir'."
	
	pip install --system --prefix=$blockDiagAppDir "$toolName" > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		Log "     ﹂ Failed to install '$toolName'. Please try installing '$toolName' manually."
		exit 1
	fi
	
	binaryLocation=`which "$toolName" 2>/dev/null`
	if [ $? -ne 0 ]; then
		Log "     ﹂ The script could not locate the '$toolName' (installation even though the installation completed just now)."
		exit 1
	fi
	
	Log "     ﹂ '$toolName' was installed into '$binaryLocation'."
	
    export "DEPENDENCY_${toolName}Binary"="$binaryLocation"
}
scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupDitaa()
{
    cd "$appDirectory"

    Log "Setting the up the 'Ditaa' installation."
    Log " ﹂ Downloading Ditaa binary..."
    
    ditaaAppDirectory=`CreateDependencySubDir "ditaa"`

    ditaaPackage="https://sourceforge.net/projects/ditaa/files/ditaa/0.9/ditaa0_9.zip/download"
    downloadFilePath="$ditaaAppDirectory/ditaa.jar"

    if [ `DownloadFile "$ditaaPackage" "$downloadFilePath"` == "SUCCESS" ]
    then
        Log "     ﹂ Ditaa binary was downloaded successfully."
    else
        Log "     ﹂ Failed to download Ditaa binary."
        exit 1
    fi

    export DEPENDENCY_DitaaBinary="$downloadFilePath"
}
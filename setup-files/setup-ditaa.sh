scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupDitaa()
{
    cd "$appDirectory"

    Log "Setting up the 'Ditaa' installation."
    Log " ﹂ Downloading Ditaa binary..."
    
    tempDirectory=`CreateTempSubDir "ditaa"`
    ditaaAppDirectory=`CreateDependencySubDir "ditaa"`

    ditaaPackage="https://sourceforge.net/projects/ditaa/files/ditaa/0.9/ditaa0_9.zip/download"
    downloadFilePath="$tempDirectory/ditaa.zip"

    if [ `DownloadFile "$ditaaPackage" "$downloadFilePath"` == "SUCCESS" ]
    then
        Log "     ﹂ Ditaa binary was downloaded successfully."
    else
        Log "     ﹂ Failed to download Ditaa binary."
        exit 1
    fi

    Log " ﹂ Extracting the downloaded archive."
    unzip "$downloadFilePath" -d "$tempDirectory" > /dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
        Log "     ﹂ Successfully extracted the archive."
    else
        Log "     ﹂ Failed to extract the archive. Please retry."
        exit 1
    fi
    
    binaryFile=`find "$tempDirectory" -name "ditaa*.jar" 2>/dev/null`
    if [[ $? -eq 0 ]]
    then
        Log " ﹂ The ditaa binary was found at '$binaryFile'."
    else
        Log " ﹂ Failed to find the ditaa binary at '$tempDirectory'."
        exit 1
    fi
    
    targetFile="$ditaaAppDirectory/ditaa.jar"
    Log " ﹂ Moving the binary '$binaryFile' into '$targetFile'..."
    
    mv "$binaryFile" "$targetFile" > /dev/null 2>&1

    export DEPENDENCY_ditaaBinary="$targetFile"
}
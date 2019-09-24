temporaryDirectory="$appDirectory/tmp"
dependencyDirectory="$appDirectory/dependencies"
coreCount=`grep -c ^processor /proc/cpuinfo`

function CreateDirectory()
{
    directoryPath="$1"
    if [ ! -d "$directoryPath" ]
    then
        mkdir -p "$directoryPath" > /dev/null 2>&1
    fi
}

function DeleteDirectory()
{
    directoryPath="$1"
    if [ -d "$directoryPath" ]
    then
        rm -rf "$directoryPath" > /dev/null 2>&1
    fi
}

function CreateTempSubDir()
{
    subDirPath="$temporaryDirectory/$1"
    CreateDirectory "$subDirPath"
    echo "$subDirPath"
}

function CreateDependencySubDir()
{
    subDirPath="$pluginDirectory/$1"
    CreateDirectory "$subDirPath"
    echo "$subDirPath"
}

function CleanTempDir()
{
    DeleteDirectory "$temporaryDirectory"
}

function CleanDependencyDirectory()
{
    DeleteDirectory "$pluginDirectory"
}

function Log()
{
    message="$1"
    echo ">> $message"
}

function DownloadFile()
{
    downloadUrl="$1"
    downloadFilePath="$2"

    wget "$downloadUrl" -O "$downloadFilePath" > /dev/null 2>&1

    if [ $? -eq 0 ] && [ -f "$downloadFilePath" ]
    then
        echo "SUCCESS"
    else
        echo "FAILED"
    fi
}
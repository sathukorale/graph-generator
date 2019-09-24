scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupPlantUml()
{
    cd "$appDirectory"

    Log "Setting up the 'Plantuml' installation."
    Log " ﹂ Downloading Plantuml binary..."
    
    plantumlAppDirectory=`CreateDependencySubDir "plantuml"`

    plantumlPackage="http://sourceforge.net/projects/plantuml/files/plantuml.jar/download"
    downloadFilePath="$plantumlAppDirectory/plantuml.jar"

    if [ `DownloadFile "$plantumlPackage" "$downloadFilePath"` == "SUCCESS" ]
    then
        Log "     ﹂ Plantuml binary was downloaded successfully."
    else
        Log "     ﹂ Failed to download Plantuml binary."
        exit 1
    fi

    export DEPENDENCY_plantumlBinary="$downloadFilePath"
}
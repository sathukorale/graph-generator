scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupDot()
{
    cd "$appDirectory"

    Log "Setting the up the 'dot' installation."
    Log " ﹂ Downloading Graphviz sources..."
    
    tempDirectory=`CreateTempSubDir "graphviz"`
    graphvizAppDirectory=`CreatePluginSubDir "graphviz"`

    graphvizPackage="https://graphviz.gitlab.io/pub/graphviz/stable/SOURCES/graphviz.tar.gz"
    downloadFilePath="$temporaryDirectory/graphviz.tar.gz"

    if [ `DownloadFile "$graphvizPackage" "$downloadFilePath"` == "SUCCESS" ]
    then
        Log "     ﹂ Graphviz sources were downloaded successfully."
    else
        Log "     ﹂ Failed to download Graphviz sources."
        exit 1
    fi

    Log " ﹂ Extracting the downloaded archive."
    tar -xvf "$downloadFilePath" -C "$tempDirectory" > /dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
        Log "     ﹂ Successfully extracted the archive."
    else
        Log "     ﹂ Failed to extract the archive. Please retry."
        exit 1
    fi

    cd "$tempDirectory"
    graphvizDirectory=$(dirname `find \`pwd\` -maxdepth 2 -name configure`)

    cd "$graphvizDirectory"

    Log " ﹂ Attempting to compile Graphviz."
    ./configure --prefix="$graphvizAppDirectory" --with-libgd=yes --with-gdincludedir="$DEPENDENCY_libgdDirectory/include" --with-gdlibdir="$DEPENDENCY_libgdDirectory/lib" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to configure. Please try manually configuring '$graphvizDirectory'."
        exit 1
    fi

    make "-j$coreCount" CFLAGS=-DHAVE_GD_PNG > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to build. Please try manually building '$graphvizDirectory'."
        exit 1
    fi

    make install > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to install graphviz binaries. Please try manually installing '$graphvizDirectory' into '$graphvizAppDirectory'."
        exit 1
    fi

    Log " ﹂ Graphviz was compiled and install into '$graphvizAppDirectory'."

    export DEPENDENCY_graphvizDirectory="$graphvizAppDirectory"
}
scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupLibpng()
{
    libpngSources="http://prdownloads.sourceforge.net/libpng/libpng-1.6.37.tar.gz?download"
    downloadFilePath="$temporaryDirectory/libpng.tar.gz"

    cd "$appDirectory"

    Log "Setting the up the 'libpng' installation."
    Log " ﹂ Downloading libpng sources..."
    
    tempDirectory=`CreateTempSubDir "libpng"`
    libpngAppDirectory=`CreatePluginSubDir "libpng"`

    if [ `DownloadFile "$libpngSources" "$downloadFilePath"` == "SUCCESS" ]
    then
        Log "     ﹂ libpng sources were downloaded succesfully."
    else
        Log "     ﹂ Failed to download libpng sources."
        exit 1
    fi

    Log " ﹂ Extracting the downloaded archive..."
    tar -xvf "$downloadFilePath" -C "$tempDirectory" > /dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
        Log "     ﹂ Successfully extracted the archive."
    else
        Log "     ﹂ Failed to extract the archive. Please retry."
        exit 1
    fi

    cd "$tempDirectory"
    libpngDirectory=$(dirname `find \`pwd\` -maxdepth 2 -name configure`)
    cd "$libpngDirectory"

    Log " ﹂ Attempting to compile libpng."
    ./configure --prefix="$libpngAppDirectory" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to configure. Please try manually configuring '$libpngDirectory'."
        exit 1
    fi

    make "-j$coreCount" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to build. Please try manually building '$libpngDirectory'."
        exit 1
    fi

    make install > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to install libpng binaries. Please try manually installing '$libpngDirectory' into '$libpngAppDirectory'."
        exit 1
    fi

    Log " ﹂ libpng was compiled and install into '$libpngAppDirectory'."

    export DEPENDENCY_libpngDirectory="$libpngAppDirectory"
}
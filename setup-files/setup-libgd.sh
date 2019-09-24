scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupLibgd()
{
    libgdSources="https://github.com/libgd/libgd/releases/download/gd-2.2.5/libgd-2.2.5.tar.gz"
    downloadFilePath="$temporaryDirectory/libgd.tar.gz"

    cd "$appDirectory"

    Log "Setting the up the 'libgd' installation."
    Log " ﹂ Downloading libgd sources..."
    
    tempDirectory=`CreateTempSubDir "libgd"`
    libgdAppDirectory=`CreateDependencySubDir "libgd"`

    if [ `DownloadFile "$libgdSources" "$downloadFilePath"` == "SUCCESS" ]
    then
        Log "     ﹂ Libgd sources were downloaded succesfully."
    else
        Log "     ﹂ Failed to download libgd sources."
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
    libgdDirectory=$(dirname `find \`pwd\` -maxdepth 2 -name configure`)
    cd "$libgdDirectory"

    Log " ﹂ Attempting to compile libgd."
    ./configure --prefix="$libgdAppDirectory" --with-png="$DEPENDENCY_libpngDirectory" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to configure. Please try manually configuring '$libgdDirectory'."
        exit 1
    fi

    make "-j$coreCount" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to build. Please try manually building '$libgdDirectory'."
        exit 1
    fi

    make install > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to install libgd binaries. Please try manually installing '$libgdDirectory' into '$libgdAppDirectory'."
        exit 1
    fi

    Log " ﹂ libgd was compiled and install into '$libgdAppDirectory'."

    export DEPENDENCY_libgdDirectory="$libgdAppDirectory"
}
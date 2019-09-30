scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupLibexpat()
{
    libexpatSources="https://github.com/libexpat/libexpat/releases/download/R_2_2_9/expat-2.2.9.tar.gz"
    downloadFilePath="$temporaryDirectory/libexpat.tar.gz"

    cd "$appDirectory"

    Log "Setting up the 'libexpat' installation."
    Log " ﹂ Downloading libexpat sources..."
    
    tempDirectory=`CreateTempSubDir "libexpat"`
    libexpatAppDirectory=`CreateDependencySubDir "libexpat"`

    if [ `DownloadFile "$libexpatSources" "$downloadFilePath"` == "SUCCESS" ]
    then
        Log "     ﹂ Libexpat sources were downloaded succesfully."
    else
        Log "     ﹂ Failed to download libexpat sources."
        exit 1
    fi

    Log " ﹂ Extracting the downloaded archive..."
    tar -xvf "$downloadFilePath" -C "$tempDirectory" > /dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
        Log "     ﹂ Successfully extracted the archive.":
    else
        Log "     ﹂ Failed to extract the archive. Please retry."
        exit 1
    fi

    cd "$tempDirectory"
    libexpatDirectory=$(dirname `find \`pwd\` -maxdepth 2 -name configure`)
    cd "$libexpatDirectory"

    Log " ﹂ Attempting to compile libexpat."
    ./configure --prefix="$libexpatAppDirectory" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to configure. Please try manually configuring '$libexpatDirectory'."
        exit 1
    fi

    make "-j$coreCount" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to build. Please try manually building '$libexpatDirectory'."
        exit 1
    fi

    make install > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to install libexpat binaries. Please try manually installing '$libexpatDirectory' into '$libexpatAppDirectory'."
        exit 1
    fi

    Log " ﹂ libexpat was compiled and install into '$libexpatAppDirectory'."

    export DEPENDENCY_libexpatDirectory="$libexpatAppDirectory"
}
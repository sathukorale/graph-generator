scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupZlib()
{
    zlibSources="https://www.zlib.net/zlib-1.2.11.tar.gz"
    downloadFilePath="$temporaryDirectory/zlib.tar.gz"

    cd "$appDirectory"

    Log "Setting up the 'zlib' installation."
    Log " ﹂ Downloading zlib sources..."
    
    tempDirectory=`CreateTempSubDir "zlib"`
    zlibAppDirectory=`CreateDependencySubDir "zlib"`

    if [ `DownloadFile "$zlibSources" "$downloadFilePath"` == "SUCCESS" ]
    then
        Log "     ﹂ zlib sources were downloaded succesfully."
    else
        Log "     ﹂ Failed to download zlib sources."
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
    zlibDirectory=$(dirname `find \`pwd\` -maxdepth 2 -name configure`)
    cd "$zlibDirectory"

    Log " ﹂ Attempting to compile zlib."
    ./configure --prefix="$zlibAppDirectory" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to configure. Please try manually configuring '$zlibDirectory'."
        exit 1
    fi

    make "-j$coreCount" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to build. Please try manually building '$zlibDirectory'."
        exit 1
    fi

    make install > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to install zlib binaries. Please try manually installing '$zlibDirectory' into '$zlibAppDirectory'."
        exit 1
    fi

    Log " ﹂ zlib was compiled and install into '$zlibAppDirectory'."

    export DEPENDENCY_zlibDirectory="$zlibAppDirectory"

    export CPPFLAGS="-I$DEPENDENCY_zlibDirectory/include $CPPFLAGS"
    export LDFLAGS="-L$DEPENDENCY_zlibDirectory/lib $CPPFLAGS"
}
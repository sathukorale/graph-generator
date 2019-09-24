scriptLocation=`realpath "$(dirname $BASH_SOURCE)"`
source "$scriptLocation/utilities.sh"

function SetupLibjpeg()
{
    libjpegSources="http://www.ijg.org/files/jpegsrc.v9c.tar.gz"
    downloadFilePath="$temporaryDirectory/libjpeg.tar.gz"

    cd "$appDirectory"

    Log "Setting up the 'libjpeg' installation."
    Log " ﹂ Downloading libjpeg sources..."
    
    tempDirectory=`CreateTempSubDir "libjpeg"`
    libjpegAppDirectory=`CreateDependencySubDir "libjpeg"`

    if [ `DownloadFile "$libjpegSources" "$downloadFilePath"` == "SUCCESS" ]
    then
        Log "     ﹂ libjpeg sources were downloaded succesfully."
    else
        Log "     ﹂ Failed to download libjpeg sources."
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
    libjpegDirectory=$(dirname `find \`pwd\` -maxdepth 2 -name configure`)
    cd "$libjpegDirectory"

    Log " ﹂ Attempting to compile libjpeg."
    ./configure --prefix="$libjpegAppDirectory" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to configure. Please try manually configuring '$libjpegDirectory'."
        exit 1
    fi

    make "-j$coreCount" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to build. Please try manually building '$libjpegDirectory'."
        exit 1
    fi

    make install > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "     ﹂ Failed to install libjpeg binaries. Please try manually installing '$libjpegDirectory' into '$libjpegAppDirectory'."
        exit 1
    fi

    Log " ﹂ libjpeg was compiled and install into '$libjpegAppDirectory'."

    export DEPENDENCY_libjpegDirectory="$libjpegAppDirectory"
}
#!/bin/bash

appDirectory=`realpath "$(dirname $BASH_SOURCE)"`
temporaryDirectory="$appDirectory/tmp"
pluginDirectory="$appDirectory/plugins"
coreCount=`grep -c ^processor /proc/cpuinfo`

DEPENDENCY_libgdDirectory=""
DEPENDENCY_graphvizDirectory=""

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

function CreatePluginSubDir()
{
    subDirPath="$pluginDirectory/$1"
    CreateDirectory "$subDirPath"
    echo "$subDirPath"
}

function CleanTempDir()
{
    DeleteDirectory "$temporaryDirectory"
}

function CleanPluginDirectory()
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

function SetupLibgd()
{
    libgdSources="https://github.com/libgd/libgd/releases/download/gd-2.2.5/libgd-2.2.5.tar.gz"
    downloadFilePath="$temporaryDirectory/libgd.tar.gz"

    cd "$appDirectory"

    Log "Setting the up the 'libgd' installation."
    Log " ﹂ Downloading libgd sources..."
    
    tempDirectory=`CreateTempSubDir "libgd"`
    libgdAppDirectory=`CreatePluginSubDir "libgd"`

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
    ./configure --prefix="$libgdAppDirectory" > /dev/null 2>&1
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

    DEPENDENCY_libgdDirectory="$libgdAppDirectory"
}

function SetupDot()
{
    cd "$appDirectory"

    Log "Setting the up the 'dot' installation."
    Log " ﹂ Installing graphviz."
    Log "     ﹂ Downloading Graphviz sources..."
    
    tempDirectory=`CreateTempSubDir "graphviz"`
    graphvizAppDirectory=`CreatePluginSubDir "graphviz"`

    graphvizPackage="https://graphviz.gitlab.io/pub/graphviz/stable/SOURCES/graphviz.tar.gz"
    downloadFilePath="$temporaryDirectory/graphviz.tar.gz"

    if [ `DownloadFile "$graphvizPackage" "$downloadFilePath"` == "SUCCESS" ]
    then
        Log "         ﹂ Graphviz sources were downloaded successfully."
    else
        Log "         ﹂ Failed to download Graphviz sources."
        exit 1
    fi

    Log "     ﹂ Extracting the downloaded archive."
    tar -xvf "$downloadFilePath" -C "$tempDirectory" > /dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
        Log "         ﹂ Successfully extracted the archive."
    else
        Log "         ﹂ Failed to extract the archive. Please retry."
        exit 1
    fi

    cd "$tempDirectory"
    graphvizDirectory=$(dirname `find \`pwd\` -maxdepth 2 -name configure`)

    cd "$graphvizDirectory"

    Log "     ﹂ Attempting to compile Graphviz."
    ./configure --prefix="$graphvizAppDirectory" --with-libgd=yes --with-gdincludedir="$DEPENDENCY_libgdDirectory/include" --with-gdlibdir="$DEPENDENCY_libgdDirectory/lib" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "         ﹂ Failed to configure. Please try manually configuring '$graphvizDirectory'."
        exit 1
    fi

    make "-j$coreCount" CFLAGS=-DHAVE_GD_PNG > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "         ﹂ Failed to build. Please try manually building '$graphvizDirectory'."
        exit 1
    fi

    make install > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "         ﹂ Failed to install graphviz binaries. Please try manually installing '$graphvizDirectory' into '$graphvizAppDirectory'."
        exit 1
    fi

    Log "     ﹂ Graphviz was compiled and install into '$graphvizAppDirectory'."

    DEPENDENCY_graphvizDirectory="$graphvizAppDirectory"
}

function Setup()
{
    Log "* AppDirectory = '$appDirectory'"
    Log "* Plugin Directory = '$pluginDirectory'"
    Log "* Temp Directory = '$temporaryDirectory'"
    Log ""

    CleanTempDir
    CleanPluginDirectory

    SetupLibgd
    SetupDot
}

Setup
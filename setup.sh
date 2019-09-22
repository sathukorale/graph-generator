#!/bin/bash

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

    if [ $? -eq 0 ]
    then
        echo "SUCCESS"
    else
        echo "FAILED"
    fi
}

function SetupLibgd()
{
    
}

function SetupDot()
{
    Log "Setting the up the 'dot' installation."
    Log " ﹂ Checking whether dot is already installed..."

    dotBinaryLocation=`which dot 2>/dev/null`
    if [[ $? -eq 0 ]]
    then
        Log "     ﹂ An existing installation was found."
        return
    else
        Log "     ﹂ No dot installation was found."
    fi

    Log " ﹂ Installing graphviz."
    Log "     ﹂ Downloading Graphviz sources..."

    if [ ! -d tmp ]; then
        mkdir tmp
    fi

    if [ ! -d "tmp/graphviz" ]; then
        mkdir "tmp/graphviz"
    fi

    appDirectory="$(pwd)/app-directory"
    graphvizAppDirectory="$appDirectory/graphviz"

    if [ ! -d "$appDirectory" ]; then
        mkdir "$appDirectory"
    fi
    
    if [ ! -d "$graphvizAppDirectory" ]; then
        mkdir "$graphvizAppDirectory"
    fi

    graphvizPackage="https://graphviz.gitlab.io/pub/graphviz/stable/SOURCES/graphviz.tar.gz"
    downloadFilePath="graphviz.tar.gz"

    if [ `DownloadFile "$graphvizPackage" "tmp/$downloadFilePath"` == "SUCCESS" ] && [ -f "tmp/$downloadFilePath" ]
    then
        Log "         ﹂ Graphviz sources were downloaded successfully."
    else
        Log "         ﹂ Failed to download Graphviz sources."
        exit 1
    fi

    Log "     ﹂ Extracting the downloaded archive."
    tar -xvf "tmp/$downloadFilePath" -C "tmp/graphviz/" > /dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
        Log "         ﹂ Successfully extracted the archive."
    else
        Log "         ﹂ Failed to extract the archive. Please retry"
        exit 1
    fi

    cd "tmp/graphviz"
    graphvizDirectory=$(dirname `find \`pwd\` -maxdepth 2 -name configure`)
    cd "$graphvizDirectory"

    Log "     ﹂ Attempting to compile Graphviz."
    ./configure --prefix="$graphvizAppDirectory" > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        Log "         ﹂ Failed to configure. Please try manually configuring '$graphvizDirectory'."
        exit 1
    fi

    make > /dev/null 2>&1
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

    Log "         ﹂ Graphviz was compiled and install into '$graphvizAppDirectory'."
}

function Setup()
{
    SetupDot
}

Setup
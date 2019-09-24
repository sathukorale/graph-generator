#!/bin/bash

appDirectory=`realpath "$(dirname $BASH_SOURCE)"`

source "$appDirectory/setup-files/utilities.sh"

source "$appDirectory/setup-files/setup-libpng.sh"
source "$appDirectory/setup-files/setup-libgd.sh"
source "$appDirectory/setup-files/setup-graphviz.sh"
source "$appDirectory/setup-files/setup-plantuml.sh"
source "$appDirectory/setup-files/setup-mermaid.sh"
source "$appDirectory/setup-files/setup-ditaa.sh"
source "$appDirectory/setup-files/setup-blockdiag-tools.sh"

DEPENDENCY_libgdDirectory=""
DEPENDENCY_graphvizDirectory=""
DEPENDENCY_libpngDirectory=""
DEPENDENCY_plantumlBinary=""
DEPENDENCY_mermaidBinary=""
DEPENDENCY_DitaaBinary=""
DEPENDENCY_actdiagBinary=""
DEPENDENCY_nwdiagBinary=""
DEPENDENCY_blockdiagBinary=""
DEPENDENCY_seqdiagBinary=""
DEPENDENCY_packetdiagBinary=""
DEPENDENCY_rackdiagBinary=""

function Setup()
{
    Log "* AppDirectory = '$appDirectory'"
    Log "* Plugin Directory = '$pluginDirectory'"
    Log "* Temp Directory = '$temporaryDirectory'"
    Log ""

    CleanTempDir
    CleanDependencyDirectory

    #SetupLibpng
    Log ""
    #SetupLibgd
    Log ""
    #SetupDot
    Log ""
    #SetupPlantUml
    Log ""
    #SetupMermaid
    Log ""
    #SetupDitaa
    Log ""
    SetupBlockdiagTools
}

Setup
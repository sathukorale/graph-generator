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
source "$appDirectory/setup-files/setup-zlib.sh"
source "$appDirectory/setup-files/setup-libjpeg.sh"

DEPENDENCY_libgdDirectory=""
DEPENDENCY_graphvizDirectory=""
DEPENDENCY_libpngDirectory=""
DEPENDENCY_plantumlBinary=""
DEPENDENCY_mermaidBinary=""
DEPENDENCY_ditaaBinary=""
DEPENDENCY_actdiagBinary=""
DEPENDENCY_nwdiagBinary=""
DEPENDENCY_blockdiagBinary=""
DEPENDENCY_seqdiagBinary=""
DEPENDENCY_packetdiagBinary=""
DEPENDENCY_rackdiagBinary=""
DEPENDENCY_zlibDirectory=""
DEPENDENCY_libjpegDirectory=""

function GenerateDepedenciesJs()
{
    echo "const graphvizBinary = '$DEPENDENCY_graphvizDirectory/bin/dot';" > "$appDirectory/depdendencies.js"
    echo "const plantumlBinary = '$DEPENDENCY_plantumlBinary';" >> "$appDirectory/depdendencies.js"
    echo "const mermaidBinary = '$DEPENDENCY_mermaidBinary';" >> "$appDirectory/depdendencies.js"
    echo "const ditaaBinary = '$DEPENDENCY_ditaaBinary';" >> "$appDirectory/depdendencies.js"
    echo "const actdiagBinary = '$DEPENDENCY_actdiagBinary';" >> "$appDirectory/depdendencies.js"
    echo "const nwdiagBinary = '$DEPENDENCY_nwdiagBinary';" >> "$appDirectory/depdendencies.js"
    echo "const blockdiagBinary = '$DEPENDENCY_blockdiagBinary';" >> "$appDirectory/depdendencies.js"
    echo "const seqdiagBinary = '$DEPENDENCY_seqdiagBinary';" >> "$appDirectory/depdendencies.js"
    echo "const packetdiagBinary = '$DEPENDENCY_packetdiagBinary';" >> "$appDirectory/depdendencies.js"
    echo "const rackdiagBinary = '$DEPENDENCY_rackdiagBinary';" >> "$appDirectory/depdendencies.js"
    echo "" >> "$appDirectory/depdendencies.js"
    echo "const blockdiagTools = {};" >> "$appDirectory/depdendencies.js"
    echo "blockdiagTools['actdiag'] = actdiagBinary;" >> "$appDirectory/dependencies.js"
    echo "blockdiagTools['nwdiag'] = nwdiagBinary;" >> "$appDirectory/dependencies.js"
    echo "blockdiagTools['blockdiag'] = blockdiagBinary;" >> "$appDirectory/dependencies.js"
    echo "blockdiagTools['seqdiag'] = seqdiagBinary;" >> "$appDirectory/dependencies.js"
    echo "blockdiagTools['packetdiag'] = packetdiagBinary;" >> "$appDirectory/dependencies.js"
    echo "blockdiagTools['rackdiag'] = rackdiagBinary;" >> "$appDirectory/dependencies.js"
    echo "" >> "$appDirectory/depdendencies.js"
    echo "function PrintDependencyLocations()" >> "$appDirectory/depdendencies.js"
    echo "{" >> "$appDirectory/depdendencies.js"
    echo "\tconsole.log(\"* Graphviz Binary Path = '\" + graphvizBinary + \"'\");" >> "$appDirectory/depdendencies.js"
    echo "\tconsole.log(\"* Plantuml Binary Path = '\" + plantumlBinary + \"'\");" >> "$appDirectory/depdendencies.js"
    echo "\tconsole.log(\"* Mermaid Binary Path = '\" + mermaidBinary + \"'\");" >> "$appDirectory/depdendencies.js"
    echo "\tconsole.log(\"* Ditaa Binary Path = '\" + ditaaBinary + \"'\");" >> "$appDirectory/depdendencies.js"
    echo "\tconsole.log(\"* Actdiag Binary Path = '\" + actdiagBinary + \"'\");" >> "$appDirectory/depdendencies.js"
    echo "\tconsole.log(\"* Nwdiag Binary Path = '\" + nwdiagBinary + \"'\");" >> "$appDirectory/depdendencies.js"
    echo "\tconsole.log(\"* Blockdiag Binary Path = '\" + blockdiagBinary + \"'\");" >> "$appDirectory/depdendencies.js"
    echo "\tconsole.log(\"* Seqdiag Binary Path = '\" + seqdiagBinary + \"'\");" >> "$appDirectory/depdendencies.js"
    echo "\tconsole.log(\"* Packetdiag Binary Path = '\" + packetdiagBinary + \"'\");" >> "$appDirectory/depdendencies.js"
    echo "\tconsole.log(\"* Rackdiag Binary Path = '\" + rackdiagBinary + \"'\");" >> "$appDirectory/depdendencies.js"
    echo "}" >> "$appDirectory/depdendencies.js"
    
}

function GenerateStartScript()
{
    echo "#!/bin/bash" > "$appDirectory/start.sh"
    echo "" >> "$appDirectory/start.sh"
    echo "export LD_LIBRARY_PATH=\"$DEPENDENCY_graphvizDirectory/lib:$LD_LIBRARY_PATH\"" >> "$appDirectory/start.sh"
    echo "export LD_LIBRARY_PATH_64=\"$DEPENDENCY_graphvizDirectory/lib:$LD_LIBRARY_PATH_64\"" >> "$appDirectory/start.sh"
    echo "" >> "$appDirectory/start.sh"
    echo "export LD_LIBRARY_PATH=\"$DEPENDENCY_libgdDirectory/lib:$LD_LIBRARY_PATH\"" >> "$appDirectory/start.sh"
    echo "export LD_LIBRARY_PATH_64=\"$DEPENDENCY_libgdDirectory/lib:$LD_LIBRARY_PATH_64\"" >> "$appDirectory/start.sh"
    echo "" >> "$appDirectory/start.sh"
    echo "export LD_LIBRARY_PATH=\"$DEPENDENCY_libjpegDirectory/lib:$LD_LIBRARY_PATH\"" >> "$appDirectory/start.sh"
    echo "export LD_LIBRARY_PATH_64=\"$DEPENDENCY_libjpegDirectory/lib:$LD_LIBRARY_PATH_64\"" >> "$appDirectory/start.sh"
    echo "" >> "$appDirectory/start.sh"
    echo "export LD_LIBRARY_PATH=\"$DEPENDENCY_libpngDirectory/lib:$LD_LIBRARY_PATH\"" >> "$appDirectory/start.sh"
    echo "export LD_LIBRARY_PATH_64=\"$DEPENDENCY_libpngDirectory/lib:$LD_LIBRARY_PATH_64\"" >> "$appDirectory/start.sh"
    echo "" >> "$appDirectory/start.sh"
    echo "export LD_LIBRARY_PATH=\"$DEPENDENCY_zlibDirectory/lib:$LD_LIBRARY_PATH\"" >> "$appDirectory/start.sh"
    echo "export LD_LIBRARY_PATH_64=\"$DEPENDENCY_zlibDirectory/lib:$LD_LIBRARY_PATH_64\"" >> "$appDirectory/start.sh"
    echo "" >> "$appDirectory/start.sh"
    echo "screen -dm bash -c \" node --max-http-header-size=80000 index.js\" -S nodejs-graph-generator" >> "$appDirectory/start.sh"
}

function Setup()
{
    Log "* AppDirectory = '$appDirectory'"
    Log "* Plugin Directory = '$pluginDirectory'"
    Log "* Temp Directory = '$temporaryDirectory'"
    Log ""

    CleanTempDir
    CleanDependencyDirectory

    SetupZlib
    Log ""

    SetupLibpng
    Log ""

    SetupLibjpeg
    Log ""

    SetupLibgd
    Log ""

    SetupDot
    Log ""

    SetupPlantUml
    Log ""

    SetupMermaid
    Log ""

    SetupDitaa
    Log ""
    
    SetupBlockdiagTools
    Log ""
    
    GenerateDepedenciesJs
    GenerateStartScript
}

Setup
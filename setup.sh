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
    Log "Generating the Dependencies JS File..."
    
    echo -e "const graphvizBinary = '$DEPENDENCY_graphvizDirectory/bin/dot';" >> "$appDirectory/dependencies.js"
    echo -e "const plantumlBinary = '$DEPENDENCY_plantumlBinary';" >> "$appDirectory/dependencies.js"
    echo -e "const mermaidBinary = '$DEPENDENCY_mermaidBinary';" >> "$appDirectory/dependencies.js"
    echo -e "const ditaaBinary = '$DEPENDENCY_ditaaBinary';" >> "$appDirectory/dependencies.js"
    echo -e "const actdiagBinary = '$DEPENDENCY_actdiagBinary';" >> "$appDirectory/dependencies.js"
    echo -e "const nwdiagBinary = '$DEPENDENCY_nwdiagBinary';" >> "$appDirectory/dependencies.js"
    echo -e "const blockdiagBinary = '$DEPENDENCY_blockdiagBinary';" >> "$appDirectory/dependencies.js"
    echo -e "const seqdiagBinary = '$DEPENDENCY_seqdiagBinary';" >> "$appDirectory/dependencies.js"
    echo -e "const packetdiagBinary = '$DEPENDENCY_packetdiagBinary';" >> "$appDirectory/dependencies.js"
    echo -e "const rackdiagBinary = '$DEPENDENCY_rackdiagBinary';" >> "$appDirectory/dependencies.js"
    echo -e "" >> "$appDirectory/dependencies.js"
    echo -e "const blockdiagTools = {};" >> "$appDirectory/dependencies.js"
    echo -e "blockdiagTools['actdiag'] = actdiagBinary;" >> "$appDirectory/dependencies.js"
    echo -e "blockdiagTools['nwdiag'] = nwdiagBinary;" >> "$appDirectory/dependencies.js"
    echo -e "blockdiagTools['blockdiag'] = blockdiagBinary;" >> "$appDirectory/dependencies.js"
    echo -e "blockdiagTools['seqdiag'] = seqdiagBinary;" >> "$appDirectory/dependencies.js"
    echo -e "blockdiagTools['packetdiag'] = packetdiagBinary;" >> "$appDirectory/dependencies.js"
    echo -e "blockdiagTools['rackdiag'] = rackdiagBinary;" >> "$appDirectory/dependencies.js"
    echo -e "" >> "$appDirectory/dependencies.js"
    echo -e "function PrintDependencyLocations()" >> "$appDirectory/dependencies.js"
    echo -e "{" >> "$appDirectory/dependencies.js"
    echo -e "\tconsole.log(\"* Graphviz Binary Path = '\" + graphvizBinary + \"'\");" >> "$appDirectory/dependencies.js"
    echo -e "\tconsole.log(\"* Plantuml Binary Path = '\" + plantumlBinary + \"'\");" >> "$appDirectory/dependencies.js"
    echo -e "\tconsole.log(\"* Mermaid Binary Path = '\" + mermaidBinary + \"'\");" >> "$appDirectory/dependencies.js"
    echo -e "\tconsole.log(\"* Ditaa Binary Path = '\" + ditaaBinary + \"'\");" >> "$appDirectory/dependencies.js"
    echo -e "\tconsole.log(\"* Actdiag Binary Path = '\" + actdiagBinary + \"'\");" >> "$appDirectory/dependencies.js"
    echo -e "\tconsole.log(\"* Nwdiag Binary Path = '\" + nwdiagBinary + \"'\");" >> "$appDirectory/dependencies.js"
    echo -e "\tconsole.log(\"* Blockdiag Binary Path = '\" + blockdiagBinary + \"'\");" >> "$appDirectory/dependencies.js"
    echo -e "\tconsole.log(\"* Seqdiag Binary Path = '\" + seqdiagBinary + \"'\");" >> "$appDirectory/dependencies.js"
    echo -e "\tconsole.log(\"* Packetdiag Binary Path = '\" + packetdiagBinary + \"'\");" >> "$appDirectory/dependencies.js"
    echo -e "\tconsole.log(\"* Rackdiag Binary Path = '\" + rackdiagBinary + \"'\");" >> "$appDirectory/dependencies.js"
    echo -e "}" >> "$appDirectory/dependencies.js"
    echo -e "" >> "$appDirectory/dependencies.js"
    echo -e "module.exports = {" >> "$appDirectory/dependencies.js"
    echo -e "\tgraphvizBinary," >> "$appDirectory/dependencies.js"
    echo -e "\tplantumlBinary," >> "$appDirectory/dependencies.js"
    echo -e "\tmermaidBinary," >> "$appDirectory/dependencies.js"
    echo -e "\tditaaBinary," >> "$appDirectory/dependencies.js"
    echo -e "\tactdiagBinary," >> "$appDirectory/dependencies.js"
    echo -e "\tnwdiagBinary," >> "$appDirectory/dependencies.js"
    echo -e "\tblockdiagBinary," >> "$appDirectory/dependencies.js"
    echo -e "\tseqdiagBinary," >> "$appDirectory/dependencies.js"
    echo -e "\tpacketdiagBinary," >> "$appDirectory/dependencies.js"
    echo -e "\trackdiagBinary," >> "$appDirectory/dependencies.js"
    echo -e "\tblockdiagTools," >> "$appDirectory/dependencies.js"
    echo -e "\tPrintDependencyLocations" >> "$appDirectory/dependencies.js"
    echo -e "};" >> "$appDirectory/dependencies.js"
}

function GenerateStartScript()
{
    Log "Generating the Start Script..."
    
    echo -e "#!/bin/bash" >> "$appDirectory/start.sh"
    echo -e "" >> "$appDirectory/start.sh"
    echo -e "export LD_LIBRARY_PATH=\"$DEPENDENCY_graphvizDirectory/lib:\$LD_LIBRARY_PATH\"" >> "$appDirectory/start.sh"
    echo -e "export LD_LIBRARY_PATH_64=\"$DEPENDENCY_graphvizDirectory/lib:\$LD_LIBRARY_PATH_64\"" >> "$appDirectory/start.sh"
    echo -e "" >> "$appDirectory/start.sh"
    echo -e "export LD_LIBRARY_PATH=\"$DEPENDENCY_libgdDirectory/lib:\$LD_LIBRARY_PATH\"" >> "$appDirectory/start.sh"
    echo -e "export LD_LIBRARY_PATH_64=\"$DEPENDENCY_libgdDirectory/lib:\$LD_LIBRARY_PATH_64\"" >> "$appDirectory/start.sh"
    echo -e "" >> "$appDirectory/start.sh"
    echo -e "export LD_LIBRARY_PATH=\"$DEPENDENCY_libjpegDirectory/lib:\$LD_LIBRARY_PATH\"" >> "$appDirectory/start.sh"
    echo -e "export LD_LIBRARY_PATH_64=\"$DEPENDENCY_libjpegDirectory/lib:\$LD_LIBRARY_PATH_64\"" >> "$appDirectory/start.sh"
    echo -e "" >> "$appDirectory/start.sh"
    echo -e "export LD_LIBRARY_PATH=\"$DEPENDENCY_libpngDirectory/lib:\$LD_LIBRARY_PATH\"" >> "$appDirectory/start.sh"
    echo -e "export LD_LIBRARY_PATH_64=\"$DEPENDENCY_libpngDirectory/lib:\$LD_LIBRARY_PATH_64\"" >> "$appDirectory/start.sh"
    echo -e "" >> "$appDirectory/start.sh"
    echo -e "export LD_LIBRARY_PATH=\"$DEPENDENCY_zlibDirectory/lib:\$LD_LIBRARY_PATH\"" >> "$appDirectory/start.sh"
    echo -e "export LD_LIBRARY_PATH_64=\"$DEPENDENCY_zlibDirectory/lib:\$LD_LIBRARY_PATH_64\"" >> "$appDirectory/start.sh"
    echo -e "" >> "$appDirectory/start.sh"
    echo -e "if [ ! -f \"$appDirectory/dependencies.js\" ]" >> "$appDirectory/start.sh"
    echo -e "then" >> "$appDirectory/start.sh"
    echo -e "\techo \"Looks like the GraphGenerator server isn't setup properly. Please run the 'setup.sh' script to do the initial setup.\"" >> "$appDirectory/start.sh"
    echo -e "\treturn" >> "$appDirectory/start.sh"
    echo -e "fi" >> "$appDirectory/start.sh"
    echo -e "" >> "$appDirectory/start.sh"
    echo -e "screen -dm bash -c \"node --max-http-header-size=80000 index.js\" -S nodejs-graph-generator" >> "$appDirectory/start.sh"
    
    chmod +x "$appDirectory/start.sh"
}

function Setup()
{
    Log "* AppDirectory = '$appDirectory'"
    Log "* Plugin Directory = '$pluginDirectory'"
    Log "* Temp Directory = '$temporaryDirectory'"
    Log ""
    
    if [ -f "$appDirectory/dependencies.js" ] && [ -f "$appDirectory/start.sh" ]
    then
        echo "Looks like the server is already setup. If you think that there is an issue with the configuration or want to reset the setup, please delete the '$appDirectory/depdendencies.js' and the '$appDirectory/start.sh' and re-run the script."
        exit 0
    fi

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
    
    echo ""
    echo "Process completed. Please use the generated 'start.sh' File to Start the GraphGenerator Server."
}

Setup
#!/bin/bash
# 
# this bash script exports gcode to route a PCB as specified by a kicad project archive zip file
#
# Prerequisites:
# - unzip
# - kicad-cli
# - pcb2gcode

# PART 0: make sure we have an argument

if [ -z "$1" ]; then
	echo "ERROR: this script requires an argument!" >&2
	echo "Usage: $0 [KICAD ARCHIVE ZIP]" >&2
	echo "Example: $0 myproj.zip" >&2
	exit 1 # exit with an error
fi


# PART 1: process the archive

# 1. create working and output directories
mkdir -p "working" "outputs"

# 2. get files from archive
unzip -u "$1" -d "working" # overwrite existing files

# PART 2: export the layers as separate files

# 1. gerbers
kicad-cli pcb export gerbers working/*.kicad_pcb --no-protel-ext     --output working

# 2. edge cuts
kicad-cli pcb export pos     working/*.kicad_pcb --gerber-board-edge --output working

# 3. drill
kicad-cli pcb export drill   working/*.kicad_pcb --format excellon   --output working


# PART 3: export the gcode

# 1. rename files into those specified in millproject so will pcb2gcode will understand them
mv working/*-B_Cu.gbr      working/B_Cu.gbr
mv working/*-Edge_Cuts.gbr working/Edge_Cuts.gbr
mv working/*.drl           working/Drill.drl

# 2. run pcb2gcode with correct arguments

# 1. copy millproject into working folder
cp millproject working

# 2. cd into working folder
cd working

# 3. create output dir
mkdir -p gcode

# 4. export gcodes
pcb2gcode --config millproject --output-dir ../outputs


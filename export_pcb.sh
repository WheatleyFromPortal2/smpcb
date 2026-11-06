#!/bin/bash
# 
# this bash script exports gcode to route a PCB as specified by a kicad project archive zip file
#
# Prerequisites:
# - unzip
# - kicad-cli
# - pcb2gcode

# CONSTANTS
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$SCRIPT_DIR/tmp"
OUTPUTS_DIR="$SCRIPT_DIR/outputs"
CONFIG_FILE="$SCRIPT_DIR/millproject"

# PART 0: make sure we have an argument

if [ -z "$1" ]; then
	echo "ERROR: this script requires an argument!" >&2
	echo "Usage: $0 [KICAD ARCHIVE ZIP]" >&2
	echo "Example: $0 myproj.zip" >&2
	exit 1 # exit with an error
fi


# PART 1: process the archive

# 1. create temp and output directories
mkdir -p "$TMP_DIR" "$OUTPUTS_DIR"

# 2. get files from archive
unzip -u "$1" -d "$TMP_DIR" # overwrite existing files

# PART 2: export the layers as separate files

# 1. gerbers
kicad-cli pcb export gerbers "$TMP_DIR"/*.kicad_pcb --no-protel-ext     --output "$TMP_DIR"

# 2. edge cuts
kicad-cli pcb export pos     "$TMP_DIR"/*.kicad_pcb --gerber-board-edge --output "$TMP_DIR"

# 3. drill
kicad-cli pcb export drill   "$TMP_DIR"/*.kicad_pcb --format excellon   --output "$TMP_DIR"


# PART 3: export the gcode

# 1. rename files into those specified in millproject so will pcb2gcode will understand them
mv "$TMP_DIR"/*-F_Cu.gbr      "$TMP_DIR"/F_Cu.gbr
mv "$TMP_DIR"/*-B_Cu.gbr      "$TMP_DIR"/B_Cu.gbr
mv "$TMP_DIR"/*-Edge_Cuts.gbr "$TMP_DIR"/Edge_Cuts.gbr
mv "$TMP_DIR"/*.drl           "$TMP_DIR"/Drill.drl

# 2. run pcb2gcode with correct arguments

# 1. copy millproject into working folder
cp millproject "$TMP_DIR"

# 2. cd into working folder
cd "$TMP_DIR"

# 3. export gcodes
pcb2gcode --config "$CONFIG_FILE" --output-dir "$OUTPUTS_DIR"


# PART 4: cleanup

# 1. delete tmp directory
rm -rf "$TMP_DIR" # scary

# 2. organize output directory
mkdir -p "$OUTPUTS_DIR/svg"
mv "$OUTPUTS_DIR"/*.svg "$OUTPUTS_DIR/svg"

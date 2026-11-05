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

# 1. create working directory
mkdir -p "working"

# 2. get files from archive
unzip -u "$1" -d "working" # overwrite existing files

# PART 2: export the gerber

# 1. clean up the working directory


# PART 3: export the gcode
# - may need to rename files to align with pcb2gcode config file

# PART 1: process the archive
# 1. unzip

mkdir current # create folder for current work
unzip "inputs/$1" -d "current"

# PART 2: export the gerber

# PART 3: export the gcode
# - may need to rename files to align with pcb2gcode config file

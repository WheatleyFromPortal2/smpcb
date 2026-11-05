# smpcb

# goals

## MVP

- take in kicad project archives (`.zip`)
- export gerber files
- process gerber files with `pcb2gcode`
- return `.rgc` files

## extras

- create a web server so people without the program installed can use it
- host it on a raspi that can control the PCB router and run jobs
	- auto tool changer?
	- add ability to cut out multiple different PCBs from one layer of copper

# info
using ShopBot D2418

dashboard at http://10.127.5.161/#/dashboard
uses FluidNC

[kicad-cli docs](https://docs.kicad.org/8.0/en/cli/cli.html)

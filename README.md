# smpcb

# TODO

## 1. basic function

- [x] take in kicad project archives (`.zip`)
- [x] export gerber files
- [x] process gerber files with `pcb2gcode`
- [x] return `.rgc` files
- [ ] export either back or front gcode

## 2. cut host

- [ ] host it on a raspi that can control the PCB router and run jobs
    - [ ] auto tool changer?
    - [ ] add ability to cut out multiple different PCBs from one layer of copper

## 3. multi-user server

- [ ] create a web server so people without the program installed can use it
- [ ] ability to CRUD jobs
    - save jobs to sqlite database
        - use unix time millis for job id
        - save state as an integer with a lookup table

# info
using ShopBot D2418

dashboard at http://10.127.5.161/#/dashboard
uses FluidNC

[kicad-cli docs](https://docs.kicad.org/8.0/en/cli/cli.html)

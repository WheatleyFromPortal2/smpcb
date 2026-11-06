import serial, time, re


ser = serial.Serial("/dev/ttyUSB0", 115200, timeout=1)
time.sleep(2)               # opening the port can reset the ESP32; let it boot
ser.reset_input_buffer()

def send(line):
    ser.write((line.strip() + "\n").encode())
    while True:
        resp = ser.readline().decode().strip()
        if resp == "ok":
            return
        if resp.startswith("error") or resp.startswith("ALARM"):
            raise RuntimeError(resp)
        print("resp", resp)
        # ignore status/message lines like [MSG:...]

# ---send gcode file---

filename = sys.argv[1]

if filename == "":
    print("specify a filename as your first argument!")
    exit(1)

# strip out .ngc comments

_PAREN = re.compile(r"\([^)]*\)")

def _drop_paren(m):
    # keep (MSG, ...) so the controller still prints tool-change prompts
    return m.group(0) if m.group(0)[1:].lstrip().upper().startswith("MSG") else ""


def strip_line(line: str) -> str:
    # return the line without comments or surrounding whitespace 
    # '' if nothing is left
    line = _PAREN.sub(_drop_paren, line)
    return line.split(";", 1)[0].strip()

count = 0
with open(filename, "r") as gcode:
    for line in gcode:
        count += 1
        strippedLine = strip_line(line)
        if not strippedLine:
            continue
        send(strippedLine)


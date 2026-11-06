# overall structure

- bash for project processing
- one python process for serial communication to the router 
    - reads current job from db
    - sends that gcode to the router
    - updates job state (IN_PROGRESS, FINISHED, FAILED)
    - also updates job_progress
        - only update every 50 lines or 1 second
            - don't want to wear our SD card
        - log specific line if there was an error
- another python process for web server
    - reads database for the current state
    - writes changes
- write ahead log has locks on writes so it allows both processes to communicate


# TODO

## 1. basic function

- [x] take in kicad project archives (`.zip`)
- [x] export gerber files
- [x] process gerber files with `pcb2gcode`
- [x] return `.ngc` files
- [x] export both front and back gcode

## 2. cli-controlled cutting

- [ ] figure out how to send gcode to the router with python
    - can test serial connection with `minicom -D /dev/ttyUSB0 -b 115200`
- [ ] figure out how to home the router and start jobs successfully
- [ ] learn sqlite using [sqlbolt](https://sqlbolt.com/lesson/select_queries_introduction)
    - currently on [this lesson](https://sqlbolt.com/lesson/select_queries_with_joins)
- [ ] convert table schemas to `.sql` schema files with comments and move out of the README.md

## 3. multi-user server

- [ ] learn how to use flask to create a basic web server controlled by python
    - want to avoid using javascript for this project if possible
- [ ] host the web server on a raspi

## 4. extras / feature creep :)

- [ ] auto tool changer integration
- [ ] add ability to cut out multiple jobs from one big layer of copper

# data ontology
- all data is stored in a gitignore-exempted `data` folder
- periodic archives of `data` are zipped into a `~/smpcb-backups` folder
    - database must be backed up with sqlite3's own tools and zipped along with `res`
    - otherwise risk weird stuff happening
    - backup archives to my onedrive occasionally in case of sd card failure
- jobs saved to sqlite database named `smpcb.sqlite3`
    - this must be in write ahead log mode
- gcode and svgs saved to `data/res` folder inside

## database tables


### table: users
- use unix time millis for primary key / job id
    - also functions as creation date
    - stole this from the Anki db schema (dae is a genius)

1. id
2. username
3. email
4. password_hash
5. role 
    - user or admin
6. archived_at
    - NULL for current users
    - better alternative to deleting


### table: jobs
- this will be the most important table
- use unix time millis for primary key / job id
    - also functions as creation date
    - stole this from the Anki db schema (dae is a genius)
- users can see their own jobs along with their states
- jobs may include multiple layers and may need to wait for tool changes between them

### table: job_events
- we don't want to store job state directly in jobs table
    - we want to track how a job moves through the program with a log
    - we can derive our current state by looking at the last event
- jobs must always have a DRAFT event when created

- save state as an integer with a lookup table
    - DRAFT
    - SUBMITTED
        - admins can either approve or reject
    - APPROVED
    - REJECTED
    - IN_PROGRESS
        - currently being cut
    - COMPLETED
    - FAILED
    - TRASHED
        - must be returned to DRAFT state upon un-trashing
        - users can only trash their own jobs and view their own trashed jobs
        - admins can trash any job and view any trashed jobs

1. id (plain autoincrement)
2. job_id
3. state (what the state changed to)
4. time (when the state changed)
5. gcode_line (only relevant for for IN_PROGRESS jobs)
    - also allows to compute percent complete
5. user_id (who did the change)
6. note (ex: reason for rejection, error log for failure)

### table: job_progress
- this is mostly just to have a status bar for the job

1. job_id
2. lines_total
3. lines_acked
4. updated_at

### table: machine_commands

1. id
2. kind
3. args
4. requested_by
5. requested_at
6. status
    - PENDING, RUNNING, DONE, REJECTED, FAILED
    - REJECTED for malformed commands
7. result
    - should be empty for success
    - shoudl have error for REJECTED
8. finished_at

### table: machine_status
- single row table with live machine status

1. id
2. stat
3. x
4. y
5. z
6. heartbeat
    - periodicically write current timestamp
    - web app can use this to display a warning

## object storage
- inside of the `data/res` folder are job folders named with job id
- each job folder contains a `data/res/JOB_ID/job.zip`
    - uploaded zips must be carefully scanned
        - reject `../../x` entries
        - reject zip bombs
        - run export_pcb.sh with timeouts in the background
        - make sure that export_pcb.sh has a clear place for failures
        - maybe write a SUCCESS empty file upon success?
    - this name must not be specified by the user to prevent writes outside the folder
    - specifying it also makes the code easier
    - ex: `../../etc/passwd`
- each job folder has two subfolders: `data/res/JOB_ID/gcode` and `data/res/JOB_ID/svg`
- `gcode` and `svg` files preserve their original names and extensions and can be directly downloaded
    - these filenames will be generated by pcb2gcode, not provided by users

# notes

## interacting with the router
using a ShopBot D2418

[dashboard](http://10.127.5.161/#/dashboard)
- uses FluidNC
- [grbl](https://github.com/grbl/grbl) compatible firmware
    - can interface over serial, wifi, or websocket/http
    - ideally want to use serial
- need to figure out how fast I can stream lines to it
- 

[kicad-cli docs](https://docs.kicad.org/8.0/en/cli/cli.html)

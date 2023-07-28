# Cessna 310 family
The Cessna 310 family modelled for FlightGear

## Installation

Put the contents of this repository into a directory of your choice by either
* `git clone`ing it:
	```sh
	~$ cd /some/path/Aircraft
	/some/path/Aircraft$ git clone https://github.com/TheFGFSEagle/c310-family
	```
* or downloading the repository as a ZIP file and unzipping it with your favorite archive manager into `/some/path/Aircraft/c310-family` (make sure to remove the trailing `-master` from the directory name !)

Then, tell FlightGear to search `/some/path/Aircraft` for aircraft by either
* adding `/some/path/Aircraft` to the list of additional aircraft folders in the Addons tab of FGLauncher
* or passing `--aircraft-dir=/some/path/Aircraft` on the command line.

### IMPORTANT:
**No matter which of the methods above you use, make sure that you put this into `/some/path/Aircraft/c310-family` and pass `/some/path/Aircraft` to FlightGear to search for aircraft in - if you change `Aircraft/c310-family` to anything else, FlightGear will NOT be able to find and load the 3D model !**

## Contents

* Cessna 310A

## Status

This aircraft is currently being worked on by @ysopflying, chad3006 (on the forum) and @TheFGFSEagle.

### Features
* Exterior 3D model only missing some details like gear actuators etc.
* Interior model: Seats, fuel selectors, engine controls, doors, yokes, most switches, most instruments, all circuit breakers, … are modelled and fully interactive.
* FDM: Work in progress by @ysopflying, using wind tunnel data from a C310P and OpenVSP to adapt that to the C310A.
* Systems: Propeller feathering, oil system, engine overheating, lights …
* Equipment: Optional auxiliary fuel tanks, right landing light and rotating beacon are available
* Some failures are implemented

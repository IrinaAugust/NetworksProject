README for TokenPassing
Group 2
-Tyler Gauvreau    - 007696523
-Irina Avgustyniak - 007725420
-Nolan Labelle     - 007712175

Description:
TokenPassing is a simple "token passing" program. It has a list of the nodes to be used for the routing, and generates a token to be passed along, toggling the LEDs in the genomotes.

Installation instructions:
We are manually setting the node addresses during installation.

Example install command for a mote with ID of #:
make genomote master install.# /dev/ttyUSB#
So installation for 4 motes will need the following commands issued to install:
make genomote master install.0 /dev/ttyUSB0
make genomote master install.1 /dev/ttyUSB1
make genomote master install.2 /dev/ttyUSB2
make genomote master install.3 /dev/ttyUSB3

Motes must be assigned their ID's during installation.
The mote with an ID of zero will be considered the base station and will boot up and generate the token. Boot up this mote only after all 3 other motes have booted up.
Mode ID's must be unique. Do not program multiple motes with the same ID.
Right now the routing is hard coded for 4 motes with ID's of 0, 1, 2 and 3. These ID's must be specified during installation.

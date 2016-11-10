README for TokenPassing
Group 2

Description:
TokenPassing is a simple "token passing" program. It creates a list of the nodes to be used for the routing, and generates a token to be passed along, toggling the LEDs in the genomotes.

Example install command for a mote with ID of #:
make genomote master install.# /dev/ttyUSB0

Motes must be assigned their ID's during installation.
Mote with ID of zero will be considered the base station and will boot up and generate the token.
The numbers 126 and 255 are reserved by TinyOS. Do not program a mote to use those ID's.
Mode ID's must be unique. Do not program multiple motes with the same ID.

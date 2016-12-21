README for TokenPassing
Group 2
-Tyler Gauvreau    - 007696523
-Irina Avgustyniak - 007725420
-Nolan Labelle     - 007712175

Description:
TokenPassing is a simple "token passing" program. It has since bee upgraded from part 1 of the project.
TokenPassing now supports transmission to random addresses.
Whichever node you designate as zero will also print packets to the screen and retransmit them.

Installation instructions:
We are manually setting the node addresses during installation.

Example install command for a mote with ID of #:
make genomote master install.# /dev/ttyUSB#
So installation for 5 motes will need the following commands issued to install:
make genomote master install.0 /dev/ttyUSB0
make genomote master install.1 /dev/ttyUSB1
make genomote master install.2 /dev/ttyUSB2
make genomote master install.3 /dev/ttyUSB3
make genomote master install.3 /dev/ttyUSB3

To get output from node 0:
java net.tinyos.tools.PrintfClient serial@/dev/ttyUSB#:57600
Where # is the propper USB device node 0 has been assigned to by your operating system.

-Motes must be assigned their ID's during installation.
-The mote with an ID of zero will be considered the base station and will be able to print to a terminal.
	This node will also retransmit packets it recieves.
-Mode ID's must be unique. Do not program multiple motes with the same ID.

The addressing scheme is as follows:
-Node 0 will be the base station.
-Node 1-4 will be the edge nodes.
-Addresses 10 to 90 are assigned to each node via modulus.
	For example, the address 20 has been assigned to node 1. 20 mod 4 = 0, except that 0 is the address of the base station. Edge nodes are 1-4, so we add one to the result. (20 mod 4)+1 = 1.

Program description:
Upon boot, inside TokenPassingC's Boot.booted implementation, we turn the radio on.
Once the radio has turned on, AMControl.startDone fires.
At this point, the base mote will simply start waiting for packets to print and forward. When it recieves a packet, it will print that it has recieved it, then print that it is sending it on to the next client. The packet is then forwarded.
Edge nodes will start generating packets with random addresses every 3 seconds. Edge nodes also listen for a packet send to their address space, and will blink Led2 when a packet addressed to them is recieved.

On all nodes Led1 blinks when a packet is sent, and Led2 blinks when a packet is received.


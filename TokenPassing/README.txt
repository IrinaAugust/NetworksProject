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

Program description:
Upon boot, inside TokenPassingC's Boot.booted implementation, we turn the radio on.
Once the radio has turned on, AMControl.startDone fires. In here, we get the base station to start the token ring by sending the initial packet.
Timer0.fired() is the code responsible for transmitting the token to the next node on the network. This is also where the hard-coded routing information is.
Once the call to AMSend.send is done, AMSend.sendDone will fire. Here we check to see if the sent message is the same one that got signaled as done sending. This is mostly used in the case that there is more the one user of the radio. In our case, there is only one, so I am not expecting that check to ever fail.

Once a node boots up, it turns on it's radio. Once the radio is on, a node just sits and waits for a packet addressed to it. The exception is the base station that transmits a packet upon boot, then goes back to acting like any other node on the network.

Once a node gets sent a packet, the Receive.receive event fires. This is where you can access the contents of the packet we are passsing around.
Once we recieve a packet, we call Timer0 to send the token on it's way to the next node.

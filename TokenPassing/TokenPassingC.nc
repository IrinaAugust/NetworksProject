/**
 * TokenPassing is a simple "token passing" program. It has a list of the
 * nodes to be used for the routing, and generates a token to be passed along,
 * toggling the LEDs in the genomotes.
 *
 * @author Group 2
 * @date November 7th, 2016
 */

#include "Timer.h"
#include "printf.h"

module TokenPassingC @safe()
{
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as Timer1;
  uses interface Timer<TMilli> as Timer2;
  uses interface Timer<TMilli> as Timer3;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Receive;
  uses interface Random;
}
implementation
{
  bool radioLocked = FALSE;
  message_t packet;

  event void Boot.booted() {
    call AMControl.start();
  }

  //We blink this over and over when we notice an error.
  event void Timer1.fired() {
    call Leds.led0Toggle();
    call Leds.led1Toggle();
    call Leds.led2Toggle();
  }

  //Tx light
  event void Timer2.fired() {
    call Leds.led1Off();
  }

  //Rx light
  event void Timer3.fired() {
    call Leds.led2Off();
  }

  void sendPacket (uint16_t sendTo, uint16_t content) {
    if (!radioLocked) {
	  TokenMessage* tokenMessagePacket = (TokenMessage*)(call Packet.getPayload(&packet, sizeof(TokenMessage)));

	  tokenMessagePacket->destination = sendTo;
	  tokenMessagePacket->payload = content;
	  tokenMessagePacket->source = TOS_NODE_ID;

	  printf("Sending Message: %04X From: %d To: %d\n", content, TOS_NODE_ID, sendTo);
	  printfflush();
	  if (call AMSend.send(0xFFFF, &packet, sizeof(TokenMessage)) == SUCCESS) { //0xFF for broadcasting.
	    radioLocked = TRUE;
	  }
	  else {
	  //Packet was not accepted. Bad packet somehow.
	  call Timer1.startPeriodic(100);
	  }
	}
	else {
	  //Radio was locked, keep retrying.
	  //call Timer0.startOneShot(100);
	}
  }

  //Send a packet to a random address
  event void Timer0.fired() {
    uint16_t randomDestination = ((call Random.rand16()) % 89) + 10; //Generate random number and make that random number between 10 and 99.
	sendPacket(randomDestination, 0xBEEF);
  }

  event void AMControl.startDone(error_t error) {
    if (error != SUCCESS) {
      call AMControl.start();
    }
    else { //Radio is now on.
      if (TOS_NODE_ID != 0){
	    call Timer0.startPeriodic(3000); //Start sending random packets every 3 seconds.
	  }
	  //Else we are the base station and we just wait around to recieve packets to print.
    }
  }

  event void AMControl.stopDone(error_t err) {
    //Nothing
  }

  //Happens after an accepted send request.
  //message_t* message is the message that was sent.
  //error_t error indicates whether the send was successful.
  //SUCCESS if it was sent successfully, FAIL if it was not, and ECANCEL if it was cancelled.
  event void AMSend.sendDone(message_t* message, error_t error) {
    //Check to see if the sent message is the same one that is being signaled as done sending.
    //Only really needed if more then one user of the radio.
    if (&packet == message) {
      radioLocked = FALSE;
      call Leds.led1On();
      call Timer2.startOneShot(1000); //Turn the send light off after 1000ms.
    }
    else {
      call Timer1.startPeriodic(100); //Errors.
    }
  }

  event message_t* Receive.receive(message_t* message, void* payload, uint8_t length) {
    if (length == sizeof(TokenMessage)) {
      TokenMessage* tokenMessagePacket = (TokenMessage*)payload;
      uint16_t from = tokenMessagePacket->source;
	  uint16_t to = tokenMessagePacket->destination;
	  uint16_t content = tokenMessagePacket->payload;

	  if (TOS_NODE_ID == 0) {
	    printf("Message received From: %d To: %d Message: %04X\n", from, to, content);
	    printfflush();
	    call Leds.led2On(); //Turn on Rx light.
	    call Timer3.startOneShot(500); //Turn off the Rx light
		sendPacket(to,content); //Forward the packet
	  }
	  else //We're an edge node.
	  {
		if (((to % 4)+1) == TOS_NODE_ID) { //Then this is a packet meant for us.
		  call Leds.led2On(); //Turn on Rx light.
		  call Timer3.startOneShot(500); //Turn off the Rx light
		}
	  }
    }
    return message;
  }
}

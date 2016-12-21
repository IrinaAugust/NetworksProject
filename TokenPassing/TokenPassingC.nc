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
  uint8_t randomDestination = 0;
  uint16_t edgeNodeAddr = 0;

  event void Boot.booted() {
    call AMControl.start();
  }

  //We blink this over and over when we notice an error.
  event void Timer1.fired() {
    call Leds.led0Toggle();
    call Leds.led1Toggle();
    call Leds.led2Toggle();
  }

  //Just to turn the LED's off
  event void Timer2.fired() {
    call Leds.led0Off();
    call Leds.led1Off();
    call Leds.led2Off();
  }

  //Transmission code
  event void Timer0.fired() {
    if (!radioLocked) {
      TokenMessage* tokenMessagePacket = (TokenMessage*)(call Packet.getPayload(&packet, sizeof(TokenMessage)));

      randomDestination = call Random.rand16(); //Generate random number.
      randomDestination = (randomDestination % 89) + 10; //Make that random number between 10 and 99.
      tokenMessagePacket->destination = randomDestination;
      tokenMessagePacket->payload = 0xBEEF; //Or whatever other payload you like.
      tokenMessagePacket->source = TOS_NODE_ID; //Makes it easier to print out the ID of the sender.

      if (call AMSend.send(0xFFFF, &packet, sizeof(TokenMessage)) == SUCCESS) { //0xFF for broadcasting.
        radioLocked = TRUE;
      }
      else {
        //Packet was not accepted. Bad packet somehow.
        call Timer1.startPeriodic(100);
      }
    }
    else {
      //Radio was locked for some odd reason
      call Timer1.startPeriodic(100);
    }
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
      call Leds.led0On();
      call Leds.led1On();
      call Leds.led2On();
      call Timer2.startOneShot(1000);
    }
    else {
      call Timer1.startPeriodic(100); //Errors.
    }
  }

  event message_t* Receive.receive(message_t* message, void* payload, uint8_t length) {
    if (length == sizeof(TokenMessage)) {
      TokenMessage* tokenMessagePacket = (TokenMessage*)payload;
	  if (TOS_NODE_ID == 0) {
	    uint16_t from = tokenMessagePacket->source;
	    uint16_t to = tokenMessagePacket->destination;
	    uint16_t content = tokenMessagePacket->payload;
	    printf("Message received From: %d To: %d Message: %04X\n", from, to, content);
	    printfflush();
	    call Leds.led0On();
            call Leds.led1On();
            call Leds.led2On();
	    call Timer2.startOneShot(500);
	  }
    }
    return message;
  }
}

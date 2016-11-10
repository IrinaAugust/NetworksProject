/**
 * TokenPassing is a simple "token passing" program. It creates a list of the
 * nodes to be used for the routing, and generates a token to be passed along,
 * toggling the LEDs in the genomotes.
 *
 * @author Group 2
 * @date November 7th, 2016
 */

#include "Timer.h"

#define MAX_NODES 2

module TokenPassingC @safe()
{
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as Timer1;

  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;

  uses interface Receive;

}
implementation
{
  bool radioLocked = FALSE;
  message_t packet;
  uint8_t nextNodeAddr = 0;

  event void Boot.booted() {
    call AMControl.start();
  }

  event void Timer1.fired() {
    call Leds.led0Toggle();
    call Leds.led1Toggle();
    call Leds.led2Toggle();
  }

  //Transmission code
  event void Timer0.fired() {
    if (!radioLocked) {
      TokenMessage* tokenMessagePacket = (TokenMessage*)(call Packet.getPayload(&packet, sizeof(TokenMessage)));
      tokenMessagePacket->payload = 0xBEEF; //Or random other payload.

      //bump up to next node id.
      //nextNodeAddr = (TOS_NODE_ID + 1) % MAX_NODES;

      if (TOS_NODE_ID == 1) {
        nextNodeAddr = 0;
      }
      if (TOS_NODE_ID == 0) {
        nextNodeAddr = 1;
      }

      if (call AMSend.send(nextNodeAddr, &packet, sizeof(TokenMessage)) == SUCCESS) {
        radioLocked = TRUE;
        call Leds.led0Off();
        call Leds.led1Off();
        call Leds.led2Off();
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
      if (0 == TOS_NODE_ID) { //If base station, generate the token.
        call Leds.led0On();
        call Leds.led1On();
        call Leds.led2On();
        call Timer0.startOneShot(3000);
      }
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
    }
    else {
      //Probably snow in hell.
      call Timer1.startPeriodic(100);
    }
  }

  event message_t* Receive.receive(message_t* message, void* payload, uint8_t length) {
    //call Timer1.startPeriodic(500);
    if (length == sizeof(TokenMessage)) {
      TokenMessage* tokenMessagePacket = (TokenMessage*)payload;
      //tokenMessagePacket->payload now contains whatever we are passing around.

      //call Timer1.startPeriodic(500);
      call Leds.led0On();
      call Leds.led1On();
      call Leds.led2On();
      call Timer0.startOneShot(1000);
    }
    return message;
  }
}

/*
call AMPacket.isForMe(msg)
*/

/**
 * TokenPassing is a simple "token passing" program. It creates a list of the
 * nodes to be used for the routing, and generates a token to be passed along,
 * toggling the LEDs in the genomotes.
 *
 * @author Group 2
 * @date November 7th, 2016
 */

#include "Timer.h"

module TokenPassingC @safe()
{
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;

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

  event void Boot.booted() {
    call AMControl.start();
  }

  event void Timer0.fired() {
    if (!radioLocked) {
      TokenMessage* tokenMessagePacket = (TokenMessage*)(call Packet.getPayload(&packet, sizeof(TokenMessage)));
      tokenMessagePacket->payload = 0xBEEF; //Or random other payload.

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(TokenMessage)) == SUCCESS) { //Change to next node in the list, not AM_BROADCAST_ADDR.
        radioLocked = TRUE;
      }
      else {
        //Packet was not accepted. Bad packet somehow.
      }
    }
    else {
      //Radio was locked for some odd reason
    }

    call Leds.led0Off();
  }

  event void AMControl.startDone(error_t error) {
    if (error != SUCCESS) {
      call AMControl.start();
    }
    else {
      if (0 == TOS_NODE_ID) { //If this node has been designated as the base station
        call Leds.led0On();
        call Timer0.startOneShot(3000);
      }
      while (1) { //Now just act like any node on the ring.
        call Leds.led0On();
        call Timer0.startOneShot(1000);
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
    }
  }

  event message_t* Receive.receive(message_t* message, void* payload, uint8_t length) {
    if (length == sizeof(TokenMessage)) {
      TokenMessage* tokenMessagePacket = (TokenMessage*)payload;
      //tokenMessagePacket->payload now contains whatever we are passing around.
      //No processing requirements as of yet.
    }
    return message;
  }
}

/*
call AMSend.send("the address", msg, len)
call AMPacket.isForMe(msg)
call AMSend.send(AM_BROADCAST_ADDR, &pkt, len)
*/

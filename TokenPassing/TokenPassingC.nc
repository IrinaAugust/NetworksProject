/**
 * TokenPassing is a simple "token passing" program. It creates a list of the
 * nodes to be used for the routing, and generates a token to be passed along,
 * toggling the LEDs in the genomotes.
 *
 * @author Group 2
 * @date November 7th, 2016
 */

#include "Timer.h"

#define BASE_STATION A6005whe

module TokenPassingC @safe()
{
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
}
implementation
{
  event void Boot.booted() {
    //do we need to turn the radio on first?

    if (BASE_STATION = TOS_NODE_ID) { //If this node has been designated as the base station
      call Leds.led0On();
      //generate random token
      call Timer0.start(TIMER_ONE_SHOT, 3000);
    }

    while (1) { //Now just act like any node on the ring.
      //wait for a token addressed to me 
        //does this involve listening to all Tx's?
      //get token
      call Leds.led0On();
      call Timer0.start(TIMER_ONE_SHOT, 1000);
    }
  }

  event void Timer0.fired() {
    call Leds.led0Off();
    //send token to next node in the list
      //Error checking required for good send?
  }
}


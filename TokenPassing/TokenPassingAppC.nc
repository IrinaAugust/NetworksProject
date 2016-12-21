/**
 * TokenPassing is a simple "token passing" program. It has a list of the
 * nodes to be used for the routing, and generates a token to be passed along,
 * toggling the LEDs in the genomotes.
 *
 * @author Group 2
 * @date November 7th, 2016
 */

#include "TokenPassing.h"
#include <printf.h>

configuration TokenPassingAppC {

}
implementation {
  components MainC, TokenPassingC, LedsC;
  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;
  components new TimerMilliC() as Timer3;
  components ActiveMessageC;
  components new AMSenderC(AM_TOKEN);
  components new AMReceiverC(AM_TOKEN);
  components RandomC;
  components PrintfC;

  TokenPassingC.Boot -> MainC.Boot;
  TokenPassingC.Leds -> LedsC;
  TokenPassingC.Timer0 -> Timer0;
  TokenPassingC.Timer1 -> Timer1;
  TokenPassingC.Timer2 -> Timer2;
  TokenPassingC.Timer3 -> Timer3;
  TokenPassingC.Packet -> AMSenderC;
  TokenPassingC.AMPacket -> AMSenderC;
  TokenPassingC.AMSend -> AMSenderC;
  TokenPassingC.AMControl -> ActiveMessageC;
  TokenPassingC.Receive -> AMReceiverC;
  TokenPassingC.Random -> RandomC;
}

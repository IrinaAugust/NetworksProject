/**
 * TokenPassing is a simple "token passing" program. It creates a list of the
 * nodes to be used for the routing, and generates a token to be passed along,
 * toggling the LEDs in the genomotes.
 *
 * @author Group 2
 * @date November 7th, 2016
 */

#include "TokenPassing.h"

configuration TokenPassingAppC {
  //Nobody should be using this
}
implementation {
  components MainC, TokenPassingC, LedsC;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_TOKEN);
  components new AMReceiverC(AM_TOKEN);

  TokenPassingC.Boot -> MainC.Boot;
  TokenPassingC.Leds -> LedsC;
  TokenPassingC.Timer0 -> Timer0;

  TokenPassingC.Packet -> AMSenderC;
  TokenPassingC.AMPacket -> AMSenderC;
  TokenPassingC.AMSend -> AMSenderC;
  TokenPassingC.AMControl -> ActiveMessageC;

  TokenPassingC.Receive -> AMReceiverC;
}

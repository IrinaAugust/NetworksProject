/**
 * TokenPassing is a simple "token passing" program. It creates a list of the
 * nodes to be used for the routing, and generates a token to be passed along,
 * toggling the LEDs in the genomotes.
 *
 * @author Group 2
 * @date November 7th, 2016
 */

configuration TokenPassingAppC {
  //Nobody should be using this
}
implementation {
  components MainC, TokenPassingC, LedsC;
  components new TimerMilliC() as Timer0;

  //ActiveMessageC would send radio messages.

  TokenPassingC.Boot -> MainC.Boot;
  TokenPassingC.Leds -> LedsC;
  TokenPassingC.Timer0 -> Timer0;
}


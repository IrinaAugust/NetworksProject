/**
 * TokenPassing is a simple "token passing" program. It creates a list of the
 * nodes to be used for the routing, and generates a token to be passed along,
 * toggling the LEDs in the genomotes.
 *
 * @author Group 2
 * @date November 7th, 2016
 */

configuration TokenPassingAppC{}
implementation {
  components MainC, TokenPassingC;

  MainC.Boot <- TokenPassingC;
}


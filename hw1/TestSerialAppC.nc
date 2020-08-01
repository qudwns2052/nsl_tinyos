#include "TestSerial.h"

configuration TestSerialAppC {}
implementation {
  components TestSerialC as App, LedsC, MainC;
  components SerialActiveMessageC as Serial;
  components ActiveMessageC as Radio;
  components new AMSenderC(AM_BLINKTORADIO);
  components new TimerMilliC();
  components new AMReceiverC(AM_BLINKTORADIO);

  App.Boot -> MainC.Boot;
  App.Control -> Serial;
  App.AMControl -> Radio;
  App.RadioReceive -> AMReceiverC;
  App.RadioSend -> AMSenderC;
  App.SerialReceive -> Serial.Receive[AM_TEST_SERIAL_MSG];
  App.SerialSend -> Serial.AMSend[AM_TEST_SERIAL_MSG];
  App.AMPacket -> AMSenderC;
  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;
  App.RadioPacket -> AMSenderC;
  App.SerialPacket -> Serial;
}



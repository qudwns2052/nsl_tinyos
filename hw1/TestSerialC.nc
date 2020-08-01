// $Id: TestSerialC.nc,v 1.7 2010-06-29 22:07:25 scipio Exp $

/*									tab:4
 * Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Application to test that the TinyOS java toolchain can communicate
 * with motes over the serial port. 
 *
 *  @author Gilman Tolle
 *  @author Philip Levis
 *  
 *  @date   Aug 12 2005
 *
 **/

#include "Timer.h"
#include "TestSerial.h"

module TestSerialC {
  uses {
    interface SplitControl as Control;
    interface SplitControl as AMControl;
    interface Leds;
    interface Boot;

    interface Receive as RadioReceive;
    interface AMSend as RadioSend;
    interface Receive as SerialReceive;
    interface AMSend as SerialSend;
    
    interface Packet as RadioPacket;
    interface Packet as SerialPacket;
    interface Timer<TMilli> as MilliTimer;
    interface AMPacket;
  }
}

implementation {

  message_t packet;
  bool locked = FALSE;
  uint16_t counter = 0;
  
  event void Boot.booted() {
    call Control.start();
    call AMControl.start();
  }
  
  event void MilliTimer.fired() {
//    counter++;
//    if (!locked) {
//        BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&packet, sizeof (BlinkToRadioMsg)));
//       btrpkt->nodeid = TOS_NODE_ID;
//        btrpkt->counter = counter;
//        if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(BlinkToRadioMsg)) == SUCCESS) {
//          locked = TRUE;
//        }
//     }
//    
  }

  event void RadioSend.sendDone(message_t* msg, error_t error) {
  }

  event void SerialSend.sendDone(message_t* msg, error_t error) {
  }

  event message_t* SerialReceive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
       
       test_serial_msg_t* rcm = (test_serial_msg_t*)payload;
       BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call RadioPacket.getPayload(&packet, sizeof (BlinkToRadioMsg)));
       btrpkt->data = rcm->counter;

       if (call RadioSend.send(AM_BROADCAST_ADDR, &packet, sizeof(BlinkToRadioMsg)) == SUCCESS) {
	       call Leds.led0Toggle();
	}

      return bufPtr;
  }

  event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
    BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
    test_serial_msg_t* rcm = (test_serial_msg_t*)call SerialPacket.getPayload(&packet, sizeof(test_serial_msg_t));
    rcm->counter = btrpkt->data;
      if (call SerialSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_serial_msg_t)) == SUCCESS) {
		call Leds.led1Toggle();
      }

  
  return msg;
}


  event void Control.startDone(error_t err) {
    if (err == SUCCESS) {
//      call MilliTimer.startPeriodic(1000);
    }
    else {
	call Control.start();
    }
  }

  event void Control.stopDone(error_t err) {}



  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
//      call MilliTimer.startPeriodic(1000);
    }
    else {
      call AMControl.start();
    }
  }

event void AMControl.stopDone(error_t err) {}

}



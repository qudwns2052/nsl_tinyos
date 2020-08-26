// $Id: RadioCountToLedsC.nc,v 1.6 2008/06/24 05:32:31 regehr Exp $

/*									tab:4
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
 
#include "Timer.h"
#include "TestRPL.h"
#include "lib6lowpan/ip.h"
//#include "color.h"

#include "blip_printf.h"
/**
 * Implementation of the RadioCountToLeds application. RadioCountToLeds 
 * maintains a 4Hz counter, broadcasting its value in an AM packet 
 * every time it gets updated. A RadioCountToLeds node that hears a counter 
 * displays the bottom three bits on its LEDs. This application is a useful 
 * test to show that basic AM communication and timers work.
 *
 * @author Philip Levis
 * @date   June 6 2005
 */

module TestRPLC @safe() {
  uses {
    interface Leds;
    interface Boot;
    interface Timer<TMilli> as MilliTimer;
    interface Timer<TMilli> as Timer;
    interface RPLRoutingEngine as RPLRoute;
    interface RootControl;
    interface StdControl as RoutingControl;
    interface SplitControl;
    //interface IP as RPL;
    interface UDP as RPLUDP;
    //interface RPLForwardingEngine;
    interface RPLDAORoutingEngine as RPLDAO;
    interface Random;
    //interface Lcd;
    //interface Draw;


    interface Receive;
    interface AMSend;
    interface Packet;

  }
}

implementation {


#ifndef RPL_ROOT_ADDR
#define RPL_ROOT_ADDR 1
#endif

#define UDP_PORT 5678

   message_t packet;
    
    //uint8_t payload[10];
  //struct in6_addr dest;
  struct in6_addr MULTICAST_ADDR;


  bool locked;
  uint16_t counter = 0;
  
  event void Boot.booted() {
    memset(MULTICAST_ADDR.s6_addr, 0, 16);
    MULTICAST_ADDR.s6_addr[0] = 0xFF;
    MULTICAST_ADDR.s6_addr[1] = 0x2;
    MULTICAST_ADDR.s6_addr[15] = 0x1A;

    
    //call Lcd.initialize();

    if(TOS_NODE_ID == RPL_ROOT_ADDR){
      call RootControl.setRoot();
    }
    call RoutingControl.start();
    //call RoutingControl.start();
    call SplitControl.start();

    call RPLUDP.bind(UDP_PORT);
  }

  /*
    event void Lcd.initializeDone(error_t err)
    {
        if(err != SUCCESS)
        {
        }
        else
        {
            call Draw.fill(COLOR_RED);
            call Lcd.start();
        }
    }

    event void Lcd.startDone()
    {
    }
  */


  uint32_t countrx = 0;
  uint32_t counttx = 0;


    event message_t* Receive.receive(message_t* bufPtr,
				   void* payload, uint8_t len) {
    if (len != sizeof(test_serial_msg_t)) {return bufPtr;}
    else {

        test_serial_msg_t* rcm = (test_serial_msg_t*)payload;
        nx_uint16_t temp[10];
        uint8_t i;
        struct sockaddr_in6 dest;

        for(i=0;i<10;i++){
            temp[i] = 0xABCD;
        }

        temp[0] = TOS_NODE_ID;
        temp[9] = rcm->counter;


        memcpy(dest.sin6_addr.s6_addr, MULTICAST_ADDR.s6_addr, sizeof(struct in6_addr));

        call Leds.led1Toggle();

    
        dest.sin6_port = htons(UDP_PORT);
        
        call RPLUDP.sendto(&dest, temp, 20);
        return bufPtr;
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }


  event void RPLUDP.recvfrom(struct sockaddr_in6 *from, void *payload, uint16_t len, struct ip6_metadata *meta){

    nx_uint16_t temp[10];

    struct in6_addr parent;
    uint8_t i;

    memcpy(temp, (uint8_t*)payload, len);

    if(TOS_NODE_ID != 1)
    {
        call Leds.led1Toggle();
        printf("Command = %d\n", temp[9]);

        switch(temp[9])
        {
            case 0:
                call MilliTimer.stop();
                printf("Timer Stop\n");
                printfflush();
                break;
            case 1:
                call MilliTimer.startOneShot(PACKET_INTERVAL + (call Random.rand16() % 100));
                printf("Timer Start\n");
                printfflush();
                break;
            default:
                break;
        }
    }

    else
    {
        call Leds.led2Toggle();
        printf(">>>> RX %d to %d (parent = %d. RSSI = %u) \n", TOS_NODE_ID, temp[0], temp[9], meta->rssi);
        printfflush();
    }
  }
  
  event void SplitControl.startDone(error_t err){
    while( call RPLDAO.startDAO() != SUCCESS );
    
    if(TOS_NODE_ID != RPL_ROOT_ADDR){
      call Timer.startOneShot((call Random.rand16()%2)*2048U);
    }
  }

  event void Timer.fired(){
    call MilliTimer.startOneShot(PACKET_INTERVAL + (call Random.rand16() % 100));
  }

  task void sendTask(){
    struct sockaddr_in6 dest;

    nx_uint16_t temp[10];
    uint8_t i;


    struct in6_addr parent;


    //call Draw.fill(COLOR_BLACK);
    for(i=0;i<10;i++){
      temp[i] = 0xABCD;
    }

    call RPLRoute.getDefaultRoute(&parent);

    temp[0] = TOS_NODE_ID;
    temp[9] = parent.s6_addr[15];

    memcpy(dest.sin6_addr.s6_addr, call RPLRoute.getDodagId(), sizeof(struct in6_addr));

    if(dest.sin6_addr.s6_addr[15] != 0) // destination is set as root!
      ++counttx;

    //if(dest.sin6_addr.s6_addr[0] == 0xAA)
    call Leds.led0Toggle();

    dest.sin6_port = htons(UDP_PORT);


//    printf("Generate Packet at %d to ", TOS_NODE_ID);
//    for (i = 0; i < 15; i++)
//    {
//        printf("%02x", dest.sin6_addr.s6_addr[i]);
//    }
//    printf("%02x\n", dest.sin6_addr.s6_addr[15]);

    printf(">>>> TX %d to %d\n", TOS_NODE_ID, temp[9]);
    printfflush();
    call RPLUDP.sendto(&dest, temp, 20);
  }

  event void MilliTimer.fired(){
    //call Leds.led1Toggle();
    call MilliTimer.startOneShot(PACKET_INTERVAL + (call Random.rand16() % 100));
    post sendTask();
  }

  event void SplitControl.stopDone(error_t err){}


}

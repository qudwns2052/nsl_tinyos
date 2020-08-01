
#ifndef TEST_SERIAL_H
#define TEST_SERIAL_H

typedef nx_struct test_serial_msg {
  nx_uint16_t counter;
} test_serial_msg_t;

enum {
  AM_TEST_SERIAL_MSG = 0x89,
};

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t data;
} BlinkToRadioMsg;



#endif

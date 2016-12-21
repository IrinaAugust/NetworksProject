
#ifndef TOKENPASSING_H
#define TOKENPASSING_H

enum {
  AM_TOKEN = 6
};

typedef nx_struct TokenMessage {
  nx_uint16_t source;
  nx_uint16_t destination;
  nx_uint8_t payload[9];
} TokenMessage;

#endif

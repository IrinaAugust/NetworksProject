
#ifndef TOKENPASSING_H
#define TOKENPASSING_H

enum {
  AM_TOKEN = 6,
  BASE_STATION = "A6005whe"
};

typedef nx_struct TokenMessage {
  nx_uint16_t payload;
} TokenMessage;

#endif

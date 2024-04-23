#include "ruby.h"

#define TP_EVENT_CALL (RUBY_EVENT_CALL | RUBY_EVENT_C_CALL)
#define TP_EVENT_RETURN (RUBY_EVENT_RETURN | RUBY_EVENT_C_RETURN)

typedef struct {
  VALUE self;
  VALUE trace_point;
} Session;

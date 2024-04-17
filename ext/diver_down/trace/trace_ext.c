#include "ruby/ruby.h"

static VALUE
dd_trace_session_test(VALUE session)
{
	/* rubyのputs "helloworld"を呼び出す */
	rb_funcall(rb_mKernel, rb_intern("puts"), 1, rb_str_new_cstr("helloworld"));

    return Qnil;
}

void
Init_trace_ext(void) 
{
	VALUE rb_mDiverDown = rb_const_get(rb_cObject, rb_intern("DiverDown"));
	VALUE rb_mDiverDownTrace = rb_const_get(rb_mDiverDown, rb_intern("Trace"));
	VALUE rb_cDiverDownTraceSession = rb_const_get(rb_mDiverDownTrace, rb_intern("Session"));

	rb_define_method(rb_cDiverDownTraceSession, "test", dd_trace_session_test, 0);
}

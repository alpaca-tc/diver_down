#include "ruby/ruby.h"
#include "ruby/debug.h"

static VALUE
dd_trace_session_start(VALUE session)
{
	/* インスタンス変数 @trace_point を取得する */
	VALUE trace_point = rb_iv_get(session, "@trace_point");
	rb_tracepoint_enable(trace_point);

    return Qnil;
}

static VALUE
dd_trace_session_stop(VALUE session)
{
	/* インスタンス変数 @trace_point を取得する */
	VALUE trace_point = rb_iv_get(session, "@trace_point");
	rb_tracepoint_disable(trace_point);

    return Qnil;
}


void
Init_trace_ext(void) 
{
	VALUE rb_mDiverDown = rb_const_get(rb_cObject, rb_intern("DiverDown"));
	VALUE rb_mDiverDownTrace = rb_const_get(rb_mDiverDown, rb_intern("Trace"));
	VALUE rb_cDiverDownTraceSession = rb_const_get(rb_mDiverDownTrace, rb_intern("Session"));

	rb_define_method(rb_cDiverDownTraceSession, "start", dd_trace_session_start, 0);
	rb_define_method(rb_cDiverDownTraceSession, "stop", dd_trace_session_stop, 0);
}

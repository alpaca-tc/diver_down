#include "diver_down_trace_ext.h"
#include "ruby/ruby.h"
#include "ruby/debug.h"

VALUE cTracePoint;
VALUE mDiverDownTrace;
VALUE cDiverDownTraceSession;

static size_t dd_session_memsize(const void *data) { 
	return sizeof(Session); 
}

static void dd_session_gc_mark(void *data) {
  Session *session = (Session *)data;
  rb_gc_mark(session->trace_point);
}

static void dd_session_cleanup(Session *session) {
	if (RB_TYPE_P(session->trace_point, T_DATA) && CLASS_OF(session->trace_point) == cTracePoint) {
		rb_tracepoint_disable(session->trace_point);
	}
}

static void dd_session_free(void *data) {
  Session *session = (Session *)data;
  dd_session_cleanup(session);
  xfree(session);
}

static const rb_data_type_t dd_session_data_type = {
	.wrap_struct_name = "Session",
	.function = {
		.dmark = dd_session_gc_mark,
		.dfree = dd_session_free,
		.dsize = dd_session_memsize,
	},
	.flags = RUBY_TYPED_FREE_IMMEDIATELY
};

static Session *current_session(VALUE self) {
  Session *session;
  TypedData_Get_Struct(self, Session, &dd_session_data_type, session);

  return session;
}

static VALUE
dd_session_start(VALUE self)
{
	Session *session = current_session(self);
	rb_tracepoint_enable(session->trace_point);

    return Qnil;
}

static VALUE
dd_session_stop(VALUE self)
{
	Session *session = current_session(self);
	rb_tracepoint_disable(session->trace_point);

    return Qnil;
}

static void dd_session_tracepoint_hook(VALUE tp, void *data) {
	Session *session = (Session *)data;

	VALUE trace_point_proc = rb_iv_get(session->self, "@trace_point_proc");

	rb_trace_arg_t *trace_arg = rb_tracearg_from_tracepoint(tp);

	if (rb_tracearg_defined_class(trace_arg) == cDiverDownTraceSession) {
		return;
	}

	rb_event_flag_t event_flag = rb_tracearg_event_flag(trace_arg);

	// NOTE: only call, c_call, return and c_return
	if (event_flag & TP_EVENT_CALL) {
		rb_funcall(trace_point_proc, rb_intern("call"), 1, tp);
	} else if (event_flag & TP_EVENT_RETURN) {
		VALUE call_stack = rb_iv_get(session->self, "@call_stack");
		rb_funcall(call_stack, rb_intern("pop"), 0);
	} 
}

static VALUE
dd_session_alloc(VALUE klass)
{
	Session *session;
	VALUE self = TypedData_Make_Struct(klass, Session, &dd_session_data_type, session);
	session->self = self;
	session->trace_point = rb_tracepoint_new(
		Qnil, 
		// TODO: only_ruby_events
		TP_EVENT_CALL | TP_EVENT_RETURN,
		dd_session_tracepoint_hook, 
		(void *)session
	);

	return self;
}

void
Init_diver_down_trace_ext(void) 
{
	cTracePoint = rb_const_get(rb_cObject, rb_intern("TracePoint"));

	VALUE mDiverDown = rb_const_get(rb_cObject, rb_intern("DiverDown"));
	mDiverDownTrace = rb_const_get(mDiverDown, rb_intern("Trace"));
	cDiverDownTraceSession = rb_const_get(mDiverDownTrace, rb_intern("Session"));

	rb_define_alloc_func(cDiverDownTraceSession, dd_session_alloc);
	rb_define_method(cDiverDownTraceSession, "start", dd_session_start, 0);
	rb_define_method(cDiverDownTraceSession, "stop", dd_session_stop, 0);
}

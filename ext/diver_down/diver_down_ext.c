#include "ruby/ruby.h"

static VALUE
dd_helper_module_p(VALUE helper, VALUE obj) {
	return rb_obj_is_kind_of(obj, rb_cModule);
}

static VALUE
dd_helper_class_p(VALUE helper, VALUE obj) {
	return rb_obj_is_kind_of(obj, rb_cClass);
}

static VALUE
dd_helper_resolve_module(VALUE helper, VALUE obj) {
	if (rb_obj_is_kind_of(obj, rb_cModule)) {
		return rb_funcall(helper, rb_intern("resolve_singleton_class"), 1, obj);
	} else {
		VALUE klass = rb_obj_class(obj);
		return rb_funcall(helper, rb_intern("resolve_singleton_class"), 1, klass);
	}
}

static VALUE
dd_helper_resolve_singleton_class(VALUE helper, VALUE klass) {
	if (rb_funcall(klass, rb_intern("singleton_class?"), 0) == Qtrue) {
	    return rb_class_attached_object(klass);
	} else {
		return klass;
	}
}

static VALUE
dd_helper_normalize_module_name(VALUE helper, VALUE resolved_mod) {
	VALUE mod_name = rb_mod_name(resolved_mod);

	if (mod_name == Qnil) {
		return rb_funcall(resolved_mod, rb_intern("name"), 0);
	} else {
		return mod_name;
	}
}


void Init_diver_down_helper(void) {
	VALUE rb_mDiverDown = rb_const_get(rb_cObject, rb_intern("DiverDown"));
	VALUE rb_mDiverDownHelper = rb_const_get(rb_mDiverDown, rb_intern("Helper"));

	rb_define_singleton_method(rb_mDiverDownHelper, "module?", dd_helper_module_p, 1);
	rb_define_singleton_method(rb_mDiverDownHelper, "class?", dd_helper_class_p, 1);
	rb_define_singleton_method(rb_mDiverDownHelper, "resolve_singleton_class", dd_helper_resolve_singleton_class, 1);
	rb_define_singleton_method(rb_mDiverDownHelper, "resolve_module", dd_helper_resolve_module, 1);
	rb_define_singleton_method(rb_mDiverDownHelper, "normalize_module_name", dd_helper_normalize_module_name, 1);
}

void Init_diver_down_ext(void) {
	Init_diver_down_helper();
}

#include <sys/types.h>
#include <stdio.h>
#include <ruby.h>
#include <idn2.h>

static VALUE rb_idn2_strerror(VALUE self, VALUE errcode){
    const char *res;
    res = idn2_strerror(NUM2INT(errcode));
    return res ? rb_str_new_cstr(res) : Qnil;
}

void
Init_testgem2(void)
{
    VALUE lg = rb_define_class("Idn2", rb_cObject);
    rb_define_singleton_method(lg, "idn2_strerror", rb_idn2_strerror, 1);
}

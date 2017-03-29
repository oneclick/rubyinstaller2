#include <sys/types.h>
#include <stdio.h>
#include <ruby.h>
#include <libguess.h>

static VALUE determine_encoding(VALUE self, VALUE string, VALUE langset){
    const char *res;
    StringValue(string);
    res = libguess_determine_encoding(RSTRING_PTR(string), RSTRING_LENINT(string), StringValueCStr(langset));
    return res ? rb_str_new_cstr(res) : Qnil;
}

void
Init_testgem(void)
{
    VALUE lg = rb_define_class("Libguess", rb_cObject);
    rb_define_singleton_method(lg, "determine_encoding", determine_encoding, 2);

    libguess_init();
}

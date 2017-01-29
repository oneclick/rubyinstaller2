#!/usr/bin/env ruby

require 'mkmf'
require 'rbconfig'

have_header('sys/types.h') || raise("have_header should find std header files")
have_func('rb_thread_call_with_gvl') || raise("have_func should find libruby symbols")

create_makefile("testgem")

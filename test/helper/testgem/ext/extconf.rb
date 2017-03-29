#!/usr/bin/env ruby

require 'mkmf'
require 'rbconfig'

$CFLAGS << " -Wall -Wcast-qual -Wwrite-strings -Wconversion -Wmissing-noreturn -Winline"

have_header('sys/types.h') || raise("have_header should find std header files")
have_func('rb_thread_call_with_gvl') || raise("have_func should find libruby symbols")

message "checking for libguess package: "
pkg = pkg_config('libguess') || raise("pkg_config should find the config")
message "#{pkg.inspect}\n"
have_func('libguess_determine_encoding') || raise("have_func should find the pkgconfig library")

create_makefile("testgem")

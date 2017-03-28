#!/usr/bin/env ruby

require 'mkmf'
require 'rbconfig'

$CFLAGS << " -Wall -Wcast-qual -Wwrite-strings -Wconversion -Wmissing-noreturn -Winline"

have_header('sys/types.h') || raise("have_header should find std header files")
have_func('rb_thread_call_with_gvl') || raise("have_func should find libruby symbols")

message "checking for yaml-1.0 package "
pkg = pkg_config('yaml-0.1') || raise("pkg_config should find the config")
message "#{pkg.inspect}\n"
have_func('yaml_get_version_string') || raise("have_func should find the pkgconfig library")

create_makefile("testgem")

require 'mkmf'

message "checking for libidn2 package: "
pkg = pkg_config('libidn2') || raise("pkg_config should find the config")
message "#{pkg.inspect}\n"
have_func('idn2_strerror') || raise("have_func should find the pkgconfig library")

create_makefile("testgem2")

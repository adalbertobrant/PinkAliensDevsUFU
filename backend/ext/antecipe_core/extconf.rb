require 'mkmf'
require 'rice'

gem_dir = Gem.loaded_specs['rice'].gem_dir
$CXXFLAGS << " -std=c++17 -O2 -I#{gem_dir}/include"

create_makefile('antecipe_core')

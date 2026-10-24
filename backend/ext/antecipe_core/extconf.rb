require 'mkmf'
require 'rice'

gem_dir = '/home/adalberto/.rvm/gems/ruby-3.4.12/gems/rice-4.12.0'
$CXXFLAGS << " -std=c++17 -I#{gem_dir}/include"

create_makefile('antecipe_core')

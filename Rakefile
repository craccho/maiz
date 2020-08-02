require 'pry'
require_relative 'maiz.rb'

desc 'run main file'
task :run do |t|
  Maiz.run!
end

desc 'debug task'
task 'debug' do |t|
  pry binding
end

desc 'make png files'
task png: ['doc/program.png']

rule '.png' => ['.dot'] do |t|
  sh "dot #{t.source} -Tpng > #{t.name}"
end

desc 'run task forever watching file changes'
task :forever, [:task] do |t, args|
  sh "fswatch -o . | xargs -n1 -I{} rake #{args.task}"
end

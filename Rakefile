require 'rubygems'
require 'rake'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = "VivoOrgChart"
  s.version = "0.3.1"
  s.author = "Alex Rockwell"
  s.email = "alexhr@ufl.edu"
  s.homepage = "http://vivo.ufl.edu"
  s.summary = "Creates graphs of the academic structure based on vivo data."
  s.files = FileList["lib/**/*"].to_a
  s.require_path = "lib"
  s.has_rdoc = false
  s.add_runtime_dependency 'rdf-raptor'
  s.add_runtime_dependency 'ruby-graphviz'
  s.add_runtime_dependency 'mechanize'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

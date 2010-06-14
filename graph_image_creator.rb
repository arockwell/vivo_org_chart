#!/usr/bin/ruby

require 'rubygems'
require 'vivo_org_chart'
require 'rdf/raptor'
require 'graphviz'


start_uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
if ARGV.size == 1
  start_uri = ARGV[0]
end
puts start_uri

org_chart = VivoOrgChart::Base.new(start_uri)
org_chart.find_all_organizations

VivoOrgChart::TextFormatter.format(org_chart)

g = GraphViz.new(:G, "type" => "digraph", :sep => "1", :size => "170,300", :overlap => "orthoyx")
g.node[:margin] = 0.0
g.node[:fontsize] = 12
g = VivoOrgChart::GraphvizFormatter.format(g, org_chart)
g.output(:svg => "fdp.svg", :use => "twopi")

File.open("graphml.xml", "w") {|f| f.write(VivoOrgChart::GraphMLFormatter.format(org_chart)) }

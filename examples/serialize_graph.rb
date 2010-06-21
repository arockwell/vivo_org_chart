#!/usr/bin/ruby

require 'rubygems'
require 'vivo_org_chart'

start_uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
if ARGV.size == 1
  start_uri = ARGV[0]
end
puts start_uri

org_chart = VivoOrgChart::Base.new(start_uri)
org_chart.find_all_organizations

VivoOrgChart::TextFormatter.format(org_chart)

org_chart.serialize('uf_org.nt')

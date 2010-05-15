#!/usr/bin/ruby

require 'rubygems'
require 'rdf/raptor'

def find_sub_organizations(uri)
	graph = RDF::Graph.load(uri)
	sub_org_uri = "http://vivoweb.org/ontology/core#hasSubOrganization"
	sub_org_pred = RDF::URI.new(sub_org_uri)
	sub_orgs = []
	graph.query(:predicate => sub_org_pred).each_statement { |s| sub_orgs.push(s.object) }
	
	return sub_orgs
end

def generate_rdf_uri(uri)
	regex =	Regexp.new("http://vivo.ufl.edu/individual/(.+)")
	uri + "/" + uri.match(regex)[1] + ".rdf"
end

uf_uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
uf_rdf_uri = generate_rdf_uri(uf_uri)
puts uf_rdf_uri

uf_key = "University of Florida"
uf = { uf_key => [] }

uf[uf_key] = find_sub_organizations(uf_rdf_uri)

uf[uf_key].each do |sub_org| 
	puts "\t" + sub_org + "\n"
	depth = 2
	sub_org = find_sub_organizations(generate_rdf_uri(sub_org.to_s))
	sub_org.each do |x|
		puts "\t" * depth + x + "\n"
	end
end



#!/usr/bin/ruby

require 'rubygems'
require 'rdf/raptor'

# Data class to hold Organizations and constants relating to organizaitons
class Org
	HAS_SUB_ORG_URI = "http://vivoweb.org/ontology/core#hasSubOrganization"
	RDF_LABEL_URI = "http://www.w3.org/2000/01/rdf-schema#label"

	attr_accessor :name, :uri, :sub_orgs

	def initialize(name="",  uri="", sub_orgs=[])
		@name = name
		@uri = uri
		@sub_orgs = sub_orgs
	end
end

# Methods to pull the organizational structure out of vivo 
class OrgChart
	# Recursively search for sub_organizations given a starting uri
	def self.find_all_organizations(uri)
		uri = generate_rdf_uri(uri)
		puts "Retrieving uri: " + uri + "\n"
		begin 
			org_rdf = RDF::Graph.load(uri)
		rescue
			# If we get an error loading the uri return nil
			puts "Error retrieving uri"
			return nil
		end

		# Extract the rdf-label
		rdf_label_pred = RDF::URI.new(Org::RDF_LABEL_URI)
		name = org_rdf.query(:predicate => rdf_label_pred)[0].object.to_s
		# names are of the from "Name of Org"@en-us, reduce to name of Name of Org
		name = name.match(/"([^"]*)"/)[0]

		# Find all sub_org uris of the organization
		has_sub_org_pred = RDF::URI.new(Org::HAS_SUB_ORG_URI)
		sub_org_uris = []
		org_rdf.query(:predicate => has_sub_org_pred).each_statement do |subject| 
			sub_org_uris.push(subject.object.to_s) 
		end

		# Recur on every uri found
		sub_orgs = []
		sub_org_uris.each do |sub_org_uri|
			sub_org = find_all_organizations(sub_org_uri)
			# If we did not get an error retrieving the sub_org, add to the array
			if sub_org != nil
				sub_orgs.push(sub_org)
			end
		end

		# Build and return the org object of the current recursive step
		return Org.new(name, uri, sub_orgs) 
	end

	# Print the organization name and recursively print all sub_organizations
	def self.print_graph(org) 
		puts org.name.to_s + "\n"
		depth = 1
		if org.sub_orgs.size != 0
			org.sub_orgs.each do |sub_org|
				do_print_graph(sub_org, depth)
			end
		end
	end

	def self.do_print_graph(sub_org, depth)
		puts "\t" * depth + sub_org.name.to_s + "\n"
		depth = depth + 1	
		if sub_org.sub_orgs.size !=0
			sub_org.sub_orgs.each do |sub_org|
				do_print_graph(sub_org, depth)
			end
		end
	end	

	# Transform the vivo uri to a location we can retrieve rdf.
	# If you are using this at a vivo installation other than UF modify this
	# method accordingly.
	# This expands a url like 
	# http://vivo.ufl.edu/individual/UniversityofFlorida
	# to
	# http://vivo.ufl.edu/individual/UniversityofFlorida/UniversityofFlorida.rdf
	def self.generate_rdf_uri(uri)
		regex =	Regexp.new("http://vivo.ufl.edu/individual/(.+)")
		uri + "/" + uri.match(regex)[1] + ".rdf"
	end
end

# Start uri for the org chart.
uf_uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
puts uf_uri

# Create the graph
orgs = OrgChart.find_all_organizations(uf_uri)

#Print the graph
OrgChart.print_graph(orgs)

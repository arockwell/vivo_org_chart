#!/usr/bin/ruby

require 'rubygems'
require 'rdf/raptor'
require 'graphviz'

class Org
  attr_accessor :name, :uri, :sub_orgs

  def initialize(name="",  uri="", sub_orgs=[])
    @name = name
    @uri = uri
    @sub_orgs = sub_orgs
  end

  def to_s 
    puts "Name: " + @name + "\n"
    puts "URI: " + @uri + "\n"
  end
end

def find_all_colleges(uri)
  uri = generate_rdf_uri(uri)
  #puts "Retrieving uri: " + uri + "\n"
  begin 
    graph = RDF::Graph.load(uri)
  rescue
  # puts "Error retrieving uri : " + uri + "\n"
    return nil
  end
  sub_org_uri = "http://vivoweb.org/ontology/core#hasSubOrganization"
  sub_org_pred = RDF::URI.new(sub_org_uri)
  label_uri = "http://www.w3.org/2000/01/rdf-schema#label"
  label_pred = RDF::URI.new(label_uri)
  name = graph.query(:predicate => label_pred)[0].object.to_s
  name = (name != nil) ? name : ""
  name = name.match(/"([^"]*)"/)[0]

  sub_org_uris = []
  graph.query(:predicate => sub_org_pred).each_statement { |s| sub_org_uris.push(s.object.to_s) }
  sub_orgs = []
  sub_org_uris.each do |sub_org_uri|
    sub_org_individual = RDF::Graph.load(generate_rdf_uri(sub_org_uri))
    college_uri = "http://vivoweb.org/ontology/core#College"
    college_pred = RDF::URI.new(college_uri)
    if sub_org_individual.query(:object => college_pred).size != 0
      sub_org = find_all_organizations(sub_org_uri)
      sub_orgs.push(sub_org)
    end
  end
  org = Org.new(name, uri, sub_orgs)
  
  return org 
end
def find_all_organizations(uri)
  uri = generate_rdf_uri(uri)
  #puts "Retrieving uri: " + uri + "\n"
  begin 
    graph = RDF::Graph.load(uri)
  rescue
  # puts "Error retrieving uri : " + uri + "\n"
    return nil
  end
  sub_org_uri = "http://vivoweb.org/ontology/core#hasSubOrganization"
  sub_org_pred = RDF::URI.new(sub_org_uri)
  label_uri = "http://www.w3.org/2000/01/rdf-schema#label"
  label_pred = RDF::URI.new(label_uri)
  name = graph.query(:predicate => label_pred)[0].object.to_s
  name = (name != nil) ? name : ""
  name = name.match(/"([^"]*)"/)[0]

  sub_org_uris = []
  graph.query(:predicate => sub_org_pred).each_statement { |s| sub_org_uris.push(s.object.to_s) }
  sub_orgs = []
  sub_org_uris.each do |sub_org_uri|
    sub_org = find_all_organizations(sub_org_uri)
    sub_orgs.push(sub_org)
  end
  org = Org.new(name, uri, sub_orgs)
  
  return org 
end

def generate_rdf_uri(uri)
  regex = Regexp.new("http://vivo.ufl.edu/individual/(.+)")
  uri + "/" + uri.match(regex)[1] + ".rdf"
end

def graph_as_string(org) 
  puts org.name.to_s + "\n"
  depth = 1
  if org.sub_orgs.size != 0
    org.sub_orgs.each do |sub_org|
      do_graph_as_string(sub_org, depth)
    end
  end
end

def do_graph_as_string(sub_org, depth)
  if sub_org != nil
    puts "\t" * depth + sub_org.name.to_s + "\n"
    depth = depth + 1 
    if sub_org.sub_orgs.size !=0
      sub_org.sub_orgs.each do |sub_org|
        do_graph_as_string(sub_org, depth)
      end
    end
  end
end 

def graph_as_image(g, org) 
  org_node = g.add_node(org.name.to_s)
  if org.sub_orgs.size != 0
    org.sub_orgs.each do |sub_org|
      sub_org_node = g.add_node(sub_org.name.to_s)
      g.add_edge(org_node, sub_org_node)
      do_graph_as_image(g, sub_org, sub_org_node)
    end
  end
  return g
end

def do_graph_as_image(g, org, org_node)
  if org != nil
    if org.sub_orgs.size !=0
      org.sub_orgs.each do |sub_org|
        if sub_org != nil 
          sub_org_node = g.add_node(sub_org.name.to_s)
          g.add_edge(org_node, sub_org_node)
          do_graph_as_image(g, sub_org, sub_org_node)
        end
      end
    end
  end
end 
uf_uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
puts uf_uri

orgs = find_all_colleges(uf_uri)
graph_as_string(orgs) 

g = GraphViz.new(:G, "type" => "digraph", :sep => "1", :size => "170,300", :overlap => "orthoyx")
g.node[:margin] = 0.0
g.node[:fontsize] = 12
g = graph_as_image(g, orgs)
g.output(:svg => "fdp.svg", :use => "twopi")

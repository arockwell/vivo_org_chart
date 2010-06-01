#!/usr/bin/ruby

require 'rubygems'
require 'rdf/raptor'
require 'graphviz'

module Vivo
  class Org
    HAS_SUB_ORG_URI = "http://vivoweb.org/ontology/core#hasSubOrganization"
    RDF_LABEL_URI = "http://www.w3.org/2000/01/rdf-schema#label"

    attr_accessor :name, :uri, :sub_org_uris, :sub_orgs

    def initialize(name="",  uri="", sub_org_uris=[], sub_orgs=[])
      @name = name
      @uri = uri
      @sub_org_uris = sub_org_uris
      @sub_orgs = sub_orgs
    end

    def to_s 
      puts "Name: " + @name + "\n"
      puts "URI: " + @uri + "\n"
    end

    def self.build_from_rdf(uri, rdf)
      sub_org_pred = RDF::URI.new(Org::HAS_SUB_ORG_URI)
      label_pred = RDF::URI.new(Org::RDF_LABEL_URI)
      name = rdf.query(:predicate => label_pred)[0].object.to_s
      name = (name != nil) ? name : ""
      name = name.match(/"([^"]*)"/)[0]

      sub_org_uris = []
      rdf.query(:predicate => sub_org_pred).each_statement do |s| 
        sub_org_uris.push(s.object.to_s) 
      end

      return Org.new(name, uri, sub_org_uris)
    end
  end

  class OrgChart
    def self.find_all_organizations(uri)
      graph = RdfHelper.retrieve_uri(uri)
      return nil if graph == nil

      org = Org::build_from_rdf(uri, graph)
      sub_orgs = []
      org.sub_org_uris.each do |sub_org_uri|
        sub_org = find_all_organizations(sub_org_uri)
        if sub_org != nil
          sub_orgs.push(sub_org)
        end
      end
      org.sub_orgs = sub_orgs
      return org 
    end

    def self.traverse_graph(org, &block)
      depth = 0
      block.call org, depth
      if org.sub_orgs.size != 0
        org.sub_orgs.each do |sub_org|
          do_traverse_graph(sub_org, depth, block)
        end
      end
    end

    def self.do_traverse_graph(org, depth, block)
      block.call org, depth
      depth = depth + 1
      if org.sub_orgs.size != 0
        org.sub_orgs.each do |sub_org|
          do_traverse_graph(sub_org, depth, block)
        end
      end
    end

    def self.graph_as_string(org) 
      traverse_graph(org) do |org, depth|
        puts "\t" * depth + org.name.to_s + "\n"
      end
    end

    def self.graph_as_image(g, org) 
      traverse_graph(org) do |org, depth|
        org_node = g.add_node(org.name.to_s)
        if org.sub_orgs.size != 0
          org.sub_orgs.each do |sub_org|
            sub_org_node = g.add_node(sub_org.name.to_s)
            g.add_edge(org_node, sub_org_node)
          end
        end
      end
      return g
    end
  end

  class RdfHelper
    def self.retrieve_uri(uri)
      begin 
        graph = RDF::Graph.load(generate_rdf_uri(uri))
      rescue
        return nil
      end
    end

    def self.generate_rdf_uri(uri)
      regex = Regexp.new("http://vivo.ufl.edu/individual/(.+)")
      uri + "/" + uri.match(regex)[1] + ".rdf"
    end
  end
end

uf_uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
puts uf_uri

orgs = Vivo::OrgChart.find_all_organizations(uf_uri)
Vivo::OrgChart.graph_as_string(orgs) 

g = GraphViz.new(:G, "type" => "digraph", :sep => "1", :size => "170,300", :overlap => "orthoyx")
g.node[:margin] = 0.0
g.node[:fontsize] = 12
g = Vivo::OrgChart.graph_as_image(g, orgs)
g.output(:svg => "fdp.svg", :use => "twopi")

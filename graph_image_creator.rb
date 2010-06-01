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
      name = name.match(/"([^"]*)"/)[1]

      sub_org_uris = []
      rdf.query(:predicate => sub_org_pred).each_statement do |s| 
        sub_org_uris.push(s.object.to_s) 
      end

      return Org.new(name, uri, sub_org_uris)
    end
  end

  class OrgChart
    attr_accessor :root_uri, :root_org

    def initialize(root_uri, graph=nil)
      @root_uri = root_uri
    end

    def find_all_organizations
      @root_org = do_find_all_organizations(@root_uri)
    end

    def do_find_all_organizations(uri)
      graph = RdfHelper.retrieve_uri(uri)
      return nil if graph == nil

      org = Org::build_from_rdf(uri, graph)
      sub_orgs = []
      org.sub_org_uris.each do |sub_org_uri|
        sub_org = do_find_all_organizations(sub_org_uri)
        if sub_org != nil
          sub_orgs.push(sub_org)
        end
      end
      org.sub_orgs = sub_orgs
      return org 
    end

    def traverse_graph(&block)
      depth = 0
      block.call @root_org, depth
      if @root_org.sub_orgs.size != 0
        @root_org.sub_orgs.each do |sub_org|
          do_traverse_graph(sub_org, depth, block)
        end
      end
    end

    def do_traverse_graph(org, depth, block)
      block.call org, depth
      depth = depth + 1
      if org.sub_orgs.size != 0
        org.sub_orgs.each do |sub_org|
          do_traverse_graph(sub_org, depth, block)
        end
      end
    end
  end

  class TextFormatter
    def self.format(org_chart)
      org_chart.traverse_graph do |org, depth|
        puts "\t" * depth + org.name.to_s + "\n"
      end
    end
  end

  class GraphvizFormatter
    def self.format(g, org_chart)
      org_chart.traverse_graph do |org, depth|
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

  class GraphMLFormatter
    def self.format(org_chart)
      output = GRAPH_HEADER
      node_counter = 0
      edge_counter = 0

      org_chart.traverse_graph do |org, depth|
        parent_node_name = "n#{node_counter}"
        output += create_node(parent_node_name, org.name.to_s)
        if org.sub_orgs.size != 0
          org.sub_orgs.each do |sub_org|
            node_counter = node_counter + 1
            output += create_node("n#{node_counter}", sub_org.name.to_s)
            edge_name = "#{parent_node_name}n#{node_counter}"
            output += create_edge(edge_name, parent_node_name, "n#{node_counter}")
          end
        end
      end

      output += GRAPH_FOOTER
    end

    private
    GRAPH_HEADER = <<-EOH
      <graphml xmlns="http://graphml.graphdrawing.org/xmlns"  
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
          xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
          http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
        <graph id="G" edgedefault="directed">
    EOH

    GRAPH_FOOTER = <<-EOH
      </graph>
    </graphml>
    EOH

    def self.create_node(node_name, node_description)
      output = <<-EOH
          <node id="#{node_name}"/>
      EOH
      return output
    end

    def self.create_edge(edge_name, source, target)
      output = <<-EOH
          <edge id="#{edge_name}" source="#{source}" target="#{target}" />
      EOH
      return output
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
      regex = Regexp.new("individual/(.+)")
      uri + "/" + uri.match(regex)[1] + ".rdf"
    end
  end
end

start_uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
if ARGV.size == 1
  start_uri = ARGV[0]
end
puts start_uri

org_chart = Vivo::OrgChart.new(start_uri)
org_chart.find_all_organizations

Vivo::TextFormatter.format(org_chart)

g = GraphViz.new(:G, "type" => "digraph", :sep => "1", :size => "170,300", :overlap => "orthoyx")
g.node[:margin] = 0.0
g.node[:fontsize] = 12
g = Vivo::GraphvizFormatter.format(g, org_chart)
g.output(:svg => "fdp.svg", :use => "twopi")

File.open("graphml.xml", "w") {|f| f.write(Vivo::GraphMLFormatter.format(org_chart)) }

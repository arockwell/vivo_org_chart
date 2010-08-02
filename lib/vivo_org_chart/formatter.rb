module VivoOrgChart
  class TextFormatter
    def self.format(org_chart)
      org_chart.traverse_graph do |org, depth|
        puts "\t" * depth + org.name.to_s + "\n"
      end
    end
  end

  class CsvFormatter
    def self.format(org_chart)
      org_chart.traverse_graph do |org, depth|
        #if org.dept_ids != nil && org.dept_ids.size > 0
        #  org.dept_ids.each do |dept_id|
        #    puts "\"#{org.uri}\",#{org.name}\",\"#{dept_id}\""
        #  end
        #else
          puts "\"#{org.name}\",\"#{org.uri}\""
      end
    end
  end
    
  class GraphvizFormatter
    def self.format(g, org_chart)
      org_chart.traverse_graph do |org, depth|
        org_node = g.add_node(org.name.to_s)
        if org.parent_org != nil
          g.add_edge(g.get_node(org.parent_org.name.to_s), org_node)
        end
      end

      return g
    end
  end

  class GraphMLFormatter
    def self.format(org_chart)
      output = GRAPH_HEADER
      node_counter = 0

      node_output = ""
      edge_output = ""

      node_refs = {}
      org_chart.traverse_graph do |org, depth|
        node_counter = node_counter + 1
        node_name = "n#{node_counter}"
        node_output += create_node(node_name, org.name.to_s)
        node_refs[org.name.to_s] = node_name

        if org.parent_org != nil
          edge_name = "#{node_refs[org.parent_org.name.to_s]}#{node_name}"
          edge_output += create_edge(edge_name, node_refs[org.parent_org.name.to_s], node_name)
        end
      end
      output += node_output + edge_output

      output += GRAPH_FOOTER
    end

    private
    GRAPH_HEADER = <<-EOH
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
    http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
  <graph id="G" edgedefault="directed">
    <key id="label" for="node" attr.name="label" attr.type="string" />
    EOH

    GRAPH_FOOTER = <<-EOH
  </graph>
</graphml>
    EOH

    def self.create_node(node_name, node_description)
      node_description.gsub!('&', 'and')
      output = <<-EOH
    <node id="#{node_name}">
      <data key="label">#{node_description}</data>
    </node> 
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
  class InfoVisFormatter
    @@counter = 0
    def self.format(org_chart)
      graph = {}
      root_org = org_chart.root_org
      root_org_hash = {}
      root_org_hash[:id] = @@counter
      root_org_hash[:name] = root_org.name.to_s
      root_org_hash[:children] = []
      root_org.sub_orgs.each do |sub_org|
        if sub_org.name.to_s != ""
          @@counter = @@counter + 1
          sub_org_hash = {:id => @@counter, :name => sub_org.name.to_s}
          sub_org_hash[:children] = do_format(sub_org)
          root_org_hash[:children] << sub_org_hash
        end
      end
      return root_org_hash
    end

    def self.do_format(org)
      sub_org_hashes = []
      org.sub_orgs.each do |sub_org|
        if sub_org.name.to_s != ""
          @@counter = @@counter + 1
          sub_org_hash = {:id => @@counter, :name => sub_org.name.to_s}
          sub_org_hash[:children] = do_format(sub_org)
          sub_org_hashes << sub_org_hash
        end
      end
      return sub_org_hashes
    end
  end
end

module VivoOrgChart
  class Base
    attr_accessor :root_uri, :root_org

    def initialize(root_uri)
      @root_uri = root_uri
    end

    def find_all_organizations(filename=nil, opts={})
      if filename == nil
        @root_org = do_find_all_organizations(@root_uri, nil, opts)
      else
        @graph = RDF::Graph.load(filename)
        @root_org = do_find_all_organizations(@root_uri, nil)
      end
    end

    def do_find_all_organizations(uri, parent_org, opts={})
      if @graph == nil
        if (opts.has_key?(:username) && opts.has_key?(:password))
          agent = Authenticate.authenticate
        end
        graph = RdfHelper.retrieve_uri(uri, agent)
        return nil if graph == nil
      else
        graph = @graph
      end

      org = Org::build_from_rdf(uri, parent_org, graph)
      sub_orgs = []
      org.sub_org_uris.each do |sub_org_uri|
        sub_org = do_find_all_organizations(sub_org_uri, org)
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
      depth = depth + 1
      block.call org, depth
      if org.sub_orgs.size != 0
        org.sub_orgs.each do |sub_org|
          do_traverse_graph(sub_org, depth, block)
        end
      end
    end

    def serialize(filename)
      RDF::Writer.open(filename) do |writer|
        self.traverse_graph do |org, depth|
          org.each_statement do |statement|
            writer << statement
          end
        end
      end
    end
  end
end

module VivoOrgChart
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

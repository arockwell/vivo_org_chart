module VivoOrgChart
  class RdfHelper
    def self.retrieve_uri(uri, agent=nil)
      if agent == nil
        agent = Mechanize.new
      end

      begin 
        rdf_uri = generate_rdf_uri(uri)
        rdf = agent.get(rdf_uri).body
        repo = RDF::Repository.new
        tmp_file = '/tmp/__tmp.rdf'
        File.open(tmp_file, 'w') {|f| f.write(rdf)}
        RDF::Reader.open(tmp_file) do |reader|
          reader.each_statement do |statement|
            repo << statement
          end
        end
        File.delete(tmp_file)
        return repo
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

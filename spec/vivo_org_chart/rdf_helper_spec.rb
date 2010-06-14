require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module VivoOrgChart
  describe RdfHelper do
    it "should translate a vivo uri to a location that has rdf" do
      uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
      rdf_loc = RdfHelper.generate_rdf_uri(uri)
      rdf_loc.should == uri + "/UniversityofFlorida.rdf"
    end

    it "should load rdf from a vivo uri" do
      uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
      graph = RdfHelper.retrieve_uri(uri)
      graph.should_not == nil
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module VivoOrgChart
  describe Org do
    it "should create a new org from URI" do
      uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
      graph = RdfHelper.retrieve_uri(uri)
      org = Org.build_from_rdf(uri, nil, graph)
      org.name.should == "University of Florida"
      org.parent_org.should == nil
      org.sub_org_uris.size.should == 38
    end

  end
end

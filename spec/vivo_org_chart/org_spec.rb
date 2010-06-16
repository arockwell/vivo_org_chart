require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module VivoOrgChart
  describe Org do
    it "should create a new org from URI" do
      uri = "http://vivo.ufl.edu/individual/UniversityofFlorida"
      graph = RdfHelper.retrieve_uri(uri)
      org = Org.build_from_rdf(uri, nil, graph)
      org.uri.should == uri
      org.name.should == "University of Florida"
      org.parent_org.should == nil
      org.sub_org_uris.size.should == 38
    end

    it "should return org serialized as rdf" do
      org = Org.new("test", "test_uri", nil)
      sub1 = Org.new("sub1", "sub1_uri", org)
      sub2 = Org.new("sub2", "sub2_uri", org)
      org.sub_org_uris << sub1.uri
      org.sub_org_uris << sub2.uri

      statements = []

      org.each_statement { |s| statements << s }
      statements.size.should == 3
    end

  end
end

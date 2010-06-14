require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module VivoOrgChart
  describe Base do
    it "should find an organization and all sub orgs in vivo given a uri" do
      uri = "http://vivo.ufl.edu/individual/CollegeofEducation"
      org_chart = VivoOrgChart::Base.new(uri)
      org_chart.find_all_organizations
      org_chart.root_org.name.should == "College of Education"
      org_chart.root_org.sub_orgs.size.should == 7
    end

    it "should traverse all nodes in the graph" do 
      org = Org.new("test_org", "test_org_uri", nil, "test1")
      sub_org = Org.new("test_sub_org", "test_sub_org_uri", org)
      org.sub_orgs.push sub_org

      org_chart = VivoOrgChart::Base.new("test_org_uri")
      org_chart.root_org = org
      
      count = 0
      org_chart.traverse_graph do |org, depth|
        if count == 0
          org_chart.root_org.name.should == org.name
        elsif count == 1
          org_chart.root_org.sub_orgs[0].name.should == org.name
        end
        count = count + 1
      end
    end
  end
end

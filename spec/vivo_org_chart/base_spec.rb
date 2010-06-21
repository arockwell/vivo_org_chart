require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module VivoOrgChart
  describe Base do
    it "should find an organization and all sub orgs in vivo given a uri" do
      uri = "http://vivo.ufl.edu/individual/CollegeofEducation"
      org_chart = VivoOrgChart::Base.new(uri)
      org_chart.find_all_organizations
      org_chart.root_org.name.should == "College of Education"
      org_chart.root_org.sub_orgs.size.should == 7
      # I would like to be able to log in and check this, but don't want 
      # passwords in git
      #org_chart.root_org.dept_ids.size.should == 24
    end

    it "should find an organization and all sub orgs in vivo given a file" do
      org = Org.new("test_org", "test_org_uri", nil, "test1")
      sub_org = Org.new("test_sub_org", "test_sub_org_uri", org)
      org.sub_orgs.push sub_org

      org_chart = VivoOrgChart::Base.new("test_org_uri")
      org_chart.root_org = org

      tmp_file = File.dirname(__FILE__) + '/tmp.nt'
      org_chart.serialize(tmp_file)
      org_chart = VivoOrgChart::Base.new("test_org_uri")
      org_chart.find_all_organizations(tmp_file)
      org_chart.root_org.name.should == "test_org"
      org_chart.root_org.sub_orgs.size.should == 1
      File.delete(tmp_file)
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
          depth.should == 1
          org_chart.root_org.sub_orgs[0].name.should == org.name
        end
        count = count + 1
      end
    end

    it "should prune branches of the graph" do
      org = Org.new("test_org", "test_org_uri", nil, "test1")
      org.sub_orgs <<  Org.new("test_sub_org", "test_sub_org_uri", org)
      org.sub_orgs << Org.new("test_sub_org2", "test_sub_org_uri", org)
      org.sub_orgs << Org.new("sub_org", "test_sub_org_uri", org)

      sub_sub_org = Org.new("sub_sub_org", "sub_sub_org", org.sub_orgs[1])

      org_chart = VivoOrgChart::Base.new("test_org_uri")
      org_chart.root_org = org

      org_chart.prune do |org, depth|
        if org.name.match(/^test_sub_org/)
          true
        else 
          false
        end
      end

      org_chart.root_org.sub_orgs.size.should == 1
    end

    it "should serialize the output in n3" do
      org = Org.new("test_org", "test_org_uri", nil, "test1")
      sub_org = Org.new("test_sub_org", "test_sub_org_uri", org)
      org.sub_orgs.push sub_org

      org_chart = VivoOrgChart::Base.new("test_org_uri")
      org_chart.root_org = org

      tmp_file = File.dirname(__FILE__) + '/tmp.nt'
      org_chart.serialize(tmp_file)
      counter = 0
      File.open(tmp_file).each { |line| counter = counter + 1 }
      counter.should == 3
      File.delete(tmp_file)
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module VivoOrgChart
  describe InfoVisFormatter do
    it "should output json" do 
      org_chart = VivoOrgChart::Base.new('http://vivo.ufl.edu/individual/UniversityofFlorida')
      #data_file = File.dirname(__FILE__) + '/data/uf_org.nt'
      data_file = '/home/arockwell/dev/vivo_org_chart/examples/prune.nt'
      org_chart.find_all_organizations(data_file)
      output = InfoVisFormatter.format(org_chart)
      puts JSON.pretty_generate(output)
    end
  end
end

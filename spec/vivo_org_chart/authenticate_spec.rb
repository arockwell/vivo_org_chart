require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#module VivoOrgChart
#  describe Authenticate do
#    it "should log me in" do
#      agent = Authenticate.authenticate('', '')
#      agent.visited?("http://vivo.ufl.edu/siteAdmin?home=1&login=block")
#    end
#
#    it "should allow me to see hidden rdf fields" do
#      agent = Authenticate.authenticate('', '')
#      uri = "http://vivo.ufl.edu/individual/CollegeofDentistry"
#      graph = RdfHelper.retrieve_uri(uri, agent)
#      org = Org.build_from_rdf(uri, nil, graph)
#      org.dept_ids.size.should > 0
#    end
#  end
#end

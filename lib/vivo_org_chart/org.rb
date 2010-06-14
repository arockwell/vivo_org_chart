module VivoOrgChart
  class Org
    HAS_SUB_ORG_URI = "http://vivoweb.org/ontology/core#hasSubOrganization"
    RDF_LABEL_URI = "http://www.w3.org/2000/01/rdf-schema#label"

    attr_accessor :name, :uri, :parent_org, :sub_org_uris, :sub_orgs

    def initialize(name="",  uri="", parent_org=nil, sub_org_uris=[], sub_orgs=[])
      @name = name
      @uri = uri
      @parent_org = parent_org
      @sub_org_uris = sub_org_uris
      @sub_orgs = sub_orgs
    end

    def self.build_from_rdf(uri, parent_org, rdf)
      sub_org_pred = RDF::URI.new(Org::HAS_SUB_ORG_URI)
      label_pred = RDF::URI.new(Org::RDF_LABEL_URI)
      name = rdf.query(:predicate => label_pred)[0].object.to_s
      name = (name != nil) ? name : ""
      name = name.match(/"([^"]*)"/)[1]

      sub_org_uris = []
      rdf.query(:predicate => sub_org_pred).each_statement do |s| 
        sub_org_uris.push(s.object.to_s) 
      end

      return Org.new(name, uri, parent_org, sub_org_uris)
    end
  end
end

module VivoOrgChart
  class Org
    SINGLE_VALUE_PROPERTIES = {
      :name => "http://www.w3.org/2000/01/rdf-schema#label",
    }
    MULTI_VALUE_PROPERTIES = {
      :dept_ids => "http://vivo.ufl.edu/ontology/vivo-ufl/deptID",
    }
    SUB_ORG_RELATION_PROPERTIES = {
      :sub_org_uris => "http://vivoweb.org/ontology/core#hasSubOrganization",
      :collection_within_uris => "http://vivo.ufl.edu/ontology/vivo-ufl/hasCollection",
    }

    attr_accessor :name, :uri, :parent_org, :dept_ids
    attr_accessor :sub_org_uris, :sub_orgs 

    def initialize(name="",  uri="", parent_org=nil, sub_org_uris=[])
      @name = name
      @uri = uri
      @parent_org = parent_org
      @sub_org_uris = sub_org_uris
      @sub_orgs = []
      @dept_ids = []
    end

    def self.build_from_rdf(uri, parent_org, rdf)
      rdf_uri = RDF::URI.new(uri)

      org = Org.new
      org.uri = uri
      org.parent_org = parent_org

      SINGLE_VALUE_PROPERTIES.each do |k, v|
        query = rdf.query(:subject => rdf_uri, :predicate => RDF::URI.new(v)).to_a
        if query[0] != nil
          value = query[0].object.literal? ? query[0].object.value : query[0].object.to_s
          org.send(k.to_s + '=', value)
        end
      end

      MULTI_VALUE_PROPERTIES.each do |k, v|
        query = rdf.query(:subject => rdf_uri, :predicate => RDF::URI.new(v)).to_a
        if query.size > 0
          a = []
          query.each do |q|
            value = q.object.literal? ? q.object.value : q.object.to_s
            a << value
          end
          org.send(k.to_s + '=', a)
        end
      end

      SUB_ORG_RELATION_PROPERTIES.each do |k, v|
        query = rdf.query(:subject => rdf_uri, :predicate => RDF::URI.new(v)).to_a
        if query.size > 0
          a = []
          query.each do |q|
            value = q.object.literal? ? q.object.value : q.object.to_s
            org.sub_org_uris << value
          end
        end
      end
      return org
    end

    def each_statement(&block)
      statements = []

      SINGLE_VALUE_PROPERTIES.each do |k, v|
        if self.send(k) != nil
          statements << RDF::Statement.new(RDF::URI.new(@uri), RDF::URI.new(v), self.send(k))
        end
      end
      
      MULTI_VALUE_PROPERTIES.each do |k, v|
        if self.send(k) != nil && self.send(k).size > 0
          self.send(k).each do |value|
            statements << RDF::Statement.new(RDF::URI.new(@uri), RDF::URI.new(v), value)
          end
        end
      end

      self.sub_org_uris.each do |sub_org_uri|
        statements << RDF::Statement.new(RDF::URI.new(@uri), RDF::URI.new("http://vivoweb.org/ontology/core#hasSubOrganization"), sub_org_uri)
      end
      
      statements.each do |statement|
        yield statement
      end
    end
  end
end

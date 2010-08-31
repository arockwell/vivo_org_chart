require 'mechanize'
require 'digest/md5'

module VivoOrgChart
  class Authenticate
    def self.authenticate(username, password)
      agent = Mechanize.new
      # must access the login page to setup the cookie before issuing a post
      agent.get('http://vivo.ufl.edu/siteAdmin')
      agent.post('http://vivo.ufl.edu/authenticate?home=1&login=block', { 
        'loginName' => username,
        'loginPassword' => password,
        'loginForm' => 'Log in'
      })
      return agent
    end
  end
end

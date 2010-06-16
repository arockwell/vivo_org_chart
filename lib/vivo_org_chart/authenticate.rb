require 'mechanize'
require 'digest/md5'

module VivoOrgChart
  class Authenticate
    def self.authenticate(username, password)
      agent = Mechanize.new
      password = Digest::MD5.hexdigest(password).upcase
      agent.post('http://vivo.ufl.edu/login_process.jsp', { 
        'home' => '1',
        'loginName' => username,
        'loginPassword' => password,
        'loginSubmitMode' => 'Log in'
      })
      return agent
    end
  end
end

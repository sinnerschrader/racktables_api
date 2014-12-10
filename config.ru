require 'bundler/setup'
require 'racktables_api'
require 'authenticator'
require 'digest/sha1'
require 'model/user'

$stderr.puts <<BANNER
       _                    _
  _ __| |_       __ _ _ __ (_)
 | '__| __|____ / _` | '_ \| |
 | |  | ||_____| (_| | |_) | |
 |_|  \\__|      \\__,_| .__/|_|
                     |_|

BANNER

class SetLogger

  def initialize(app)
    @app = app
  end

  def call(env)
    env['rack.logger'] = Logger.new(STDOUT)
    env['rack.logger'].sev_threshold = Logger::DEBUG
    return @app.call(env)
  end

end

use SetLogger

use Authenticator do |user, pass|
  next false if user.empty? || pass.empty?

  Model::User::Account.where({:user_name => user, :user_password_hash => Digest::SHA1.hexdigest(pass)}).count == 1
end

run RacktablesApi.to_app

require 'rack/auth/basic'
require 'model/user'
require 'digest'

class RacktablesAuthenticator < Rack::Auth::Basic

  def initialize(app)
    super(app, self.class.name)
  end

  def call(env)
    if env['racktables.auth'] || ( env.key?('rack.session') && env['rack.session']['user'] )

      return @app.call(env)

    else

      auth = Rack::Auth::Basic::Request.new(env)

      if auth.provided? and auth.basic?
        if Model::User::Account.where({
          :user_name => auth.credentials.first,
          :user_password_hash => Digest::SHA1.hexdigest(auth.credentials.last)}).count == 1
          return @app.call(env)
        end
      end
      unauthorized
    end
  end

end

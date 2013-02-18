class User < ActiveRecord::Base

	attr_accessor :imageURL

  # attachments for a user
  # must update :s3_credentials to the right amazon credentials
	has_attached_file 	:thumbnail,
						:storage => :s3,
						:default_url => ActionController::Base.helpers.asset_path("usericon.png"),
						:bucket => '',
	                    :s3_credentials => {
							:access_key_id => '',
							:secret_access_key => '+'
						}

  # creates an new account if someone tries to log in with a 3rd party auth provider
  def self.create_omni(hash)

    acc = Account.new
    acc.password = BCrypt::Engine.generate_salt
    acc.email = hash['info']['email']
    acc.account_type = Account.roles[:user]
    acc.confirmed = true

    begin
      acc.save!

      user = User.new
      user.account_id = acc.id
      user.fullname = hash['info']['name']
      user.location = ''
      user.save!

      o = Omniuser.new
      o.provider = Omniuser.providers[hash['provider']]
      o.uid = hash['uid']
      o.account_id = acc.id
      o.save!
    rescue
      nil
    end

    o
  end
end

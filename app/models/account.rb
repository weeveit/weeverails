class Account < ActiveRecord::Base

	attr_accessor :password
	before_save :encrypt_password

	validates_presence_of :password, :on => :create
	validates_presence_of :email
	validates_uniqueness_of :email
	validates_length_of :password, :minimum=>6, :message=>"must be at least 6 characters"

  # account model
  # an Account represents the generic account for any type of user

  # these are the roles defined for Weeve, must be changed to reflect the type of users
  # that are in the system, then do a project wide search of Account.roles
  # in order to find out where it is used
	def self.roles
		Hash[:user => "user", :npo => "npo"]
	end

  # helper to udpate an email
	def self.update_email(email, new_email)
		user = find_by_email(email)
		user.confirmed = false
		user.update_attribute('email', new_email)
		UserMailer.reconfirm_email(user).deliver
	end

  # authenticates an account
	def self.authenticate(email, password)
		user = find_by_email(email)
		if user && user.hashed_password == BCrypt::Engine.hash_secret(password, user.salt)
			user
		else
			nil
		end
  end

  # omni authenticate based on an account id
  # this is called for when someone tries to log in with a 3rd party authentication
  def self.omni_authenticate(account_id)
    find(account_id)
  end

  # adds an account to a mailchimip account
  # need to change MAILCHIMP_ID to the api key given by mailchimp
  # need to change LIST_ID to the list id that you want to add the account to
  def self.mailchimp(account)
    
    gb = Gibbon.new(MAILCHIMP_ID)

    list_id = LIST_ID

    if account.account_type == Account.roles[:npo]
      
      firstname = Npo.find_by_account_id(account.id).name
      lastname = ''
      
    elsif account.account_type == Account.roles[:user]
      
      user = User.find_by_account_id(account.id)
      index = user.fullname.rindex(' ')
      
			if index
			  firstname = user.fullname[0..(index-1)]
			  lastname = user.fullname[index+1..-1]
			else
			  firstname = user.fullname
			  lastname = ''
			end
    end

    merge_vars = {
      'FNAME' => firstname,
      'LNAME' => lastname
    }

    response = gb.listSubscribe({:id => list_id, 
      :email_address => account.email, 
      :merge_vars => merge_vars})
  end

  # password encryptor based on a salt
	def encrypt_password
		if password.present?
			self.salt = BCrypt::Engine.generate_salt
			self.hashed_password = BCrypt::Engine.hash_secret(password, salt)
		end
	end
end

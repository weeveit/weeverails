class AccountsController < ApplicationController

	protect_from_forgery

	before_filter :authenticated, :only => [:edit_password, :change_password]

  # accounts controller which takes care of all account related actions

  # confirms an account by finding their email
  # this confirmation uses a token which is encrypted by the user's salt
  # this is for any type of user (users or nonprofits)
  # will continue to work with any other type of accounts because emails are tied to the Account model
	def confirm
		@user = Account.find_by_email(params[:email])

		if @user
			if @user.confirmed == true
				redirect_to root_url, :notice => "You've already confirmed your account."
			elsif Digest::SHA1.hexdigest(@user.salt) == params[:token]
				@user.update_attribute(:confirmed, true)
				session[:user_id] = @user.id
				redirect_to root_url, :notice => "You've confirmed your account. Happy Funding!"
			else
				flash[:error] = "Wrong confirmation token."
				redirect_to root_url, :action => :index
			end
		else
			flash[:error] = "Invalid confirmation URL"
			redirect_to root_url, :action => :index
		end
  end

  # a generic profile controller
  # redirects an user based on which type of account
	def profile
		@user = Account.find_by_id(params[:id])

    # add more conditions based which type of account it is
		if @user.account_type == Account.roles[:user]
			@user_details = User.find_by_account_id(params[:id])
			redirect_to :controller => :users, :action => :history, :id => params[:id]
		elsif @user.account_type == Account.roles[:npo]
			@user_details = Npo.find_by_account_id(params[:id])
			redirect_to :controller => :npos, :action => :profile, :id => params[:id]
		end

		if !@user
			flash[:error] = "There is an error with your profile, please contact the administrator at admins@weeve.it"
			redirect_to root_url
		end
	end

  # password recovery view
	def recover
		if request.post?
			@account = Account.find_by_email(params[:account][:email])

			if @account
				if !@account.recoverable
					if @account.update_attribute('recoverable', true) && @account.update_attribute('recovery_date', Time.now)
						UserMailer.recover_email(@account).deliver
						flash[:notice] = "An email has been sent with next steps on password recovery"
						redirect_to root_url
					else
						flash[:error] = "An error occured"
						redirect_to :action => :recover
					end
				else
					flash[:error] = "A request to recover the password for this account has already been sent, please check your email."
					redirect_to :action => :recover
				end
			else
				flash[:error] = "Email does not exist in Weeve"
				redirect_to :action => :recover
			end
		end
	end

  # the actual password reset
  # passwords can only be recovered if the URL in the password recovery email has not expired
	def reset
		@user = Account.find_by_email(params[:email])

		if @user && Digest::SHA1.hexdigest(@user.salt) == params[:token]
			if @user.recoverable
				if Time.now - 7.days < @user.recovery_date
					render 'reset'
				else
					flash[:error] = "This URL has expired"
					@user.update_attribute('recoverable', false)
					redirect_to root_url, :action => :index
				end
			else
				flash[:error] = "This URL has already been used for password recovery"
				redirect_to root_url, :action => :index
			end
		else
			flash[:error] = "Invalid confirmation URL or token"
			redirect_to root_url, :action => :index
		end
	end

  # updates the an account's password
  # this is used for when users forgot their password and must reset their password
	def update_password
		@user = Account.find_by_id(params[:account][:id])
		@user.password = params[:account][:new_password]

    # there must be a confirmation
		if params[:account][:new_password] == params[:account][:new_password_confirm]
			if @user.save && @user.update_attribute('recoverable', false)
				flash[:notice] = "Password udpated"
				redirect_to root_url
			else
				render 'reset'
			end
		else
			flash[:error] = "Password confirmation does not match"
			render 'reset'
		end
	end

  # the edit password view for accounts
  # redirects to the correct view based on account type
	def edit_password
		@account = current_user
		@usertype = current_usertype

    # redirects based on account type
		if @account.account_type == Account.roles[:user]
			render "users/edit"
		elsif @account.account_type == Account.roles[:npo]
			render "npos/edit"
		end
	end

  # changes the password for the current user
  # the user must put in their current password (as a security feature)
	def change_password
		@account = current_user
		@account.password = params[:account][:new_password]

		if Account.authenticate(@account.email, params[:account][:password])
			if params[:account][:new_password] != params[:account][:password]
				if @account.save
					flash[:notice] = "Password udpated"
				else
					flash[:error] = "Password must be at least 6 characters"
				end
			else
				flash[:error] = "Password confirmation does not match"
			end
		else
			flash[:error] = "Current password is incorrect"
		end

		redirect_to :action => :edit_password
  end

  # omniauth
  # allows users to log in with other authentication
  # this is the method called by the callback function of the 3rd party authentication
  # expectes auth_hash to contain a 'uid' provided by the service
  # and a 'provider' (ie. facebook, twitter, linkedin, etc)
  def omniauth_weeve
    auth_hash = request.env['omniauth.auth']

    #auth_hash = Hash['uid' => "1234", 'provider' => 'facebook', 'info' => Hash['email' => 'emailu@email.com', 'name' => 'Vin Chu']]

    # any user that logs in with a 3rd party authentication service also has an Omniuser object
    user = Omniuser.find_by_uid_and_provider(auth_hash['uid'], Omniuser.providers[auth_hash['provider']])

    # creates a new omni user if that user's email doesn't already exist in the user database
    if !user
      user = create_omni(auth_hash)
      
      if !user
        flash[:error] = "Your account could not be created.  Your email already exists in the database."
        
        # MARKED_FOR_RELEASE
        redirect_to root_url
      end

      flash[:notice] = "Account successfully created, you maybe now log in with Facebook Connect."
    end

    Account.omni_authenticate(user.account_id)
    session[:user_id] = user.account_id
    session[:provider] = user.provider

    flash[:notice] = "Logged in with your Facebook account.  Happy funding!"
    redirect_to root_url
  end
end
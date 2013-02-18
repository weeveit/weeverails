class UsersController < ApplicationController

	protect_from_forgery

	before_filter :authenticated, :only => [:edit, :update_profile, :personal_information, :update_personal_information]
	before_filter :admin, :only => [:remove_user]

  # controller for users (contributors)

	def index

	end

	def new
		@user = User.new
    @account = Account.new
	end

	def edit
		@account = current_user
		@usertype = current_usertype
	end

  # for updating profile information
	def update_profile
		@account = current_user
		@usertype = current_usertype

		if @usertype.update_attributes(params[:user])
			flash[:notice] = "Account updated"

			if params[:account][:email] != @account.email
        @account.update_attribute(:confirmed, false)
				Account.update_email(@account.email, params[:account][:email])
				flash[:notice] = "Account updated.  A confirmation email was sent to the updated email address."
			end

			redirect_to :action => :edit
		else
			flash[:error] = "Could not update profile"
			render "users/edit"
		end
	end

  # creates a new user
	def create
		@user = User.new(params[:user])
    @account = Account.new(params[:account])
    @account.account_type = Account.roles[:user]
		if @account.save
      @user.account_id = @account.id
      @user.save
			UserMailer.confirm_email(@account).deliver
			Account.mailchimp(@account)
			redirect_to root_url, :notice => "Thank you for signing up!  A confirmation email has been sent to the email address you provided with next steps.  Happy funding!"
		else
			render "new"
		end
	end

  # static page
	def history
		@user = Account.find_by_id(params[:id])
		@user_details = User.find_by_account_id(params[:id])
	end

  # for editing an user's personal information
	def personal_information
		@account = current_user
		@usertype = current_usertype

		render "users/edit"
	end

  # updates a user's personal information
	def update_personal_information
		@account = current_user
		@usertype = current_usertype

		if @usertype.update_attributes(params[:user])
			flash[:notice] = "Personal Information updated"

			redirect_to :action => :personal_information
		else
			flash[:error] = "Could not update personal information"
			render "users/edit"
		end
	end

  # removes a user from the system, only admins can do this
	def remove_user
	  @account = Account.find(params[:id])
	  @user = User.find_by_account_id(@account.id)
	  @omni = Omniuser.find_by_account_id(@account.id)
	  
	  @account.destroy
	  @user.destroy
	  @omni.destroy if @omni
	  
	  flash[:notice] = 'User removed'
	  redirect_to :controller => :admins, :action => :controlpanel
	end  
end

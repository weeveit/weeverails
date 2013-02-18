class NposController < ApplicationController

	protect_from_forgery

	before_filter :authenticated, :only => [:edit, :update_profile, :edit_paypal, :update_paypal]
	before_filter :current_admin, :only => [:delete_account, :verify_paypal]

  # npo controller

  # signing up as a new NPO
	def new
		@user = Npo.new
    @account = Account.new
	end

  # creates the NPO account and sends them an email
	def create
		@user = Npo.new(params[:npo])
		@user.paypal_status = Npo.paypal_status[:unverified]
    @account = Account.new(params[:account])
    @account.account_type = Account.roles[:npo]

		if @account.save
      @user.account_id = @account.id
      @user.save
			UserMailer.npo_confirm_email(@account).deliver
			Account.mailchimp(@account)
			redirect_to root_url, :notice => "Thank you for signing up!  A confirmation email has been sent to the email address you provided with next steps."
		else
			render "new"
		end
	end

  # view for updating the NPO profile
	def edit
 		@account = current_user
		@usertype = current_usertype
	end

  # updates an NPO profile
	def update_profile
		@account = current_user
		@usertype = current_usertype

		if @usertype.update_attributes(params[:npo])
			flash[:notice] = "Account updated"

			if params[:account][:email] != @account.email
				Account.update_email(@account.email, params[:account][:email])
				flash[:notice] = "Account updated.  A confirmation email was sent to the updated email address."
			end

			redirect_to :action => :edit
		else
			flash[:error] = "Bio cannot be more than 300 characters."
			redirect_to :action => :edit
		end
	end

	def edit_paypal
		@account = current_user
		@usertype = current_usertype

		render "edit"
	end

  # udpates an NPO paypal information
	def update_paypal
		@account = current_user
		@usertype = current_usertype

		if @usertype.update_attributes(params[:npo])
			flash[:notice] = "PayPal email submitted.  We will verify your PayPal information as soon as we can."

			@usertype.update_attribute('paypal_status', Npo.paypal_status[:pending])
			redirect_to :action => :edit_paypal
		else
			flash[:error] = "Your PayPal information could not be updated.  Please contact the administrator at admins@weeve.it"
			redirect_to :action => :edit_paypal
		end
	end

  # deletes an NPO account
  # only admins can do this
	def delete_account
		npo = Npo.find(params[:id])
		account = Account.find(npo.account_id)

		npo.destroy
		account.destroy
		Project.destroy_all(:account_id => account.id)

		flash[:notice] = "Account deleted"
		redirect_to :controller => :admins, :action => :controlpanel
	end

  # changes the PayPal status of an NPO
  # this allows admins to tell NPOs that their PayPal informatino has been verified
	def verify_paypal
		npo = Npo.find(params[:id])
		npo.update_attribute(:paypal_status, Npo.paypal_status[:verified])
		flash[:notice] = "#{npo.name}'s PayPal info successfully verified"

		redirect_to :controller => :admins, :action => :controlpanel
	end

  # static pages of the NPO
	def about
		@user = Account.find(params[:id])
		@user_details = Npo.find_by_account_id(@user.id)
	end

	def profile
		@user = Account.find_by_id(params[:id])
		@user_details = Npo.find_by_account_id(params[:id])

		if @user == current_user && @user_details.paypal_status == Npo.paypal_status[:unverified]
			flash[:warning] = 'Your account currently does not have a verified Business PayPal account.  You must have a verified Business PayPal account in order to receive donations from users.  Please add a PayPal email in your Account Settings under the PayPal tab.'
		end
  end
end
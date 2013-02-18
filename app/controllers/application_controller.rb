class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :current_admin, :get_featured, :current_usertype, :current_npo

  # application helpers
  # all methods can be accessed by admins

  # redirects a person if they are trying to view an NPO specific page but is not logged in as an NPO
  def current_npo
    if current_admin
      true
    elsif npo && current_user.id == params[:account_id].to_i
      true
    else
      flash[:error] = 'You are not authorized to view this page'
      redirect_to root_url
    end
  end

  # checks if there is a current user, as in they are authenticated
	def authenticated
		if current_user || current_admin
			true
		else
			flash[:error] = "You must log in to view that page!"
			redirect_to root_url
		end
	end

  # checks if there is a current non profit logged in
	def npo
		if current_user && current_user.account_type == Account.roles[:npo] || current_admin
			true
		else
			flash[:error] = "You must log in as a non-profit to view that page!"
			redirect_to root_url
		end
	end

  # checks if there is an admin logged in
	def admin
		if !session[:admin]
			redirect_to root_url
		end
	end

  # checks if the current person logged in is a user (a project backer)
	def user
		if current_user.account_type != Account.roles[:user]
			redirect_to root_url
		end
	end

  private

  # gets all the featured categories
  # can add items to the hash in order to add on to featured categories
	def get_featured
		{:recent => "Recently Started", :ending => "Ending Soon", :small => "Small Projects"}
	end

  # returns the current admin if there is one
	def current_admin
		@admin ||= Admin.find(session[:admin]) if session[:admin]
	end

  # returns the current account if there is one
  def current_user
    @current_user ||= Account.find(session[:user_id]) if session[:user_id]
	end

  # returns the current user type (users or NPOs) if there is one
	def current_usertype
	  
	  if current_admin
	    @current_usertype = current_admin
	    return @current_usertype
	  end
	  
		account = current_user

		if account
			if account.account_type == Account.roles[:user]
				@current_usertype ||= User.find_by_account_id(account.id)
			elsif account.account_type == Account.roles[:npo]
				@current_usertype ||= Npo.find_by_account_id(account.id)
			end
		end

		@current_usertype
	end
end

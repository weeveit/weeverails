class UserMailer < ActionMailer::Base
	default from: Weeverails::Application.config.d_email

  # this is the mailer for the application
  # each method sends an email
  # email configuration can be found in the environment files
  # the contents of the emails are found in the user_mailer folder in the views

  # confirmation email to contributors
	def confirm_email(user)
		@account = user
		@confirmUrl  = "#{Weeverails::Application.config.domain}/account/confirm?token=#{Digest::SHA1.hexdigest(@account.salt)}&email=#{@account.email}"
		mail(:to => user.email, :subject => "Welcome to Weeve")
	end

  # confirmation email to NPOs
	def npo_confirm_email(user)
		@account = user
		@confirmUrl  = "#{Weeverails::Application.config.domain}/account/confirm?token=#{Digest::SHA1.hexdigest(@account.salt)}&email=#{@account.email}"
		mail(:to => user.email, :subject => "Welcome to Weeve")
	end

  # reconfrim email if they request it
	def reconfirm_email(user)
		@account = user
		@confirmUrl  = "#{Weeverails::Application.config.domain}/account/confirm?token=#{Digest::SHA1.hexdigest(@account.salt)}&email=#{@account.email}"
		mail(:to => user.email, :subject => "Reconfirm Email")
	end

  # email for password recovery
	def recover_email(user)
		@account = user
		@confirmUrl  = "#{Weeverails::Application.config.domain}/account/reset?token=#{Digest::SHA1.hexdigest(@account.salt)}&email=#{@account.email}"
		mail(:to => user.email, :subject => "Recover Password")
	end

  # once a project has ended, an email is sent to the creator
	def project_complete(project)
		@project = project
		@user = Account.find(@project.account_id)
		@npo = Npo.find_by_account_id(@project.account_id)
		mail(:to => @user.email, :subject => "Project #{@project.title} has ended successfully")
	end

  # when a project goes live, an email is sent to the creator
	def project_started(project)
		@project = project
		@user = Account.find(@project.account_id)
		@npo = Npo.find_by_account_id(@project.account_id)
		mail(:to => @user.email, :subject => "Project #{@project.title} has been accepted and started!")
  end

  # when a donation is made, an email is sent to the contributor
  def donation_success(donation)
    @project = Project.find(donation.project_id)
    
    if donation.user_id == -1
      @user = Guest.find_by_donation_id(donation.id)
      @account = @user
    else
      @user = User.find(donation.user_id)
      @account = Account.find(@user.account_id)
    end

    match = /([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i.match(@account.email)

    if match
      mail(:to => @account.email, :subject => "Thank you for your donation!")
    end
  end

  # when someone creates a feedback, it is sent to an admin
  # change the :to to change where the feedback gets sent
  def feedback(subject, message)
    @message = message
    mail(:to => FEEDBACK_EMAIL, :subject => subject)
  end
end

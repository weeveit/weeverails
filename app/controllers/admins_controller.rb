class AdminsController < ApplicationController

	protect_from_forgery

	before_filter :admin, :except => [:login]

  require 'spreadsheet'
  require 'stringio'

  # admin login
  # refer to seeds.rb for more info about admins
	def login
		if session[:admin]
			redirect_to :action => :controlpanel
		end

		if request.post?
			admin = Admin.where(:username => params[:admin][:username]).first

			if admin != nil && admin.hashed_password == BCrypt::Engine.hash_secret(params[:admin][:password], admin.salt)
				session[:admin] = admin.id
				redirect_to :action => :controlpanel
			else
				flash[:error] = "Invalid Login"
				redirect_to :action => :login
			end
		end
  end

  # the generic controller that admins get redirected to
  # can grab any data from the database to render
	def controlpanel
    @npos = Npo.all
    @donations = Donation.all
    @subs = Subscriber.all
    @users = User.all
    @features = Feature.all
    @guests = Guest.all
    @projects = Project.all
	end

  # starts a project
  # queues up a project to start at 12:00AM the following day when this project was started
	def start_project
		@project = Project.find(params[:id])

		tomorrow = Time.at(((Time.now.to_f / 1.day).floor * 1.day) - 5.minutes)
		@project.update_attribute(:startdate, tomorrow + 7.hours)
		@project.update_attribute(:status, Project.status[:queued])
		flash[:notice] = "Project queued to start at #{tomorrow}"
		redirect_to :action => :controlpanel
  end

  # stops a project
  # a stopped project will not show up in the projects list when users browse for it
  def stop_project
    @project = Project.find(params[:id])

    @project.update_attribute(:startdate, nil)
    @project.update_attribute(:status, Project.status[:unverified])
    flash[:notice] = "Project stopped"
    redirect_to :action => :controlpanel
  end

  # features a project to be shown on the front page
  # refer to schema.rb for more info about featured projects
   def feature_project
     
     p = Project.find(params[:id])
     if p
       f = Feature.new
       f.project_id = p.id
       f.save
       
       flash[:notice] = "Project #{p.title} has been featured!"
     else
       flash[:error] = "Invalid project"
     end
     
     redirect_to :action => :controlpanel
   end

  # more generic admin views
  def projectoverview
    @npos = Npo.all
    @donations = Donation.all
    @subs = Subscriber.all
    @users = User.all
    @features = Feature.all
    @guests = Guest.all
    @projects = Project.all(:order => 'created_at DESC')
  end

  def search
    @npos = Npo.all
    @donations = Donation.all
    @subs = Subscriber.all
    @users = User.all
    @features = Feature.all
    @guests = Guest.all
    @projects = Project.all(:order => 'created_at DESC')
  end

  def newpanel
    @npos = Npo.all
    @donations = Donation.all
    @subs = Subscriber.all
    @users = User.all
    @features = Feature.all
    @guests = Guest.all
    @projects = Project.all(:order => 'created_at DESC')
  end

  def users_overview
    @npos = Npo.all
    @donations = Donation.all
    @subs = Subscriber.all
    @users = User.all(:order => 'created_at DESC')
    @features = Feature.all
    @guests = Guest.all
    @projects = Project.all(:order => 'created_at DESC')
  end

  def npos_overview
    @npos = Npo.all
    @donations = Donation.all
    @subs = Subscriber.all
    @users = User.all(:order => 'created_at DESC')
    @features = Feature.all
    @guests = Guest.all
    @projects = Project.all(:order => 'created_at DESC')
  end

  def donations_overview
    @npos = Npo.all
    @donations = Donation.all(:order => 'created_at DESC')
    @subs = Subscriber.all
    @users = User.all(:order => 'created_at DESC')
    @features = Feature.all
    @guests = Guest.all
    @projects = Project.all(:order => 'created_at DESC')
  end

  # archives a project
  def archive
    p = Project.find(params[:id])
    p.update_attribute(:archive, true)
    redirect_to :action => :projectoverview
  end

  def npopanel

  end

  # update an NPOs paypal as an admin
  # don't need checks since we are logged in as an admin
  def update_npo_paypal
    p = Npo.find(params[:npo_id])
    p.update_attributes(params[:npo])

    flash[:notice] = 'Paypal updated ' + p.to_s
    redirect_to :action => :npopanel
  end

  # exports all the users into a spreadsheet
  def users_spreadsheet
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet :name => 'User Email'

    #users = Donation.donations_for(params[:id])
    users = User.all

    row = sheet.row(0)
    row.push("First Name")
    row.push("Email")
    
    x = 1
    users.each do |d|

      row = sheet.row(x)
      row.push(d.fullname)
      row.push(Account.find(d.account_id).email)
      x = x +1
    end

    data = StringIO.new ''
    book.write data

    send_data data.string, :type => 'application/excel', :disposition => 'attachment', :filename => 'User_Email.xls'
  end

  # exports all the NPOs into a spreadsheet
  def npos_spreadsheet
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet :name => 'NPO Email'

    #users = Donation.donations_for(params[:id])
    npos = Npo.all

    row = sheet.row(0)
    row.push("First Name")
    row.push("Representative")
    row.push("Email")
    
    x = 1
    npos.each do |d|

      row = sheet.row(x)
      row.push(d.name)
      row.push(d.representative)
      row.push(Account.find(d.account_id).email)
      x = x +1
    end

    data = StringIO.new ''
    book.write data

    send_data data.string, :type => 'application/excel', :disposition => 'attachment', :filename => 'Npo_Email.xls'
  end

  # updates a project duration
  # this can extend the lifetime of a project
  def update_project_duration
    p = Project.find(params[:p_id])
    p.update_attribute(:duration, params[:project][:duration])

    flash[:notice] = 'Project duration updated'
    redirect_to :action => :projectoverview
  end
end


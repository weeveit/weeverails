class ProjectsController < ApplicationController

	protect_from_forgery

	before_filter :authenticated, :only => []
	before_filter :npo, :except => [:show, :updates_show, :donors_show, :comments_show, :embed, :guest_checkout]
	before_filter :current_npo, :except => [:show, :updates_show, :donors_show, :comments_show, :embed, :guest_checkout]

	require 'spreadsheet'
	require 'stringio'

  # ******************
  # the following methods are public ones that can be accessed by anyone
  # ******************
	def terms
	end

  # renders the guest checkout piece
  def guest_checkout
    respond_to do |format|
      format.html { render :controller => :home }
      format.js
    end
  end

  # renders the embed box
  def embed
    render :partial => 'projects/embed_project_box', :locals => {:p => Project.find(params[:id])}
  end

  # project home page
  def show
    @project = Project.find(params[:id])
    @npo = Npo.find_by_account_id(@project.account_id)
    @donations = Donation.donations_for(@project.id)

    add_view(@project.id)

    @twitter = get_twitter(@npo)
    @guest = Guest.new
  end

  # view for project updates
  def project_updates
    @project = Project.find(params[:id])
  end

  # view for showing all the contributors to the project
  def donors_show
    @project = Project.find(params[:id])
    @npo = Npo.find_by_account_id(@project.account_id)
    @donations = Donation.donations_for(@project.id)
    @twitter = get_twitter(@npo)
    @guest = Guest.new
    render "projects/project_donors_show"
  end

  # view for showing all the comments to the project
  def comments_show
    @guest = Guest.new
    @project = Project.find(params[:id])
    @npo = Npo.find_by_account_id(@project.account_id)
    @comments = Comment.find_all_by_project_id(@project.id)
    @twitter = get_twitter(@npo)
    render "projects/project_comments_show"
  end

  # ******************
  # the following methods are only for project creators
  # ******************

  # creating a new project
	def new
		if params[:project][:terms] == '0'
			flash[:error] = "You must agree to the terms before creating a project"
			redirect_to :action => :terms, :account_id => current_usertype.account_id
		end

		@project = Project.new
	end

  # creates project
	def create

		@project = Project.new(params[:project])
    @account = current_user
		@project.account_id = @account.id
		@project.status = Project.status[:unverified]

		if params[:project][:startingvideo] == ''
			@project.startingvideo = nil
		end

		if @project.save
			flash[:notice] = "Thank you for creating a project!  We will review it soon and publish your project as soon as possible."
			redirect_to :controller => :npos, :action => :profile, :id => @account.id
		else
			render "new"
		end
	end

  # view to edit project
	def edit_project
 		@project = Project.find(params[:id])
	end

  # updates general project information
	def update_home
		@project = Project.find(params[:id])

		if params[:project][:startingvideo] == '' || params[:project][:startmedia]
			params[:project][:startingvideo] = nil
		end

		if @project.update_attributes(params[:project])
			flash[:notice] = 'Project updated'
			redirect_to :action => :edit_project, :id => @project.id, :account_id => current_usertype.account_id
		else
			render 'edit_project'
		end
	end

  # shows all the updates that have been created for this project
	def updates_show
    @guest = Guest.new
		@project = Project.find(params[:id])
		@npo = Npo.find_by_account_id(@project.account_id)
		@updates = Update.order("created_at").find_all_by_project_id(@project.id)
		@twitter = get_twitter(@npo)

		render 'projects/project_updates_show'
	end

  # displays the project status to the creator of this project
	def project_status
		@project = Project.find(params[:id])

		render 'projects/project_status'
	end

	private

  # adds a project view, this tracks unique visitors
	def add_view(id)

		if Pview.where(:project_id => id, :ip => request.remote_ip).all.size == 0
			view = Pview.new
			view.project_id = id
			view.ip = request.remote_ip
			view.save
		end
	end

	def parse(raw)
		data = Hash.new
		for line in raw.split('&')
			key, value = CGI.unescape(*line).scan( %r{^([A-Za-z0-9_.\[\]]+)\=(.*)$} ).flatten
			data[key] = value
		end
		data
	end

  # attempts to grab twitter info from twitter
  # if this fails, then the project page will not display the project creator's
  # twitter panel
	def get_twitter(npo)
		require 'net/http'
		require 'rexml/document'

    begin

      res = Net::HTTP.get(URI.parse("http://api.twitter.com/1/users/show.xml?screen_name=#{npo.twitter}"))
      document = REXML::Document.new(res)

      if document.root.elements[2]
        document.root.elements[2].expanded_name == 'error' ? nil : npo.twitter
      end
    rescue
      nil
    end
	end
end
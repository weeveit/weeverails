class HomeController < ApplicationController

	protect_from_forgery

	require 'active_support/all'

  # home controller

  # landing page
	def index

    @npo = Npo.new
    @account = Account.new
    
    f = Feature.all.last
    @feature = Project.find(f.project_id)
    @featurenpo = Npo.find_by_account_id(@feature.account_id)
    @landing = true
    @projects = Project.where("id <> " + @feature.id.to_s + " AND status = '" + Project.status[:running] + "'").all.last(3)
	end

  # allows a user to choose what type of account they want
	def signup_choose
	end

  # logs in a user
  def login
    user = Account.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
    else
      flash[:error] = "Invalid username or password"
    end

    if user && user.account_type == Account.roles[:npo]
      redirect_to :controller => :accounts, :action => :profile, :id => session[:user_id]
    else
      redirect_to root_url
    end
	end

  # logs out a user
	def logout
		session[:user_id] = nil
		session[:admin] = nil
    session[:provider] = nil
		redirect_to root_url
	end

  # adds a person to the mailing list
  def subscribe

    if Subscriber.find_by_email(params[:subscriber][:email])
      flash[:error] = "The email provided is already on the subscription list"
      redirect_to root_url and return
    end


    if Subscriber.subscribe(params[:subscriber][:email])
      flash[:notice] = "Your email has been added to our subscription list. Thanks for subscribing to our newsletter!"
    else
      flash[:error] = "There was an error subscribing to the newsletter.  Please try again later."
    end

    redirect_to root_url
  end

  # shows the list of projects
	def projects

		@projects = Project.find_all_by_status(Project.status[:running])
		@categories = grab_categories( @projects )
		@locations = grab_locations( @projects )

    # this part is for featured projects
    # currently, there are Recently Started, Ending Soon, and Small Projects
    # this section can be extended to grab different features
    # based on different criteria
		if params[:featured]
			@featured = params[:featured]
			features = get_featured

			if params[:featured] == features[:recent]
				@projects = Project.order('startdate').find_all_by_status(Project.status[:running]).reverse

				if @projects.length == 0
					flash[:error] = "There are no projects in this feature!"
					redirect_to root_url and return
				end

			elsif params[:featured] == features[:ending]
				@projects = Project.find_all_by_status(Project.status[:running])
				@projects.sort! { |x,y|
					x.startdate + x.duration.days <=> y.startdate + y.duration.days
				}
			elsif params[:featured] == features[:small]
				@projects = Project.where(
						"status = :status AND target_amount < 1000",
						{:status => Project.status[:running]}
				).all
			end

			if @projects.length == 0
				flash[:error] = "There are no projects in this feature!"
				redirect_to :action => :projects, :featured => get_featured[:recent] and return
			end

    # grabs projects based on a category
		elsif params[:category]
			@projects = Project.find_all_by_category_and_status(params[:category], Project.status[:running])
			@category = params[:category]

			if @projects.length == 0
				flash[:error] = "There are no projects in this category!"
				redirect_to :action => :projects, :featured => get_featured[:recent] and return
			end

    # grabs all projects based on a location
		elsif params[:location]
			proj = Project.all
			@projects = Array.new
			@location = params[:location]

			proj.each do |p|
				if p.location[/#{params[:location]}/] != nil && p.status == Project.status[:running]
					@projects.push(p)
				end
			end

			if @projects.length == 0
				flash[:error] = "There are no projects in this location!"
				redirect_to :action => :projects, :featured => get_featured[:recent] and return
			end
		else
			flash[:error] = "There are no projects with this filter"
			redirect_to :action => :projects, :featured => get_featured[:recent] and return
		end
  end

  # sends feedback to admins, refer to user_mailer.rb for more information about the mailers
  def send_feedback 
    UserMailer.feedback(params[:subject], params[:message]).deliver
    flash[:notice] = 'Thank you for your feedback!  Enjoy your stay at Weeve.'
    redirect_to root_url
  end

  # static pages
	def faq
	end

	def terms
	end

	def privacy
	end

	def contact
	end

	def about

	end
	
	def press
	end
	
	def pr
  end
  
  def pc
  end

  # for PR page to allow people to download company logos
	def download_logos
	  loc = ActionController::Base.helpers.asset_path('Alex.png')
	  send_data 'app/assets/logos.zip', :type => 'application/zip'
	end

	private

  # looks at all the projects, and returns the list of categories available to choose from
	def grab_categories( projects )
		cats = Array.new
		projects.each do |p|
			if cats.index(p.category) == nil && p.status == Project.status[:running]
				cats.push(p.category)
			end
		end

		cats.sort! { |x,y|
			x <=> y
		}

		cats
	end

  # looks at all the locations and returns the list of locations to choose from
	def grab_locations( projects )
		locs = Array.new

		projects.each do |p|
			l = p.location[/.*[,]/][0..-2]
			if locs.index(l) == nil && p.status == Project.status[:running]
				locs.push(l)
			end
		end

		locs.sort! { |x,y|
			x <=> y
		}

		locs
  end


end

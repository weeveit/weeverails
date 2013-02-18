class UpdatesController < ApplicationController

	protect_from_forgery

	before_filter :authenticated
	before_filter :npo
	before_filter :current_npo

  # controllers for project updates

  # view for creating a new update
	def new
		@project = Project.find(params[:project_id])

		if current_user.id != @project.account_id
			flash[:error] = "You can only create updates for your own projects!"
			redirect_to root_url
		end

		@update = Update.new

		render "projects/new_update"
	end

  # creates a new project update
	def create
		@project = Project.find(params[:project_id])
		@update = Update.new(params[:update])
		@update.project_id = @project.id

		if current_user.id != @project.account_id
			flash[:error] = "You can only create updates for your own projects!"
			redirect_to root_url
		end

		if @update.save
			flash[:notice] = "Update created successfully"
			redirect_to :controller => :projects, :action => :project_updates, :id => @project.id, :account_id => current_usertype.account_id
		else
			render 'new'
		end
	end

  # view for editing an update
	def edit
		@project = Project.find(params[:project_id])
		@update = Update.find(params[:update_id])

		if current_user.id != @project.account_id
			flash[:error] = "You can only edi updates for your own projects!"
			redirect_to root_url
		end

		render "projects/edit_update"
	end

  # "updates" the update
	def change_update
		@update = Update.find(params[:update_id])

		if @update
			@project = Project.find(@update.project_id)

			if current_user.id != @project.account_id
				flash[:error] = "You can only change updates for your own projects!"
				redirect_to root_url
			end

			if @update.update_attributes(params[:update])
				flash[:notice] = "Update changed successfully"
				redirect_to :controller => :projects, :action => :project_updates, :id => @update.project_id, :account_id => current_usertype.account_id
			else
				render 'edit'
			end
		end
	end

  # deletes the update
	def remove
		@update = Update.find(params[:update_id])

		if @update
			@project = Project.find(@update.project_id)

			if current_user.id != @project.account_id
				flash[:error] = "You can only delete updates for your own projects!"
				redirect_to root_url
			end

			if @update.destroy
				flash[:notice] = "Update changed successfully"
				redirect_to :controller => :projects, :action => :project_updates, :id => @update.project_id, :account_id => current_usertype.account_id
			else
				flash[:notice] = "Update changed successfully"
				redirect_to :controller => :projects, :action => :project_updates, :id => @project.project_id, :account_id => current_usertype.account_id
			end
		end
	end
end

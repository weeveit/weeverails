class CommentsController < ApplicationController

	protect_from_forgery
	
	before_filter :authenticated, :only => [:create_comment]

  # comments for a project controller

  # create a comment, anyone who is logged in can create a comment
	def create_comment
		comment = Comment.new
		comment.body = @string = CGI.unescape(params[:comment][:body]).gsub(/\n/,"<br />")
		comment.project_id = params[:project_id]
		comment.account_id = params[:account_id]
		comment.save

		flash[:notice] = "Your comment has been created"
		redirect_to :controller => :projects, :action => :comments_show, :id => params[:project_id]
	end

  # deletes a comment
  # only admins and the comment's owner can delete comments
	def remove_comment
	  if current_usertype.account_id == params[:account_id].to_i || current_admin
  		comment = Comment.find(params[:id])
  		comment.destroy
  		flash[:notice] = "Comment removed"
  		redirect_to :controller => :projects, :action => :comments_show, :id => params[:project_id]
	  else
	    flash[:error] = "You do not have access to this page"
	    redirect_to root_url
	  end
	end
end

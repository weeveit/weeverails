class ProjectValidator < ActiveModel::Validator

  # project validator will validate a project to make sure a project can be made properly
	def validate(record)
		if (record.startingvideo == 'Enter your video URL here' || record.startingvideo == '') && !record.startmedia.file?
			record.errors['At least'] << ' one starting media must exist'
		end

		if (record.startingvideo)
			id = parse_youtube(record.startingvideo)
			if !id
				record.errors['Starting video'] << ' is in an invalid format'
			end
		end

		record.title.strip!
		record.blurb.strip!
		record.overview.strip!
		record.impact.strip!
		record.funds.strip!
		record.milestones.strip!
	end

	def parse_youtube(url)
  	regex = /^(?:http:\/\/)?(?:www\.)?\w*\.\w*\/(?:watch\?v=)?((?:p\/)?[\w\-]+)/
  	match = url.match(regex)
		if match
			match[1]
		else
			nil
		end
	end
end

class Project < ActiveRecord::Base

	attr_accessor :imageURL

  before_save :remove_styles

	validates_length_of :blurb, :maximum => 220, :message => 'cannot be more than 220 characters'
  validates_length_of :title, :maximum => 60, :message => 'cannot be more than 60 characters'
	validates_numericality_of :target_amount, :greater_than => 499, :message => 'to raise must be at least $500'
	validates_numericality_of :duration, :greater_than => 19, :less_than => 61, :message => 'of your project must be at least 20 days and less than 60 days'
	validates_presence_of :title, :location, :blurb, :overview, :impact, :funds, :milestones

	validates_attachment_presence :thumbnail
	validates_attachment_content_type :thumbnail, :message => 'must be JPG, PNG, or GIF',:content_type => ['image/png','image/jpg','image/jpeg','image/gif']
	validates_attachment_size :thumbnail, :message => 'must be under 10MB', :size => {:in => 0..10.megabytes}

	validates_attachment_content_type :startmedia, :message => 'must be JPG, PNG, or GIF', :content_type => ['image/png','image/jpg','image/jpeg','image/gif']
	validates_attachment_size :startmedia, :message => 'must be under 10MB', :size => {:in => 0..10.megabytes}

	validates_with ProjectValidator

  # attached files for a project
  # must change s3_credentials to point to the right buckets
	has_attached_file 	:thumbnail,
											:storage => :s3,
											:default_url => ActionController::Base.helpers.asset_path("npoicon.png"),
											:bucket => '',
											:s3_credentials => {
												:access_key_id => '',
												:secret_access_key => '+'
											}

	has_attached_file 	:startmedia,
											:storage => :s3,
											:default_url => ActionController::Base.helpers.asset_path("npoicon.png"),
											:bucket => '',
											:s3_credentials => {
												:access_key_id => '',
												:secret_access_key => '+'
											}

  # removes the inline css styles for the attributes of this projects
  def remove_styles

    if self.overview
      self.overview = self.overview.gsub(/font-family[^;]*;/,'')
      self.overview = self.overview.gsub(/font-size[^;]*;/,'')
      self.overview = self.overview.gsub(/background[^;]*;/,'')
      self.overview = self.overview.gsub(/color[^;]*;/,'')
      self.overview = self.overview.gsub(/border[^;]*;/,'')
      self.overview = self.overview.gsub(/line-height[^;]*;/,'')
    end

    if self.impact
      self.impact = self.impact.gsub(/font-family[^;]*;/,'')
      self.impact = self.impact.gsub(/font-size[^;]*;/,'')
      self.impact = self.impact.gsub(/background[^;]*;/,'')
      self.impact = self.impact.gsub(/color[^;]*;/,'')
      self.impact = self.impact.gsub(/border[^;]*;/,'')
      self.impact = self.impact.gsub(/line-height[^;]*;/,'')
    end

    if self.funds
      self.funds = self.funds.gsub(/font-family[^;]*;/,'')
      self.funds = self.funds.gsub(/font-size[^;]*;/,'')
      self.funds = self.funds.gsub(/background[^;]*;/,'')
      self.funds = self.funds.gsub(/color[^;]*;/,'')
      self.funds = self.funds.gsub(/border[^;]*;/,'')
      self.funds = self.funds.gsub(/line-height[^;]*;/,'')
    end

    if self.milestones
      self.milestones = self.milestones.gsub(/font-family[^;]*;/,'')
      self.milestones = self.milestones.gsub(/font-size[^;]*;/,'')
      self.milestones = self.milestones.gsub(/background[^;]*;/,'')
      self.milestones = self.milestones.gsub(/color[^;]*;/,'')
      self.milestones = self.milestones.gsub(/border[^;]*;/,'')
      self.milestones = self.milestones.gsub(/line-height[^;]*;/,'')
    end
  end

  # the static project statuses for a project
  # must be changed if there are different status for a project
  # then need to do a Project.status project search to find out where it is used and change accordingly
  # it is stored as a hash so the naming can be changed so there need not be a lot of refactoring
	def self.status
		Hash[:unverified => "Processing", :queued => "Accepted and queued", :running => "Running", :success => "Ended Successfully"]
	end

  # returns the amount of days left for a particular project
	def self.days_left(id)

		project = Project.find(id)

		if project.startdate
			daysleft = project.duration - (Time.now - project.startdate).to_i / 1.day
			if daysleft > 0
				return daysleft
			else
				return 0
			end
		else
			return 0
		end
	end

  # returns all the projects for a project creator
	def self.all_projects_for_npo(id)
		Project.find_all_by_account_id(id)
	end

  # checks all projects and ends any projects whose time is up
  # if a project's time is up, it will change the status and send an email
  # to the project creator
	def self.check_completion
		proj = Project.where(:status => Project.status[:running]).all

		proj.each do |p|
			if ((p.startdate + p.duration.to_i.days) <=> Time.now) <= 0
				p.update_attribute(:status, Project.status[:success])
				UserMailer.project_complete(p).deliver
				puts "Project #{p.title} has ended."
			end
		end
	end

  # checks all projects and starts any projects that are queued to start
  # if a project can be started, the status is updated and an email is
  # sent to the project creator
	def self.check_start
		proj = Project.where(:status => Project.status[:queued]).all
		proj.each do |p|
			if (p.startdate <=> Time.now) <= 0
				p.update_attribute(:status, Project.status[:running])
				UserMailer.project_started(p).deliver
				puts "Project #{p.title} has started."
			end
		end
  end
end



class Npo < ActiveRecord::Base

	before_save :remove_styles

	attr_accessor :imageURL

	validates_length_of :bio, :maximum => 300, :message => 'Bio cannot be more than 300 characters'

	has_attached_file 	:thumbnail,
											:storage => :s3,
											:default_url => ActionController::Base.helpers.asset_path("npoicon.png"),
											:bucket => 'vvweeverails',
											:s3_credentials => {
												:access_key_id => 'AKIAI576XAU7SH57QZFA',
												:secret_access_key => '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'
											}

  # npo model

  # currently the application supports CAD and USD
  # can add additional currencies here
  def self.currency
    Hash[:CAD => "CAD", :USD => "USD"]
  end

  # returns the correct array for displaying currencies in the view
  def self.currency_for_select
    array = Array.new
    
    Npo.currency.keys.each do |k|
      array << Npo.currency[k]
    end
  end

  # the current PayPal statuses available to project creators
	def self.paypal_status
		Hash[:unverified => "Not Verified", :pending => "Pending", :verified => "Verified"]
	end

  # returns all the projects for this particular project creator
	def projects
		Project.order("created_at").find_all_by_account_id(account_id).reverse
	end

  # strips out the styles of the about
  def remove_styles

		if self.about
		  self.about = self.about.gsub(/font-family[^;]*;/,'')
		  self.about = self.about.gsub(/font-size[^;]*;/,'')
		  self.about = self.about.gsub(/background[^;]*;/,'')
		  self.about = self.about.gsub(/color[^;]*;/,'')
		  self.about = self.about.gsub(/border[^;]*;/,'')
		end
	end
end

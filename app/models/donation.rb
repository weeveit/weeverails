class Donation < ActiveRecord::Base

  # donation model
  # this represents a contribution made to a project by a user

  # returns all donations that are complete
  # Donations are first made when a user types in an amount to donate and proceed to PayPal
  # but at that point the donation is not "complete"
  # only once the IPN gets sent back to the application, will the donation be considered complete
  def self.all_donations
    Donation.order(:received_at).where(:complete => true).all
  end

  # requtrns all the complete donations for a particular project
	def self.donations_for(project_id)
		Donation.order(:received_at).where(:project_id => project_id, :complete => true).all
	end

  # returns the total amount contributed for the input array of Donations
	def self.total_for(donations)

		amount = 0
		donations.each do |d|
			amount = amount + d.npo_amount
		end

		amount.to_i
	end

  # returns all the complete Donations for a particular user
	def self.donations_for_user(id)
		Donation.order("received_at").where(:user_id => id, :complete => true).all
	end

  # returns the number of projects the input Donation array spans across
	def self.number_of_projects_for_user(donations)

		proj = Array.new

		donations.each do |d|
			if !proj.index(d.project_id)
				proj.push(d.project_id)
			end
		end

		proj.size
	end

  # returns the project this Donation was made to
	def self.project_for(donation)
		Project.find(donation.project_id)
	end

  # returns all the complete donations for a particular project creator (NPO)
	def self.donations_for_npo(id)
		donations = Array.new

		projects = Project.find_all_by_account_id(id)

		projects.each do |p|
			donations = donations + Donation.donations_for(p.id)
		end

		donations
	end

  # returns the size of the list of unique users from input array of Donations
	def self.number_of_donors_for_npo(donations)

		users = Array.new

		donations.each do |d|
			if !users.index(d.user_id)
				users.push(d.user_id)
			end
		end

		users.size
	end
end

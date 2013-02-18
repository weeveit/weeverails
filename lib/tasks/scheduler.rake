desc "This task is called by the Heroku scheduler add-on"
task :update_projects => :environment do
	puts "Checking for projects to update status..."
	Project.check_completion
	puts "done."
end

task :start_projects => :environment do
	puts "Checking for projects to start..."
	Project.check_start
	puts "done."
end

task :delete_tasks => :environment do
	projects = Project.all
	projects.each do |p|
		if !Npo.find_by_account_id(p.account_id)
			p.destroy
			puts "Destroyed #{p.title}"
		end
	end
end

task :create_users => :environment do
  x = 1

  while x < 100
    valA = {
      :password => 'donburichan',
      :email => 'user'+x.to_s,
      :account_type => Account.roles[:user],
      :confirmed => true
    }

    account = Account.new(valA)
    account.save

    valU = {
      :fullname => 'Donburi Chan',
      :account_id => account.id
    }

    user = User.new(valU)
    user.save

    x = x + 1
  end
end
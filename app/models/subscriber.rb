class Subscriber < ActiveRecord::Base

  validates_presence_of :email

  def self.subscribe(email)
    s = Subscriber.new
    s.email = email
    s.save
  end
end

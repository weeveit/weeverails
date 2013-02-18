class Omniuser < ActiveRecord::Base

  def self.providers
    Hash['facebook' => "facebook"]
  end

end

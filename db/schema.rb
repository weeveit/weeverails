# this file represents the schema for the database

ActiveRecord::Schema.define(:version => 20120810221517) do

  # the application has an Account model, which is a generic model for
  # any type of account
  #
  #              Account
  #           /     |    \
  #         Admin  User   NPO
  #
  # in other words, all Admins, Users, and NPOs are all Accounts
  # Accounts are generic and only contain the hashed_password, email, and account type
  # refer to the models below to understand more about each type of account
  create_table "accounts", :force => true do |t|
    t.string   "hashed_password",                    :null => false
    t.string   "email",                              :null => false
    t.string   "salt",                               :null => false
    t.string   "account_type",                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed",       :default => false
    t.boolean  "recoverable",     :default => false
    t.datetime "recovery_date"
  end

  # admin model
  # only has a username and hashed_password
  create_table "admins", :force => true do |t|
    t.string   "username",                       :null => false
    t.string   "hashed_password",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salt",                           :null => false
    t.integer  "account_id",      :default => 0
  end

  # comments for a particular project
  # linked to a project and account
  create_table "comments", :force => true do |t|
    t.integer  "project_id"
    t.integer  "account_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  # donation (contribution) for a particular project
  # linked to a project, and user
  # application only keeps track of the transactional ids, and the amounts
  # no credit card information is stored
  create_table "donations", :force => true do |t|
    t.integer  "project_id",                                           :null => false
    t.integer  "user_id",                                              :null => false
    t.string   "sender_transaction_id"
    t.string   "npo_transaction_id"
    t.string   "weeve_transaction_id"
    t.boolean  "complete"
    t.decimal  "npo_amount",            :precision => 63, :scale => 2
    t.decimal  "weeve_amount",          :precision => 63, :scale => 2
    t.datetime "received_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "taxable"
  end

  # this represents the Featured projects for the application
  # this is here so that more than 1 project can be featured at a time
  create_table "features", :force => true do |t|
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  # this is a Guest account for people who want to contribute as a guest
  # guests can still input their personal information if they want to
  # but they do not have a persisting "account"
  create_table "guests", :force => true do |t|
    t.integer "donation_id"
    t.string  "fullname",    :default => ""
    t.string  "email",       :default => ""
    t.string  "address1",    :default => ""
    t.string  "address2",    :default => ""
    t.string  "city",        :default => ""
    t.string  "province",    :default => ""
    t.string  "postal_code", :default => ""
    t.string  "country",     :default => ""
  end

  # this is the NPO model, which are the project creators
  # they have paypal information (status, email, currency)
  # they also have twitter handles
  create_table "npos", :force => true do |t|
    t.integer  "account_id",                                :null => false
    t.string   "name",                                      :null => false
    t.string   "representative",                            :null => false
    t.string   "paypal_email"
    t.text     "about"
    t.text     "bio"
    t.string   "website"
    t.boolean  "showemail",              :default => false
    t.boolean  "showlocation",           :default => true
    t.boolean  "verified",               :default => false
    t.string   "paypal_status",                             :null => false
    t.string   "location"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter"
    t.string   "paypal_currency",        :default => "CAD"
  end

  # the omniuser which is linked to an account and user
  create_table "omniusers", :force => true do |t|
    t.integer  "account_id"
    t.string   "uid"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  # the project table
  # has many attributes that describe the project
  # tied to an account
  # startdate is the date that the project is set to start
  # duration is how long the project should stay live for
  # target_amount is the amount the project wishes to raise
  # category is which category the project belongs to
  create_table "projects", :force => true do |t|
    t.integer  "account_id",                                                     :null => false
    t.string   "title",                                                          :null => false
    t.string   "location",                                                       :null => false
    t.string   "startingvideo"
    t.boolean  "verified",                                    :default => false
    t.string   "status",                                                         :null => false
    t.datetime "startdate"
    t.integer  "target_amount",                                                  :null => false
    t.integer  "duration",                                                       :null => false
    t.string   "category",                                                       :null => false
    t.text     "blurb",                                                          :null => false
    t.text     "overview",                                                       :null => false
    t.text     "impact",                                                         :null => false
    t.text     "funds",                                                          :null => false
    t.text     "milestones",              :limit => 16777215
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.string   "startmedia_file_name"
    t.string   "startmedia_content_type"
    t.integer  "startmedia_file_size"
    t.datetime "startmedia_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archive",                                     :default => false
  end

  # this is the table to store unique project views
  # has an ip attribute to track the IP
  create_table "pviews", :force => true do |t|
    t.integer  "project_id"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  # the subscribers of the application
  create_table "subscribers", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  # project updates
  # linked to a project id
  create_table "updates", :force => true do |t|
    t.integer  "project_id", :null => false
    t.string   "title",      :null => false
    t.text     "body",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  # a user in the system
  # has some privacy settings (show history, showemail, and showlocation)
  # users can also have personal information
  create_table "users", :force => true do |t|
    t.integer  "account_id",                                :null => false
    t.string   "fullname",                                  :null => false
    t.boolean  "showhistory",            :default => true
    t.boolean  "showemail",              :default => false
    t.boolean  "showlocation",           :default => true
    t.string   "location"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address1",               :default => ""
    t.string   "address2",               :default => ""
    t.string   "city",                   :default => ""
    t.string   "province",               :default => ""
    t.string   "postal_code",            :default => ""
    t.string   "country",                :default => ""
  end

end

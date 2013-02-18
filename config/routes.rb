Weeverails::Application.routes.draw do

	match "admin/login" => "admins#login"
	match "admin/controlpanel" => "admins#controlpanel"
	match "admin/startproject" => "admins#start_project"
  match "admin/stopproject" => "admins#stop_project"
  match "admin/featureproject" => "admins#feature_project"
  match "admin/newpanel"   => "admins#newpanel"
  match "admin/npopanel"   => "admins#npopanel"
  match "admin/projectoverview" => "admins#projectoverview"
  match "admin/search" => "admins#search"
  match "admin/archive" => "admins#archive"
  match "admin/update-npo-paypal" => "admins#update_npo_paypal"
  match "admin/users_overview" => "admins#users_overview"
  match "admin/npos_overview" => "admins#npos_overview"
  match "admin/donations_overview" => "admins#donations_overview"
  match "admin/user_amt" => "admins#user_amt"
  match "admin/users_spreadsheet" => "admins#users_spreadsheet"
  match "admin/npos_spreadsheet" => "admins#npos_spreadsheet"
  match "admin/update_project_duration" => "admins#update_project_duration"

	match "faq" => "home#faq"
	match "terms" => "home#terms"
	match "privacy" => "home#privacy"
	match "contact" => "home#contact"
	match "about" => "home#about"
	match "embed" => "projects#embed"

	match "npos/removeAccount" => "npos#delete_account"
	match "npos/verify_paypal" => "npos#verify_paypal"
	match "npos/about" => "npos#about"
	match "npo/profile" => "npos#profile"

	match "user/profile" => "users#history"
	match "user/personalInformation" => "users#personal_information"
	match "user/updatePersonalInformation" => "users#update_personal_information"
	match "user/destroy" => "users#remove_user"

	match "landing" => "home#index"
	match "users/usersignup" => "users#new"
	match "profile/npoedit" => "npos#edit", :as => :npo_edit
	match "profile/useredit" => "users#edit", :as => :user_edit
	match "user/update_profile" => "users#update_profile"
	match "npo/update_profile" => "npos#update_profile"
	match "npo/edit_paypal" => "npos#edit_paypal"
	match "npo/update_paypal" => "npos#update_paypal"
	match "profile/password" => "accounts#edit_password"
	match "profile/change_password" => "accounts#change_password"

	match "account/recover" => "accounts#recover"
	match "account/confirm" => "accounts#confirm"
	match "account/reset" => "accounts#reset"
	match "account/update_password" => "accounts#update_password"
	match "profile/:id" => "accounts#profile"
	match "project/home/:id" => "projects#show", :as => :show_project
	match "project/edit" => "projects#edit_project"
	match "project/updateHome" => "projects#update_home"
	match "project/create" => "projects#create"
	match "project/viewUpdates" => "projects#project_updates"

	match "project/newupdate" => "updates#new"
	match "project/updateCreate" => "updates#create"
	match "project/editUpdate" => "updates#edit"
	match "project/changeUpdate" => "updates#change_update"
	match "project/removeUpdate" => "updates#remove"
	match "project/updates" => "projects#updates_show"
	match "project/status" => "projects#project_status"
	match "project/donorInfo" => "projects#donation_spreadsheet"
	match "project/donors" => "projects#donors_show"
	match "project/comments" => "projects#comments_show"
	match	"project/createComment" => "comments#create_comment"

	match "home/chooserole" => "home#signup_choose"
	match "home/nposubscribe" => "home#nonprofit_subscribe"
	match "home/usersubscribe" => "home#user_subscribe"
	match "home/corpsubscribe" => "home#corp_subscribe"
  match "home/feedback" => "home#send_feedback"
  match "home/media" => "home#press"
  match "home/press" => "home#pr"
  match "home/logos" => "home#download_logos"
  match "home/pc" => "home#pc"
  match "home/announcement" => "home#announcement"

	match "projects" => "home#projects"
	match "logout" => "home#logout"

	match "login" => "home#login"

	match "donations/pay" => "donations#donate"
	match "donations/complete" => "donations#complete"
	match "donations/cancel" => "donations#cancel"
	match "donations/success" => "donations#success"

	match "comment/remove" => "comments#remove_comment"

	match "help/main" => "university#index"
  match "help/npo-start" => "university#nonprofit_accounts"
  match "help/define-proj" => "university#define_project"
  match "help/describe-proj" => "university#describe_project"
  match "help/comm-engage" => "university#community_engagement"
  match "help/proj-mgmt" => "university#manage_project"
  match "help/proj-promo" => "university#project_promo"
  match "help/proj-complete" => "university#complete_project"
  match "help/user-start" => "university#user_accounts"
  match "help/disc-proj" => "university#discover_projects"
  match "help/donate-proj" => "university#donate_projects"

  match "subscribe" => "home#subscribe"

  match "careers" => "careers#index"

	get "project/terms" => "projects#terms"
	get "project/new" => "projects#terms"
	post "project/new" => "projects#new"

	resources :users
	resources :accounts
	resources :npos

  match 'omni', :to => 'accounts#omniauth_weeve'
  match '/auth/:provider/callback', :to => 'accounts#omniauth_weeve'
  match '/auth/failure', :to => 'accounts#omni_failure'
  
  match 'check_paypal' => "admins#check_paypal"

  match '/sitemap' => "sitemap#index"

	root :to => "home#index"
end

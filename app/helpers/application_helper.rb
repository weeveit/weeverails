module ApplicationHelper

  # helper methods that can be used by any view

  # returns whether you are in a 'landing page', which are the static pages
  # of the application
	def in_landing_pages
		(params[:controller] == "home" && params[:action] == "index") ||
				(params[:controller] == "home" && params[:action] == "signup_choose") ||
				(params[:controller] == "users" && params[:action] == "new") ||
				(params[:controller] == "accounts" && params[:action] == "recover") ||
				(params[:controller] == "npos" && params[:action] == "new") ||
				(params[:controller] == "admins" && params[:action] == "login") ||
				(params[:controller] == "home" && params[:action] == "faq") ||
				(params[:controller] == "home" && params[:action] == "terms") ||
				(params[:controller] == "home" && params[:action] == "privacy") ||
				(params[:controller] == "home" && params[:action] == "contact") ||
				(params[:controller] == "home" && params[:action] == "about")
  end

  # returns whether you are on the home page
  def home
    (params[:controller] == "home" && params[:action] == "index")
  end

  # helper method to check whether you are in a controller and an action
	def cp(controller, action)
		params[:controller] == controller && params[:action] == action
	end

  # returns all the categories of a project that a creator can choose from
  # edit this array to change the project categories available to project creators
	def getCategories
		["Animal", "Art", "Children", "Community", "Culture", "Education", "Health", "Housing", "Religion", "Service", "Youth"]
	end

  # returns the HTML iframe for a youtube embed
	def renderYoutube(width, height, url)
		"<iframe width='#{width}' height='#{height}' src='http://www.youtube.com/embed/#{parse_youtube(url)}?wmode=transparent&modestbranding=1&rel=0&showinfo=0' frameborder='0' allowfullscreen></iframe>"
	end

  # parses an URL and returns the youtube id, returns nil if it's an invalid url
	def parse_youtube(url)
  	regex = /^(?:http:\/\/)?(?:www\.)?\w*\.\w*\/(?:watch\?v=)?((?:p\/)?[\w\-]+)/
  	match = url.match(regex)
		if match
			match[1]
		else
			nil
		end
	end

  # returns the donation history of a particular user
	def user_donation_history(donations)

		values = ActiveSupport::OrderedHash.new

		donations.each do |d|
			month = d.received_at.month
			if values.keys.index(month)
				values[month].push(d)
			else
				values[month] = Array.new
				values[month].push(d)
			end
		end

		values
	end

  # month hashes
	def month_hash
		Hash[1 => "January", 2 => "February", 3 => "March", 4 => "April", 5 => "May", 6 => "June", 7 => "July",
				 8 => "August", 9 => "September", 10 => "October", 11 => "November", 12 => "December"]
	end

	def short_month_hash
		Hash[1 => "jan", 2 => "feb", 3 => "mar", 4 => "apr", 5 => "may", 6 => "jun", 7 => "jul",
				 8 => "aug", 9 => "sept", 10 => "oct", 11 => "nov", 12 => "dec"]
	end

	# ISO 3166 Standard list of Countries
	def countries
		 ["Canada", "United States", "Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola",
        "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria",
        "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin",
        "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Bouvet Island", "Brazil",
        "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia",
        "Cameroon", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China",
        "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo",
        "Congo, the Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba",
        "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt",
        "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)",
        "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia",
        "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea",
        "Guinea-Bissau", "Guyana", "Haiti", "Heard and McDonald Islands", "Holy See (Vatican City State)",
        "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran, Islamic Republic of", "Iraq",
        "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya",
        "Kiribati", "Korea, Democratic People's Republic of", "Korea, Republic of", "Kuwait", "Kyrgyzstan",
        "Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya",
        "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia, The Former Yugoslav Republic Of",
        "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique",
        "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova, Republic of",
        "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru",
        "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger",
        "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau",
        "Palestinian Territory, Occupied", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines",
        "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation",
        "Rwanda", "Saint Barthelemy", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia",
        "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino",
        "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore",
        "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa",
        "South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "Sudan", "Suriname",
        "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic",
        "Taiwan", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Timor-Leste",
        "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan",
        "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela",
        "Viet Nam", "Virgin Islands, British", "Virgin Islands, U.S.", "Wallis and Futuna", "Western Sahara",
        "Yemen", "Zambia", "Zimbabwe"]
	end
end


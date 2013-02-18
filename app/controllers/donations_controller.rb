class DonationsController < ApplicationController

	protect_from_forgery

	include ActiveMerchant::Billing::Integrations

  # donation controller, but this is the representation of a contribution to a project
  # which is a donation in Weeve's case

  # the donate method
  # takes in the amount that someone wants to donate, and calls PayPal
	def donate

    # amount is the amount that the user wants to donate
		amount = params[:donation][:amount].to_i
    # this is the amount that can be deferred to someone else
    # for example if someone wants to donate $1.00 and your policy is that
    # $0.05 will come out of every dollar to go towards a charity, then you would set
    # that amount here.  This exists because of PayPal's adaptive payment system
    # https://www.x.com/developers/paypal/products/adaptive-payments
		weeve_amount = 0.01
		
		@donation = Donation.new

    # if this is a guest checkout (without the need to sign in)
    # refer to schema.rb for more details about guest checkouts
    if params[:guest_checkout]
      @guest = Guest.new(params[:guest])
	    @guest.save
      @donation.user_id = -1
    else
      @user = current_usertype
      @donation.user_id = params[:user_id]
    end

		@project = Project.find(params[:project_id])
		@donation.project_id = @project.id
		@npo = Npo.find_by_account_id(@project.account_id)

    # calls paypal with the right amounts
    # for more information on how to use this
    # refer to https://github.com/jpablobr/active_paypal_adaptive_payment
		if @donation.save && @project && @npo.paypal_email
      
      if params[:guest_checkout]
        @guest.update_attribute(:donation_id, @donation.id)
      end
      
			config = Weeverails::Application.config

			gateway =  ActiveMerchant::Billing::PaypalAdaptivePayment.new(
							:login => config.paypal_login,
							:password => config.paypal_password,
							:signature => config.paypal_apikey,
							:appid => config.app_id )

			recipients = [{:email => @npo.paypal_email,
							 :amount => amount,
							 :primary => true},
							{:email => config.weeve_paypal_email,
							 :amount => weeve_amount,
							 :primary => false}
							 ]

			response = gateway.setup_purchase(
					:currency_code => @npo.paypal_currency,
					:return_url => url_for(:action => :complete, :project_id => params[:project_id], :only_path => false),
					:cancel_url => url_for(:action => :cancel, :project_id => params[:project_id],:only_path => false),
					:ipn_notification_url => url_for(:action => :success, :donation_id => @donation.id, :only_path => false),
					:receiver_list => recipients
			)

			if response.success?
				redirect_to (gateway.redirect_url_for(response[:pay_key]))
			else
				#flash[:error] = "There was an error in processing your donation, please try again or contact administration at admin@weeve.it"
				flash[:error] = response.inspect
				redirect_to :controller => :projects, :action => :show, :id => params[:project_id]
			end
		else
			flash[:error] = "Invalid donation URL"
			redirect_to root_url
		end
	end

  # this callback will get called by PayPal if the contribution is cancelled
	def cancel
		flash[:error] = "Donation Cancelled"
		redirect_to :controller => :projects, :action => :show, :id => params[:project_id]
	end

  # this callback will get called once the user has completed the payment
  # at this point, you _CANNOT_ assume that the payment is 100% (ie. money has been trasnfered)
  # refer to method 'success'
	def complete
		flash[:notice] = "Donation completed.  Thank you!"
		redirect_to :controller => :projects, :action => :show, :id => params[:project_id]
	end

  # this is an async call made by PayPal as a callback once the transfer is complete
  # ie. money has been transferred from a user's PayPal account to it's destinations
	def success
		notify = Paypal::Notification.new(request.raw_post)
		raw = request.raw_post.to_s

    # this data attribute has all the values you can get from a successful (comes back as an IPN)
    # the documentation for a IPN is
    # https://www.x.com/developers/paypal/documentation-tools/adaptive-payments/integration-guide/APIPN
		data = parse(raw)

    if notify.acknowledge

			donation = Donation.find(params[:donation_id])
			npo = '0'
			weeve = '1'

			if data["transaction[#{npo}].is_primary_receiver"] != "true"
				npo = '1'
				weeve = '0'
			end

			reg = %r{[0-9]+.[0-9]+}

			donation.update_attribute('sender_transaction_id', data["transaction[#{npo}].id_for_sender_txn"])
			donation.update_attribute('npo_transaction_id', data["transaction[#{npo}].id"])
			donation.update_attribute('weeve_transaction_id', data["transaction[#{weeve}].id"])
			donation.update_attribute('complete', (true if data["status"].casecmp("Completed") == 0))
			donation.update_attribute('npo_amount', reg.match(data["transaction[#{npo}].amount"])[0].to_f.round(2))
			donation.update_attribute('weeve_amount', reg.match(data["transaction[#{weeve}].amount"])[0].to_f.round(2))
			donation.update_attribute('received_at', Time.now)

      if donation.user_id != -1
        UserMailer.donation_success(donation).deliver
      end

			redirect_to root_url
    end
	end

	private

	def parse(raw)
		data = Hash.new
		for line in raw.split('&')
			key, value = CGI.unescape(*line).scan( %r{^([A-Za-z0-9_.\[\]]+)\=(.*)$} ).flatten
			data[key] = value
		end
		data
	end
end

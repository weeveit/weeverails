Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '446180152073734', '763a0c6702b66df618924c168f17b4f6',
           :scope => 'email', :display => 'popup'
end
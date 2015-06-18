if Rails.env.test?
  Rails.application.config.x.zuora.api_key    = 'ZUORA_API_KEY'
  Rails.application.config.x.zuora.api_secret = 'ZUORA_API_SECRET'
else
  Rails.application.config.x.zuora.api_key    = ENV['ZUORA_API_KEY']
  Rails.application.config.x.zuora.api_secret = ENV['ZUORA_API_SECRET']
end

Rails.application.config.x.zuora.api_url    = 'https://apisandbox-api.zuora.com'

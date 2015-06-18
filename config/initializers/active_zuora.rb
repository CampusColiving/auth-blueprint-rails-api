ActiveZuora.configure(
  username: '<USERNAME>',
  password: 'PASSWORD',
  log:      !Rails.env.test?,
  wsdl:     Rails.root.join('config/zuora.a.67.0.wsdl')
)

module Zuora; end
ActiveZuora.generate_classes inside: Zuora
Dir[File.join(Rails.root, 'lib', 'active_zuora_ext', '*.rb')].each { |f| require f }

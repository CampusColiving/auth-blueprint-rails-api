class PaymentsController < ApplicationController

  before_action :authenticate!

  include JSONAPI::ActsAsResourceController

  # JR doesn't pick it up from ApplicationController
  def context
    { current_user: current_user }
  end

end

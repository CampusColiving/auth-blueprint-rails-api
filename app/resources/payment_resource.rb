require 'jsonapi/resource'

class PaymentResource < JSONAPI::Resource

  attributes :amount, :currency, :date

  def date
    @model.created_date
  end

  def currency
    @model.account.currency
  end

  class << self

    # for GET /payments/index
    def records(options)
      current_user = options[:context][:current_user]
      @zuora_account ||= Zuora::Account.find_by!(crm_id: current_user.zuora_account_key)
      @zuora_account.payments
    end

    # for GET /payments/index
    def find(filters, options)
      resources = []
      records = filter_records(filters, options)
      records.each do |model|
        resources.push new(model, context)
      end

      resources
    end

    # Accept UUIDs. Default enforces integers
    def verify_key(key, _context = nil)
      key && String(key)
    end

  end

end

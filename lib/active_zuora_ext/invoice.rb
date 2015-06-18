module Zuora

  class Invoice

    exclude_from_queries :bill_run_id
    exclude_from_json :body

  end

end

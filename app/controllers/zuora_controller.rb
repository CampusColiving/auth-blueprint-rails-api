class ZuoraController < ApplicationController

  class ZuoraConnectionError < StandardError; end

  def create_hmac_signature
    data = signature_request(params)

    if data[:success]
      render json: { signature: data[:signature], token: data[:token], cookie: zuora_session }
    else
      render json: { reasons: data[:reasons] }, status: 422
    end
  rescue ZuoraConnectionError
    render nothing: true, status: 502
  end

  private

    def zuora_session
      @_session ||= begin
        response = session_request
        if response.code == 200
          cookie_header = response.headers['set-cookie']
          cookie_header.match(/(ZSession=.*?);/)[1]
        else
          raise ZuoraConnectionError.new
        end
      end
    end

    def signature_request(params)
      HTTParty.post('https://apisandbox-api.zuora.com/rest/v1/hmac-signatures', headers: {
        'Cookie'             => zuora_session,
        'Accept'             => 'application/json',
        'Content-Type'       => 'application/json',
        'apiAccessKeyId'     => Rails.configuration.x.zuora.api_key,
        'apiSecretAccessKey' => Rails.configuration.x.zuora.api_secret
      }, body: signature_request_body(params)).parsed_response.symbolize_keys
    end

    def signature_request_body(params)
      body = {
        uri:    params[:uri],
        method: params[:method].upcase
      }.merge(params[:params])
      JSON.generate(body)
    end

    def session_request
      HTTParty.post(
        'https://apisandbox-api.zuora.com/rest/v1/connections',
        headers: {
          'apiAccessKeyId'     => Rails.configuration.x.zuora.api_key,
          'apiSecretAccessKey' => Rails.configuration.x.zuora.api_secret
        }
      )
    end

end

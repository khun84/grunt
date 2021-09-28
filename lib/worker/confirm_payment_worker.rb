class ConfirmPaymentworker
  include Shoryuken::Worker
  shoryuken_options queue: 'daniel-payment.fifo', auto_delete: true, body_parser: :json

  # @param [Hash] body
  #   @option [String] :payer
  #   @option [String] :paid_date
  #   @option [Numeric] :amount
  #   @option [String] :event_time
  #   @option [String] :response_url
  # @param [Aws::SQS::Message] sqs_msg
  def perform(sqs_msg, body)
    @body = body
    @response_url = body['response_url']
    @ref_no = sqs_msg.attributes['MessageDeduplicationId']

    if @body['action'] == '/payment_summary'
      fetch_payment_summary
    else
      confirm_payment!
    end
  rescue StandardError => e
    if e.is_a?(RestClient::Exception)
      PaymentLogger.error(error_source: 'Response callback', code: e.http_code, error_msg: e.message, error_response: e.http_body)
      return
    end
    PaymentLogger.error(error_msg: e.message, backtrace: e.backtrace.take(20).join("\n"))
  end

  def reply_success_response
    return unless @response_url
    RestClient.post(@response_url, { text: "Payment with ref_no #{@ref_no} was captured!" }.to_json )
  end

  def confirm_payment!
    payer = @body['payer']
    paid_date = Time.parse(@body['paid_date'])
    amount = @body['amount']
    event_time = Time.parse(@body['event_time'])
    item = Payment.identify_item(payer: payer, amount: amount)
    payment = Payment.new(payer: payer, paid_at: paid_date, amount: amount, item: item)
    payment.save!
    return unless @response_url
    RestClient.post(@response_url, { text: "Payment with ref_no #{@ref_no} was captured!" }.to_json )
  end

  def fetch_payment_summary
    return unless @response_url
    res = Payment.last_n_payments
    response = Slack::PaymentSummarySerializer.new(res).as_json
    RestClient.post(@response_url, response.to_json)
  end

  private

  def set_time_zone
    Time.zone ||= TZ
  end
end

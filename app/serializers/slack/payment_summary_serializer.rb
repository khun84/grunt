module Slack
  class PaymentSummarySerializer
    def initialize(object)
      @object = object
    end

    def blocks
      blks = [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: 'Payment Summary'
          }
        },
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: "Latest summary as of *#{Time.current.to_s(:long_human)}*"
          }
        },
        {
          type: 'divider'
        }
      ]

      @object.each_with_object(blks) do |ele, memo|
        payer = ele['payer']
        payments = ele['payments']

        memo << {
          type: 'section',
          text: {
            text: "*#{payer}*",
            type: 'mrkdwn'
          }
        }

        if payments.present?
          table = Terminal::Table.new do |t|
            t.headings = payments.first.keys
            t.rows = payments.map do |pmt|
              Shoryuken.logger.info("log timezone #{pmt['paid_at'].zone}")
              pmt['paid_at'] = pmt['paid_at']&.strftime('%Y-%m-%d %H:%M')
              pmt.values
            end
            t.style = { :border_top => false, :border_bottom => false, border_left: false, border_right: false }
          end
          memo << {
            type: 'section',
            text: {
              text: "```\n#{table.to_s}\n```",
              type: 'mrkdwn'
            }
          }
        end

        memo << { type: 'divider' }
      end
    end

    def as_json
      { blocks: blocks }
    end
  end
end

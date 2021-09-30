class SlackService
  class_attribute :client
  self.client = RestClient

  class << self
    def config
      Settings.slack
    end

    # @param [String, Hash] message
    def async_worker(message)
      # @type [Hash]
      message = { text: message } if message.is_a? String
      send_message(message.merge(channel: channel(:async_worker)))
    end

    # @param [Hash] payload
    def send_message(payload)
      client.post(
        config.apis.post_message,
        payload.to_json,
        authorization: "Bearer #{config.bot_token}",
        content_type: 'application/json'
      )
    rescue RestClient::ExceptionWithResponse => e
      ApiLogger.error(
        object_class: 'SlackService',
        body: e.http_body,
        code: e.http_code,
        url: e.response.request.url
      )
    rescue StandardError => e
      ApiLogger.error(
        object_class: 'SlackService',
        error: e.message
      )
    end

    def message_builder
      MessageBuilder
    end

    private

    def channel(ch_name)
      config.channels[ch_name]
    end
  end

  class MessageBuilder
    TYPE_MAPPER = {
      text: 'plain_text',
      markdown: 'mrkdwn'
    }.freeze

    COLORS = {
      green: '#00ff00',
      red: '#ff0000',
      yellow: '#f2c744'
    }.freeze

    class << self
      # @param [Symbol] clr
      def color(clr)
        COLORS[clr]
      end

      def txt_section(text: '', type: :text)
        {
          type: 'section',
          text: {
            type: TYPE_MAPPER[type],
            text: text
          }
        }
      end

      def button_section(buttons)
        {
          type: 'actions',
          elements: buttons
        }
      end

      def button(text: '', url: '', type: :text)
        {
          type: 'button',
          text: {
            type: TYPE_MAPPER[type],
            text: text
          },
          url: url
        }
      end

      def div
        { type: 'divider' }
      end
    end
  end
end

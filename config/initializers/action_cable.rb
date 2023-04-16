module ActionCable
  class TwilioMediaStreamTransformer
    def transform(data)
      return unless data["event"].in?(["start", "media"]) && data["streamSid"]

      if data["event"] == "start"
        {
          "command" => "subscribe",
          "identifier" => data.merge("channel" => "MediaStreamsChannel").to_json
        }
      else # media
        {
          "command" => "message",
          "identifier" => "{\"channel\": \"MediaStreamsChannel\"}",
          "data" => data.merge("action" => "media").to_json
        }
      end
    end
  end

  module Connection
    class Subscriptions
      def execute_command(data)
        case data["command"]
        when "subscribe"   then add data
        when "unsubscribe" then remove data
        when "message"     then perform_action data
        else
          handle_unrecognized_command(data)
        end
      rescue Exception => e
        @connection.rescue_with_handler(e)
        logger.error "Could not execute command from (#{data.inspect}) [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(" | ")}"
      end

      private

      def handle_unrecognized_command(data)
        transformed_data = ActionCable::TwilioMediaStreamTransformer.new.transform(data)

        if transformed_data
          execute_command(transformed_data)
        else
          logger.error "Received unrecognized command in #{data.inspect}"
        end
      end
    end
  end
end
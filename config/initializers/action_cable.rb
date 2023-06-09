# Twilio's Media Stream messages do not follow the JSON structure of Action Cable,
# so we need to transform them in this monkey patch.
# See https://www.twilio.com/docs/voice/twiml/stream

module ActionCable
  module Connection
    class Subscriptions
      def execute_command(data)
        case data["command"]
        when "subscribe"   then add data
        when "unsubscribe" then remove data
        when "message"     then perform_action data
        else
          handle_unrecognized_command(data) # this is the only line updated in execute_command
        end
      rescue Exception => e
        @connection.rescue_with_handler(e)
        logger.error "Could not execute command from (#{data.inspect}) [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(" | ")}"
      end

      private

      # These are two new private methods to help facilitate data transformation.

      def handle_unrecognized_command(data)
        transformed_data = transform_data(data)

        if transformed_data
          execute_command(transformed_data)
        else
          logger.error "Received unrecognized command in #{data.inspect}"
        end
      end

      def transform_data(data)
        return unless data["event"].in?(["start", "media", "stop"]) && data["streamSid"]

        identifier = "{\"channel\": \"MediaStreamsChannel\", \"streamSid\": \"#{data["streamSid"]}\"}"

        case data["event"]
        when "start"
          { "command" => "subscribe", "identifier" => identifier }
        when "stop"
          { "command" => "unsubscribe", "identifier" => identifier }
        when "media"
          {
            "command" => "message",
            "identifier" => identifier,
            "data" => data.merge("action" => "media").to_json
          }
        end
      end
    end
  end
end

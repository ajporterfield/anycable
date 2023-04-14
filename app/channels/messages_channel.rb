class MessagesChannel < ApplicationCable::Channel
  def subscribed
    puts "subscribed"
    stream_from "my_messages"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def my_method(data)
    puts data
  end
end

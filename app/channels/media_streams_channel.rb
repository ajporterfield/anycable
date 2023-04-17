class MediaStreamsChannel < ApplicationCable::Channel
  def subscribed
    puts "subscribed"
    puts params
    stream_from "media_streams"
  end

  def unsubscribed
  end

  def media(data)
    puts data
  end
end

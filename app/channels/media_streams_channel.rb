class MediaStreamsChannel < ApplicationCable::Channel
  def subscribed
    puts "subscribed"
    puts params
  end

  def unsubscribed
  end

  def media(data)
    puts data
  end
end

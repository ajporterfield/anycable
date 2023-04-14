import consumer from "channels/consumer"

consumer.subscriptions.create("MessagesChannel", {
  connected() {
    console.log("connected");
  },

  disconnected() {
    console.log("disconnected");
  },

  received(data) {
    console.log(`received data: ${data}`);
  }
});

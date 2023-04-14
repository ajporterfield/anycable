## Setting Up a Rails Project with AnyCable for Websockets
This guide will walk you through setting up a Rails project that uses AnyCable for Websockets. It is designed to be developer friendly, suitable for both experienced developers and newcomers alike.

### Prerequisites
Before you begin, ensure that you have the following installed on your system:

* Git
* Ruby (version 2.7.6 or higher)
* rbenv (optional, but recommended for managing Ruby versions)
* Bundler
* Homebrew (macOS only)

1. Clone the project repository
First, clone the project repository to your local machine using Git:

```
git clone git@github.com:ajporterfield/anycable.git

cd anycable
```

2. Set up the Ruby environment
Set the global Ruby version using rbenv (if you have it installed):

```
rbenv global 2.7.6
```

Next, install the project dependencies using Bundler:

```
bundle install
```

3. Run AnyCable RPC server

```
bundle exec anycable
```

THis runs the AnyCable RPC server. The RPC server is responsible for handling the application-specific logic for your WebSocket connections, such as authenticating users, processing messages, and broadcasting updates to other connected clients.

When you run `bundle exec anycable`, it starts the RPC server, which listens for connections from the WebSocket server (in this case, `anycable-go`). The RPC server is implemented in Ruby and uses your Rails application code to perform actions specific to your application.

4. Install and configure Redis
AnyCable relies on Redis for message broadcasting. To install Redis, use Homebrew on macOS:

```
brew install redis
```

Start the Redis service:

```
brew services start redis
```

5. Install and run anycable-go
AnyCable-Go is a WebSocket server that works with AnyCable. To install it, use Homebrew:

```
brew install anycable-go
```

Run anycable-go with the following command:

```
anycable-go --host=localhost --port=8080
```

This runs the AnyCable-Go WebSocket server. The WebSocket server is responsible for managing WebSocket connections with the clients (i.e., web browsers) and relaying messages between the clients and the RPC server.

When you run anycable-go --host=localhost --port=8080, it starts the WebSocket server on localhost at port 8080. The WebSocket server is implemented in Go, which provides better performance and concurrency compared to a Ruby-based server. This is particularly beneficial for managing a large number of simultaneous WebSocket connections.

6. Database Migration and Running the Rails Server
After setting up the Rails project with AnyCable and configuring Redis, it's time to migrate the database and run the Rails server.

```
bundle exec rake db:migrate
```

And start the Rails server

```
bundle exec rails s
```


7. Confirming Your Setup by Testing in the Web Browser Console and Rails Console

To ensure AnyCable is set up correctly, you can perform tests using both the web browser console and the Rails console.

7.1 Testing in the web browser console

Open your web browser and navigate to your application's URL (e.g., http://[::1]:3000/messages). Open the browser's console.

Paste the following JavaScript code into the console and press Enter:

```
// Create a new WebSocket connection
const socket = new WebSocket('ws://localhost:8080/cable');

// Set up the connection event handlers
socket.onopen = () => {
  console.log('WebSocket connection opened');

  // Send a sample message through the WebSocket
  const message = {
    command: 'message',
    identifier: JSON.stringify({ channel: 'MessagesChannel' }),
    data: JSON.stringify({ action: 'send_message', content: 'Hello, AnyCable!' }),
  };
  socket.send(JSON.stringify(message));
};

socket.onmessage = (event) => {
  console.log('WebSocket message received:', event.data);
};

socket.onclose = () => {
  console.log('WebSocket connection closed');
};

socket.onerror = (error) => {
  console.error('WebSocket error:', error);
};
```

This creates a new WebSocket connection to the AnyCable-Go server and sends a sample message. You should see output in the console indicating that the connection was established and that messages are being sent and received.


You should immediatly see some output like this imediatly in the browser console:

```
WebSocket connection opened
VM176:17 WebSocket message received: {"type":"welcome","sid":"paSpXx8kS2-MOLAlh5LJT"}
VM176:17 WebSocket message received: {"type":"ping","message":1681507346}
```

And on the server you will see this message show up in the `anycable-go` server logs.

7.2 Testing in the Rails console

Open a new terminal window, navigate to your project directory, and run the Rails console:

```
bundle exec rails console
```

Inside the Rails console, you can interact with your Rails application and test your WebSocket-related code.

ActionCable.server.broadcast "my_messages", message: "Hello from Rails console!"

After executing the code in the Rails console, check your browser console for any new WebSocket messages received. You should see the new message created in the Rails console being received by the WebSocket connection in the browser console.

### That's it
That is all the pieces that make it work.
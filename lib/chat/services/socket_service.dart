import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;
  // Replace with your actual Flask server IP and port
  // For Android Emulator: 'http://10.0.2.2:5000' (if Flask runs on port 5000 on host)
  // For iOS Simulator/Physical Device (same Wi-Fi): 'http://YOUR_COMPUTER_LOCAL_IP:5000'
  // For deployed server: 'https://your_deployed_server_address.com'
  final String _serverUrl = 'http://10.0.2.2:5000'; // <<--- IMPORTANT: CONFIGURE THIS

  Function(dynamic)? _onNewMessageListener;
  Function(dynamic)? _onRoomJoinedListener;
  Function(dynamic)? _onUserJoinedListener;
  Function(dynamic)? _onUserLeftListener;
  Function(dynamic)? _onErrorListener;


  void connect() {
    if (_socket != null && _socket!.connected) {
      print("Socket already connected");
      return;
    }

    try {
      _socket = io.io(_serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        // 'forceNew': true, // Use this if you have connection issues and want to force a new connection
      });

      _socket!.connect();

      _socket!.onConnect((_) {
        print('Socket connected: ${_socket!.id}');
        // You might want to send some identification info here
        // _socket!.emit('identify', {'userId': 'your_user_id_here'});
      });

      _socket!.on('new_message', (data) {
        print('Socket received new_message: $data');
        _onNewMessageListener?.call(data);
      });

      _socket!.on('ai_response', (data) {
        print('Socket received ai_response: $data');
        _onNewMessageListener?.call(data); // Assuming same handler for AI response
      });

      _socket!.on('room_joined', (data) {
        print('Socket received room_joined: $data');
        _onRoomJoinedListener?.call(data);
      });

      _socket!.on('user_joined_room', (data) {
        print('Socket received user_joined_room: $data');
        _onUserJoinedListener?.call(data);
      });

      _socket!.on('user_left_room', (data) {
        print('Socket received user_left_room: $data');
        _onUserLeftListener?.call(data);
      });

      _socket!.onDisconnect((_) {
        print('Socket disconnected');
      });

      _socket!.onConnectError((data) {
        print('Socket connection error: $data');
        _onErrorListener?.call(data);
      });

      _socket!.onError((data) {
        print('Socket error: $data');
        _onErrorListener?.call(data);
      });
    } catch (e) {
      print("Socket connection exception: $e");
      _onErrorListener?.call(e.toString());
    }
  }

  void setOnNewMessageListener(Function(dynamic data) listener) {
    _onNewMessageListener = listener;
  }

  void setOnRoomJoinedListener(Function(dynamic data) listener) {
    _onRoomJoinedListener = listener;
  }

  void setOnUserJoinedListener(Function(dynamic data) listener) {
    _onUserJoinedListener = listener;
  }

  void setOnUserLeftListener(Function(dynamic data) listener) {
    _onUserLeftListener = listener;
  }

  void setOnErrorListener(Function(dynamic data) listener) {
    _onErrorListener = listener;
  }

  void sendMessage(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
      print('Socket sent $event: $data');
    } else {
      print('Socket not connected. Cannot send message.');
      // Optionally, queue the message or notify the user
    }
  }

  void joinRoom(String roomId, String userId) {
    sendMessage('join_room', {'room_id': roomId, 'user_id': userId});
  }

  void leaveRoom(String roomId, String userId) {
    sendMessage('leave_room', {'room_id': roomId, 'user_id': userId});
  }

  void sendChatMessageToRoom(String roomId, String message, String userId) {
    sendMessage('chat_message_to_room', {
      'room_id': roomId,
      'message': message,
      'sender_id': userId,
    });
  }

  void sendAiMessage(String message, String userId) {
    sendMessage('message_to_ai', {
      'message': message,
      'user_id': userId, // Or session_id
    });
  }


  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  bool isConnected() {
    return _socket?.connected ?? false;
  }
}
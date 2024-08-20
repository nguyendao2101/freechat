// ignore_for_file: constant_identifier_names

import 'package:ezyfox_server_flutter_client/ezy_client.dart';
import 'package:ezyfox_server_flutter_client/ezy_clients.dart';
import 'package:ezyfox_server_flutter_client/ezy_config.dart';
import 'package:ezyfox_server_flutter_client/ezy_constants.dart';
import 'package:ezyfox_server_flutter_client/ezy_entities.dart';
import 'package:ezyfox_server_flutter_client/ezy_handlers.dart';

import 'app/globals.dart';

const ZONE_NAME = "freechat";
const APP_NAME = "freechat";

class SocketProxy {
  bool settedUp = false;
  late String username;
  late String password;
  late EzyClient _client;
  late Function(String)? _greetCallback;
  late Function(String)? _secureChatCallback;
  late Function? _disconnectedCallback;
  late Function? _connectionCallback;
  late Function? _connectionFailedCallback;
  late Function? _requestCallback;
  late Function? _loginErrorCallback;
  static final SocketProxy _INSTANCE = SocketProxy._();

  SocketProxy._();

  static SocketProxy getInstance() {
    return _INSTANCE;
  }

  void _setup() {
    EzyConfig config = EzyConfig();
    config.clientName = ZONE_NAME;
    config.enableSSL =
        false; // SSL is not active by default using freechat server
    config.ping.maxLostPingCount = 3;
    config.ping.pingPeriod = 1000;
    config.reconnect.maxReconnectCount = 3;
    config.reconnect.reconnectPeriod = 1000;
    // config.enableDebug = true;
    EzyClients clients = EzyClients.getInstance();
    _client = clients.newDefaultClient(config);
    _client.setup.addEventHandler(EzyEventType.DISCONNECTION,
        _DisconnectionHandler(_disconnectedCallback!));
    _client.setup.addEventHandler(EzyEventType.CONNECTION_SUCCESS,
        _ConnectionHandler(_connectionCallback!));
    _client.setup.addEventHandler(EzyEventType.CONNECTION_FAILURE,
        _ConnectionFailureHandler(_connectionFailedCallback!));
    _client.setup.addDataHandler(EzyCommand.HANDSHAKE, _HandshakeHandler());
    _client.setup.addDataHandler(EzyCommand.LOGIN, _LoginSuccessHandler());
    _client.setup.addDataHandler(EzyCommand.APP_ACCESS, _AppAccessHandler());
    _client.setup.addDataHandler(
        EzyCommand.APP_REQUEST, _RequestHandler(_requestCallback!));
    _client.setup.addDataHandler(
        EzyCommand.LOGIN_ERROR, _LoginErrorHandler(_loginErrorCallback!));
    var appSetup = _client.setup.setupApp(APP_NAME);
    appSetup.addDataHandler("greet", _GreetResponseHandler((message) {
      _greetCallback!(message);
    }));
    appSetup.addDataHandler("secureChat", _SecureChatResponseHandler((message) {
      _secureChatCallback!(message);
    }));
  }

  void connectToServer(String username, String password) {
    if (!settedUp) {
      settedUp = true;
      _setup();
    }
    this.username = username;
    this.password = password;
    _client.connect("10.0.2.2", 3005);
  } // Android emulator localhost-10.0.2.2 for ios it may be 127.0.0.1

  void disconnect() {
    _client.disconnect();
  }

  void onGreet(Function(String) callback) {
    _greetCallback = callback;
  }

  void onSecureChat(Function(String) callback) {
    _secureChatCallback = callback;
  }

  void onDisconnected(Function callback) {
    _disconnectedCallback = callback;
  }

  void onConnection(Function callback) {
    _connectionCallback = callback;
  }

  void onConnectionFailed(Function callback) {
    _connectionFailedCallback = callback;
  }

  void onContacts(Function callback) {
    _connectionFailedCallback = callback;
  }

  void onData(Function callback) {
    _requestCallback = callback;
  }

  void onLoginError(Function callback) {
    _loginErrorCallback = callback;
  }
}

class _HandshakeHandler extends EzyHandshakeHandler {
  @override
  List getLoginRequest() {
    var request = [];
    request.add(ZONE_NAME);
    request.add(SocketProxy.getInstance().username);
    request.add(SocketProxy.getInstance().password);
    request.add([]);
    return request;
  }
}

class _LoginSuccessHandler extends EzyLoginSuccessHandler {
  @override
  void handleLoginSuccess(responseData) {
    client.send(EzyCommand.APP_ACCESS, [APP_NAME]);
  }
}

class _AppAccessHandler extends EzyAppAccessHandler {
  @override
  void postHandle(EzyApp app, List data) {
    var _data = {};
    _data["limit"] = 50;
    _data["skip"] = 0;
    app.send("5", _data);
  }
}

class _GreetResponseHandler extends EzyAppDataHandler<Map> {
  late Function(String) _callback;

  _GreetResponseHandler(Function(String) callback) {
    _callback = callback;
  }

  @override
  void handle(EzyApp app, Map data) {
    _callback(data["message"]);
    app.send("secureChat", {"who": "Young Monkey"}, true);
  }
}

class _SecureChatResponseHandler extends EzyAppDataHandler<Map> {
  late Function(String) _callback;

  _SecureChatResponseHandler(Function(String) callback) {
    _callback = callback;
  }

  @override
  void handle(EzyApp app, Map data) {
    _callback(data["secure-message"]);
  }
}

class _DisconnectionHandler extends EzyDisconnectionHandler {
  late Function _callback;

  _DisconnectionHandler(Function callback) {
    _callback = callback;
  }
  @override
  void postHandle(Map event) {
    _callback();
  }
}

class _ConnectionFailureHandler extends EzyConnectionFailureHandler {
  late Function _callback;

  _ConnectionFailureHandler(Function callback) {
    _callback = callback;
  }

  @override
  void onConnectionFailed(Map event) {
    _callback();
  }
}

class _ConnectionHandler extends EzyConnectionSuccessHandler {
  late Function _callback;

  _ConnectionHandler(Function callback) {
    _callback = callback;
  }

  @override
  void handle(Map event) {
    sendHandshakeRequest();
    postHandle();
    _callback();
  }
}

class _LoginErrorHandler extends EzyAbstractDataHandler {
  late Function _callback;

  _LoginErrorHandler(Function callback) {
    _callback = callback;
  }

  @override
  void handle(List data) {
    client.disconnect();
    _callback();
  }
}

class _RequestHandler extends EzyAbstractDataHandler {
  late Function _callback;

  _RequestHandler(Function callback) {
    _callback = callback;
  }

  @override
  handle(List data) {
    // Handle requests
    if (data[1][0] == '5') {
      // Get contacts
      contacts = data[1][1] + contacts;
    }
    if (data[1][0] == '2') {
      // Add contact
      contacts = data[1][1] + contacts;
    }
    if (data[1][0] == '6') {
      // User message
      messages = messages +
          [
            {'from': data[1][1]['from'], 'message': data[1][1]['message']}
          ];
    }
    if (data[1][0] == '1') {
      // Suggest Contacts
      suggestions = [];
      for (var element in data[1][1]['users']) {
        suggestions = suggestions + [element['username'].toString()];
      }
    }
    if (data[1][0] == '10') {
      // Suggest Contacts
      suggestions = [];
      for (var element in data[1][1]['users']) {
        suggestions = suggestions + [element['username'].toString()];
      }
    }
    _callback();
  }
}

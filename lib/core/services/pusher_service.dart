import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:sgwatch_app/app/config/env.dart';

typedef PusherCallback = void Function(Map<String, dynamic> data);

class PusherService {
  PusherService._();
  static final PusherService _instance = PusherService._();
  factory PusherService() => _instance;

  PusherChannelsFlutter? _pusher;
  bool _isConnected = false;

  /// channelName → { eventName → [callbacks] }
  final Map<String, Map<String, List<PusherCallback>>> _listeners = {};

  /// Channels đã subscribe trên SDK
  final Set<String> _subscribedChannels = {};

  bool get isConnected => _isConnected;

  Future<void> init() async {
    if (_pusher != null) return;

    _pusher = PusherChannelsFlutter.getInstance();

    await _pusher!.init(
      apiKey: PusherConfig.apiKey,
      cluster: PusherConfig.cluster,
      useTLS: PusherConfig.useTLS,
      onConnectionStateChange: (currentState, previousState) {
        debugPrint('[Pusher] $previousState -> $currentState');
        _isConnected = currentState == 'CONNECTED';
      },
      onError: (message, code, error) {
        debugPrint('[Pusher] Error: $message (code: $code, error: $error)');
      },
    );

    await _pusher!.connect();
  }

  /// Subscribe và thêm callback. Hỗ trợ nhiều listener trên cùng channel/event.
  Future<void> subscribe({
    required String channelName,
    required String eventName,
    required PusherCallback onEvent,
  }) async {
    if (_pusher == null) await init();

    // Thêm callback vào list
    _listeners
        .putIfAbsent(channelName, () => {})
        .putIfAbsent(eventName, () => [])
        .add(onEvent);

    // Chỉ subscribe SDK 1 lần per channel
    if (!_subscribedChannels.contains(channelName)) {
      _subscribedChannels.add(channelName);
      await _pusher!.subscribe(
        channelName: channelName,
        onEvent: (event) => _dispatchEvent(channelName, event),
      );
      debugPrint('[Pusher] Subscribed to channel: $channelName');
    }

    debugPrint('[Pusher] Added listener for $channelName / $eventName');
  }

  /// Dispatch event tới tất cả listeners đã đăng ký
  void _dispatchEvent(String channelName, PusherEvent event) {
    debugPrint('[Pusher] Event on $channelName: ${event.eventName}');

    final channelListeners = _listeners[channelName];
    if (channelListeners == null) return;

    final callbacks = channelListeners[event.eventName];
    if (callbacks == null || callbacks.isEmpty || event.data == null) return;

    try {
      final decoded = event.data is String
          ? jsonDecode(event.data as String) as Map<String, dynamic>
          : event.data as Map<String, dynamic>;

      for (final cb in callbacks) {
        cb(decoded);
      }
    } catch (e) {
      debugPrint('[Pusher] Parse error: $e');
    }
  }

  /// Xóa một callback cụ thể
  void removeListener({
    required String channelName,
    required String eventName,
    required PusherCallback onEvent,
  }) {
    _listeners[channelName]?[eventName]?.remove(onEvent);
    debugPrint('[Pusher] Removed listener for $channelName / $eventName');
  }

  Future<void> unsubscribe(String channelName) async {
    await _pusher?.unsubscribe(channelName: channelName);
    _subscribedChannels.remove(channelName);
    _listeners.remove(channelName);
    debugPrint('[Pusher] Unsubscribed from $channelName');
  }

  Future<void> disconnect() async {
    await _pusher?.disconnect();
    _isConnected = false;
    _subscribedChannels.clear();
    _listeners.clear();
    debugPrint('[Pusher] Disconnected');
  }
}

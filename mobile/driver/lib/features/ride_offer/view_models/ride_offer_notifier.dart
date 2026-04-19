import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/ride_offer_state.dart';

typedef OnOfferAccepted = void Function(String rideId);
typedef OnOfferDeclined = void Function();
typedef OnOfferExpired = void Function();

class RideOfferManager extends ChangeNotifier {
  final SakaiApiClient _apiClient;
  final RideOfferState _offer;
  Timer? _countdownTimer;
  int _countdownSeconds;
  bool _accepting = false;
  bool _declining = false;
  String? _error;

  OnOfferAccepted? onAccepted;
  OnOfferDeclined? onDeclined;
  OnOfferExpired? onExpired;

  RideOfferManager({
    required SakaiApiClient apiClient,
    required RideOfferState offer,
  }) : _apiClient = apiClient,
       _offer = offer,
       _countdownSeconds = _calcCountdown(offer.expiresAt);

  RideOfferState get offer => _offer;
  int get countdownSeconds => _countdownSeconds;
  bool get accepting => _accepting;
  bool get declining => _declining;
  String? get error => _error;

  static int _calcCountdown(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining.clamp(0, 999);
  }

  void startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  void _tick() {
    final remaining = _offer.expiresAt.difference(DateTime.now()).inSeconds;
    final clamped = remaining.clamp(0, 999);
    if (clamped != _countdownSeconds) {
      _countdownSeconds = clamped;
      notifyListeners();
    }
    if (clamped <= 0) onExpired?.call();
  }

  Future<void> acceptRide() async {
    if (_accepting) return;
    _accepting = true;
    _error = null;
    notifyListeners();

    int attempts = 0;
    while (attempts < 3) {
      try {
        await _apiClient.getRidesApi().rideAccept(rideId: _offer.rideId);
        _accepting = false;
        onAccepted?.call(_offer.rideId);
        notifyListeners();
        return;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        if (statusCode != null && statusCode >= 200 && statusCode < 300) {
          _accepting = false;
          onAccepted?.call(_offer.rideId);
          notifyListeners();
          return;
        }
        attempts++;
        if (attempts >= 3) {
          _accepting = false;
          _error = 'Accept failed — please wait for the next offer.';
          notifyListeners();
          return;
        }
        await Future.delayed(const Duration(seconds: 1));
      } catch (_) {
        attempts++;
        if (attempts >= 3) {
          _accepting = false;
          _error = 'Accept failed — please wait for the next offer.';
          notifyListeners();
          return;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> declineRide() async {
    if (_declining) return;
    _declining = true;
    _error = null;
    notifyListeners();
    try {
      await _apiClient.getRidesApi().rideDecline(rideId: _offer.rideId);
      _declining = false;
      onDeclined?.call();
      notifyListeners();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        _declining = false;
        onDeclined?.call();
        notifyListeners();
        return;
      }
      _declining = false;
      _error = 'Failed to decline. Please try again.';
      notifyListeners();
    } catch (_) {
      _declining = false;
      _error = 'Failed to decline. Please try again.';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    onAccepted = null;
    onDeclined = null;
    onExpired = null;
    super.dispose();
  }
}

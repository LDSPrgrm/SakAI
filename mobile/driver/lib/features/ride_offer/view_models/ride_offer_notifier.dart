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
    debugPrint('[D-Offer] startCountdown: rideId=${_offer.rideId}, expiresAt=${_offer.expiresAt}, initial=${_countdownSeconds}s');
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
    if (clamped <= 0) {
      debugPrint('[D-Offer] countdown expired for rideId=${_offer.rideId}');
      onExpired?.call();
    }
  }

  Future<void> acceptRide() async {
    if (_accepting) return;
    debugPrint('[D-Offer] acceptRide: rideId=${_offer.rideId}');
    _accepting = true;
    _error = null;
    notifyListeners();

    int attempts = 0;
    while (attempts < 3) {
      try {
        debugPrint('[D-Offer] acceptRide attempt ${attempts + 1}/3...');
        await _apiClient.getRidesApi().rideAccept(rideId: _offer.rideId);
        debugPrint('[D-Offer] acceptRide succeeded on attempt ${attempts + 1}');
        _accepting = false;
        onAccepted?.call(_offer.rideId);
        notifyListeners();
        return;
      } on DioException catch (e) {
        // If it's a 409, the offer might have already been accepted or expired.
        if (e.response?.statusCode == 409) {
          debugPrint('[D-Offer] acceptRide got 409 — offer no longer available');
          _accepting = false;
          _error = 'This offer is no longer available.';
          notifyListeners();
          return;
        }
        attempts++;
        debugPrint('[D-Offer] acceptRide DioException (attempt $attempts): ${e.message}');
        if (attempts >= 3) {
          _accepting = false;
          _error = 'Accept failed — please wait for the next offer.';
          notifyListeners();
          return;
        }
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        attempts++;
        debugPrint('[D-Offer] acceptRide unexpected error (attempt $attempts): $e');
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
    debugPrint('[D-Offer] declineRide: rideId=${_offer.rideId}');
    _declining = true;
    _error = null;
    notifyListeners();
    try {
      await _apiClient.getRidesApi().rideDecline(rideId: _offer.rideId);
      debugPrint('[D-Offer] declineRide succeeded');
      _declining = false;
      onDeclined?.call();
      notifyListeners();
    } on DioException catch (e) {
      debugPrint('[D-Offer] declineRide DioException: ${e.message}');
      _declining = false;
      _error = 'Failed to decline. Please try again.';
      notifyListeners();
    } catch (e) {
      debugPrint('[D-Offer] declineRide unexpected error: $e');
      _declining = false;
      _error = 'Failed to decline. Please try again.';
      notifyListeners();
    }
  }

  void clearError() {
    debugPrint('[D-Offer] clearError');
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('[D-Offer] dispose: rideId=${_offer.rideId}');
    _countdownTimer?.cancel();
    onAccepted = null;
    onDeclined = null;
    onExpired = null;
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:parkease/core/models/booking_model.dart';
import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/services/booking_service.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingService _bookingService;

  List<Booking> _userBookings = [];
  Booking? _selectedBooking;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreBookings = false;

  BookingViewModel(
    this._bookingService,
  );

  List<Booking> get userBookings => _userBookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMoreBookings => _hasMoreBookings;

  // Get user bookings
  Future<void> getUserBookings({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _bookingService.getUserBookings(
        page: _currentPage,
        limit: 10,
      );

      if (result['success']) {
        if (refresh) {
          _userBookings = result['bookings'];
        } else {
          _userBookings.addAll(result['bookings']);
        }

        _totalPages = result['pages'];
        _hasMoreBookings = _currentPage < _totalPages;
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to get bookings';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load more bookings
  Future<void> loadMoreBookings() async {
    if (_isLoading || !_hasMoreBookings) return;

    _currentPage++;
    await getUserBookings();
  }

  // Get booking details
  Future<void> getBookingDetails(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _bookingService.getBookingDetails(bookingId);

      if (result['success']) {
        _selectedBooking = result['booking'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to get booking details';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create booking
  Future<bool> createBooking({
    required String parkingLotId,
    required String spotNumber,
    required DateTime startTime,
    required DateTime endTime,
    required VehicleInfo vehicleInfo,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _bookingService.createBooking(
        parkingLotId: parkingLotId,
        spotNumber: spotNumber,
        startTime: startTime,
        endTime: endTime,
        vehicleInfo: vehicleInfo,
        paymentMethod: paymentMethod,
      );

      if (result['success']) {
        _selectedBooking = result['booking'];
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to create booking';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _bookingService.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );

      if (result['success']) {
        // Update selected booking if it's the one being cancelled
        if (_selectedBooking != null && _selectedBooking!.id == bookingId) {
          _selectedBooking = result['booking'];
        }

        // Update booking in the list
        final index =
            _userBookings.indexWhere((booking) => booking.id == bookingId);
        if (index != -1) {
          _userBookings[index] = result['booking'];
        }

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to cancel booking';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check in to booking
  Future<bool> checkInBooking(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _bookingService.checkInBooking(bookingId);

      if (result['success']) {
        // Update selected booking if it's the one being checked in
        if (_selectedBooking != null && _selectedBooking!.id == bookingId) {
          _selectedBooking = result['booking'];
        }

        // Update booking in the list
        final index =
            _userBookings.indexWhere((booking) => booking.id == bookingId);
        if (index != -1) {
          _userBookings[index] = result['booking'];
        }

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to check in';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check out from booking
  Future<bool> checkOutBooking(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _bookingService.checkOutBooking(bookingId);

      if (result['success']) {
        // Update selected booking if it's the one being checked out
        if (_selectedBooking != null && _selectedBooking!.id == bookingId) {
          _selectedBooking = result['booking'];
        }

        // Update booking in the list
        final index =
            _userBookings.indexWhere((booking) => booking.id == bookingId);
        if (index != -1) {
          _userBookings[index] = result['booking'];
        }

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to check out';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Submit booking feedback
  Future<bool> submitFeedback(String bookingId, int rating,
      {String? comment}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _bookingService.submitFeedback(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );

      if (result['success']) {
        // Update selected booking if it's the one being rated
        if (_selectedBooking != null && _selectedBooking!.id == bookingId) {
          _selectedBooking = result['booking'];
        }

        // Update booking in the list
        final index =
            _userBookings.indexWhere((booking) => booking.id == bookingId);
        if (index != -1) {
          _userBookings[index] = result['booking'];
        }

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to submit feedback';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Filter bookings by status
  Future<void> filterBookingsByStatus(String status) async {
    _currentPage = 1;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _bookingService.getUserBookings(
        page: _currentPage,
        limit: 10,
        status: status,
      );

      if (result['success']) {
        _userBookings = result['bookings'];
        _totalPages = result['pages'];
        _hasMoreBookings = _currentPage < _totalPages;
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to filter bookings';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get active bookings
  List<Booking> getActiveBookings() {
    return _userBookings.where((booking) => booking.isActive).toList();
  }

  // Get upcoming bookings
  List<Booking> getUpcomingBookings() {
    return _userBookings.where((booking) => booking.isReserved).toList();
  }

  // Get completed bookings
  List<Booking> getCompletedBookings() {
    return _userBookings.where((booking) => booking.isCompleted).toList();
  }

  // Clear selected booking
  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

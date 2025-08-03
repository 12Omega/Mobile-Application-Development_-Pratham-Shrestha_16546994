import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/viewmodels/auth_viewmodel.dart';
import 'package:parkease/core/viewmodels/booking_viewmodel.dart';
import 'package:parkease/core/viewmodels/parking_viewmodel.dart';
import 'package:parkease/ui/router.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:parkease/ui/widgets/custom_app_bar.dart';
import 'package:parkease/ui/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class CreateBookingScreen extends StatefulWidget {
  final String? parkingId;
  final String? spotNumber;

  const CreateBookingScreen({
    Key? key,
    this.parkingId,
    this.spotNumber,
  }) : super(key: key);

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  DateTime _startDate = DateTime.now().add(const Duration(hours: 1));
  DateTime _endDate = DateTime.now().add(const Duration(hours: 3));
  String _selectedPaymentMethod = 'card';
  VehicleInfo? _vehicleInfo;

  @override
  void initState() {
    super.initState();

    // Round to nearest hour
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day, now.hour + 1);
    _endDate = DateTime(now.year, now.month, now.day, now.hour + 3);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (widget.parkingId != null) {
      await Provider.of<ParkingViewModel>(context, listen: false)
          .getParkingLotDetails(widget.parkingId!);
    }

    // Get user's vehicle info
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.user != null) {
      setState(() {
        _vehicleInfo = authViewModel.user!.vehicleInfo;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );

      if (pickedTime != null) {
        setState(() {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          // Ensure end date is after start date
          if (_endDate.isBefore(_startDate.add(const Duration(hours: 1)))) {
            _endDate = _startDate.add(const Duration(hours: 2));
          }
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 7)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDate),
      );

      if (pickedTime != null) {
        setState(() {
          _endDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _createBooking() async {
    if (widget.parkingId == null ||
        widget.spotNumber == null ||
        _vehicleInfo == null) {
      return;
    }

    final bookingViewModel =
        Provider.of<BookingViewModel>(context, listen: false);

    final success = await bookingViewModel.createBooking(
      parkingLotId: widget.parkingId!,
      spotNumber: widget.spotNumber!,
      startTime: _startDate,
      endTime: _endDate,
      vehicleInfo: _vehicleInfo!,
      paymentMethod: _selectedPaymentMethod,
    );

    if (success && mounted) {
      // Navigate to booking details
      final bookingId = bookingViewModel.selectedBooking!.id;
      context.go('${AppRoutes.bookingDetails.replaceAll(':id', '')}$bookingId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final parkingViewModel = Provider.of<ParkingViewModel>(context);
    final bookingViewModel = Provider.of<BookingViewModel>(context);

    final parkingLot = parkingViewModel.selectedParkingLot;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Create Booking',
      ),
      body: parkingViewModel.isLoading || parkingLot == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Parking lot info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parkingLot.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                parkingLot.fullAddress,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_parking,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Spot ${widget.spotNumber}',
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Date and time selection
                  const Text(
                    'Select Date & Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Start time
                  _buildDateTimeSelector(
                    'Start Time',
                    Icons.access_time,
                    _formatDateTime(_startDate),
                    _selectStartDate,
                  ),

                  const SizedBox(height: 16),

                  // End time
                  _buildDateTimeSelector(
                    'End Time',
                    Icons.access_time,
                    _formatDateTime(_endDate),
                    _selectEndDate,
                  ),

                  const SizedBox(height: 16),

                  // Duration
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Duration',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatDuration(_endDate.difference(_startDate)),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Vehicle information
                  const Text(
                    'Vehicle Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_vehicleInfo != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          _buildVehicleInfoRow(
                              'License Plate', _vehicleInfo!.licensePlate),
                          const SizedBox(height: 8),
                          _buildVehicleInfoRow('Vehicle Type',
                              _vehicleInfo!.vehicleType.capitalize()),
                          if (_vehicleInfo!.color != null) ...[
                            const SizedBox(height: 8),
                            _buildVehicleInfoRow('Color', _vehicleInfo!.color!),
                          ],
                          if (_vehicleInfo!.model != null) ...[
                            const SizedBox(height: 8),
                            _buildVehicleInfoRow('Model', _vehicleInfo!.model!),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Payment method
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Payment options
                  Row(
                    children: [
                      _buildPaymentOption(
                          'card', 'Credit Card', Icons.credit_card),
                      const SizedBox(width: 16),
                      _buildPaymentOption(
                          'wallet', 'Wallet', Icons.account_balance_wallet),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Price breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Price Breakdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPriceRow(
                          'Parking Fee',
                          _calculateParkingFee(parkingLot.pricing.hourlyRate),
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Tax',
                          _calculateTax(_calculateParkingFee(
                              parkingLot.pricing.hourlyRate)),
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Service Fee',
                          2.50,
                        ),
                        const Divider(height: 24),
                        _buildPriceRow(
                          'Total',
                          _calculateTotal(parkingLot.pricing.hourlyRate),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            text: 'Confirm Booking',
            onPressed: _createBooking,
            isLoading: bookingViewModel.isLoading,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector(
      String label, IconData icon, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, MMM d, h:mm a').format(dateTime);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours hr ${minutes} min';
    } else if (hours > 0) {
      return '$hours hr';
    } else {
      return '$minutes min';
    }
  }

  double _calculateParkingFee(double hourlyRate) {
    final hours = _endDate.difference(_startDate).inMinutes / 60;
    return hourlyRate * hours;
  }

  double _calculateTax(double amount) {
    return amount * 0.08; // 8% tax
  }

  double _calculateTotal(double hourlyRate) {
    final parkingFee = _calculateParkingFee(hourlyRate);
    final tax = _calculateTax(parkingFee);
    const serviceFee = 2.50;

    return parkingFee + tax + serviceFee;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

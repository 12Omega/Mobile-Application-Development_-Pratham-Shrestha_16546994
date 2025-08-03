import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkease/core/models/booking_model.dart';
import 'package:parkease/core/viewmodels/booking_viewmodel.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:parkease/ui/widgets/custom_app_bar.dart';
import 'package:parkease/ui/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookingDetails();
    });
  }

  Future<void> _loadBookingDetails() async {
    await Provider.of<BookingViewModel>(context, listen: false)
        .getBookingDetails(widget.bookingId);
  }

  Future<void> _checkIn() async {
    await Provider.of<BookingViewModel>(context, listen: false)
        .checkInBooking(widget.bookingId);
  }

  Future<void> _checkOut() async {
    await Provider.of<BookingViewModel>(context, listen: false)
        .checkOutBooking(widget.bookingId);
  }

  Future<void> _cancelBooking() async {
    final reason = await _showCancellationDialog();

    if (reason != null) {
      await Provider.of<BookingViewModel>(context, listen: false)
          .cancelBooking(widget.bookingId, reason: reason);
    }
  }

  Future<String?> _showCancellationDialog() async {
    final reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to cancel this booking? Please provide a reason:',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Reason for cancellation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BACK'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, reasonController.text),
              child: const Text('CANCEL BOOKING'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitFeedback() async {
    final result = await _showFeedbackDialog();

    if (result != null) {
      await Provider.of<BookingViewModel>(context, listen: false)
          .submitFeedback(widget.bookingId, result['rating'],
              comment: result['comment']);
    }
  }

  Future<Map<String, dynamic>?> _showFeedbackDialog() async {
    int rating = 5;
    final commentController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate Your Experience'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: index < rating ? Colors.amber : Colors.grey,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, {
                    'rating': rating,
                    'comment': commentController.text,
                  }),
                  child: const Text('SUBMIT'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingViewModel>(
      builder: (context, viewModel, child) {
        final booking = viewModel.selectedBooking;

        return Scaffold(
          appBar: CustomAppBar(
            title: booking != null
                ? 'Booking #${booking.id.substring(0, 8)}'
                : 'Booking Details',
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : booking == null
                  ? _buildErrorState()
                  : _buildContent(context, viewModel, booking),
          bottomNavigationBar: booking != null
              ? _buildBottomBar(context, viewModel, booking)
              : null,
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load booking details',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Retry',
            onPressed: _loadBookingDetails,
            width: 120,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, BookingViewModel viewModel, Booking booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _buildStatusCard(booking),

          const SizedBox(height: 24),

          // QR code
          if (booking.isReserved || booking.isActive) _buildQRCode(booking),

          const SizedBox(height: 24),

          // Booking details
          const Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildDetailItem('Parking Lot', booking.parkingLotName),
          _buildDetailItem('Spot Number', booking.spotNumber),
          _buildDetailItem(
              'Start Time', _formatDateTime(booking.bookingDetails.startTime)),
          _buildDetailItem(
              'End Time', _formatDateTime(booking.bookingDetails.endTime)),
          _buildDetailItem(
              'Duration', _formatDuration(booking.bookingDetails.duration)),

          const SizedBox(height: 24),

          // Vehicle details
          const Text(
            'Vehicle Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildDetailItem('License Plate', booking.vehicleInfo.licensePlate),
          _buildDetailItem(
              'Vehicle Type', booking.vehicleInfo.vehicleType.capitalize()),
          if (booking.vehicleInfo.color != null)
            _buildDetailItem('Color', booking.vehicleInfo.color!),
          if (booking.vehicleInfo.model != null)
            _buildDetailItem('Model', booking.vehicleInfo.model!),

          const SizedBox(height: 24),

          // Payment details
          const Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildDetailItem(
              'Payment Method', booking.payment.method.capitalize()),
          _buildDetailItem(
              'Payment Status', booking.payment.status.capitalize()),
          _buildDetailItem('Base Amount',
              '\$${booking.pricing.baseAmount.toStringAsFixed(2)}'),
          _buildDetailItem(
              'Taxes', '\$${booking.pricing.taxes.toStringAsFixed(2)}'),
          _buildDetailItem(
              'Service Fee', '\$${booking.pricing.fees.toStringAsFixed(2)}'),
          _buildDetailItem('Total Amount',
              '\$${booking.pricing.totalAmount.toStringAsFixed(2)}',
              isHighlighted: true),

          // Feedback section
          if (booking.isCompleted && booking.feedback == null) ...[
            const SizedBox(height: 24),
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
                    'How was your experience?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please rate your parking experience to help us improve our service.',
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Rate Now',
                    onPressed: _submitFeedback,
                    backgroundColor: Colors.white,
                    textColor: AppTheme.primaryColor,
                    isOutlined: true,
                  ),
                ],
              ),
            ),
          ],

          // Feedback display
          if (booking.feedback != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Your Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < booking.feedback!.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: index < booking.feedback!.rating
                              ? Colors.amber
                              : Colors.grey,
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${booking.feedback!.rating}/5',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (booking.feedback!.comment != null &&
                      booking.feedback!.comment!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(booking.feedback!.comment!),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Submitted on ${DateFormat('MMM d, yyyy').format(booking.feedback!.submittedAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Cancellation details
          if (booking.isCancelled && booking.cancellation != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Cancellation Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cancelled on ${DateFormat('MMM d, yyyy, h:mm a').format(booking.cancellation!.cancelledAt)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  if (booking.cancellation!.reason != null &&
                      booking.cancellation!.reason!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Reason: ${booking.cancellation!.reason}',
                      style: TextStyle(
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    booking.cancellation!.refundEligible
                        ? 'Refund status: ${booking.payment.status == 'refunded' ? 'Processed' : 'Pending'}'
                        : 'Not eligible for refund',
                    style: TextStyle(
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(Booking booking) {
    Color color;
    IconData icon;
    String statusText;

    if (booking.isActive) {
      color = Colors.green;
      icon = Icons.directions_car;
      statusText = 'Active';
    } else if (booking.isReserved) {
      color = AppTheme.primaryColor;
      icon = Icons.access_time;
      statusText = 'Reserved';
    } else if (booking.isCompleted) {
      color = Colors.blue;
      icon = Icons.check_circle;
      statusText = 'Completed';
    } else if (booking.isCancelled) {
      color = Colors.red;
      icon = Icons.cancel;
      statusText = 'Cancelled';
    } else {
      color = Colors.orange;
      icon = Icons.warning;
      statusText = booking.status.capitalize();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(booking),
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode(Booking booking) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: QrImageView(
              data: booking.qrCode,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Show this QR code at the parking entrance',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, BookingViewModel viewModel, Booking booking) {
    if (booking.isCompleted || booking.isCancelled) {
      return const SizedBox.shrink();
    }

    return Container(
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
        child: booking.isActive
            ? CustomButton(
                text: 'Check Out',
                onPressed: _checkOut,
                isLoading: viewModel.isLoading,
                icon: Icons.logout,
              )
            : Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: _cancelBooking,
                      isOutlined: true,
                      backgroundColor: Colors.white,
                      textColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Check In',
                      onPressed: _checkIn,
                      isLoading: viewModel.isLoading,
                      icon: Icons.login,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, MMM d, h:mm a').format(dateTime);
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '$hours hr $mins min';
    } else if (hours > 0) {
      return '$hours hr';
    } else {
      return '$mins min';
    }
  }

  String _getStatusDescription(Booking booking) {
    if (booking.isActive) {
      return 'Your parking is in progress';
    } else if (booking.isReserved) {
      return 'Your spot is reserved and waiting for you';
    } else if (booking.isCompleted) {
      return 'Parking completed on ${DateFormat('MMM d, h:mm a').format(booking.bookingDetails.actualEndTime!)}';
    } else if (booking.isCancelled) {
      return 'Booking was cancelled';
    } else {
      return 'Status: ${booking.status}';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

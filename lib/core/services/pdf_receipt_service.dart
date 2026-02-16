import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// Generates PDF receipts for rides.
///
/// Creates professional-looking receipts with:
/// - Company branding
/// - Trip details
/// - Price breakdown
/// - QR code for verification
class PdfReceiptService {
  PdfReceiptService._();

  static final PdfReceiptService instance = PdfReceiptService._();

  /// App brand colors
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF2E7D32);
  static const PdfColor textColor = PdfColor.fromInt(0xFF333333);
  static const PdfColor lightGray = PdfColor.fromInt(0xFFF5F5F5);

  /// Generates a PDF receipt for a completed ride.
  Future<Uint8List> generateRideReceipt({
    required String rideId,
    required String fromAddress,
    required String toAddress,
    required DateTime departureTime,
    required DateTime? completedTime,
    required String driverName,
    required String? driverPhone,
    required double pricePerSeat,
    required int seatsBooked,
    required double serviceFee,
    required String? passengerName,
  }) async {
    final pdf = pw.Document();

    final baseFare = pricePerSeat * seatsBooked;
    final total = baseFare + serviceFee;
    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    // Generate a simple verification code from ride ID
    final verificationCode = _generateVerificationCode(rideId);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with branding
              _buildHeader(),
              pw.SizedBox(height: 30),

              // Receipt title
              pw.Center(
                child: pw.Text(
                  'TRIP RECEIPT',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // Trip details card
              _buildCard(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Trip Details'),
                    pw.SizedBox(height: 15),
                    _buildDetailRow('Ride ID', rideId.substring(0, 8).toUpperCase()),
                    pw.SizedBox(height: 8),
                    _buildDetailRow('Departure', dateFormat.format(departureTime)),
                    if (completedTime != null) ...[
                      pw.SizedBox(height: 8),
                      _buildDetailRow('Completed', dateFormat.format(completedTime)),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Route card
              _buildCard(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Route'),
                    pw.SizedBox(height: 15),
                    _buildRouteRow('From', fromAddress),
                    pw.SizedBox(height: 12),
                    _buildRouteRow('To', toAddress),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Driver info card
              _buildCard(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Driver'),
                    pw.SizedBox(height: 15),
                    _buildDetailRow('Name', driverName),
                    if (driverPhone != null) ...[
                      pw.SizedBox(height: 8),
                      _buildDetailRow('Phone', driverPhone),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Passenger info (if available)
              if (passengerName != null) ...[
                _buildCard(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Passenger'),
                      pw.SizedBox(height: 15),
                      _buildDetailRow('Name', passengerName),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Price breakdown card
              _buildCard(
                background: true,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Payment Summary'),
                    pw.SizedBox(height: 15),
                    _buildPriceRow(
                      'Base Fare ($seatsBooked seat${seatsBooked > 1 ? 's' : ''})',
                      currencyFormat.format(baseFare),
                    ),
                    pw.SizedBox(height: 8),
                    _buildPriceRow('Service Fee', currencyFormat.format(serviceFee)),
                    pw.Divider(color: lightGray, thickness: 1),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          currencyFormat.format(total),
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Verification code
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: lightGray,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'Verification Code: $verificationCode',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for using SportConnect!',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Your eco-friendly carpooling choice',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates PDF report for driver earnings.
  Future<Uint8List> generateEarningsReport({
    required String driverName,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double totalEarnings,
    required double totalTrips,
    required double averageRating,
    required List<EarningsTrip> trips,
  }) async {
    final pdf = pw.Document();

    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');
    final periodFormat = DateFormat('MMMM d, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return [
            // Header
            _buildHeader(),
            pw.SizedBox(height: 30),

            // Report title
            pw.Center(
              child: pw.Text(
                'EARNINGS REPORT',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                '${periodFormat.format(periodStart)} - ${periodFormat.format(periodEnd)}',
                style: const pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.SizedBox(height: 30),

            // Summary cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard('Total Earnings', currencyFormat.format(totalEarnings)),
                _buildSummaryCard('Total Trips', totalTrips.toStringAsFixed(0)),
                _buildSummaryCard('Average Rating', '${averageRating.toStringAsFixed(1)} ⭐'),
              ],
            ),
            pw.SizedBox(height: 30),

            // Trip history
            pw.Text(
              'Trip History',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 15),

            // Table header
            pw.Table(
              border: pw.TableBorder.all(color: lightGray, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: primaryColor),
                  children: [
                    _buildTableHeader('Date'),
                    _buildTableHeader('Route'),
                    _buildTableHeader('Earnings'),
                  ],
                ),
                ...trips.map((trip) => pw.TableRow(
                  children: [
                    _buildTableCell(dateFormat.format(trip.date)),
                    _buildTableCell('${trip.from} → ${trip.to}'),
                    _buildTableCell(currencyFormat.format(trip.earnings)),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 20),

            // Footer
            pw.Center(
              child: pw.Text(
                'Generated on ${dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Helper methods
  pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Container(
          width: 40,
          height: 40,
          decoration: pw.BoxDecoration(
            color: primaryColor,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Center(
            child: pw.Text(
              'SC',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Text(
          'SportConnect',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildCard({
    required pw.Widget child,
    bool background = false,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: background ? primaryColor.shade(0.95) : null,
        border: pw.Border.all(color: lightGray, width: 1),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: secondaryColor,
      ),
    );
  }

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildRouteRow(String label, String address) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 60,
          child: pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            address,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPriceRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryCard(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: lightGray,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  String _generateVerificationCode(String rideId) {
    // Generate a simple verification code from the ride ID
    final hash = rideId.hashCode.abs();
    return 'SC-${hash.toString().substring(0, 6).toUpperCase()}';
  }
}

/// Represents a trip in the earnings report.
class EarningsTrip {
  final DateTime date;
  final String from;
  final String to;
  final double earnings;

  const EarningsTrip({
    required this.date,
    required this.from,
    required this.to,
    required this.earnings,
  });
}

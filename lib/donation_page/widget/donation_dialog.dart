import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruracare/services/api_service.dart';
import 'package:ruracare/services/models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class DonationDialog extends ConsumerStatefulWidget {
  final String donationType;
  final String userId;
  final String? teamId;
  final String? teamName;
  final VoidCallback? onDonationSuccess;

  const DonationDialog({
    super.key,
    required this.donationType,
    required this.userId,
    this.teamId,
    this.teamName,
    this.onDonationSuccess,
  });

  @override
  DonationDialogState createState() => DonationDialogState();
}

class DonationDialogState extends ConsumerState<DonationDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  String _selectedNetwork = 'MTN';
  final List<String> _networks = ['MTN', 'Vodafone', 'AirtelTigo'];
  bool _isLoading = false;

  bool _validateInputs() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter donation amount')),
      );
      return false;
    }
    
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return false;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return false;
    }
    
    // Enhanced phone number validation for Ghanaian numbers
    final phoneRegex = RegExp(r'^(?:\+233|0)[235]\d{8}$');
    final normalizedPhone = _phoneController.text.trim();
    
    if (!phoneRegex.hasMatch(normalizedPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Ghanaian phone number (e.g., 0234567890 or +233234567890)')),
      );
      return false;
    }
    
    return true;
  }

  Future<void> _processDonation() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Normalize phone number format
      String normalizedPhone = _phoneController.text.trim();
      if (normalizedPhone.startsWith('0')) {
        normalizedPhone = '+233${normalizedPhone.substring(1)}';
      }

      DonationResponse response;
      if (widget.donationType == 'individual') {
        final donationData = IndividualDonationRequest(
          userId: widget.userId,
          amount: double.parse(_amountController.text),
          phoneNumber: normalizedPhone,
          network: _selectedNetwork,
          reference: _referenceController.text.isNotEmpty ? _referenceController.text : null,
        );
        response = await apiService.individualDonation(donationData);
      } else {
        final donationData = TeamDonationRequest(
          userId: widget.userId,
          teamId: widget.teamId!,
          amount: double.parse(_amountController.text),
          phoneNumber: normalizedPhone,
          network: _selectedNetwork,
          reference: _referenceController.text.isNotEmpty ? _referenceController.text : null,
        );
        response = await apiService.teamDonation(donationData);
      }

      // Check if we have a payment link
      final paymentLink = response.data.paymentLink;
      if (paymentLink != null && paymentLink.isNotEmpty) {
        final url = Uri.parse(paymentLink);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          
          // Show success message immediately after launching payment
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment page opened for donation of GHS ${_amountController.text}'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        } else {
          throw Exception('Could not launch payment URL');
        }
      } else {
        // If no payment link, verify immediately
        await _verifyDonation(response.data.transactionId);
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onDonationSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyDonation(String transactionId) async {
    final apiService = ref.read(apiServiceProvider);
    
    try {
      DonationVerificationResponse verificationResponse;
      
      if (widget.donationType == 'individual') {
        verificationResponse = await apiService.verifyDonation(transactionId);
      } else {
        verificationResponse = await apiService.verifyTeamDonation(transactionId);
      }

      if (verificationResponse.status == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Donation of GHS ${_amountController.text} processed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(verificationResponse.message);
      }
    } catch (e) {
      // Don't throw error here, just log it
      debugPrint('Verification error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF2196F3);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.donationType == 'individual' 
                      ? "Individual Donation" 
                      : "Donate to ${widget.teamName ?? 'Team'}",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: blue,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.donationType == 'individual'
                ? "Enter your donation details to contribute as an individual."
                : "Enter your donation details to contribute to ${widget.teamName ?? 'the team'}.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Amount (GHS)",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: "Enter donation amount",
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixText: "GHS ",
                suffixIcon: IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.grey.shade500),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Donation Amount', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        content: Text('Enter the amount you wish to donate in Ghana Cedis (GHS).', style: GoogleFonts.poppins()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: GoogleFonts.poppins(color: blue)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 12),
            Text(
              "Phone Number",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "e.g., 0234567890 or +233234567890",
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: Icon(Icons.phone, color: blue),
              ),
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 12),
            Text(
              "Mobile Network",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedNetwork,
              items: _networks.map((String network) {
                return DropdownMenuItem<String>(
                  value: network,
                  child: Text(network, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedNetwork = newValue!;
                });
              },
              decoration: InputDecoration(
                hintText: "Select your network",
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              "Reference (Optional)",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _referenceController,
              decoration: InputDecoration(
                hintText: "Enter reference note (e.g., Birthday donation)",
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: Icon(Icons.note, color: blue),
              ),
              style: GoogleFonts.poppins(),
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Information',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'After clicking "Donate Now", you will be redirected to complete your payment via mobile money.',
                    style: GoogleFonts.poppins(fontSize: 12, color: blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: blue),
                      foregroundColor: blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Cancel", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _processDonation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            "Donate Now",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}
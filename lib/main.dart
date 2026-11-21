import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const BaggageFeeApp());
}

class BaggageFeeApp extends StatelessWidget {
  const BaggageFeeApp({super.key});

  static const Color primaryNavy = Color(0xFF0F2537);
  static const Color accentCrimson = Color(0xFFDC2626);
  static const Color backgroundLight = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Fee Calculation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          primary: primaryNavy,
          secondary: accentCrimson,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// Main Screen managing the navigation and tabs
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Pages corresponding to navigation items
  final List<Widget> _pages = const [
    HomePage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedIndex == 0
                  ? Icons.flight_takeoff_rounded
                  : Icons.badge_outlined,
              size: 22,
              color: const Color(0xFFF87171),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedIndex == 0
                  ? 'Baggage Fee Calculator'
                  : 'About Application',
            ),
          ],
        ),
      ),
      // Preserves input state when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded, color: BaggageFeeApp.primaryNavy),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline_rounded),
            selectedIcon: Icon(Icons.info_rounded, color: BaggageFeeApp.primaryNavy),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  // Nullable so that Reset completely clears all 3 options
  String? _ticketClass;

  double _inputWeight = 0.0;
  double _allowance = 20.0;
  double _inputRate = 0.0;
  double _excessWeight = 0.0;
  double _excessCharge = 0.0;
  double _taxAmount = 0.0;
  double _totalAmount = 0.0;
  bool _hasCalculated = false;

  @override
  void dispose() {
    _weightController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _calculateFee() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (_ticketClass == null) {
        return;
      }
      final double weight = double.parse(_weightController.text.trim());
      final double rate = double.parse(_rateController.text.trim());

      // Free allowance: 20 kg for Economy, 40 kg for Business
      final double allowance = _ticketClass == 'Economy' ? 20.0 : 40.0;

      // Excess weight (never negative)
      final double excess = weight - allowance;
      final double excessWeight = excess > 0 ? excess : 0.0;

      // Excess baggage charge
      final double excessCharge = excessWeight * rate;

      // 8% service tax
      final double tax = excessCharge * 0.08;

      // Total amount payable including 8% service tax
      final double total = excessCharge + tax;

      setState(() {
        _inputWeight = weight;
        _allowance = allowance;
        _inputRate = rate;
        _excessWeight = excessWeight;
        _excessCharge = excessCharge;
        _taxAmount = tax;
        _totalAmount = total;
        _hasCalculated = true;
      });
    }
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    _weightController.clear();
    _rateController.clear();
    setState(() {
      _ticketClass = null; // Clears the ticket class selection
      _hasCalculated = false;
      _inputWeight = 0.0;
      _allowance = 20.0;
      _inputRate = 0.0;
      _excessWeight = 0.0;
      _excessCharge = 0.0;
      _taxAmount = 0.0;
      _totalAmount = 0.0;
    });
  }

  Widget _buildInstructionStep(String stepNumber, String text, Color primaryNavy) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primaryNavy,
            shape: BoxShape.circle,
          ),
          child: Text(
            stepNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryNavy = BaggageFeeApp.primaryNavy;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            // Step-by-Step Instructions Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryNavy.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.format_list_numbered_rounded,
                          color: primaryNavy,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Step-by-Step Instructions',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildInstructionStep(
                    '1',
                    'Enter your checked baggage weight in kg (Maximum: 200 kg).',
                    primaryNavy,
                  ),
                  const SizedBox(height: 10),
                  _buildInstructionStep(
                    '2',
                    'Select your ticket class (Economy: 20 kg or Business: 40 kg free allowance).',
                    primaryNavy,
                  ),
                  const SizedBox(height: 10),
                  _buildInstructionStep(
                    '3',
                    'Input the excess baggage rate per kg in RM.',
                    primaryNavy,
                  ),
                  const SizedBox(height: 10),
                  _buildInstructionStep(
                    '4',
                    'Tap "Calculate Fee" to generate your detailed baggage receipt.',
                    primaryNavy,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Allowance Policy Notice Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_rounded, color: Colors.amber.shade800, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 12.5, color: Colors.amber.shade900, height: 1.4),
                        children: const [
                          TextSpan(
                            text: 'Policy Notice: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Economy includes ',
                          ),
                          TextSpan(
                            text: '20 kg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' free allowance; Business includes ',
                          ),
                          TextSpan(
                            text: '40 kg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '. Baggage at or below allowance has 0 kg excess. An 8% service tax applies to excess charges. Maximum baggage limit is 200 kg.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section Label
            const Text(
              'Trip & Baggage Details',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryNavy,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),

            // Input 1: Baggage Weight
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Total Baggage Weight (kg)',
                hintText: 'e.g. 28.5 (Max 200 kg)',
                helperText: 'Maximum weight limit: 200 kg',
                suffixText: 'kg',
                suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: primaryNavy),
                prefixIcon: const Icon(Icons.scale_rounded, color: primaryNavy),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: primaryNavy, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Error: Baggage weight cannot be empty.';
                }
                final numVal = double.tryParse(value.trim());
                if (numVal == null || numVal < 0) {
                  return 'Error: Please enter a valid positive number.';
                }
                if (numVal > 200.0) {
                  return 'Error: Baggage weight cannot exceed 200 kg.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Input 2: Ticket Class Dropdown (using value: _ticketClass so it properly resets)
            DropdownButtonFormField<String>(
              value: _ticketClass,
              hint: const Text('Select Ticket Class'),
              decoration: InputDecoration(
                labelText: 'Ticket Class',
                prefixIcon: const Icon(Icons.airplanemode_active_rounded, color: primaryNavy),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: primaryNavy, width: 2),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Economy',
                  child: Text('Economy (20 kg allowance)'),
                ),
                DropdownMenuItem(
                  value: 'Business',
                  child: Text('Business (40 kg allowance)'),
                ),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Error: Please select a ticket class.';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _ticketClass = value;
                  if (_hasCalculated && value != null) {
                    _calculateFee();
                  }
                });
              },
            ),

            // Live allowance helper chip when class is selected
            if (_ticketClass != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _ticketClass == 'Economy' ? Colors.blue.shade50 : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _ticketClass == 'Economy' ? Colors.blue.shade200 : Colors.purple.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: _ticketClass == 'Economy' ? Colors.blue.shade700 : Colors.purple.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _ticketClass == 'Economy'
                            ? 'Economy includes 20 kg free baggage allowance'
                            : 'Business includes 40 kg free baggage allowance',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _ticketClass == 'Economy' ? Colors.blue.shade900 : Colors.purple.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Input 3: Excess Rate per kg
            TextFormField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Excess Baggage Rate per kg (RM)',
                hintText: 'e.g. 15.00',
                prefixText: 'RM ',
                prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: primaryNavy),
                prefixIcon: const Icon(Icons.payments_outlined, color: primaryNavy),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: primaryNavy, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Error: Rate per kg cannot be empty.';
                }
                final numVal = double.tryParse(value.trim());
                if (numVal == null || numVal < 0) {
                  return 'Error: Please enter a valid positive rate.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _calculateFee,
                    icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                    label: const Text(
                      'Calculate Fee',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Boarding-Pass Style Results Card
            if (_hasCalculated && _ticketClass != null) ...[
              BoardingPassReceipt(
                ticketClass: _ticketClass!,
                totalWeight: _inputWeight,
                allowance: _allowance,
                ratePerKg: _inputRate,
                excessWeight: _excessWeight,
                excessCharge: _excessCharge,
                taxAmount: _taxAmount,
                totalAmount: _totalAmount,
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom Boarding-Pass / Ticket Receipt Widget
class BoardingPassReceipt extends StatelessWidget {
  final String ticketClass;
  final double totalWeight;
  final double allowance;
  final double ratePerKg;
  final double excessWeight;
  final double excessCharge;
  final double taxAmount;
  final double totalAmount;

  const BoardingPassReceipt({
    super.key,
    required this.ticketClass,
    required this.totalWeight,
    required this.allowance,
    required this.ratePerKg,
    required this.excessWeight,
    required this.excessCharge,
    required this.taxAmount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    const primaryNavy = BaggageFeeApp.primaryNavy;
    const accentCrimson = BaggageFeeApp.accentCrimson;
    final bool hasExcess = excessWeight > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Boarding Pass Header Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: primaryNavy,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'BAGGAGE FEE RECEIPT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: hasExcess ? accentCrimson : const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasExcess ? 'EXCESS DUE' : 'WITHIN LIMIT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Flight Segment Overview
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TICKET CLASS',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$ticketClass Class',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryNavy,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.flight_takeoff_rounded, color: primaryNavy, size: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'FREE ALLOWANCE',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${allowance.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Perforation Notch with Dotted Line
          const TicketDivider(),

          // Breakdown Items
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildReceiptRow(
                  label: '1. Checked Luggage Weight',
                  value: '${totalWeight.toStringAsFixed(1)} kg',
                  isBold: false,
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  label: '2. Free Baggage Allowance',
                  value: '- ${allowance.toStringAsFixed(1)} kg',
                  isBold: false,
                  valueColor: Colors.grey.shade700,
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  label: '3. Excess Baggage Weight',
                  value: '${excessWeight.toStringAsFixed(1)} kg',
                  isBold: true,
                  valueColor: hasExcess ? accentCrimson : const Color(0xFF059669),
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  label: '4. Excess Rate per kg',
                  value: 'RM ${ratePerKg.toStringAsFixed(2)}',
                  isBold: false,
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  label: '5. Excess Baggage Charge',
                  value: 'RM ${excessCharge.toStringAsFixed(2)}',
                  isBold: true,
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  label: '6. Service Tax (8% SST)',
                  value: '+ RM ${taxAmount.toStringAsFixed(2)}',
                  isBold: false,
                  valueColor: Colors.grey.shade700,
                ),
                const SizedBox(height: 18),

                // Total Payable Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: primaryNavy.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryNavy.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL AMOUNT PAYABLE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: primaryNavy,
                            ),
                          ),
                          Text(
                            'Inclusive of 8% service tax',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'RM ${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: primaryNavy,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Barcode simulation
                _buildBarcode(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow({
    required String label,
    required String value,
    required bool isBold,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: const Color(0xFF334155),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildBarcode() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 38; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.2),
                width: (i % 4 == 0)
                    ? 3.2
                    : (i % 3 == 0 ? 2.2 : (i % 2 == 0 ? 1.2 : 2.0)),
                height: 26,
                color: const Color(0xFF334155),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'OFFICIAL PASSENGER CHECK-IN RECEIPT',
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.5,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Perforation Divider with Circular Notches on Left and Right
class TicketDivider extends StatelessWidget {
  const TicketDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed Perforation Line
          LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 6.0;
              const dashSpace = 4.0;
              final boxWidth = constraints.constrainWidth() - 40;
              final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(dashCount, (_) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    width: dashWidth,
                    height: 1.5,
                    color: Colors.grey.shade300,
                  );
                }),
              );
            },
          ),
          // Left Notch
          Positioned(
            left: 0,
            child: Container(
              width: 14,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9), // Match background color
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Right Notch
          Positioned(
            right: 0,
            child: Container(
              width: 14,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9), // Match background color
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// About Page Redesign
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryNavy = BaggageFeeApp.primaryNavy;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Logo / Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryNavy.withOpacity(0.2), width: 3),
            ),
            child: const CircleAvatar(
              radius: 46,
              backgroundColor: primaryNavy,
              child: Icon(
                Icons.luggage_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // App Title
          const Text(
            'Excess Baggage Calculator',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryNavy,
            ),
          ),
          const SizedBox(height: 4),

          // Version Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryNavy,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Author / Student Information Card
          Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            child: Column(
              children: [
                // Card Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: primaryNavy,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.badge_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Student & Author Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileRow(
                        icon: Icons.person_rounded,
                        label: 'Full Name',
                        value: 'NUR IZZAH FATIN BINTI FADZLAH',
                      ),
                      const Divider(height: 20),
                      _buildProfileRow(
                        icon: Icons.numbers_rounded,
                        label: 'Matric Number',
                        value: '2025429904',
                      ),
                      const Divider(height: 20),
                      _buildProfileRow(
                        icon: Icons.school_rounded,
                        label: 'Program / Course',
                        value: 'BACHELOR OF COMPUTER SCIENCE (HONS.) NETCENTRIC COMPUTING',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Clickable GitHub Repository URL Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final Uri url = Uri.parse('https://github.com/izzahfatin/baggage-fee.git');
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  throw Exception('Could not launch $url');
                }
              },
              icon: const Icon(Icons.code_rounded, color: Colors.white),
              label: const Text(
                'GitHub Repository URL',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryNavy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Copyright Notice
          Text(
            'Copyright Notice:\n© 2026 All Rights Reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0F2537)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F2537),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

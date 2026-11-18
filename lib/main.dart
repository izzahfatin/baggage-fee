import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const BaggageFeeApp());
}

class BaggageFeeApp extends StatelessWidget {
  const BaggageFeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Fee Calculation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// Main Screen managing the BottomNavigationBar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of pages corresponding to the navigation items
  final List<Widget> _pages = const [
    HomePage(),
    AboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Baggage Fee Calculation' : 'About Application'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // IndexedStack preserves the input state when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
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

  String _ticketClass = 'Economy';

  double _excessWeight = 0.0;
  double _excessCharge = 0.0;
  double _totalAmount = 0.0;
  bool _hasCalculated = false;

  void _calculateFee() {
    if (_formKey.currentState!.validate()) {
      double weight = double.parse(_weightController.text);
      double rate = double.parse(_rateController.text);

      // Free allowance: 20 kg for economy, 40 kg for business
      double allowance = _ticketClass == 'Economy' ? 20.0 : 40.0;

      // Excess weight (never negative)
      double excess = weight - allowance;
      _excessWeight = excess > 0 ? excess : 0.0;

      // Excess baggage charge
      _excessCharge = _excessWeight * rate;

      // Total amount payable including 8% service tax
      _totalAmount = _excessCharge + (_excessCharge * 0.08);

      setState(() {
        _hasCalculated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Instructions
            const Text(
              'Instructions:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              '1. Enter your checked baggage weight in kilograms.\n'
              '2. Select your ticket class (Economy or Business).\n'
              '3. Input the excess baggage rate per kg in RM.',
            ),
            const SizedBox(height: 12),

            // Helpful Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow.shade200),
              ),
              child: const Text(
                'Notice: Economy class includes a 20 kg free allowance. Business class includes a 40 kg free allowance. Baggage weight under or equal to the allowed limit results in 0 kg excess weight. An 8% service tax is applied automatically.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),

            // Input 1: Baggage Weight
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Baggage Weight (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Error: Baggage weight cannot be empty.';
                }
                if (double.tryParse(value) == null || double.parse(value) < 0) {
                  return 'Error: Please enter a valid positive number.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Input 2: Ticket Class Dropdown
            DropdownButtonFormField<String>(
              initialValue: _ticketClass,
              decoration: const InputDecoration(
                labelText: 'Ticket Class',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.airplanemode_active),
              ),
              items: const [
                DropdownMenuItem(value: 'Economy', child: Text('Economy (20 kg allowance)')),
                DropdownMenuItem(value: 'Business', child: Text('Business (40 kg allowance)')),
              ],
              onChanged: (value) {
                setState(() {
                  _ticketClass = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Input 3: Rate per kg
            TextFormField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Excess Baggage Rate per kg (RM)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Error: Rate per kg cannot be empty.';
                }
                if (double.tryParse(value) == null || double.parse(value) < 0) {
                  return 'Error: Please enter a valid positive rate.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _calculateFee,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Fee', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Outputs Section
            if (_hasCalculated) ...[
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              const Text(
                'Calculation Results:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1. Excess Baggage Weight: ${_excessWeight.toStringAsFixed(1)} kg',
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 8),
                      Text('2. Excess Baggage Charge: RM ${_excessCharge.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 8),
                      Text('3. Total Amount Payable (incl. 8% tax): RM ${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Application Icon
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.red,
            child: Icon(Icons.luggage, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Excess Baggage Fee Calculation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Author Information
          const Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Author Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Divider(),
                  Text('Name: NUR IZZAH FATIN BINTI FADZLAH'),
                  Text('Matric No: 2025429904'),
                  Text('Course: BACHELOR OF COMPUTER SCIENCE (HONS.) NETCENTRIC COMPUTING'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Copyright Notice
          const Text(
            'Copyright Notice:\n© 2026 All Rights Reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const Spacer(),

          // Clickable GitHub Repository URL
          TextButton.icon(
          onPressed: () async {
            final Uri url = Uri.parse('https://github.com/izzahfatin/baggage-fee.git'); // Replace with your actual GitHub link
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              throw Exception('Could not launch $url');
            }
          },
          icon: const Icon(Icons.code),
          label: const Text('GitHub Repository URL'),
        ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
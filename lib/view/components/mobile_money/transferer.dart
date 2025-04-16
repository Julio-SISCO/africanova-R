import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Transfert extends StatefulWidget {
  const Transfert({super.key});

  @override
  State<Transfert> createState() => _TransfertState();
}

class _TransfertState extends State<Transfert>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  final _formKey = GlobalKey<FormState>();
  int _selectedTab = 0;

  // Form controllers
  final TextEditingController _propertyValueController =
      TextEditingController(text: '86,740');
  final TextEditingController _loanAmountController =
      TextEditingController(text: '32,740');
  final TextEditingController _downPaymentController =
      TextEditingController(text: '80,040');
  final TextEditingController _interestRateController =
      TextEditingController(text: '7.77');
  final TextEditingController _loanTermController =
      TextEditingController(text: '30');
  final TextEditingController _propertyTaxController =
      TextEditingController(text: '258');
  final TextEditingController _insuranceController =
      TextEditingController(text: '72,000');
  final TextEditingController _pmiController =
      TextEditingController(text: '0.5');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _propertyValueController.dispose();
    _loanAmountController.dispose();
    _downPaymentController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    _propertyTaxController.dispose();
    _insuranceController.dispose();
    _pmiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Transfert d'argent et de crédit",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTabSection(),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildInputSection(),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _buildResultSection(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, IconData icon, int index) {
    bool isSelected = _selectedTab == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue[900] : Colors.blue[800],
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => setState(() => _selectedTab = index),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Row(
      children: [
        _buildTabButton('Maison', Icons.home, 0),
        _buildTabButton('Véhicule', Icons.directions_car, 1),
        _buildTabButton('Vacances', Icons.beach_access, 2),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {String prefix = 'FCFA', String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              prefixText: '$prefix ',
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'Valeur du bien',
                          _propertyValueController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          'Montant du prêt',
                          _loanAmountController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'Apport initial',
                          _downPaymentController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          'Taux d\'intérêt',
                          _interestRateController,
                          prefix: '',
                          suffix: '%',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'Durée du prêt',
                          _loanTermController,
                          prefix: '',
                          suffix: ' ans',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          'Taxes foncières',
                          _propertyTaxController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'Assurance habitation',
                          _insuranceController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          'Assurance prêt (PMI)',
                          _pmiController,
                          prefix: '',
                          suffix: '%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _calculateMortgage,
                    child: const Text(
                      'Calculer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _calculateMortgage() {
    if (_formKey.currentState!.validate()) {
      // Implement calculation logic here
      setState(() {});
    }
  }

  Widget _buildResultSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 300,
                  child: SfCircularChart(
                    legend:
                        Legend(isVisible: true, position: LegendPosition.right),
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        dataSource: [
                          ChartData('Principal', 56058.22, Colors.blue[900]!),
                          ChartData('Taxes', 5634.01, Colors.blue[700]!),
                          ChartData('Assurance', 495.00, Colors.blue[500]!),
                        ],
                        pointColorMapper: (ChartData data, _) => data.color,
                        xValueMapper: (ChartData data, _) => data.category,
                        yValueMapper: (ChartData data, _) => data.value,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Résumé du remboursement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryItem('Montant du prêt', 'FCFA 979,699.62'),
                _buildSummaryItem('Date de fin', 'Avr, 2054'),
                _buildSummaryItem('Taxes mensuelles', 'FCFA 225.00'),
                _buildSummaryItem('Assurance mensuelle', 'FCFA 206.00'),
                _buildSummaryItem('Paiement annuel', 'FCFA 32,463.32'),
                _buildSummaryItem('Paiement mensuel total', 'FCFA 2,721.94'),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Choisir une banque →',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

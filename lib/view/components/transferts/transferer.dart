import 'package:africanova/view/components/transferts/transfert_form.dart';
import 'package:africanova/view/components/transferts/transfert_table.dart';
import 'package:flutter/material.dart';

class Transferer extends StatefulWidget {
  const Transferer({super.key});

  @override
  State<Transferer> createState() => _TransfererState();
}

class _TransfererState extends State<Transferer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTabButton(
                  label: 'Accueil',
                  icon: Icons.home,
                  isSelected: _tabController.index == 0,
                  onTap: () => setState(() => _tabController.animateTo(0)),
                ),
                _buildTabButton(
                  label: 'Historique',
                  icon: Icons.history,
                  isSelected: _tabController.index == 1,
                  onTap: () => setState(() => _tabController.animateTo(1)),
                ),
                _buildTabButton(
                  label: 'Statistiques',
                  icon: Icons.pie_chart,
                  isSelected: _tabController.index == 2,
                  onTap: () => setState(() => _tabController.animateTo(2)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TransfertForm(),
                TransfertTable(
                  switchView: (Widget w) {},
                ),
                const Center(
                  child: Text(
                    'Statistiques',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      {required String label,
      required IconData icon,
      required bool isSelected,
      required void Function() onTap}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4),
      child: SizedBox(
        width: 200.0,
        height: 40.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Color.fromARGB(255, 5, 97, 72).withOpacity(0.9)
                : const Color.fromARGB(255, 5, 97, 72).withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
          ),
          onPressed: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

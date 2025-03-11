import 'package:flutter/material.dart';

class ServiceStatCard extends StatefulWidget {
  const ServiceStatCard({super.key});

  @override
  State<ServiceStatCard> createState() => _ServiceStatCardState();
}

class _ServiceStatCardState extends State<ServiceStatCard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: screenWidth / 5,
          ),
          child: Card(
            elevation: 0,
            color: Colors.blueGrey[200],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Libelle Statistique',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    '100000 f',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        ': 42 % des revenus ce mois',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16.0,
          right: 16.0,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.currency_bitcoin,
                size: 40,
                color: Colors.amber[700],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

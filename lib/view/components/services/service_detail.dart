import 'package:africanova/database/service.dart';
import 'package:africanova/database/type_service.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/services/detail_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ServiceDetail extends StatelessWidget {
  final Function(Widget) switchView;
  final Service service;

  const ServiceDetail({
    super.key,
    required this.service,
    required this.switchView,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60.0,
          child: DetailHeader(
            service: service,
            switchView: switchView,
          ),
        ),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
            color: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .primary,
            elevation: 0.0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildClientAndFactureInfo(context),
                  SizedBox(height: 16.0),
                  _buildServiceTypes(context),
                  SizedBox(height: 16.0),
                  _buildServiceSummary(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientAndFactureInfo(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildClientInfo(),
            _buildFactureInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle("Informations du client"),
          _buildDetail("Nom", service.client.fullname ?? "Commun"),
          _buildDetail("Contact", service.client.contact ?? "Inconnu"),
          _buildDetail("Email", service.client.email ?? "Inconnu"),
          _buildDetail("Adresse", service.client.adresse ?? "Inconnu"),
        ],
      ),
    );
  }

  Widget _buildFactureInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTitle("Informations Facture"),
          _buildDetail("Facture N°",
              service.numFacture ?? DateFormat('ymsd').format(DateTime.now())),
          _buildDetail("Fait par", service.traiteur.prenom),
          _buildDetail("Date",
              DateFormat('d MMMM yyyy', 'fr_FR').format(service.createdAt)),
        ],
      ),
    );
  }

  Widget _buildServiceTypes(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle("Types de services"),
          SizedBox(height: 8.0),
          SizedBox(
            height: 400.0,
            child: Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
              elevation: 0.0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double totalWidth = constraints.maxWidth;
                      double itemWidth = (totalWidth - 16) / 4;
                  
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.start,
                        children: service.typeServices.isNotEmpty
                            ? service.typeServices.map((typeService) {
                                return SizedBox(
                                  width: itemWidth,
                                  child: _buildTypeDetail(typeService),
                                );
                              }).toList()
                            : [
                                const Center(
                                  child: Text("Aucun service disponible"),
                                ),
                              ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSummary(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSummaryItem("Status", _getStatusText(), _getStatusColor()),
            _buildSummaryItem("Taxes", _getTaxeText()),
            _buildSummaryItem("Remises", _getRemiseText()),
            _buildSummaryItem(
                "Total", "${formatMontant(service.total ?? 0)} f"),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDetail(TypeService typeService) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      margin: EdgeInsets.all(4.0),
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              typeService.libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0),
            ),
            SizedBox(height: 4.0),
            Text(
              typeService.description ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text("$label : $value",
          style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSummaryItem(String label, String value, [Color? color]) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(
                color: color ?? Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (service.status == null) return "EN ATTENTE";
    return service.status == "en_attente"
        ? "EN ATTENTE"
        : service.status!.toUpperCase();
  }

  Color _getStatusColor() {
    if (service.status == null) return Colors.orange;
    return service.status == "complete" ? Colors.green[700]! : Colors.red[700]!;
  }

  String _getTaxeText() {
    return service.designationTaxe != null
        ? "${service.designationTaxe} : ${(service.taxeInPercent == false) ? '${service.taxe?.toStringAsFixed(0) ?? 0} f' : '${service.taxe?.toStringAsFixed(0) ?? 0}%'}"
        : "Aucune taxe";
  }

  String _getRemiseText() {
    return service.designationRemise != null
        ? "${service.designationRemise} : ${(service.remiseInPercent == false) ? '${service.remise?.toStringAsFixed(0) ?? 0} f' : '${service.remise?.toStringAsFixed(0) ?? 0}%'}"
        : "Aucune remise";
  }
}

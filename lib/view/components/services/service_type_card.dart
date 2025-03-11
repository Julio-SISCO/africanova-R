import 'package:africanova/database/type_service.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/services/service_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceTypeCard extends StatefulWidget {
  final Function(Widget) switchView;
  final Function(Widget content) changeContent;
  final TypeService type;
  final VoidCallback? refresh;
  const ServiceTypeCard({
    super.key,
    required this.type,
    required this.changeContent,
    this.refresh,
    required this.switchView,
  });

  @override
  State<ServiceTypeCard> createState() => _ServiceTypeCardState();
}

class _ServiceTypeCardState extends State<ServiceTypeCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        widget.changeContent(ServiceType(
          switchView: (Widget w) => widget.switchView(w),
          changeContent: (Widget content) => widget.changeContent(content),
          typeService: widget.type,
          refresh: widget.refresh,
        ));
      },
      onHover: (hovering) {
        setState(() {
          _isHovered = hovering;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 2),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          elevation: 4.0,
          color: _isHovered
              ? Colors.blueGrey.shade100
              : Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .surface,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8.0,
                  children: [
                    Text(
                      '${widget.type.outilTypeList?.length ?? 0} Outils'
                          .toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text(
                      '${widget.type.articleTypeList?.length ?? 0} Articles'
                          .toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.type.libelle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

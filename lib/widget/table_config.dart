import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class TableHeader extends StatefulWidget {
  final bool enableDateFilter;
  final bool enableAdd;
  final Function(Widget)? addAction;
  final Function(DateTime?)? setDate;
  final Widget addwidget;
  const TableHeader({
    super.key,
    this.enableDateFilter = true,
    this.enableAdd = true,
    this.addAction,
    required this.addwidget,
    this.setDate,
  });

  @override
  State<TableHeader> createState() => _TableHeaderState();
}

class _TableHeaderState extends State<TableHeader> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Provider.of<ThemeProvider>(context).themeData.copyWith(
                primaryColor: Colors.deepPurple,
                hintColor: Colors.deepPurple,
                colorScheme: Provider.of<ThemeProvider>(context).isLightTheme()
                    ? ColorScheme.light(
                        primary: Colors.deepPurple,
                        onPrimary: Colors.white,
                      )
                    : ColorScheme.dark(
                        primary: Colors.deepPurple,
                        onPrimary: Colors.white,
                      ),
              ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      width: MediaQuery.of(context).size.width,
      height: 40,
      color: Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              if (widget.enableAdd)
                SizedBox(
                  height: 30,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .secondary,
                      foregroundColor: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    onPressed: () {
                      widget.addAction?.call(widget.addwidget);
                    },
                    icon: Icon(
                      Icons.add,
                      color: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .tertiary,
                    ),
                    label: const Text(
                      'Ajouter',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              SizedBox(width: 16.0),
            ],
          ),
          if (widget.enableDateFilter)
            Wrap(
              spacing: 16.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _selectedDate != null
                          ? DateFormat('dd MMMM yyyy', 'fr')
                              .format(_selectedDate!)
                          : "Sélectionner une date",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_month_outlined),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                      widget.setDate!(null);
                    },
                  ),
                SizedBox(
                  height: 30,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    onPressed: (_selectedDate != null && widget.setDate != null)
                        ? () {
                            widget.setDate!(_selectedDate);
                          }
                        : null,
                    child: const Text(
                      'Appliquer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}

final PlutoGridColumnFilterConfig columnFilterConfig =
    PlutoGridColumnFilterConfig(
        filters: const [
      ...FilterHelper.defaultFilters,
      // custom filter
      CustomPlutoFilter(),
    ],
        resolveDefaultColumnFilter: (column, resolver) {
          if (column.field == 'stock') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'categorie') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'libelle') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'nb_articles') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'client') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'status') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'vendeur') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'total') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'services') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'montant') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'traiteur') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'nom') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'prenoms') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'contact') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'fax') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'adresse') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'fournisseur') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          } else if (column.field == 'permission') {
            return resolver<CustomPlutoFilter>() as PlutoFilterType;
          }

          return resolver<CustomPlutoFilter>() as PlutoFilterType;
        });

final PlutoGridStyleConfig tableStyle = PlutoGridStyleConfig(
  enableColumnBorderVertical: true,
  enableColumnBorderHorizontal: true,
  enableCellBorderVertical: true,
  enableCellBorderHorizontal: true,
  cellColorGroupedRow: const Color(0x80F6F6F6),
  gridBorderRadius: BorderRadius.circular(2.0),
  gridPopupBorderRadius: BorderRadius.circular(7),
  rowColor: Colors.grey.shade300,
  gridBackgroundColor: Colors.grey.shade300,
  borderColor: Colors.white,
);
final PlutoGridStyleConfig darkTableStyle = PlutoGridStyleConfig.dark(
  enableColumnBorderVertical: true,
  enableColumnBorderHorizontal: true,
  enableCellBorderVertical: true,
  enableCellBorderHorizontal: true,
  cellColorGroupedRow: const Color(0x80F6F6F6),
  gridBorderRadius: BorderRadius.circular(2.0),
  gridPopupBorderRadius: BorderRadius.circular(7),
  rowColor: Color(0xFF262D4D),
  borderColor: Color(0xFF111118),
  gridBackgroundColor: Color(0xFF262D4D),
);

class CustomPlutoFilter implements PlutoFilterType {
  @override
  String get title => 'Filtre';

  @override
  get compare => ({
        required String? base,
        required String? search,
        required PlutoColumn? column,
      }) {
        if (base == null || search == null) return false;

        String baseUpper = base.toUpperCase();
        List<String> keys =
            search.split(',').map((e) => e.trim().toUpperCase()).toList();

        return keys.any((key) => baseUpper.contains(key));
      };

  const CustomPlutoFilter();
}

import 'dart:collection';
import 'package:flutter/material.dart';

// typedef DomaineEntry = DropdownMenuEntry<DomaineEtude>;
// typedef NiveauEntry = DropdownMenuEntry<NiveauEtude>;
// typedef DiplomeEntry = DropdownMenuEntry<Diplome>;

Widget buildDropdown<T>(
  String label,
  List<T> items,
  T? selectedValue,
  Color? color,
  bool none,
  ValueChanged<T?>? onChanged,
) {
  final entries = UnmodifiableListView<DropdownMenuEntry<T>>(
    items.map((T item) {
      final String itemName = (item as dynamic).nom;
      return DropdownMenuEntry<T>(value: item, label: itemName);
    }),
  );

  return LayoutBuilder(builder: (context, constrains) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 0.0,
      ),
      child: DropdownMenu<T>(
        width: constrains.maxWidth,
        label: Text(label),
        initialSelection: selectedValue,
        onSelected: onChanged,
        dropdownMenuEntries: entries,
        enableFilter: true,
        requestFocusOnTap: true,
        leadingIcon: const Icon(Icons.search),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: color ?? Colors.grey.withOpacity(0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: none ? BorderSide.none : const BorderSide(),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        ),
      ),
    );
  });
}

Widget buildDropdownA<T>(
  String label,
  List<T> items,
  T? selectedValue,
  Color? color,
  bool none,
  ValueChanged<T?>? onChanged,
) {
  final entries = UnmodifiableListView<DropdownMenuEntry<T>>(
    items.map((T item) {
      final String itemName = (item as dynamic).libelle;
      return DropdownMenuEntry<T>(value: item, label: itemName);
    }),
  );

  return LayoutBuilder(builder: (context, constrains) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: DropdownMenu<T>(
        width: constrains.maxWidth,
        label: Text(label),
        initialSelection: selectedValue,
        onSelected: onChanged,
        dropdownMenuEntries: entries,
        enableFilter: true,
        requestFocusOnTap: true,
        leadingIcon: const Icon(Icons.search),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: color ?? Colors.grey.withOpacity(0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: none ? BorderSide.none : const BorderSide(),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        ),
      ),
    );
  });
}

Widget buildDropdown2<MyIcon>(
  String label,
  List<MyIcon> items,
  MyIcon? selectedValue,
  ValueChanged<MyIcon?>? onChanged,
) {
  final entries = UnmodifiableListView<DropdownMenuEntry<MyIcon>>(
    items.map(
      (MyIcon item) {
        final String itemName = (item as dynamic).libelle;
        return DropdownMenuEntry<MyIcon>(
          value: item,
          label: itemName,
          // leadingIcon: SvgPicture.asset("assets/icons/${item.nom}"),
        );
      },
    ),
  );

  return LayoutBuilder(builder: (context, constrains) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 0.0,
      ),
      child: DropdownMenu<MyIcon>(
        width: constrains.maxWidth,
        label: Text(label),
        initialSelection: selectedValue,
        onSelected: onChanged,
        dropdownMenuEntries: entries,
        enableFilter: true,
        requestFocusOnTap: true,
        leadingIcon: const Icon(Icons.search),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.withOpacity(0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        ),
      ),
    );
  });
}

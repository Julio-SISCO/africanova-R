// import 'package:africanova/database/article.dart';
// import 'package:africanova/theme/theme_provider.dart';
// import 'package:africanova/view/components/articles/article_form.dart';
// import 'package:africanova/view/components/articles/article_grid.dart';
// import 'package:africanova/view/components/depenses/depense_categorie.dart';
// import 'package:africanova/view/components/depenses/depense_saver.dart';
// import 'package:africanova/view/components/depenses/depense_type.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class PageButton extends StatefulWidget {
//   final Function(Widget?) switchView;
//   const PageButton({super.key, required this.switchView});

//   @override
//   State<PageButton> createState() => _PageButtonState();
// }

// class _PageButtonState extends State<PageButton> {
//   String selectedButton = "Acceuil";

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(2.0),
//       ),
//       elevation: 0.0,
//       child: Padding(
//         padding: const EdgeInsets.all(4.0),
//         child: SizedBox(
//           width: double.infinity,
//           child: Wrap(
//             spacing: 8,
//             runSpacing: 4,
//             children: [
//               _buildButton(context, "Ajouter", Icons.add, () {
//                 widget.switchView(ArticleForm());
//               }),
//               _buildButton(context, "", Icons.category, () {
//                 setState(() => selectedButton = "Catégories");
//                 widget.switchView(ArticleGrid(switchView: (Widget ) {},));
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(BuildContext context, String libelle, IconData icon,
//       VoidCallback onPressed) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         bool isSelected = selectedButton == libelle;

//         return SizedBox(
//           height: 40,
//           width: 120,
//           child: TextButton.icon(
//             style: TextButton.styleFrom(
//               backgroundColor: isSelected
//                   ? const Color.fromARGB(255, 5, 202, 133).withOpacity(0.4)
//                   : themeProvider.themeData.colorScheme.primary,
//               foregroundColor: themeProvider.themeData.colorScheme.tertiary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(2.0)),
//             ),
//             onPressed: onPressed,
//             icon: Icon(icon,
//                 size: 18, color: themeProvider.themeData.colorScheme.tertiary),
//             label: Text(
//               libelle,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontSize: 13),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

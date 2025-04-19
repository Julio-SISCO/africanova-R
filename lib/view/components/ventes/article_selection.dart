import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/ligne_vente.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class ArticleSelection extends StatefulWidget {
  final Function(LigneVente) updateSelection;
  const ArticleSelection({super.key, required this.updateSelection});

  @override
  State<ArticleSelection> createState() => _ArticleSelectionState();
}

class _ArticleSelectionState extends State<ArticleSelection> {
  List<Article> filteredArticles = [];

  @override
  void initState() {
    super.initState();
    filteredArticles = Hive.box<Article>('articleBox').values.toList();
  }

  void filterArticles(String query, List<Article> allArticles) {
    setState(() {
      final search = query.toLowerCase();
      filteredArticles = query.isEmpty
          ? allArticles
          : allArticles.where((a) {
              final label = a.libelle?.toLowerCase() ?? '';
              final category = a.categorie?.libelle?.toLowerCase() ?? '';
              return label.contains(search) || category.contains(search);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Article>>(
      valueListenable: Hive.box<Article>('articleBox').listenable(),
      builder: (_, box, __) {
        final articles = box.values.toList();

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          elevation: 0,
          color: Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  onChanged: (val) => filterArticles(val, articles),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              if (articles.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Aucun article disponible', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: GridView.builder(
                      itemCount: filteredArticles.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (_, index) => _buildArticleCard(filteredArticles[index]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArticleCard(Article article) {
    final imagePath = article.images?.firstOrNull?.path;
    final imageUrl = imagePath != null ? buildUrl(imagePath) : null;

    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: double.infinity,
                          fit: BoxFit.fill,
                          placeholder: (_, __) => LinearProgressIndicator(color: Colors.grey.withOpacity(0.2)),
                          errorWidget: (_, __, ___) => const Icon(Icons.error),
                        )
                      : Image.asset(
                          'assets/images/placeholder.png',
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textLine(article.libelle ?? '', bold: true),
                    _textLine('${article.prixVente} F', color: Colors.green, size: 10),
                    _textLine('${article.stock} disponible', color: Colors.red, size: 9),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            radius: 12,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              onPressed: () => widget.updateSelection(LigneVente(
                article: article,
                montant: article.prixVente,
              )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textLine(String text, {Color color = Colors.black, double size = 12, bool bold = false}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: size,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
        color: color,
      ),
    );
  }
}

// ignore_for_file: unnecessary_import, deprecated_member_use

import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/ligne_approvision.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class ArticleSelection extends StatefulWidget {
  final Function(LigneApprovision) updateSelection;
  final int? count;
  const ArticleSelection(
      {super.key, required this.updateSelection, this.count});

  @override
  State<ArticleSelection> createState() => _ArticleSelectionState();
}

class _ArticleSelectionState extends State<ArticleSelection> {
  List<Article> filteredArticles = [];

  @override
  void initState() {
    super.initState();
    final articles = Hive.box<Article>('articleBox').values.toList();
    filteredArticles = articles;
  }

  void filterArticles(String query, List<Article> articles) {
    setState(() {
      filteredArticles = query.isEmpty
          ? articles
          : articles.where((article) {
              final labelLower = article.libelle?.toLowerCase() ?? '';
              final categorieLower =
                  article.categorie?.libelle?.toLowerCase() ?? '';
              final searchLower = query.toLowerCase();
              return labelLower.contains(searchLower) ||
                  categorieLower.contains(searchLower);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Article>>(
      valueListenable: Hive.box<Article>('articleBox').listenable(),
      builder: (context, box, _) {
        final List<Article> articles = box.values.toList();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          elevation: 0.0,
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    filterArticles(value, articles);
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              if (articles.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Aucun article disponible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.count ?? 4,
                        crossAxisSpacing: 2.0,
                        mainAxisSpacing: 2.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index];
                        return _buildArticleCard(article);
                      },
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
    return InkWell(
      onTap: () {
        final ligne = LigneApprovision(
          article: article,
          prix: article.prixAchat,
        );
        widget.updateSelection(ligne);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: article.images!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: buildUrl(article.images![0].path),
                        height: MediaQuery.of(context).size.height * .3,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => LinearProgressIndicator(
                          color: Colors.grey.withOpacity(.2),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : Image.asset(
                        'assets/images/no_image.png',
                        height: MediaQuery.of(context).size.height * .3,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.libelle!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${formatMontant(article.prixAchat ?? 0)} f',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${article.stock} disponible',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

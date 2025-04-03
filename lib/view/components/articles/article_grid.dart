import 'package:africanova/database/article.dart';
import 'package:africanova/view/components/articles/article_detail.dart';
import 'package:africanova/view/components/articles/article_table.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ArticleGrid extends StatefulWidget {
  final Function(Widget) switchView;

  const ArticleGrid({super.key, required this.switchView});

  @override
  State<ArticleGrid> createState() => _ArticleGridState();
}

class _ArticleGridState extends State<ArticleGrid> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Article>>(
      valueListenable: Hive.box<Article>('articleBox').listenable(),
      builder: (context, box, _) {
        final articles = box.values.toList();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: widget
                      .switchView(ArticleTable(switchView: widget.switchView)),
                  icon: Icon(
                    Icons.grid_view_outlined,
                  ),
                ),
              ),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];

                  return GestureDetector(
                    onTap: () {
                      widget.switchView(
                        ArticleDetail(
                          article: article,
                          switchView: (Widget w) => widget.switchView(w),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: (article.images != null &&
                                      article.images!.isNotEmpty)
                                  ? Image.network(
                                      article.images![0].path,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/placeholder.jpg', // Image par défaut
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.libelle ?? "Libelle",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Catégorie: ${article.categorie?.libelle ?? "Aucune"}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Text(
                                  'Stock: ${article.stock}',
                                  style: TextStyle(
                                    color: (article.stock ?? 0) > 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

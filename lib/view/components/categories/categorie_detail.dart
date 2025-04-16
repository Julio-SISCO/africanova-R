import 'package:africanova/controller/categorie_controller.dart';
import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/categorie.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/articles/article_detail.dart';
import 'package:africanova/view/components/categories/categorie_form.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class CategorieDetail extends StatefulWidget {
  final Function(Widget) switchView;
  final Categorie categorie;
  const CategorieDetail({
    super.key,
    required this.switchView,
    required this.categorie,
  });

  @override
  State<CategorieDetail> createState() => _CategorieDetailState();
}

class _CategorieDetailState extends State<CategorieDetail> {
  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  void fetchArticles() {
    final box = Hive.box<Article>('articleBox');
    setState(() {
      articles = box.values
          .where((article) => article.categorie?.id == widget.categorie.id)
          .toList();
    });
  }

  void _delete(context, int id) async {
    final result = await supprimerCategorie(id);
    if (result['status']) {
      Get.back();
    }
    Get.snackbar(
      '',
      result["message"],
      titleText: SizedBox.shrink(),
      messageText: Center(
        child: Text(result["message"]),
      ),
      maxWidth: 300,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          
          child: ListTile(
            title: Text(
              widget.categorie.libelle ?? "Libelle",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(widget.categorie.description ?? ""),
            trailing: FutureBuilder<Map<String, bool>>(
              future: checkPermissions([
                'voir categories',
                'modifier categories',
                'supprimer categories',
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                var permissions = snapshot.data ?? {};

                return Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    if ((permissions['modifier categories'] ?? false))
                      Tooltip(
                        message: 'Modifier la categorie',
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue[800],
                          ),
                          onPressed: () {
                            widget.switchView(
                              CategorieForm(
                                editableCategorie: widget.categorie,
                              ),
                            );
                          },
                        ),
                      ),
                    if (permissions['supprimer categories'] ?? false)
                      Tooltip(
                        message: 'Supprimer la categorie',
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red[600],
                          ),
                          onPressed: () {
                            showCancelConfirmationDialog(
                              context,
                              () {
                                _delete(
                                  context,
                                  widget.categorie.id ?? 0,
                                );
                              },
                              'Êtes-vous sûr de vouloir supprimer cet categorie ?',
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),

            //  Wrap(
            //   children: [
            //     IconButton(
            //       icon: const Icon(Icons.edit),
            //       onPressed: () {},
            //     ),
            //     IconButton(
            //       icon: const Icon(Icons.delete),
            //       onPressed: () {},
            //     ),
            //   ],
            // ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...articles.map(
                    (article) => SizedBox(
                      width: 150,
                      child: _buildArticleCard(article),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleCard(Article article) {
    return InkWell(
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
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
              child: _buildImage(article),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.libelle ?? "Sans libellé",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${formatMontant(article.prixVente ?? 0)} f',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${article.stock ?? 0} disponible',
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

  Widget _buildImage(Article article) {
    if (article.images != null && article.images!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: buildUrl(article.images![0].path),
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 150,
          color: Colors.grey.withOpacity(0.2),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      return Image.asset(
        'assets/images/no_image.png',
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }
}

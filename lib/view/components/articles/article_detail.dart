import 'package:africanova/controller/article_controller.dart';
import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/articles/article_form.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/image_article.dart';
import 'package:africanova/theme/theme_provider.dart';

class ArticleDetail extends StatefulWidget {
  final Article article;
  final Function(Widget) switchView;
  const ArticleDetail(
      {super.key, required this.article, required this.switchView});

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  List<ImageArticle>? imageUrls = [];
  ImageArticle? selectedImage;
  bool isHovering = false;
  bool _editStock = false;
  bool _loading = false;

  final TextEditingController stockController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    imageUrls = widget.article.images;
    selectedImage = imageUrls?.isNotEmpty == true ? imageUrls![0] : null;
  }

  Future<void> _submit(context) async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      setState(() {
        _loading = true;
      });
      final updatedStock = int.parse(stockController.text);
      final result = await updateStock(widget.article.id ?? 0, updatedStock);
      if (result['status']) {
        stockController.clear();
        _editStock = false;
        widget.switchView(
          ArticleDetail(
            article: result['article'],
            switchView: widget.switchView,
          ),
        );
      }
      setState(() {
        _loading = false;
      });
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
  }

  void _delete(context, int id) async {
    final result = await supprimerArticle(id);
    if (result['status']) {
      Navigator.pop(context);
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
            margin: EdgeInsets.all(0.0),
            color: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .surface,
            elevation: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                margin: EdgeInsets.all(0.0),
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .primary,
                elevation: 0.0,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: imageBuilder(),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: articleInfo(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget imageBuilder() {
    return Card(
      margin: EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      color: Provider.of<ThemeProvider>(context)
          .themeData
          .colorScheme
          .surface
          .withOpacity(0.2),
      elevation: 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Affichage de l'image principale
          selectedImage != null && selectedImage!.path.isNotEmpty
              ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    bottomLeft: Radius.circular(2),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: buildUrl(selectedImage!.path),
                    fit: BoxFit.fill,
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    placeholder: (context, url) => LinearProgressIndicator(
                      color: Colors.grey.withOpacity(.2),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/no_image.png',
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(child: Text("Aucune image disponible")),
                ),
          const SizedBox(height: 20),

          // Liste d'images
          if (imageUrls!.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls!.length,
                itemBuilder: (context, index) {
                  final imageUrl = imageUrls![index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImage = imageUrl;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedImage == imageUrl
                              ? Colors.blue
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          buildUrl(imageUrl.path),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget articleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de l'article
        Text(
          widget.article.libelle ?? "Aucune Titre",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        MouseRegion(
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    widget.article.description != null
                        ? widget.article.description!
                        : "Aucune description",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.article.description != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              if (isHovering)
                Center(
                  child: Icon(
                    Icons.edit,
                    size: 40,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;
            return Wrap(
              children: [
                SizedBox(
                  width: totalWidth / 2,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .surface
                        .withOpacity(0.2),
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Prix de vente",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${formatMontant(widget.article.prixVente ?? 0)} f",
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: totalWidth / 2,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .surface
                        .withOpacity(0.2),
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Prix d'achat",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${formatMontant(widget.article.prixAchat ?? 0)} f",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        LayoutBuilder(
          builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;
            return Wrap(
              children: [
                SizedBox(
                  width: totalWidth,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .surface
                        .withOpacity(0.2),
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quantité disponible",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    widget.article.stock.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  FutureBuilder<Map<String, bool>>(
                                    future: checkPermissions([
                                      'modifier stock',
                                    ]),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox();
                                      }
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Erreur: ${snapshot.error}'));
                                      }

                                      var permissions = snapshot.data ?? {};

                                      return Wrap(
                                        alignment: WrapAlignment.center,
                                        children: [
                                          if (permissions['modifier stock'] ??
                                              false)
                                            Tooltip(
                                              message: _editStock
                                                  ? 'Annuler la modification'
                                                  : 'Modifier le stock',
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _editStock = !_editStock;
                                                  });
                                                },
                                                icon: Icon(
                                                  _editStock
                                                      ? Icons.cancel
                                                      : Icons.edit_square,
                                                  size: 18.0,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(
                                Icons.category,
                                size: 16.0,
                                color: Colors.red,
                              ),
                              Text(
                                widget.article.categorie?.libelle ??
                                    'Aucune catégorie',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.red[500],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (!_editStock)
          LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth;
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  SizedBox(
                    width: totalWidth / 2 - 4,
                    height: 45,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .surface,
                        foregroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                      onPressed: () {
                        // Action pour approvisionner
                      },
                      icon: const Icon(Icons.download),
                      label: const Text(
                        "Approvisionner",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: totalWidth / 2 - 4,
                    height: 45,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .surface,
                        foregroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                      onPressed: () {
                        // Action pour vendre
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        "Vendre",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: totalWidth / 2 - 4,
                    height: 45,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .surface,
                        foregroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                      onPressed: () {
                        widget.switchView(
                          ArticleForm(
                            editableArticle: widget.article,
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        "Modifier",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: totalWidth / 2 - 4,
                    height: 45,
                    child: TextButton.icon(
                      onPressed: () {
                        showCancelConfirmationDialog(
                          context,
                          () {
                            _delete(
                              context,
                              widget.article.id ?? 0,
                            );
                          },
                          'Êtes-vous sûr de vouloir supprimer cet article ?',
                        );
                      },
                      icon: const Icon(Icons.delete),
                      style: TextButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .surface,
                        foregroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                      label: const Text(
                        "Supprimer",
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
              );
            },
          ),
        if (_editStock) ...[
          SizedBox(height: 16.0),
          LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth;
              return Form(
                key: _formKey,
                child: Column(
                  spacing: 8.0,
                  children: [
                    SizedBox(
                      width: totalWidth,
                      child: TextFormField(
                        controller: stockController,
                        cursorColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        decoration: InputDecoration(
                          labelText: 'Quantité en stock',
                          filled: true,
                          fillColor: Provider.of<ThemeProvider>(context)
                              .themeData
                              .colorScheme
                              .primary,
                          floatingLabelStyle: TextStyle(
                            color: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .tertiary,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une quantité';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity < 0) {
                            return 'La quantité doit être supérieure ou égale à 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: totalWidth,
                      height: 45,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Provider.of<ThemeProvider>(context)
                              .themeData
                              .colorScheme
                              .surface,
                          foregroundColor: Provider.of<ThemeProvider>(context)
                              .themeData
                              .colorScheme
                              .tertiary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            showCancelConfirmationDialog(
                              context,
                              () {
                                _submit(context);
                              },
                              'Êtes-vous sûr de vouloir modifier cette quantité ?',
                            );
                          }
                        },
                        icon: const Icon(Icons.store),
                        label: _loading
                            ? CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                color: Provider.of<ThemeProvider>(context)
                                    .themeData
                                    .colorScheme
                                    .secondary,
                              )
                            : const Text(
                                "Modifier la quantité en stock",
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
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

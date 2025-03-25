import 'package:africanova/controller/article_controller.dart';
import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/image_article.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class AjustStock extends StatefulWidget {
  final Function(Widget) switchView;
  const AjustStock({super.key, required this.switchView});

  @override
  State<AjustStock> createState() => _AjustStockState();
}

class _AjustStockState extends State<AjustStock> {
  int _currentIndex = 0;
  List<ImageArticle>? imageUrls = [];
  List<Article> articles = [];
  ImageArticle? selectedImage;
  bool isHovering = false;
  bool _loading = false;
  bool _askConfirm = false;
  bool _isSame = true;

  TextEditingController _stockController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadArticles();
    imageUrls = articles[_currentIndex].images;
    selectedImage = imageUrls![0];
    selectedImage = imageUrls?.isNotEmpty == true ? imageUrls![0] : null;
  }

  void _loadArticles() {
    final box = Hive.box<Article>('articleBox');
    setState(() {
      articles = box.values.toList();
      articles.sort((a, b) => a.stock!.compareTo(b.stock!));
      _stockController = TextEditingController(
          text: articles.isNotEmpty
              ? articles[_currentIndex].stock.toString()
              : '0');
    });
  }

  Future<void> _submit(context) async {
    if (_askConfirm) Navigator.pop(context);
    setState(() {
      _loading = true;
    });
    final updatedStock = int.parse(_stockController.text);
    final result =
        await updateStock(articles[_currentIndex].id ?? 0, updatedStock);
    if (result['status']) {
      setState(() {
        articles[_currentIndex] = result['article'];
        _stockController.clear();
        _askConfirm = false;
        _isSame = true;
        _currentIndex++;
        imageUrls = articles[_currentIndex].images;
        selectedImage = imageUrls![0];
        _stockController.text = articles[_currentIndex].stock.toString();
      });
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

  void _nextArticle() {
    if (!_isSame) {
      _submit(context);
    } else if (_currentIndex < articles.length - 1) {
      setState(() {
        _currentIndex++;
        imageUrls = articles[_currentIndex].images;
        selectedImage = imageUrls![0];
        _stockController.text = articles[_currentIndex].stock.toString();
      });
    }
  }

  void _previousArticle() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        imageUrls = articles[_currentIndex].images;
        selectedImage = imageUrls![0];
        _stockController.text = articles[_currentIndex].stock.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      margin: EdgeInsets.all(0.0),
      color: Provider.of<ThemeProvider>(context).themeData.colorScheme.surface,
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          margin: EdgeInsets.all(0.0),
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                              imageUrls = articles[_currentIndex].images;
                              selectedImage = imageUrls![0];
                              _stockController.text =
                                  articles[_currentIndex].stock.toString();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: article == articles[_currentIndex]
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _buildArticleCard(article),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          articles[_currentIndex].libelle ?? "Aucune Titre",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double totalWidth = constraints.maxWidth;
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                spacing: 8.0,
                                children: [
                                  SizedBox(
                                    width: totalWidth,
                                    child: TextFormField(
                                      controller: _stockController,
                                      cursorColor:
                                          Provider.of<ThemeProvider>(context)
                                              .themeData
                                              .colorScheme
                                              .tertiary,
                                      decoration: InputDecoration(
                                        labelText: 'Quantité en stock',
                                        filled: true,
                                        fillColor:
                                            Provider.of<ThemeProvider>(context)
                                                .themeData
                                                .colorScheme
                                                .primary,
                                        floatingLabelStyle: TextStyle(
                                          color: Provider.of<ThemeProvider>(
                                                  context)
                                              .themeData
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        if (value.isNotEmpty &&
                                            (articles[_currentIndex].stock !=
                                                int.parse(
                                                    _stockController.text))) {
                                          setState(() {
                                            _isSame = false;
                                          });
                                        } else {
                                          setState(() {
                                            _isSame = true;
                                          });
                                        }
                                      },
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
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: [
                                      SizedBox(
                                        width: (totalWidth - 32) / 2,
                                        height: 45,
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor:
                                                Provider.of<ThemeProvider>(
                                                        context)
                                                    .themeData
                                                    .colorScheme
                                                    .surface,
                                            foregroundColor:
                                                Provider.of<ThemeProvider>(
                                                        context)
                                                    .themeData
                                                    .colorScheme
                                                    .tertiary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            _previousArticle();
                                          },
                                          icon: const Icon(Icons.skip_previous),
                                          label: const Text(
                                            "Précédent",
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
                                            backgroundColor:
                                                Provider.of<ThemeProvider>(
                                                        context)
                                                    .themeData
                                                    .colorScheme
                                                    .surface,
                                            foregroundColor:
                                                Provider.of<ThemeProvider>(
                                                        context)
                                                    .themeData
                                                    .colorScheme
                                                    .tertiary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (_askConfirm) {
                                                showCancelConfirmationDialog(
                                                  context,
                                                  () {
                                                    _nextArticle();
                                                  },
                                                  'Êtes-vous sûr de vouloir modifier cette quantité ?',
                                                );
                                              } else {
                                                _nextArticle();
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.skip_next),
                                          iconAlignment: IconAlignment.end,
                                          label: _loading
                                              ? CircularProgressIndicator(
                                                  backgroundColor: Colors.white,
                                                  color: Colors.grey,
                                                )
                                              : Text(
                                                  _isSame
                                                      ? "Suivant"
                                                      : "Enregistrer et suivant",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: imageBuilder(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget imageBuilder() {
    return Card(
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

  Widget _buildArticleCard(Article article) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 4.0,
      margin: EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
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
                  article.libelle ?? "Aucune Titre",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${article.stock} disponible',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

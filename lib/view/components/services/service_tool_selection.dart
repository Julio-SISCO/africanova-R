import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/ligne_article.dart';
import 'package:africanova/database/ligne_outil.dart';
import 'package:africanova/database/outil.dart';
import 'package:africanova/database/type_service.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class ArticleSelection extends StatefulWidget {
  final Function(LigneArticle) updateSelection;
  const ArticleSelection({super.key, required this.updateSelection});

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
            borderRadius: BorderRadius.circular(4.0),
          ),
          
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
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
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
    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
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
                          placeholder: (context, url) =>
                              LinearProgressIndicator(
                            color: Colors.grey.withOpacity(.2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Image.asset(
                          'assets/images/placeholder.png',
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
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${article.prixVente} f',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${article.stock} disponible',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 6.0,
          right: 6.0,
          child: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            radius: 12,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              onPressed: () {
                final ligne = LigneArticle(
                  article: article,
                  montant: article.prixVente,
                );
                widget.updateSelection(ligne);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class OutilSelection extends StatefulWidget {
  final Function(LigneOutil outil) updateOutilList;
  const OutilSelection({
    super.key,
    required this.updateOutilList,
  });

  @override
  State<OutilSelection> createState() => _OutilSelectionState();
}

class _OutilSelectionState extends State<OutilSelection> {
  late List<Outil> filteredOutils;
  List<LigneOutil> ligneOutil = [];

  void _toggleOutil(Outil outil) {
    widget.updateOutilList(
      LigneOutil(
        outil: outil,
        quantite: 1,
        montant: 0,
        designation: "",
        applyTarif: false,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final outils = Hive.box<Outil>('outilBox').values.toList();
    filteredOutils = outils;
  }

  void filterOutils(String query, List<Outil> outils) {
    setState(() {
      filteredOutils = query.isEmpty
          ? outils
          : outils.where((outil) {
              final labelLower = outil.libelle.toLowerCase();
              final searchLower = query.toLowerCase();
              return labelLower.contains(searchLower);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Outil>>(
      valueListenable: Hive.box<Outil>('outilBox').listenable(),
      builder: (context, box, _) {
        final List<Outil> outils = box.values.toList();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    filterOutils(value, outils);
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
              if (outils.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Aucun outil disponible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double totalWidth = constraints.maxWidth;
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.start,
                          children: [
                            ...List.generate(
                              filteredOutils.length,
                              (index) => InkWell(
                                onTap: () {
                                  _toggleOutil(filteredOutils[index]);
                                },
                                hoverColor: Colors.transparent,
                                child: _outilCard(
                                    outil: filteredOutils[index],
                                    width: (totalWidth - 16) / 3),
                              ),
                            ),
                          ],
                        );
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

  Widget _outilCard({required Outil outil, required double width}) {
    return SizedBox(
      width: width,
      height: 100.0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 0,
        margin: EdgeInsets.all(0.0),
        color: Colors.blueGrey[200],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                outil.libelle,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TypeSelection extends StatefulWidget {
  final Function(TypeService) updateSelection;
  const TypeSelection({super.key, required this.updateSelection});

  @override
  State<TypeSelection> createState() => _TypeSelectionState();
}

class _TypeSelectionState extends State<TypeSelection> {
  List<TypeService> filteredTypeServices = [];

  void _toggleTypeService(TypeService typeService) {
    widget.updateSelection(typeService);
  }

  @override
  void initState() {
    super.initState();
    final typeServices =
        Hive.box<TypeService>('typeServiceBox').values.toList();
    filteredTypeServices = typeServices;
  }

  void filterTypeServices(String query, List<TypeService> typeServices) {
    setState(() {
      filteredTypeServices = query.isEmpty
          ? typeServices
          : typeServices.where((typeService) {
              final labelLower = typeService.libelle.toLowerCase();
              final searchLower = query.toLowerCase();
              return labelLower.contains(searchLower);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TypeService>>(
      valueListenable: Hive.box<TypeService>('typeServiceBox').listenable(),
      builder: (context, box, _) {
        final List<TypeService> typeServices = box.values.toList();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    filterTypeServices(value, typeServices);
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
              if (typeServices.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Aucun type de service disponible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double totalWidth = constraints.maxWidth;
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.start,
                          children: [
                            ...List.generate(
                              filteredTypeServices.length,
                              (index) => InkWell(
                                onTap: () {
                                  _toggleTypeService(
                                      filteredTypeServices[index]);
                                },
                                hoverColor: Colors.transparent,
                                child: _typeServiceCard(
                                    typeService: filteredTypeServices[index],
                                    width: (totalWidth - 16) / 3),
                              ),
                            ),
                          ],
                        );
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

  Widget _typeServiceCard({
    required TypeService typeService,
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: 100.0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 0,
        margin: EdgeInsets.all(0.0),
        color: Colors.blueGrey[200],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                typeService.libelle,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

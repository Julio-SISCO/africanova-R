import 'dart:convert';
import 'dart:io';

import 'package:africanova/database/approvision.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/bilan.dart';
import 'package:africanova/database/categorie_depense.dart';
import 'package:africanova/database/depense.dart';
import 'package:africanova/database/document.dart';
import 'package:africanova/database/ligne_approvision.dart';
import 'package:africanova/database/my_icon.dart';
import 'package:africanova/database/top_articles.dart';
import 'package:africanova/database/transfert.dart';
import 'package:africanova/database/type_article.dart';
import 'package:africanova/database/categorie.dart';
import 'package:africanova/database/client.dart';
import 'package:africanova/database/employer.dart';
import 'package:africanova/database/fournisseur.dart';
import 'package:africanova/database/image_article.dart';
import 'package:africanova/database/ligne_article.dart';
import 'package:africanova/database/ligne_outil.dart';
import 'package:africanova/database/ligne_vente.dart';
import 'package:africanova/database/outil.dart';
import 'package:africanova/database/type_depense.dart';
import 'package:africanova/database/type_outil.dart';
import 'package:africanova/database/permission.dart';
import 'package:africanova/database/role.dart';
import 'package:africanova/database/service.dart';
import 'package:africanova/database/type_service.dart';
import 'package:africanova/database/user.dart';
import 'package:africanova/database/vente.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseProvider {
  static Future<void> getDatabase() async {
    Directory directory;

    if (Platform.isWindows) {
      directory = Directory('${Platform.environment['APPDATA']}\\ANOVABOXES');
    } else if (Platform.isMacOS) {
      directory = Directory(
          '${Platform.environment['HOME']}/Library/Application Support/ANOVABOXES');
    } else if (Platform.isLinux) {
      directory =
          Directory('${Platform.environment['HOME']}/.config/ANOVABOXES');
    } else {
      throw UnsupportedError('Plateforme non supportée');
    }

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    Hive.init(directory.path);
    // await Hive.initFlutter();
    Hive.registerAdapter(EmployerAdapter());
    Hive.registerAdapter(PermissionAdapter());
    Hive.registerAdapter(RoleAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(CategorieAdapter());
    Hive.registerAdapter(ImageArticleAdapter());
    Hive.registerAdapter(ArticleAdapter());
    Hive.registerAdapter(ClientAdapter());
    Hive.registerAdapter(FournisseurAdapter());
    Hive.registerAdapter(LigneVenteAdapter());
    Hive.registerAdapter(VenteAdapter());
    Hive.registerAdapter(OutilAdapter());
    Hive.registerAdapter(TypeOutilAdapter());
    Hive.registerAdapter(TypeArticleAdapter());
    Hive.registerAdapter(TypeServiceAdapter());
    Hive.registerAdapter(LigneOutilAdapter());
    Hive.registerAdapter(LigneArticleAdapter());
    Hive.registerAdapter(ServiceAdapter());
    Hive.registerAdapter(TopArticlesAdapter());
    Hive.registerAdapter(TopVendeursAdapter());
    Hive.registerAdapter(LigneApprovisionAdapter());
    Hive.registerAdapter(ApprovisionAdapter());
    Hive.registerAdapter(MouvementAdapter());
    Hive.registerAdapter(DetailsMouvementsAdapter());
    Hive.registerAdapter(BilanAdapter());
    Hive.registerAdapter(StatistiqueAdapter());
    Hive.registerAdapter(TypeDepenseAdapter());
    Hive.registerAdapter(CategorieDepenseAdapter());
    Hive.registerAdapter(DepenseAdapter());
    Hive.registerAdapter(MyIconAdapter());
    Hive.registerAdapter(DocumentAdapter());
    Hive.registerAdapter(TransfertAdapter());
  }

  static Future<void> openBoxes() async {
    await Hive.openBox<Permission>('permissionBox');
    await Hive.openBox<Permission>('userPermissionBox');
    await Hive.openBox<Role>('roleBox');
    await Hive.openBox<User>('userBox');
    await Hive.openBox<User>('otherUser');
    await Hive.openBox<Employer>('employerBox');
    await Hive.openBox<Categorie>('categorieBox');
    await Hive.openBox<Article>('articleBox');
    await Hive.openBox<Client>('clientBox');
    await Hive.openBox<Fournisseur>('fournisseurBox');
    await Hive.openBox<Vente>('VenteHistory');
    await Hive.openBox<Outil>('outilBox');
    await Hive.openBox<Approvision>('approvisionBox');
    await Hive.openBox<TypeService>('typeServiceBox');
    await Hive.openBox<Service>('serviceBox');
    await Hive.openBox<TopArticles>('topArticlesBox');
    await Hive.openBox<TopVendeurs>('topVendeursBox');
    await Hive.openBox<Bilan>('bilanBox');
    await Hive.openBox<Statistique>('statData');
    await Hive.openBox<MyIcon>('iconBox');
    await Hive.openBox<TypeDepense>('typeDepenseBox');
    await Hive.openBox<CategorieDepense>('categorieDepenseBox');
    await Hive.openBox<Depense>('depenseBox');
    await Hive.openBox<Transfert>('transfertBox');
  }
}

Future<void> saveAppVersionData(String version) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_version', version);
}

Future<Map<String, dynamic>> checkForUpdate() async {
  try {
    final response = await http.get(Uri.parse(Endpoints.version));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('version')) {
        String latestVersion = responseData['version'];
        String? currentVersion = await getAppVersionData();

        return {
          'status': true,
          'availlable': latestVersion != currentVersion,
          'version': latestVersion,
          'message': "Nouvelle version disponible"
        };
      }
      return {
        'status': false,
        'message': "Impossible de vérifier la mise à jour"
      };
    } else {
      return {
        'status': false,
        'message': "Impossible de vérifier la mise à jour"
      };
    }
  } catch (e) {
    return {
      'status': false,
      'message': "Impossible de vérifier la mise à jour"
    };
  }
}

Future<String> getAppVersionData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? version = prefs.getString('app_version');
  return version ?? '';
}

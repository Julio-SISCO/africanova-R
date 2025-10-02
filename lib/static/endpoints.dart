class Endpoints {
  // Base URL
  static const String base = "https://africanova-in-640718.hostingersite.com";
  // static const String base = "http://127.0.0.1:8000";
  // static const String base = "https://3003-102-64-216-217.ngrok-free.app";

  static const String baseUrl = "$base/api";

  // Authentication
  static const String login = "$baseUrl/login";
  static const String logout = "$baseUrl/logout";
  static const String register = "$baseUrl/register";
  static const String setProfile = "$baseUrl/profile/set";
  static const String article = "$baseUrl/articles";
  static const String client = "$baseUrl/clients";
  static const String fournisseur = "$baseUrl/fournisseurs";
  static const String employer = "$baseUrl/employers";
  static const String categorie = "$baseUrl/categories";
  static const String image = "$base/storage/";
  static const String images = "$baseUrl/images";
  static const String stock = "$baseUrl/articles/stock";
  static const String vente = "$baseUrl/ventes";
  static const String permission = "$baseUrl/permissions";
  static const String role = "$baseUrl/roles";
  static const String user = "$baseUrl/users";
  static const String global = "$baseUrl/global";
  static const String service = "$baseUrl/services";
  static const String outil = "$baseUrl/outils";
  static const String typeService = "$baseUrl/typeservices";
  static const String topArticles = "$baseUrl/top-articles";
  static const String topVendeurs = "$baseUrl/top-vendeurs";
  static const String simpleBilan = "$baseUrl/simple-bilan";
  static const String approvision = "$baseUrl/approvisions";
  static const String bilan = "$baseUrl/bilan-stock";
  static const String version = "$baseUrl/version";
  static const String security = "$baseUrl/security-answers";
  static const String resetPassword = "$baseUrl/reset-password";
  static const String typeDepense = "$baseUrl/typedepenses";
  static const String categorieDepense = "$baseUrl/categoriedepenses";
  static const String depense = "$baseUrl/depenses";
  static const String transfert = "$baseUrl/transferts";
}

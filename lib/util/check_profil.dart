import 'package:africanova/database/user.dart';
import 'package:hive/hive.dart';

Future<bool> hasEmployerProfile() async {
  final userBox = await Hive.openBox<User>('userBox');
  final User? user = userBox.get('currentUser');

  return user?.employer != null;
}

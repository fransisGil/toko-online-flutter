import 'package:appwrite/appwrite.dart';

class AppConfig {
  late Client client;
  late Account account;
  late Databases database;
  final String databaseID = "69fbff44000b328862fc";

  AppConfig() {

    client = Client()
        .setEndpoint('https://sgp.cloud.appwrite.io/v1')
        .setProject('69f2c3590001c7054c26');
    
    account = Account(client);
    database = Databases(client);
  }
}

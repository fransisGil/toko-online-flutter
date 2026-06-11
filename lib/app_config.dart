import 'package:appwrite/appwrite.dart';

class AppConfig {
  late Client client;
  late Account account;
  late Databases database;
  late Storage storage;
  late Functions function;
  final String databaseID = '69fbfe180001f1f261f5';
  final String storageID = '6a0e7a8e00287bff39c7';
  final String endpoint = 'https://sgp.cloud.appwrite.io/v1';
  final String projectID = '69f2c35a0014829e240a';
  final String functionID = '6a20eed200285b72c2da';

  AppConfig() {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectID); 

    account = Account(client);
    database = Databases(client);
    storage = Storage(client);
    function = Functions(client);
  }
}

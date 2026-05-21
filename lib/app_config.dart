import 'package:appwrite/appwrite.dart';

class AppConfig {
  late Client client;
  late Account account;
  late Databases database;
  final String databaseID = "69fbff44000b328862fc";
  late Storage storage;
  final String storageID = "6a0e7aa1002a31c4ba45";
  final String endpoint = "https://sgp.cloud.appwrite.io/v1";
  final String projectID = "69f2c3590001c7054c26";

  AppConfig() {

    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectID);
    
    account = Account(client);
    database = Databases(client);
  }
}

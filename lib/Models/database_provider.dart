// File: database_provider.dart

import 'package:siAbank/Models/database.dart'; // Import your Drift database class

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();

  late AppDb database; // Your Drift database instance

  factory DatabaseProvider() => _instance;

  DatabaseProvider._internal() {
    // Initialize your database here
    database = AppDb(); 
  }
}

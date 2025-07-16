import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsTheaterStorage {
  static const String kDefaultTheaterId = 'default_theater_id';

  final SharedPreferences prefs;

  SharedPrefsTheaterStorage(this.prefs);

  Future<void> saveTheaterId(String id) async {
    await prefs.setString(kDefaultTheaterId, id);
  }

  String? getSavedTheaterId() {
    return prefs.getString(kDefaultTheaterId);
  }
}

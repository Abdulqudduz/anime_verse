import 'package:core/src/networking/finnkino_api.dart';
import 'package:core/src/networking/tmdb_api.dart';
import 'package:core/src/redux/actor/actor_middleware.dart';
import 'package:core/src/redux/app/app_reducer.dart';
import 'package:core/src/redux/app/app_state.dart';
import 'package:core/src/redux/event/event_middleware.dart';
import 'package:core/src/redux/show/show_middleware.dart';
import 'package:core/src/redux/theater/theater_middleware.dart';
import 'package:core/src/storage/shared_prefs_theater_storage.dart'; //  new import
import 'package:http/http.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart'; //  new import

Store<AppState> createStore(Client client, SharedPreferences prefs) {
  final tmdbApi = TMDBApi(client);
  final finnkinoApi = FinnkinoApi(client);
  final theaterStorage =
      SharedPrefsTheaterStorage(prefs); //  adapter instance

  return Store(
    appReducer,
    initialState: AppState.initial(),
    distinct: true,
    middleware: [
      ActorMiddleware(tmdbApi),
      TheaterMiddleware(theaterStorage), // 👈 pass adapter
      ShowMiddleware(finnkinoApi),
      EventMiddleware(finnkinoApi),
    ],
  );
}

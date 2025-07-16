import 'dart:async';

import 'package:core/src/models/theater.dart';
import 'package:core/src/parsers/theater_parser.dart';
import 'package:core/src/preloaded_data.dart';
import 'package:core/src/redux/_common/common_actions.dart';
import 'package:core/src/redux/app/app_state.dart';
import 'package:kt_dart/collection.dart';
import 'package:redux/redux.dart';

import 'package:core/src/storage/shared_prefs_theater_storage.dart'; // 👈 Your new adapter

class TheaterMiddleware extends MiddlewareClass<AppState> {
  TheaterMiddleware(this.storage);

  final SharedPrefsTheaterStorage storage;

  @override
  Future<Null> call(
      Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is InitAction) {
      await _init(action, next);
    } else if (action is ChangeCurrentTheaterAction) {
      await _changeCurrentTheater(action, next);
    } else {
      next(action);
    }
  }

  Future<Null> _init(InitAction action, NextDispatcher next) async {
    final theaterXml = PreloadedData.theaters;
    final theaters = TheaterParser.parse(theaterXml);
    final currentTheater = _getDefaultTheater(theaters);

    next(InitCompleteAction(theaters, Theater()));
  }

  Future<Null> _changeCurrentTheater(
      ChangeCurrentTheaterAction action, NextDispatcher next) async {
    await storage.saveTheaterId(action.selectedTheater.id); // 👈 Replaced
    next(action);
  }

  Object _getDefaultTheater(KtList<Theater> allTheaters) {
    final persistedTheaterId = storage.getSavedTheaterId(); // 👈 Replaced

    if (persistedTheaterId != null) {
      return allTheaters.single((theater) {
        return theater.id == persistedTheaterId;
      });
    }

    /// Default to Helsinki
    return allTheaters.singleOrNull((theater) => theater.id == '1033') ??
        allTheaters.first;
  }
}

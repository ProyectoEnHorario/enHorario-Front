import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';

abstract class FavoritesRepository {
  Future<List<String>> getFavorites();
  Future<List<RailwayEstablishmentView>> getFavoritesDetails();
  Future<void> addFavorite(String id);
  Future<void> removeFavorite(String id);
}

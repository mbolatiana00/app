import 'dart:convert';
import 'package:app/features/Panier/data/models/cart_item_model.dart';
import 'package:app/features/Panier/domain/entities/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CartLocalDataSource {
  static const _key = 'cart';
  final SharedPreferences _prefs;
  const CartLocalDataSource(this._prefs);

  List<CartItem> read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // données corrompues : on repart d'un panier vide
    }
  }

  Future<void> write(List<CartItem> items) =>
      _prefs.setString(_key, jsonEncode(items.map(CartItemModel.toJson).toList()));
}
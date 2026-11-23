import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:arewecookin/data/pack_recipes.dart';
import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';

Recipe _r(String id, String cat, {String cuisine = 'Hindistan', int prep = 10, int cook = 10, String d = 'Kolay'}) => Recipe(
      id: id, title: 'Tarif $id', titleEn: 'Dish $id', baseDish: 'Tarif $id', category: cat, cuisine: cuisine,
      prepTime: prep, cookTime: cook, difficulty: d, servings: 2, ingredientKeys: const [], ingredients: const [],
      substitutions: const [], steps: const [],
    );

class _FakePacks implements PackSource {
  final List<Recipe> all;
  _FakePacks(this.all);
  @override
  Future<Map<String, int>?> counts() async => {'Hindistan': all.length};
  @override
  Future<List<Recipe>> country(String id) async => id == 'Hindistan' ? all : const [];
  @override
  Future<Recipe?> byId(String id) async => all.where((r) => r.id == id).firstOrNull;
}

Map<String, dynamic> _json(int n, {String cat = 'Ana Yemek'}) => {
      'id': 'p_IN_${n.toString().padLeft(5, '0')}', 'c': 'Hindistan', 'cat': cat, 'd': 'Kolay', 'p': 10, 'k': 20, 'sv': 4,
      'tr': 'Dal $n', 'en': 'Dal $n', 'img': null,
      'ing': [{'k': 'mercimek', 'n': 'Mercimek', 'ne': 'Lentils', 'a': '200', 'u': 'g', 'ue': 'g'}],
      'st': [{'o': 1, 'tool': 'pot', 'sec': 600, 't': 'Pişir', 'i': 'Mercimeği pişirin.', 'te': 'Cook', 'ie': 'Cook the lentils.', 'p': '', 'pe': ''}],
    };

void main() {
  test('country pack recipes come first, then the bundled ones, with continuous paging', () async {
    final pack = [for (var i = 1; i <= 45; i++) _r('p_IN_${i.toString().padLeft(5, '0')}', i.isEven ? 'Tatlı' : 'Ana Yemek')];
    final repo = RecipeRepository(packs: _FakePacks(pack));
    final p1 = await repo.getRecipes(cuisine: 'Hindistan', limit: 20, offset: 0);
    expect(p1.recipes.map((r) => r.id).first, 'p_IN_00001');
    expect(p1.recipes.length, 20);
    expect(p1.hasMore, isTrue);
    final p3 = await repo.getRecipes(cuisine: 'Hindistan', limit: 20, offset: p1.nextOffset + 20);
    expect(p3.recipes.where((r) => r.id.startsWith('p_IN_')).length, 5);
    expect(p3.recipes.length, greaterThan(5), reason: 'the bundled Indian recipe follows the pack');
    final ids = <String>{};
    var off = 0;
    for (var i = 0; i < 10; i++) {
      final pg = await repo.getRecipes(cuisine: 'Hindistan', limit: 20, offset: off);
      for (final r in pg.recipes) {
        expect(ids.add(r.id), isTrue, reason: 'no recipe twice: ${r.id}');
      }
      off = pg.nextOffset;
      if (!pg.hasMore) break;
    }
    expect(ids.where((i) => i.startsWith('p_IN_')).length, 45);
  });

  test('filters apply to pack recipes', () async {
    final pack = [for (var i = 1; i <= 30; i++) _r('p_IN_$i', i.isEven ? 'Tatlı' : 'Ana Yemek', cook: i * 10)];
    final repo = RecipeRepository(packs: _FakePacks(pack));
    final sweets = await repo.getRecipes(cuisine: 'Hindistan', category: 'Tatlı', limit: 50);
    expect(sweets.recipes.where((r) => r.id.startsWith('p_IN_')).length, 15);
    final quick = await repo.getRecipes(cuisine: 'Hindistan', maxMinutes: 40, limit: 50);
    expect(quick.recipes.where((r) => r.id.startsWith('p_IN_')).length, 3);
  });

  test('without packs (or another country) the bundled catalogue is unchanged', () async {
    final a = await RecipeRepository().getRecipes(cuisine: 'Hindistan', limit: 20);
    final b = await RecipeRepository(packs: _FakePacks([_r('p_IN_00001', 'Ana Yemek')])).getRecipes(cuisine: 'Japonya', limit: 20);
    final c = await RecipeRepository().getRecipes(cuisine: 'Japonya', limit: 20);
    expect(a.recipes.any((r) => r.id.startsWith('p_')), isFalse);
    expect(b.recipes.map((r) => r.id), c.recipes.map((r) => r.id));
  });

  test('a pack recipe can be opened by id', () async {
    final repo = RecipeRepository(packs: _FakePacks([_r('p_IN_00007', 'Ana Yemek')]));
    expect((await repo.getRecipeById('p_IN_00007'))?.title, 'Tarif p_IN_00007');
    expect(await repo.getRecipeById('p_IN_00999'), isNull);
  });

  test('HttpPackSource loads all pages of a country and single recipes by id', () async {
    final calls = <String>[];
    final client = MockClient((req) async {
      calls.add(req.url.path);
      if (req.url.path.endsWith('manifest.json')) {
        return http.Response(jsonEncode({'v': 1, 'pageSize': 2, 'countries': {'Hindistan': {'iso': 'IN', 'count': 3, 'pages': 2}}}), 200);
      }
      if (req.url.path.endsWith('/IN/0.json')) return http.Response.bytes(utf8.encode(jsonEncode([_json(1), _json(2, cat: 'Çorba')])), 200);
      if (req.url.path.endsWith('/IN/1.json')) return http.Response.bytes(utf8.encode(jsonEncode([_json(3)])), 200);
      return http.Response('no', 404);
    });
    final src = HttpPackSource(client: client, baseUrl: 'https://x.test/packs');
    expect(await src.counts(), {'Hindistan': 3});
    final all = await src.country('Hindistan');
    expect(all.map((r) => r.id), ['p_IN_00001', 'p_IN_00002', 'p_IN_00003']);
    expect(all[1].category, 'Çorba');
    expect(all.first.ingredients.first.nameEn, 'Lentils');
    final n = calls.length;
    await src.country('Hindistan');
    expect(calls.length, n, reason: 'second call is served from memory');
    final fresh = HttpPackSource(client: client, baseUrl: 'https://x.test/packs');
    expect((await fresh.byId('p_IN_00003'))?.title, 'Dal 3');
    expect(await fresh.byId('p_IN_00099'), isNull);
  });

  test('an unreachable pack server leaves the country empty, not broken', () async {
    final src = HttpPackSource(client: MockClient((_) async => http.Response('x', 500)), baseUrl: 'https://x.test/packs');
    expect(await src.counts(), isNull);
    expect(await src.country('Hindistan'), isEmpty);
  });
}

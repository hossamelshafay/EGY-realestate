import 'package:egy/features/profile/data/datasources/avatar_preferences.dart';
import 'package:egy/features/profile/domain/entities/avatar_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('avatar fallback is isolated by UID and survives recreation', () async {
    SharedPreferences.setMockInitialValues({'appearance_mode': 'dark', 'locale': 'ar'});
    final prefs = await SharedPreferences.getInstance();
    final storage = AvatarPreferences(prefs);
    await storage.write('one', 'atlas'); await storage.write('two', 'lotus');
    expect(AvatarPreferences(prefs).read('one'), 'atlas');
    expect(AvatarPreferences(prefs).read('two'), 'lotus');
    await storage.remove('one');
    expect(storage.read('one'), isNull); expect(storage.read('two'), 'lotus');
    expect(prefs.getString('appearance_mode'), 'dark'); expect(prefs.getString('locale'), 'ar');
  });
  test('avatar markers accept only the six known local IDs', () {
    expect(AvatarCatalog.fromPhotoUrl(AvatarCatalog.photoUrl('yasmin')), 'yasmin');
    expect(AvatarCatalog.fromPhotoUrl('https://untrusted.example/yasmin'), isNull);
    expect(AvatarCatalog.fromPhotoUrl(AvatarCatalog.photoUrl('unknown')), isNull);
  });
}

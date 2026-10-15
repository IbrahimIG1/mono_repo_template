import 'package:flutter_test/flutter_test.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:storage/storage.dart';

void main() {
  test('memory store reads, writes, and removes supported values', () async {
    final store = MemoryKeyValueStore();

    expect(await store.writeString('name', 'platform'), isA<Success<void>>());
    expect(await store.writeInt('launches', 3), isA<Success<void>>());
    expect(await store.writeBool('ready', true), isA<Success<void>>());
    expect(
      (await store.readString('name') as Success<String?>).value,
      'platform',
    );
    expect((await store.readInt('launches') as Success<int?>).value, 3);
    expect((await store.readBool('ready') as Success<bool?>).value, isTrue);

    await store.remove('name');
    expect((await store.readString('name') as Success<String?>).value, isNull);
  });
}

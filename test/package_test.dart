import 'package:packagekit_dart/packagekit_dart.dart';
import 'package:test/test.dart';

void main() {
  group('PkPackageId', () {
    test('parse valid id', () {
      final id = PkPackageId.parse('bash;5.1.8-1;x86_64;fedora');
      expect(id.name, 'bash');
      expect(id.version, '5.1.8-1');
      expect(id.arch, 'x86_64');
      expect(id.data, 'fedora');
    });

    test('raw roundtrip', () {
      const raw = 'vim;9.0-1;x86_64;updates';
      final id = PkPackageId.parse(raw);
      expect(id.raw, raw);
    });

    test('toString', () {
      final id = PkPackageId.parse('gcc;13.2-1;x86_64;fedora');
      expect(id.toString(), 'gcc-13.2-1.x86_64');
    });

    test('parse invalid id throws', () {
      expect(() => PkPackageId.parse('bad-id'), throwsFormatException);
    });

    test('parse empty segments', () {
      final id = PkPackageId.parse('pkg;;;');
      expect(id.name, 'pkg');
      expect(id.version, '');
      expect(id.arch, '');
      expect(id.data, '');
    });
  });

  group('PkPackageDetail', () {
    test('sizeFormatted GiB', () {
      const d = PkPackageDetail(
        id: PkPackageId(
            name: 'a', version: '1', arch: 'x86_64', data: 'repo'),
        summary: '',
        description: '',
        url: '',
        license: '',
        group: '',
        size: 2 * 1024 * 1024 * 1024,
      );
      expect(d.sizeFormatted, '2.0 GiB');
    });

    test('sizeFormatted MiB', () {
      const d = PkPackageDetail(
        id: PkPackageId(
            name: 'a', version: '1', arch: 'x86_64', data: 'repo'),
        summary: '',
        description: '',
        url: '',
        license: '',
        group: '',
        size: 50 * 1024 * 1024,
      );
      expect(d.sizeFormatted, '50.0 MiB');
    });

    test('sizeFormatted unknown', () {
      const d = PkPackageDetail(
        id: PkPackageId(
            name: 'a', version: '1', arch: 'x86_64', data: 'repo'),
        summary: '',
        description: '',
        url: '',
        license: '',
        group: '',
        size: 0,
      );
      expect(d.sizeFormatted, 'unknown');
    });
  });
}

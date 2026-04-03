import 'package:packagekit_dart/packagekit_dart.dart';
import 'package:test/test.dart';

void main() {
  group('PkRepoDetail', () {
    test('enabled repo', () {
      const r = PkRepoDetail(
        repoId: 'fedora',
        description: 'Fedora 39 - x86_64',
        enabled: true,
      );
      expect(r.repoId, 'fedora');
      expect(r.description, 'Fedora 39 - x86_64');
      expect(r.enabled, isTrue);
    });

    test('disabled repo', () {
      const r = PkRepoDetail(
        repoId: 'testing',
        description: 'Testing',
        enabled: false,
      );
      expect(r.enabled, isFalse);
    });
  });

  group('PkEulaRequired', () {
    test('constructor', () {
      const e = PkEulaRequired(
        eulaId: 'eula-1',
        packageId: 'font;1.0;x86_64;nonfree',
        vendorName: 'Font Corp',
        licenseAgreement: 'You must agree...',
      );
      expect(e.eulaId, 'eula-1');
      expect(e.packageId, 'font;1.0;x86_64;nonfree');
      expect(e.vendorName, 'Font Corp');
      expect(e.licenseAgreement, 'You must agree...');
    });
  });

  group('PkRepoSigRequired', () {
    test('constructor', () {
      const s = PkRepoSigRequired(
        packageId: 'pkg;1;x;r',
        repositoryName: 'repo',
        keyUrl: 'https://keys.example.com/key.gpg',
        keyUserId: 'admin',
        keyId: 'ABCD1234',
        keyFingerprint: 'ABCD 1234 EF56',
        keyTimestamp: '2024-01-01',
        type: 1,
      );
      expect(s.packageId, 'pkg;1;x;r');
      expect(s.repositoryName, 'repo');
      expect(s.keyUrl, contains('keys.example.com'));
      expect(s.keyUserId, 'admin');
      expect(s.keyId, 'ABCD1234');
      expect(s.keyFingerprint, 'ABCD 1234 EF56');
      expect(s.keyTimestamp, '2024-01-01');
      expect(s.type, 1);
    });
  });
}

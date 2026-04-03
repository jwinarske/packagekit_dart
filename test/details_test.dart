import 'package:packagekit_dart/packagekit_dart.dart';
import 'package:test/test.dart';

void main() {
  group('PkUpdateDetail', () {
    test('constructor stores all fields', () {
      const d = PkUpdateDetail(
        packageId: 'pkg;2.0;x86_64;updates',
        updates: ['pkg;1.0;x86_64;fedora'],
        obsoletes: ['old;1.0;x86_64;fedora'],
        vendorUrls: ['https://vendor.example.com'],
        bugzillaUrls: ['https://bugs.example.com/1'],
        cveUrls: ['https://cve.example.com/CVE-2024-0001'],
        restart: 1,
        updateText: 'Security fix',
        changelog: '* Fixed bug',
        state: 2,
        issued: '2024-01-15',
        updated: '2024-01-16',
      );
      expect(d.packageId, 'pkg;2.0;x86_64;updates');
      expect(d.updates, hasLength(1));
      expect(d.obsoletes, hasLength(1));
      expect(d.vendorUrls, hasLength(1));
      expect(d.bugzillaUrls, hasLength(1));
      expect(d.cveUrls, hasLength(1));
      expect(d.restart, 1);
      expect(d.updateText, 'Security fix');
      expect(d.changelog, '* Fixed bug');
      expect(d.state, 2);
      expect(d.issued, '2024-01-15');
      expect(d.updated, '2024-01-16');
    });
  });

  group('PkFiles', () {
    test('constructor', () {
      const f = PkFiles(
        packageId: 'bash;5.1;x86_64;fedora',
        files: ['/usr/bin/bash', '/etc/bash.bashrc'],
      );
      expect(f.packageId, 'bash;5.1;x86_64;fedora');
      expect(f.files, hasLength(2));
    });

    test('empty files', () {
      const f = PkFiles(packageId: 'pkg;1;x;r', files: []);
      expect(f.files, isEmpty);
    });
  });

  group('PkMessage', () {
    test('constructor', () {
      const m = PkMessage(type: 3, details: 'Cache out of date');
      expect(m.type, 3);
      expect(m.details, 'Cache out of date');
    });
  });

  group('PkErrorCode', () {
    test('constructor', () {
      const e = PkErrorCode(code: 8, details: 'Package not found');
      expect(e.code, 8);
      expect(e.details, 'Package not found');
    });
  });

  group('PkRequireRestart', () {
    test('constructor', () {
      const r = PkRequireRestart(type: 2, packageId: 'kernel;6.5;x86_64;u');
      expect(r.type, 2);
      expect(r.packageId, 'kernel;6.5;x86_64;u');
    });
  });

  group('PkPackageDetail', () {
    test('sizeFormatted KiB', () {
      const d = PkPackageDetail(
        id: PkPackageId(name: 'a', version: '1', arch: 'x', data: 'r'),
        summary: '',
        description: '',
        url: '',
        license: '',
        group: '',
        size: 512 * 1024,
      );
      expect(d.sizeFormatted, '512.0 KiB');
    });
  });
}

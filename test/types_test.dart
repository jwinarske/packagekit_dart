import 'package:packagekit_dart/src/ffi/types.dart';
import 'package:test/test.dart';

void main() {
  group('PkManagerProps', () {
    test('constructor stores all fields', () {
      const p = PkManagerProps(
        backendName: 'dnf',
        backendDescription: 'DNF backend',
        backendAuthor: 'Authors',
        roles: 0xFF,
        filters: 0xFF,
        groups: 0xFF,
        mimeTypes: ['application/x-rpm'],
        distroId: 'fedora;39;x86_64',
        networkState: 4,
        locked: false,
        versionMajor: 1,
        versionMinor: 2,
        versionMicro: 6,
      );
      expect(p.backendName, 'dnf');
      expect(p.backendDescription, 'DNF backend');
      expect(p.backendAuthor, 'Authors');
      expect(p.roles, 0xFF);
      expect(p.filters, 0xFF);
      expect(p.groups, 0xFF);
      expect(p.mimeTypes, ['application/x-rpm']);
      expect(p.distroId, 'fedora;39;x86_64');
      expect(p.networkState, 4);
      expect(p.locked, isFalse);
      expect(p.versionMajor, 1);
      expect(p.versionMinor, 2);
      expect(p.versionMicro, 6);
    });

    test('locked state', () {
      const p = PkManagerProps(
        backendName: 'apt',
        backendDescription: '',
        backendAuthor: '',
        roles: 0,
        filters: 0,
        groups: 0,
        mimeTypes: [],
        distroId: '',
        networkState: 0,
        locked: true,
        versionMajor: 0,
        versionMinor: 0,
        versionMicro: 0,
      );
      expect(p.locked, isTrue);
    });
  });

  group('PkFinished', () {
    test('constructor', () {
      const f = PkFinished(exitCode: 1, runtimeMs: 1234);
      expect(f.exitCode, 1);
      expect(f.runtimeMs, 1234);
    });
  });
}

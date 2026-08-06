import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:lecionario_anglicano/data/services/lectionary_api.dart';
import 'package:lecionario_anglicano/data/services/load_failure.dart';

void main() {
  test('a request that never arrived is offline', () {
    // package:http reports a lost connection as a ClientException, wrapping
    // SocketException itself.
    expect(
      LoadFailure.from(http.ClientException('Failed host lookup')).kind,
      LoadFailureKind.offline,
    );
    expect(
      LoadFailure.from(TimeoutException('no answer')).kind,
      LoadFailureKind.offline,
    );
  });

  test('a request that came back wrong is the server', () {
    expect(
      LoadFailure.from(const ApiException(500, 'boom')).kind,
      LoadFailureKind.server,
    );
    expect(
      LoadFailure.from(const FormatException('not json')).kind,
      LoadFailureKind.server,
    );
    expect(
      LoadFailure.from(StateError('anything else')).kind,
      LoadFailureKind.server,
    );
  });

  test('reads as offline only when it is', () {
    expect(const LoadFailure(LoadFailureKind.offline).isOffline, isTrue);
    expect(const LoadFailure(LoadFailureKind.server).isOffline, isFalse);
    expect(
      const LoadFailure(LoadFailureKind.offline),
      const LoadFailure(LoadFailureKind.offline),
    );
    expect(
      const LoadFailure(LoadFailureKind.offline),
      isNot(const LoadFailure(LoadFailureKind.server)),
    );
  });
}

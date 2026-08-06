import 'dart:async';

import 'package:http/http.dart' as http;

/// Why a request for lectionary data did not produce data.
enum LoadFailureKind {
  /// The request never reached the lectionary.
  offline,

  /// It arrived and came back wrong.
  server,
}

class LoadFailure {
  const LoadFailure(this.kind);

  final LoadFailureKind kind;

  bool get isOffline => kind == LoadFailureKind.offline;

  /// package:http reports a lost connection as a [http.ClientException] on
  /// every platform — it wraps SocketException itself — so this needs no
  /// dart:io and holds on the web too.
  factory LoadFailure.from(Object error) {
    if (error is http.ClientException || error is TimeoutException) {
      return const LoadFailure(LoadFailureKind.offline);
    }
    return const LoadFailure(LoadFailureKind.server);
  }

  @override
  bool operator ==(Object other) => other is LoadFailure && other.kind == kind;

  @override
  int get hashCode => kind.hashCode;

  @override
  String toString() => 'LoadFailure(${kind.name})';
}

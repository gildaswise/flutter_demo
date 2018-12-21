import 'dart:convert';

class Response {
  final String data;
  final String error;

  Response({this.data, this.error});

  bool get hasData => this.data != null;

  bool get hasError =>
      (this.data == null && this.error == null) || this.error != null;

  dynamic get decodedData => (data != null) ? json.decode(data) : data;

  dynamic get decodedError => (error != null) ? json.decode(error) : error;
}

class ListSnapshot<T> {
  final String serialized;
  List<T> data = [];
  final String error;

  bool get hasData => serialized != null || data.isNotEmpty;

  bool get hasError => error != null;

  ListSnapshot({this.serialized, this.data, this.error});
}

class Snapshot<T> {
  final String serialized;
  final T data;
  final dynamic error;

  bool get hasData => data != null || serialized != null;

  bool get hasError =>
      (this.data == null && this.error == null) || this.error != null;

  bool get success => hasData && !hasError;

  Snapshot({this.serialized, this.data, this.error});
}

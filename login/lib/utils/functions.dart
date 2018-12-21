import 'dart:async';

typedef Future<void> OnAction<T>(T value);
typedef Future<void> OnConfirm();
typedef Future<void> OnCancel();

typedef void OnOperationComplete<T>(T reference);
typedef void OnUpdate<T>(T value);
typedef void OnComplete();
typedef void OnError(String error);
typedef void OnException(Object error, StackTrace stackTrace);

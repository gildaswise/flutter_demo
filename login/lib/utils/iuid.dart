import 'dart:async';
import 'dart:math';

class IUID {
  static const String ASCII_CHARS =
      '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz';

  static int lastPushTime = 0;

  static int get integer {
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    return (random.nextInt(pow(2, 32)) << 32) | random.nextInt(pow(2, 32));
  }

  static String get string {
    final lastRandomChars = List<int>(12);

    var now = DateTime.now().millisecondsSinceEpoch;
    final duplicateTime = (now == lastPushTime);

    lastPushTime = now;

    var i = 0;

    final timestampChars = List<String>(8);

    for (i = 7; i >= 0; i--) {
      timestampChars[i] = ASCII_CHARS[now % 64];
      now = (now / 64).floor();
    }

    if (now != 0) return null;

    var id = timestampChars.join('');

    if (!duplicateTime) {
      for (i = 0; i < 12; i++) {
        lastRandomChars[i] = Random().nextInt(64).floor();
      }
    } else {
      for (i = 11; i >= 0 && lastRandomChars[i] == 63; i--) {
        lastRandomChars[i] = lastRandomChars[i] + 1;
      }
    }

    for (i = 0; i < 12; i++) {
      id += ASCII_CHARS[lastRandomChars[i]];
    }

    if (id.length != 20) return null;

    return id;
  }
}

import 'package:uuid/uuid.dart';
/// The TidGen class provides a static method generateTid that generates a unique identifier (Tid) using the uuid package.

class TidGen {
  static String generateTid() {
    var uuid = Uuid();
    return uuid.v4(); // Generate a version 4 (random) UUID
  }
} 
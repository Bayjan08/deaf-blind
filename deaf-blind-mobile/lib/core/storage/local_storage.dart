/// Local key-value storage (tokens, progress cache). Stub.
abstract class LocalStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

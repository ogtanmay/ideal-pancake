abstract class SettingsRepository {
  Future<bool> loadStrictOffline();
  Future<bool> loadBrowserResearch();
  Future<void> saveStrictOffline(bool value);
  Future<void> saveBrowserResearch(bool value);
}

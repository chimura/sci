import 'package:flutter/material.dart';

enum AppThemeMode {
  system('System', ThemeMode.system),
  light('Light', ThemeMode.light),
  dark('Dark', ThemeMode.dark);

  final String label;
  final ThemeMode themeMode;
  const AppThemeMode(this.label, this.themeMode);
}

enum DefaultCitationStyle { apa, mla, chicago, ieee, harvard }

class AppSettings {
  final AppThemeMode themeMode;
  final bool autoSyncEnabled;
  final int syncIntervalMinutes;
  final DefaultCitationStyle defaultCitationStyle;
  final bool showAbstractInList;
  final bool confirmBeforeDelete;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.autoSyncEnabled = false,
    this.syncIntervalMinutes = 30,
    this.defaultCitationStyle = DefaultCitationStyle.apa,
    this.showAbstractInList = false,
    this.confirmBeforeDelete = true,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? autoSyncEnabled,
    int? syncIntervalMinutes,
    DefaultCitationStyle? defaultCitationStyle,
    bool? showAbstractInList,
    bool? confirmBeforeDelete,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncIntervalMinutes: syncIntervalMinutes ?? this.syncIntervalMinutes,
      defaultCitationStyle: defaultCitationStyle ?? this.defaultCitationStyle,
      showAbstractInList: showAbstractInList ?? this.showAbstractInList,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
    );
  }

  Map<String, dynamic> toMap() => {
        'themeMode': themeMode.name,
        'autoSyncEnabled': autoSyncEnabled,
        'syncIntervalMinutes': syncIntervalMinutes,
        'defaultCitationStyle': defaultCitationStyle.name,
        'showAbstractInList': showAbstractInList,
        'confirmBeforeDelete': confirmBeforeDelete,
      };

  static AppSettings fromMap(Map<String, dynamic> map) => AppSettings(
        themeMode: AppThemeMode.values.firstWhere(
          (t) => t.name == map['themeMode'],
          orElse: () => AppThemeMode.system,
        ),
        autoSyncEnabled: map['autoSyncEnabled'] as bool? ?? false,
        syncIntervalMinutes: map['syncIntervalMinutes'] as int? ?? 30,
        defaultCitationStyle: DefaultCitationStyle.values.firstWhere(
          (s) => s.name == map['defaultCitationStyle'],
          orElse: () => DefaultCitationStyle.apa,
        ),
        showAbstractInList: map['showAbstractInList'] as bool? ?? false,
        confirmBeforeDelete: map['confirmBeforeDelete'] as bool? ?? true,
      );
}

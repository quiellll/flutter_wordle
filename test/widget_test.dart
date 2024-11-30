import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_wordle/main.dart';

// Mock implementation for testing
class MockSharedPreferencesAsync extends SharedPreferencesAsync {
  final Map<String, dynamic> _data = {};

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    return _data[key] as bool?;
  }

  @override
  Future<String?> getString(String key) async {
    return _data[key] as String?;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<void> clear({Set<String>? allowList}) async {
    _data.clear();
  }
}

void main() {
  testWidgets('WordleApp basic smoke test', (WidgetTester tester) async {
    final asyncPrefs = MockSharedPreferencesAsync();
    
    // Build our app and trigger a frame
    await tester.pumpWidget(WordleApp(prefs: asyncPrefs));
    
    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that our title appears
    expect(find.text('WORDLE'), findsOneWidget);
    
    // Verify that welcome message appears with default username
    expect(find.text('Welcome, Player!'), findsOneWidget);

    // Verify that theme toggle button exists
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    
    // Verify that profile button exists
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
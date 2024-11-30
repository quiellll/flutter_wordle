import 'package:flutter/material.dart';
import 'package:flutter_wordle/models.dart';

class ValidationProvider extends ChangeNotifier {
  final Language language;
  String currentInput = '';
  String answer = '';
  List<String> attempts = [];
  Map<String, KeyState> keyStates = {};
  List<List<TileState>> tileStates = [];
  bool gameEnded = false;

  ValidationProvider({required this.language}) {
    _initializeKeyStates();
    _initializeTileStates();
    // TODO: Set initial answer based on language
    answer = 'WORLD'; // Temporary
  }

  void _initializeKeyStates() {
    for (var c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')) {
      keyStates[c] = KeyState.unused;
    }
    if (language == Language.spanish) {
      keyStates['Ñ'] = KeyState.unused;
    }
  }

  void _initializeTileStates() {
    tileStates = List.generate(
      6, // Max attempts
      (_) => List.generate(5, (_) => TileState.empty),
    );
  }

  void addLetter(String letter) {
    if (currentInput.length < 5 && !gameEnded) {
      currentInput += letter;
      notifyListeners();
    }
  }

  void removeLetter() {
    if (currentInput.isNotEmpty && !gameEnded) {
      currentInput = currentInput.substring(0, currentInput.length - 1);
      notifyListeners();
    }
  }

  ValidationResult submitAttempt() {
    if (currentInput.length != 5) return ValidationResult.invalid;

    // Add current attempt to the list
    attempts.add(currentInput);
    
    // Update tile states for this attempt
    List<TileState> currentTileStates = List.filled(5, TileState.wrong);
    Map<String, int> letterCounts = {};
    
    // Count letters in answer
    for (var c in answer.split('')) {
      letterCounts[c] = (letterCounts[c] ?? 0) + 1;
    }

    // First pass: mark correct positions
    for (int i = 0; i < currentInput.length; i++) {
      if (currentInput[i] == answer[i]) {
        currentTileStates[i] = TileState.correct;
        letterCounts[currentInput[i]] = letterCounts[currentInput[i]]! - 1;
        keyStates[currentInput[i]] = KeyState.correct;
      }
    }

    // Second pass: mark wrong positions
    for (int i = 0; i < currentInput.length; i++) {
      if (currentTileStates[i] != TileState.correct &&
          letterCounts[currentInput[i]] != null &&
          letterCounts[currentInput[i]]! > 0) {
        currentTileStates[i] = TileState.wrongPosition;
        letterCounts[currentInput[i]] = letterCounts[currentInput[i]]! - 1;
        if (keyStates[currentInput[i]] != KeyState.correct) {
          keyStates[currentInput[i]] = KeyState.wrongPosition;
        }
      } else if (currentTileStates[i] != TileState.correct) {
        if (keyStates[currentInput[i]] == KeyState.unused) {
          keyStates[currentInput[i]] = KeyState.wrong;
        }
      }
    }

    // Update tile states
    tileStates[attempts.length - 1] = currentTileStates;

    // Clear current input
    currentInput = '';
    
    // Check if game is won
    if (attempts.last == answer) {
      gameEnded = true;
      notifyListeners();
      return ValidationResult.win;
    }

    // Check if game is lost (6 attempts)
    if (attempts.length >= 6) {
      gameEnded = true;
    }

    notifyListeners();
    return ValidationResult.continue_;
  }
}
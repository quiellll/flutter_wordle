import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:convert';
import 'dart:math';

import 'package:flutter_wordle/models/models.dart';

class ValidationProvider extends ChangeNotifier {
  final Language language;
  String currentInput = '';
  String answer = '';
  List<String> attempts = [];
  Map<String, KeyState> keyStates = {};
  List<List<TileState>> tileStates = [];
  bool gameEnded = false;
  List<String> wordList = [];

  ValidationProvider({required this.language}) {
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    // Initialize key and tile states
    _initializeKeyStates();
    _initializeTileStates();

    // Load word list based on language
    await _loadWordList();

    // Select random answer
    _selectRandomAnswer();
  }

  Future<void> _loadWordList() async {
    try {
      // Determine the correct file path based on language
      String filePath = language == Language.english 
          ? 'assets/words_english.txt' 
          : 'assets/words_spanish.txt';

      // Explicitly initialize ByteData
      ByteData data = await rootBundle.load(filePath);

      // Convert ByteData to String using UTF-8 decoding
      String fileContent = utf8.decode(data.buffer.asUint8List());

      // Split the content into lines and convert to uppercase
      wordList = fileContent.split('\n')
          .map((word) => word.trim().toUpperCase())
          .where((word) => word.length == 5) // Ensure 5-letter words
          .toList();

      if (wordList.isEmpty) {
        throw Exception('No words found in the file');
      }

      print('Loaded ${wordList.length} words');
    } catch (e) {
      // Fallback to a default list if file reading fails
      wordList = language == Language.english 
          ? ['WORLD', 'APPLE', 'SMILE', 'DANCE', 'HAPPY']
          : ['MUNDO', 'PERRO', 'GATOS', 'MESAS', 'AGUAS'];
      print('Error loading word list: $e');
    }
  }

  void _selectRandomAnswer() {
    final Random random = Random();
    
    // Randomly select an answer from the word list
    answer = wordList[random.nextInt(wordList.length)];
    print('Selected answer: $answer');
    notifyListeners();
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
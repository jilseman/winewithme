import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Local storage service for persisting app data
class StorageService {
  static const String _partiesKey = 'parties';
  static const String _winesKey = 'wines';
  static const String _scoresKey = 'scores';
  static const String _judgesKey = 'judges';
  static const String _currentJudgeKey = 'current_judge';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Parties
  Future<List<Party>> getParties() async {
    final String? data = _prefs.getString(_partiesKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Party.fromJson(json)).toList();
  }

  Future<void> saveParties(List<Party> parties) async {
    final String data = jsonEncode(parties.map((p) => p.toJson()).toList());
    await _prefs.setString(_partiesKey, data);
  }

  Future<Party?> getPartyByCode(String code) async {
    final parties = await getParties();
    try {
      return parties.firstWhere(
        (p) => p.partyCode.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Wines
  Future<List<Wine>> getWines() async {
    final String? data = _prefs.getString(_winesKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Wine.fromJson(json)).toList();
  }

  Future<List<Wine>> getWinesForParty(String partyId) async {
    final wines = await getWines();
    return wines.where((w) => w.partyId == partyId).toList()
      ..sort((a, b) => a.blindNumber.compareTo(b.blindNumber));
  }

  Future<void> saveWines(List<Wine> wines) async {
    final String data = jsonEncode(wines.map((w) => w.toJson()).toList());
    await _prefs.setString(_winesKey, data);
  }

  // Scores
  Future<List<Score>> getScores() async {
    final String? data = _prefs.getString(_scoresKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Score.fromJson(json)).toList();
  }

  Future<List<Score>> getScoresForParty(String partyId) async {
    final scores = await getScores();
    return scores.where((s) => s.partyId == partyId).toList();
  }

  Future<List<Score>> getScoresForJudge(String judgeId, String partyId) async {
    final scores = await getScores();
    return scores
        .where((s) => s.judgeId == judgeId && s.partyId == partyId)
        .toList();
  }

  Future<void> saveScores(List<Score> scores) async {
    final String data = jsonEncode(scores.map((s) => s.toJson()).toList());
    await _prefs.setString(_scoresKey, data);
  }

  // Judges
  Future<List<Judge>> getJudges() async {
    final String? data = _prefs.getString(_judgesKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Judge.fromJson(json)).toList();
  }

  Future<List<Judge>> getJudgesForParty(String partyId) async {
    final judges = await getJudges();
    return judges.where((j) => j.partyId == partyId).toList();
  }

  Future<void> saveJudges(List<Judge> judges) async {
    final String data = jsonEncode(judges.map((j) => j.toJson()).toList());
    await _prefs.setString(_judgesKey, data);
  }

  // Current Judge (the user in judge mode)
  Future<Judge?> getCurrentJudge() async {
    final String? data = _prefs.getString(_currentJudgeKey);
    if (data == null) return null;
    return Judge.fromJson(jsonDecode(data));
  }

  Future<void> saveCurrentJudge(Judge? judge) async {
    if (judge == null) {
      await _prefs.remove(_currentJudgeKey);
    } else {
      await _prefs.setString(_currentJudgeKey, jsonEncode(judge.toJson()));
    }
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

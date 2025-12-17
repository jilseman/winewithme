import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

/// Provider for managing party state
class PartyProvider extends ChangeNotifier {
  final StorageService _storage;
  final Uuid _uuid = const Uuid();

  List<Party> _parties = [];
  Party? _currentParty;
  List<Wine> _wines = [];
  List<Score> _scores = [];
  List<Judge> _judges = [];
  Judge? _currentJudge;
  bool _isLoading = false;

  PartyProvider(this._storage);

  // Getters
  List<Party> get parties => _parties;
  Party? get currentParty => _currentParty;
  List<Wine> get wines => _wines;
  List<Score> get scores => _scores;
  List<Judge> get judges => _judges;
  Judge? get currentJudge => _currentJudge;
  bool get isLoading => _isLoading;

  // Initialize
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _parties = await _storage.getParties();
    _currentJudge = await _storage.getCurrentJudge();

    _isLoading = false;
    notifyListeners();
  }

  // Generate a random party code
  String _generatePartyCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Helper to update party in storage
  Future<void> _updateParty(Party party) async {
    _currentParty = party;
    final index = _parties.indexWhere((p) => p.id == party.id);
    if (index != -1) {
      _parties[index] = party;
      await _storage.saveParties(_parties);
    }
    notifyListeners();
  }

  // Host Functions

  Future<Party> createParty(String name, String hostName) async {
    final party = Party(
      id: _uuid.v4(),
      name: name,
      hostId: _uuid.v4(),
      hostName: hostName,
      partyCode: _generatePartyCode(),
      createdAt: DateTime.now(),
      status: PartyStatus.registering,
    );

    _parties.add(party);
    await _storage.saveParties(_parties);
    _currentParty = party;
    _wines = [];
    _scores = [];
    _judges = [];
    notifyListeners();

    return party;
  }

  Future<void> loadParty(String partyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentParty = _parties.firstWhere((p) => p.id == partyId);
    } catch (e) {
      _currentParty = null;
    }

    if (_currentParty != null) {
      _wines = await _storage.getWinesForParty(partyId);
      _scores = await _storage.getScoresForParty(partyId);
      _judges = await _storage.getJudgesForParty(partyId);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Start the party - enables scoring
  Future<void> startParty() async {
    if (_currentParty == null) return;
    await _updateParty(_currentParty!.copyWith(status: PartyStatus.active));
  }

  /// Lock the party - disables scoring
  Future<void> lockParty() async {
    if (_currentParty == null) return;
    await _updateParty(_currentParty!.copyWith(status: PartyStatus.locked));
  }

  /// Unlock the party - re-enables scoring
  Future<void> unlockParty() async {
    if (_currentParty == null) return;
    await _updateParty(_currentParty!.copyWith(status: PartyStatus.active));
  }

  /// Reopen registration (go back to registering state)
  Future<void> reopenRegistration() async {
    if (_currentParty == null) return;
    await _updateParty(_currentParty!.copyWith(status: PartyStatus.registering));
  }

  Future<void> revealResults() async {
    if (_currentParty == null) return;
    await _updateParty(_currentParty!.copyWith(resultsRevealed: true));
  }

  /// Reorder wines - update blind numbers
  Future<void> reorderWines(List<Wine> reorderedWines) async {
    if (_currentParty == null) return;

    // Update blind numbers based on new order
    List<Wine> updatedWines = [];
    for (int i = 0; i < reorderedWines.length; i++) {
      updatedWines.add(reorderedWines[i].copyWith(blindNumber: i + 1));
    }

    _wines = updatedWines;

    // Save all wines (replace wines for this party)
    final allWines = await _storage.getWines();
    final otherWines = allWines.where((w) => w.partyId != _currentParty!.id).toList();
    await _storage.saveWines([...otherWines, ..._wines]);

    notifyListeners();
  }

  // Calculate rankings
  List<WineRanking> getRankings() {
    if (_wines.isEmpty) return [];

    List<WineRanking> rankings = [];

    for (final wine in _wines) {
      final wineScores = _scores.where((s) => s.wineId == wine.id).toList();

      if (wineScores.isEmpty) {
        rankings.add(WineRanking(
          wine: wine,
          rank: 0,
          averageScore: 0,
          totalScore: 0,
          numberOfRatings: 0,
          highestScore: 0,
          lowestScore: 0,
        ));
      } else {
        final total =
            wineScores.fold(0.0, (sum, score) => sum + score.rating);
        final average = total / wineScores.length;
        final highest =
            wineScores.map((s) => s.rating).reduce((a, b) => a > b ? a : b);
        final lowest =
            wineScores.map((s) => s.rating).reduce((a, b) => a < b ? a : b);

        rankings.add(WineRanking(
          wine: wine,
          rank: 0,
          averageScore: average,
          totalScore: total,
          numberOfRatings: wineScores.length,
          highestScore: highest,
          lowestScore: lowest,
        ));
      }
    }

    // Sort by average score descending
    rankings.sort((a, b) => b.averageScore.compareTo(a.averageScore));

    // Assign ranks
    return rankings.asMap().entries.map((entry) {
      return WineRanking(
        wine: entry.value.wine,
        rank: entry.key + 1,
        averageScore: entry.value.averageScore,
        totalScore: entry.value.totalScore,
        numberOfRatings: entry.value.numberOfRatings,
        highestScore: entry.value.highestScore,
        lowestScore: entry.value.lowestScore,
      );
    }).toList();
  }

  // Attendee Functions

  Future<bool> joinParty(String partyCode, String attendeeName) async {
    final party = await _storage.getPartyByCode(partyCode);
    if (party == null) return false;

    _currentParty = party;

    // Create or update attendee (still using Judge model internally)
    _currentJudge = Judge(
      id: _uuid.v4(),
      name: attendeeName,
      partyId: party.id,
    );

    await _storage.saveCurrentJudge(_currentJudge);

    // Add attendee to party's list
    _judges = await _storage.getJudgesForParty(party.id);
    _judges.add(_currentJudge!);

    // Save all judges
    final allJudges = await _storage.getJudges();
    allJudges.add(_currentJudge!);
    await _storage.saveJudges(allJudges);

    // Load party data
    _wines = await _storage.getWinesForParty(party.id);
    _scores = await _storage.getScoresForParty(party.id);

    notifyListeners();
    return true;
  }

  Future<void> registerWine({
    required String name,
    String? winery,
    String? vintage,
    String? varietal,
    String? region,
    String? notes,
  }) async {
    if (_currentParty == null || _currentJudge == null) return;

    final nextBlindNumber = _wines.isEmpty
        ? 1
        : _wines.map((w) => w.blindNumber).reduce((a, b) => a > b ? a : b) + 1;

    final wine = Wine(
      id: _uuid.v4(),
      partyId: _currentParty!.id,
      registeredBy: _currentJudge!.id,
      blindNumber: nextBlindNumber,
      name: name,
      winery: winery,
      vintage: vintage,
      varietal: varietal,
      region: region,
      notes: notes,
    );

    _wines.add(wine);

    // Save all wines
    final allWines = await _storage.getWines();
    allWines.add(wine);
    await _storage.saveWines(allWines);

    notifyListeners();
  }

  Future<void> submitScore(String wineId, double rating, String? notes) async {
    if (_currentParty == null || _currentJudge == null) return;
    if (!_currentParty!.canScore) return; // Only allow scoring when party is active

    // Check if already scored
    final existingIndex = _scores.indexWhere(
        (s) => s.wineId == wineId && s.judgeId == _currentJudge!.id);

    final score = Score(
      id: existingIndex >= 0 ? _scores[existingIndex].id : _uuid.v4(),
      partyId: _currentParty!.id,
      wineId: wineId,
      judgeId: _currentJudge!.id,
      judgeName: _currentJudge!.name,
      rating: rating,
      notes: notes,
      createdAt: DateTime.now(),
    );

    if (existingIndex >= 0) {
      _scores[existingIndex] = score;
    } else {
      _scores.add(score);
    }

    // Save all scores
    final allScores = await _storage.getScores();
    final globalIndex =
        allScores.indexWhere((s) => s.id == score.id);
    if (globalIndex >= 0) {
      allScores[globalIndex] = score;
    } else {
      allScores.add(score);
    }
    await _storage.saveScores(allScores);

    notifyListeners();
  }

  Future<void> submitAllScores() async {
    if (_currentJudge == null) return;

    _currentJudge = _currentJudge!.copyWith(hasSubmittedScores: true);
    await _storage.saveCurrentJudge(_currentJudge);

    // Update in judges list
    final index = _judges.indexWhere((j) => j.id == _currentJudge!.id);
    if (index >= 0) {
      _judges[index] = _currentJudge!;
    }

    // Save all judges
    final allJudges = await _storage.getJudges();
    final globalIndex = allJudges.indexWhere((j) => j.id == _currentJudge!.id);
    if (globalIndex >= 0) {
      allJudges[globalIndex] = _currentJudge!;
      await _storage.saveJudges(allJudges);
    }

    notifyListeners();
  }

  Score? getScoreForWine(String wineId) {
    if (_currentJudge == null) return null;
    try {
      return _scores.firstWhere(
          (s) => s.wineId == wineId && s.judgeId == _currentJudge!.id);
    } catch (e) {
      return null;
    }
  }

  List<Score> getScoresForWine(String wineId) {
    return _scores.where((s) => s.wineId == wineId).toList();
  }

  void leaveParty() {
    _currentParty = null;
    _wines = [];
    _scores = [];
    _currentJudge = null;
    _storage.saveCurrentJudge(null);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/party_provider.dart';
import '../../models/models.dart';
import 'register_wine_screen.dart';
import 'rate_wine_screen.dart';

class JudgeDashboardScreen extends StatelessWidget {
  const JudgeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartyProvider>(
      builder: (context, provider, child) {
        final party = provider.currentParty;
        final attendee = provider.currentJudge;

        if (party == null || attendee == null) {
          return Scaffold(
            body: Center(child: Text('Session expired')),
          );
        }

        // Different UI based on party status
        return _buildForStatus(context, party, provider);
      },
    );
  }

  Widget _buildForStatus(BuildContext context, Party party, PartyProvider provider) {
    // Check if results are revealed first (takes priority over locked status)
    if (party.resultsRevealed) {
      return _RevealedPhaseUI(party: party, provider: provider);
    }

    switch (party.status) {
      case PartyStatus.registering:
        return _RegistrationPhaseUI(party: party, provider: provider);
      case PartyStatus.active:
        return _ScoringPhaseUI(party: party, provider: provider);
      case PartyStatus.locked:
        return _LockedPhaseUI(party: party, provider: provider);
    }
  }
}

/// UI shown during registration phase - view wines and register your own
class _RegistrationPhaseUI extends StatelessWidget {
  final Party party;
  final PartyProvider provider;

  const _RegistrationPhaseUI({required this.party, required this.provider});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(party.name),
          backgroundColor: Colors.deepPurple.shade900,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _confirmLeave(context, provider),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(icon: Icon(Icons.wine_bar), text: 'All Wines'),
              Tab(icon: Icon(Icons.add_circle), text: 'Register Wine'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 18, color: Colors.blue.shade800),
                  const SizedBox(width: 8),
                  Text(
                    'Waiting for host to start the party...',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AllWinesTab(wines: provider.wines),
                  _RegisterWineTab(party: party, provider: provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLeave(BuildContext context, PartyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Party?'),
        content: const Text(
          'You can rejoin anytime with the party code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.leaveParty();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

/// UI shown during scoring phase - rate wines
class _ScoringPhaseUI extends StatelessWidget {
  final Party party;
  final PartyProvider provider;

  const _ScoringPhaseUI({required this.party, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(party.name),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () => _confirmLeave(context, provider),
        ),
      ),
      body: Column(
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.how_to_vote, size: 18, color: Colors.green.shade800),
                const SizedBox(width: 8),
                Text(
                  'Scoring is open! Rate each wine below.',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _RateWinesTab(
              wines: provider.wines,
              party: party,
              provider: provider,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context, PartyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Party?'),
        content: const Text(
          'Your scores have been saved. You can rejoin anytime with the party code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.leaveParty();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

/// UI shown when scoring is locked
class _LockedPhaseUI extends StatelessWidget {
  final Party party;
  final PartyProvider provider;

  const _LockedPhaseUI({required this.party, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(party.name),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            provider.leaveParty();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  'Scoring is locked. Waiting for results...',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _YourScoresTab(
              wines: provider.wines,
              provider: provider,
              party: party,
            ),
          ),
        ],
      ),
    );
  }
}

/// UI shown when results are revealed
class _RevealedPhaseUI extends StatelessWidget {
  final Party party;
  final PartyProvider provider;

  const _RevealedPhaseUI({required this.party, required this.provider});

  @override
  Widget build(BuildContext context) {
    final rankings = provider.getRankings();
    final currentJudge = provider.currentJudge;

    // Find if current user's wine won or came last
    String? awardMessage;
    Color? awardColor;
    IconData? awardIcon;

    if (rankings.isNotEmpty && currentJudge != null) {
      final winnerWine = rankings.first;
      final loserWine = rankings.last;

      // Check if current user submitted the winning wine
      if (winnerWine.wine.registeredBy == currentJudge.id && winnerWine.numberOfRatings > 0) {
        awardMessage = "Congratulations! Your wine won!";
        awardColor = Colors.amber;
        awardIcon = Icons.emoji_events;
      }
      // Check if current user submitted the last place wine (only if more than 1 wine)
      else if (rankings.length > 1 &&
               loserWine.wine.registeredBy == currentJudge.id &&
               loserWine.numberOfRatings > 0) {
        awardMessage = "You won the 'Tastes Like Feet' Award!";
        awardColor = Colors.brown;
        awardIcon = Icons.sentiment_very_dissatisfied;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(party.name),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            provider.leaveParty();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Results revealed banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.amber.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.celebration, size: 18, color: Colors.amber.shade800),
                const SizedBox(width: 8),
                Text(
                  'Results are in! Check out the rankings!',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Award notification if applicable
          if (awardMessage != null)
            _buildAwardBanner(awardMessage, awardColor!, awardIcon!),
          Expanded(
            child: _ResultsTab(
              rankings: rankings,
              provider: provider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardBanner(String message, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Tab showing final results with rankings
class _ResultsTab extends StatelessWidget {
  final List<WineRanking> rankings;
  final PartyProvider provider;

  const _ResultsTab({required this.rankings, required this.provider});

  String _getSubmitterName(String registeredById) {
    try {
      final judge = provider.judges.firstWhere((j) => j.id == registeredById);
      return judge.name;
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (rankings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No rankings available',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final ranking = rankings[index];
        final submitterName = _getSubmitterName(ranking.wine.registeredBy);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildRankBadge(ranking.rank),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ranking.wine.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (ranking.wine.winery != null ||
                          ranking.wine.vintage != null ||
                          ranking.wine.varietal != null)
                        Text(
                          [
                            if (ranking.wine.winery != null) ranking.wine.winery,
                            if (ranking.wine.vintage != null) ranking.wine.vintage,
                            if (ranking.wine.varietal != null) ranking.wine.varietal,
                          ].where((e) => e != null).join(' • '),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Brought by: $submitterName',
                        style: TextStyle(
                          color: Colors.deepPurple.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ranking.formattedAverage,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                      ),
                    ),
                    Text(
                      '${ranking.numberOfRatings} ratings',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank) {
    Color color;
    IconData? icon;

    switch (rank) {
      case 1:
        color = Colors.amber;
        icon = Icons.emoji_events;
        break;
      case 2:
        color = Colors.grey.shade400;
        icon = Icons.emoji_events;
        break;
      case 3:
        color = Colors.brown.shade300;
        icon = Icons.emoji_events;
        break;
      default:
        color = Colors.deepPurple.shade100;
        icon = null;
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: color,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: 24)
          : Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade900,
              ),
            ),
    );
  }
}

/// Tab showing all registered wines (read-only)
class _AllWinesTab extends StatelessWidget {
  final List<Wine> wines;

  const _AllWinesTab({required this.wines});

  @override
  Widget build(BuildContext context) {
    if (wines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wine_bar_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No wines registered yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to register a wine!',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wines.length,
      itemBuilder: (context, index) {
        final wine = wines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: Text(
                '${wine.blindNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade900,
                ),
              ),
            ),
            title: Text(
              'Wine #${wine.blindNumber}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Details hidden until reveal'),
            trailing: Icon(Icons.visibility_off, color: Colors.grey.shade400),
          ),
        );
      },
    );
  }
}

/// Tab for registering wines
class _RegisterWineTab extends StatelessWidget {
  final Party party;
  final PartyProvider provider;

  const _RegisterWineTab({required this.party, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.wine_bar,
            size: 64,
            color: Colors.deepPurple.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Register Your Wine',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Details will be hidden until the host reveals results',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterWineScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Wine',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Show wines registered by this attendee
          Text(
            'Your Registered Wines',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          ...provider.wines
              .where((w) => w.registeredBy == provider.currentJudge?.id)
              .map((wine) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          '${wine.blindNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade900,
                          ),
                        ),
                      ),
                      title: Text(wine.name),
                      subtitle: Text(
                        [
                          if (wine.winery != null) wine.winery,
                          if (wine.vintage != null) wine.vintage,
                        ].where((e) => e != null).join(' • '),
                      ),
                    ),
                  ))
              .toList(),

          if (provider.wines
              .where((w) => w.registeredBy == provider.currentJudge?.id)
              .isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'You haven\'t registered any wines yet',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

/// Tab for rating wines
class _RateWinesTab extends StatelessWidget {
  final List<Wine> wines;
  final Party party;
  final PartyProvider provider;

  const _RateWinesTab({
    required this.wines,
    required this.party,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (wines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wine_bar_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No wines to rate',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Count how many wines have been rated
    final ratedCount = wines.where((w) {
      final score = provider.getScoreForWine(w.id);
      return score != null;
    }).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.assessment,
                    color: Colors.deepPurple.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress: $ratedCount / ${wines.length} wines rated',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: wines.isEmpty ? 0 : ratedCount / wines.length,
                          backgroundColor: Colors.deepPurple.shade100,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.deepPurple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: wines.length,
            itemBuilder: (context, index) {
              final wine = wines[index];
              final score = provider.getScoreForWine(wine.id);
              final hasRated = score != null;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: hasRated
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    child: Text(
                      '${wine.blindNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: hasRated
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  title: Text(
                    'Wine #${wine.blindNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: hasRated
                      ? Text('Your rating: ${score.rating}')
                      : const Text('Tap to rate'),
                  trailing: hasRated
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RateWineScreen(wine: wine),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (ratedCount == wines.length && wines.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: provider.currentJudge?.hasSubmittedScores == true
                    ? null
                    : () => _confirmSubmit(context, provider),
                icon: Icon(
                  provider.currentJudge?.hasSubmittedScores == true
                      ? Icons.check_circle
                      : Icons.send,
                ),
                label: Text(
                  provider.currentJudge?.hasSubmittedScores == true
                      ? 'Scores Submitted!'
                      : 'Submit All Scores',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _confirmSubmit(BuildContext context, PartyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit All Scores?'),
        content: const Text(
          'Your scores will be finalized. You can still update them until the host locks scoring.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Review'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.submitAllScores();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scores submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

/// Tab showing your submitted scores (read-only)
class _YourScoresTab extends StatelessWidget {
  final List<Wine> wines;
  final PartyProvider provider;
  final Party party;

  const _YourScoresTab({
    required this.wines,
    required this.provider,
    required this.party,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wines.length,
      itemBuilder: (context, index) {
        final wine = wines[index];
        final score = provider.getScoreForWine(wine.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: score != null
                  ? Colors.green.shade100
                  : Colors.grey.shade200,
              child: Text(
                '${wine.blindNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: score != null
                      ? Colors.green.shade700
                      : Colors.grey.shade700,
                ),
              ),
            ),
            title: Text(
              party.resultsRevealed ? wine.name : 'Wine #${wine.blindNumber}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: score != null
                ? Text('Your rating: ${score.rating}')
                : const Text('Not rated'),
            trailing: score != null
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.remove_circle_outline, color: Colors.grey),
          ),
        );
      },
    );
  }
}

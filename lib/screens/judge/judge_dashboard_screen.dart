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
        final judge = provider.currentJudge;

        if (party == null || judge == null) {
          return Scaffold(
            body: Center(child: Text('Session expired')),
          );
        }

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
                  Tab(icon: Icon(Icons.rate_review), text: 'Rate Wines'),
                  Tab(icon: Icon(Icons.add_circle), text: 'Register Wine'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _RateWinesTab(
                  wines: provider.wines,
                  party: party,
                  provider: provider,
                ),
                _RegisterWineTab(),
              ],
            ),
          ),
        );
      },
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
              'No wines registered yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Register a wine using the tab above',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    if (!party.isActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Voting is closed',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The host has closed voting for this party',
              style: TextStyle(color: Colors.grey.shade500),
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
          'Your scores will be finalized. You can still update them until the host closes voting.',
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

class _RegisterWineTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PartyProvider>(
      builder: (context, provider, _) {
        final party = provider.currentParty;
        if (party == null) return const SizedBox.shrink();

        if (!party.isActive) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Registration closed',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

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

              // Show wines registered by this judge
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
      },
    );
  }
}

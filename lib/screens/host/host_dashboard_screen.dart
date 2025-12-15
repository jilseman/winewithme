import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/party_provider.dart';
import '../../models/models.dart';

class HostDashboardScreen extends StatelessWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartyProvider>(
      builder: (context, provider, child) {
        final party = provider.currentParty;
        if (party == null) {
          return Scaffold(
            body: Center(child: Text('No party selected')),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(party.name),
              backgroundColor: Colors.deepPurple.shade900,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(
                    party.isActive ? Icons.lock_open : Icons.lock,
                  ),
                  onPressed: () => _togglePartyStatus(context, provider),
                  tooltip: party.isActive ? 'Close Voting' : 'Open Voting',
                ),
              ],
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.amber,
                tabs: [
                  Tab(icon: Icon(Icons.info_outline), text: 'Info'),
                  Tab(icon: Icon(Icons.wine_bar), text: 'Wines'),
                  Tab(icon: Icon(Icons.leaderboard), text: 'Rankings'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _PartyInfoTab(party: party),
                _WinesTab(wines: provider.wines, party: party),
                _RankingsTab(
                  rankings: provider.getRankings(),
                  party: party,
                  scores: provider.scores,
                  onReveal: () => provider.revealResults(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _togglePartyStatus(BuildContext context, PartyProvider provider) {
    final isActive = provider.currentParty?.isActive ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActive ? 'Close Voting?' : 'Open Voting?'),
        content: Text(
          isActive
              ? 'Judges will no longer be able to submit scores.'
              : 'Judges will be able to submit scores again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.togglePartyActive();
              Navigator.pop(context);
            },
            child: Text(isActive ? 'Close' : 'Open'),
          ),
        ],
      ),
    );
  }
}

class _PartyInfoTab extends StatelessWidget {
  final Party party;

  const _PartyInfoTab({required this.party});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Party Code',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        party.partyCode,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: Colors.deepPurple.shade900,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: party.partyCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Code copied to clipboard!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share this code with your guests',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.person,
                    label: 'Host',
                    value: party.hostName,
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.event,
                    label: 'Created',
                    value: _formatDate(party.createdAt),
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: party.isActive ? Icons.check_circle : Icons.cancel,
                    label: 'Status',
                    value: party.isActive ? 'Voting Open' : 'Voting Closed',
                    valueColor:
                        party.isActive ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Consumer<PartyProvider>(
            builder: (context, provider, _) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.wine_bar,
                              label: 'Wines',
                              value: '${provider.wines.length}',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people,
                              label: 'Judges',
                              value: '${provider.judges.length}',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.rate_review,
                              label: 'Scores',
                              value: '${provider.scores.length}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.deepPurple.shade700),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WinesTab extends StatelessWidget {
  final List<Wine> wines;
  final Party party;

  const _WinesTab({required this.wines, required this.party});

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
              'Judges can register wines when they join',
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
              party.resultsRevealed ? wine.name : 'Wine #${wine.blindNumber}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: party.resultsRevealed
                ? Text(
                    [
                      if (wine.winery != null) wine.winery,
                      if (wine.vintage != null) wine.vintage,
                      if (wine.varietal != null) wine.varietal,
                    ].where((e) => e != null).join(' • '),
                  )
                : const Text('Details hidden until reveal'),
            trailing: party.resultsRevealed
                ? null
                : Icon(Icons.visibility_off, color: Colors.grey.shade400),
          ),
        );
      },
    );
  }
}

class _RankingsTab extends StatelessWidget {
  final List<WineRanking> rankings;
  final Party party;
  final List<Score> scores;
  final VoidCallback onReveal;

  const _RankingsTab({
    required this.rankings,
    required this.party,
    required this.scores,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    if (rankings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No scores yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (!party.resultsRevealed)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _confirmReveal(context),
              icon: const Icon(Icons.visibility),
              label: const Text('Reveal Wine Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rankings.length,
            itemBuilder: (context, index) {
              final ranking = rankings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: _buildRankBadge(ranking.rank),
                  title: Text(
                    party.resultsRevealed
                        ? ranking.wine.name
                        : 'Wine #${ranking.wine.blindNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Avg: ${ranking.formattedAverage} • ${ranking.numberOfRatings} ratings',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (party.resultsRevealed) ...[
                            if (ranking.wine.winery != null)
                              Text('Winery: ${ranking.wine.winery}'),
                            if (ranking.wine.vintage != null)
                              Text('Vintage: ${ranking.wine.vintage}'),
                            if (ranking.wine.varietal != null)
                              Text('Varietal: ${ranking.wine.varietal}'),
                            if (ranking.wine.region != null)
                              Text('Region: ${ranking.wine.region}'),
                            const Divider(),
                          ],
                          Text(
                            'Score Details',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Highest: ${ranking.highestScore}'),
                          Text('Lowest: ${ranking.lowestScore}'),
                          Text('Total: ${ranking.totalScore.toStringAsFixed(1)}'),
                          const SizedBox(height: 16),
                          Text(
                            'Individual Scores',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...scores
                              .where((s) => s.wineId == ranking.wine.id)
                              .map((score) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Text(score.judgeName),
                                        const Spacer(),
                                        Text(
                                          '${score.rating}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (score.notes != null &&
                                            score.notes!.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Tooltip(
                                            message: score.notes!,
                                            child: Icon(
                                              Icons.note,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
      backgroundColor: color,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: 20)
          : Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade900,
              ),
            ),
    );
  }

  void _confirmReveal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reveal Wine Details?'),
        content: const Text(
          'This will show all wine names and details to everyone. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onReveal();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
            ),
            child: const Text('Reveal'),
          ),
        ],
      ),
    );
  }
}

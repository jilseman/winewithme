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
                _buildStatusActions(context, party, provider),
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
                _PartyInfoTab(party: party, provider: provider),
                _WinesTab(
                  wines: provider.wines,
                  party: party,
                  judges: provider.judges,
                  provider: provider,
                ),
                _RankingsTab(
                  rankings: provider.getRankings(),
                  party: party,
                  scores: provider.scores,
                  provider: provider,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusActions(BuildContext context, Party party, PartyProvider provider) {
    IconData icon;
    String tooltip;
    VoidCallback onPressed;

    switch (party.status) {
      case PartyStatus.registering:
        icon = Icons.play_arrow;
        tooltip = 'Start the Party';
        onPressed = () => _confirmStartParty(context, provider);
        break;
      case PartyStatus.active:
        icon = Icons.lock;
        tooltip = 'Lock Scoring';
        onPressed = () => _confirmLockParty(context, provider);
        break;
      case PartyStatus.locked:
        icon = Icons.lock_open;
        tooltip = 'Unlock Scoring';
        onPressed = () => provider.unlockParty();
        break;
    }

    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  void _confirmStartParty(BuildContext context, PartyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start the Party?'),
        content: const Text(
          'This will close wine registration and enable scoring. Attendees will be able to rate wines.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.startParty();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Start Party'),
          ),
        ],
      ),
    );
  }

  void _confirmLockParty(BuildContext context, PartyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lock Scoring?'),
        content: const Text(
          'Attendees will no longer be able to submit or change scores.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.lockParty();
              Navigator.pop(context);
            },
            child: const Text('Lock'),
          ),
        ],
      ),
    );
  }
}

class _PartyInfoTab extends StatelessWidget {
  final Party party;
  final PartyProvider provider;

  const _PartyInfoTab({required this.party, required this.provider});

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

          // Status action card
          _buildStatusCard(context),

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
                    icon: _getStatusIcon(party.status),
                    label: 'Status',
                    value: _getStatusText(party.status),
                    valueColor: _getStatusColor(party.status),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
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
                          label: 'Attendees',
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    switch (party.status) {
      case PartyStatus.registering:
        return Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.blue.shade700),
                const SizedBox(height: 12),
                Text(
                  'Registration Open',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Attendees can join and register their wines. When everyone is ready, start the party to begin scoring.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue.shade700),
                ),
                const SizedBox(height: 16),
                if (provider.wines.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmStart(context),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start the Party'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      case PartyStatus.active:
        return Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.how_to_vote, size: 48, color: Colors.green.shade700),
                const SizedBox(height: 12),
                Text(
                  'Scoring in Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Attendees are rating wines. Lock scoring when everyone is done.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ],
            ),
          ),
        );
      case PartyStatus.locked:
        return Card(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.lock, size: 48, color: Colors.grey.shade700),
                const SizedBox(height: 12),
                Text(
                  'Scoring Locked',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scoring is complete. View rankings to see the results!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        );
    }
  }

  void _confirmStart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start the Party?'),
        content: const Text(
          'This will close wine registration and enable scoring. Attendees will be able to rate wines.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.startParty();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Start Party'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(PartyStatus status) {
    switch (status) {
      case PartyStatus.registering:
        return Icons.edit;
      case PartyStatus.active:
        return Icons.play_circle;
      case PartyStatus.locked:
        return Icons.lock;
    }
  }

  String _getStatusText(PartyStatus status) {
    switch (status) {
      case PartyStatus.registering:
        return 'Registration Open';
      case PartyStatus.active:
        return 'Scoring Active';
      case PartyStatus.locked:
        return 'Scoring Locked';
    }
  }

  Color _getStatusColor(PartyStatus status) {
    switch (status) {
      case PartyStatus.registering:
        return Colors.blue;
      case PartyStatus.active:
        return Colors.green;
      case PartyStatus.locked:
        return Colors.grey;
    }
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
  final List<Judge> judges;
  final PartyProvider provider;

  const _WinesTab({
    required this.wines,
    required this.party,
    required this.judges,
    required this.provider,
  });

  String _getSubmitterName(String registeredById) {
    try {
      final judge = judges.firstWhere((j) => j.id == registeredById);
      return judge.name;
    } catch (e) {
      return 'Unknown';
    }
  }

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
              'Attendees can register wines when they join',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // During registration, host can see details and reorder
    if (party.isRegistering) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator, color: Colors.amber.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Drag wines to reorder before starting the party',
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: wines.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final reorderedWines = List<Wine>.from(wines);
                final wine = reorderedWines.removeAt(oldIndex);
                reorderedWines.insert(newIndex, wine);
                provider.reorderWines(reorderedWines);
              },
              itemBuilder: (context, index) {
                final wine = wines[index];
                final submitterName = _getSubmitterName(wine.registeredBy);
                return Card(
                  key: ValueKey(wine.id),
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
                      wine.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (wine.winery != null || wine.vintage != null || wine.varietal != null)
                          Text(
                            [
                              if (wine.winery != null) wine.winery,
                              if (wine.vintage != null) wine.vintage,
                              if (wine.varietal != null) wine.varietal,
                            ].where((e) => e != null).join(' • '),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        Text(
                          'Submitted by: $submitterName',
                          style: TextStyle(
                            color: Colors.deepPurple.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: Icon(Icons.drag_handle, color: Colors.grey),
                    ),
                    isThreeLine: wine.winery != null || wine.vintage != null || wine.varietal != null,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // After party starts, show blind view (or revealed if results shown)
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
  final PartyProvider provider;

  const _RankingsTab({
    required this.rankings,
    required this.party,
    required this.scores,
    required this.provider,
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
        // Show review mode banner when locked
        if (party.isLocked && !party.resultsRevealed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_note, size: 18, color: Colors.orange.shade800),
                const SizedBox(width: 8),
                Text(
                  'Review Mode: Tap scores to edit if needed',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        // End Party button when locked
        if (party.isLocked && !party.resultsRevealed)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _confirmEndParty(context),
                icon: const Icon(Icons.celebration),
                label: const Text('End Party & Reveal Results'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  foregroundColor: Colors.white,
                ),
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
                          Row(
                            children: [
                              Text(
                                'Individual Scores',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (party.isLocked && !party.resultsRevealed) ...[
                                const Spacer(),
                                Text(
                                  'Tap to edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...scores
                              .where((s) => s.wineId == ranking.wine.id)
                              .map((score) => _buildScoreRow(context, score))
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

  Widget _buildScoreRow(BuildContext context, Score score) {
    final canEdit = party.isLocked && !party.resultsRevealed;

    return InkWell(
      onTap: canEdit ? () => _showEditScoreDialog(context, score) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
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
            if (score.notes != null && score.notes!.isNotEmpty) ...[
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
            if (canEdit) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.edit,
                size: 16,
                color: Colors.orange.shade700,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditScoreDialog(BuildContext context, Score score) {
    double newRating = score.rating;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Score'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${score.judgeName}\'s rating'),
              const SizedBox(height: 16),
              Text(
                '${newRating.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade900,
                ),
              ),
              Slider(
                value: newRating,
                min: 0,
                max: 10,
                divisions: 20,
                onChanged: (value) {
                  setState(() => newRating = value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0'),
                  Text('10'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.updateScoreAsHost(score.id, newRating);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
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

  void _confirmEndParty(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Party & Reveal Results?'),
        content: const Text(
          'This will reveal all wine names, details, and final rankings to everyone. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.revealResults();
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

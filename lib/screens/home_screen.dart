import 'package:flutter/material.dart';
import 'host/create_party_screen.dart';
import 'host/host_dashboard_screen.dart';
import 'judge/join_party_screen.dart';
import 'package:provider/provider.dart';
import '../providers/party_provider.dart';
import '../models/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title
                  Icon(
                    Icons.wine_bar,
                    size: 80,
                    color: Colors.amber.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wine With Me',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Blind Wine Tasting Made Easy',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Host Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () => _showHostOptions(context),
                      icon: const Icon(Icons.celebration, size: 28),
                      label: const Text(
                        'Host a Party',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Attend Party Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinPartyScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.group, size: 28),
                      label: const Text(
                        'Attend a Party',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHostOptions(BuildContext context) {
    final provider = context.read<PartyProvider>();
    final hasParties = provider.parties.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Icon(Icons.add, color: Colors.deepPurple.shade900),
              ),
              title: const Text('Create New Party'),
              subtitle: const Text('Start a new wine tasting event'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePartyScreen(),
                  ),
                );
              },
            ),
            if (hasParties) ...[
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber.shade100,
                  child: Icon(Icons.history, color: Colors.amber.shade900),
                ),
                title: const Text('My Parties'),
                subtitle: const Text('View or manage existing parties'),
                onTap: () {
                  Navigator.pop(context);
                  _showPartyList(context);
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPartyList(BuildContext context) {
    final provider = context.read<PartyProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'My Parties',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: provider.parties.length,
                  itemBuilder: (context, index) {
                    final party = provider.parties[index];
                    Color statusColor;
                    String statusText;
                    switch (party.status) {
                      case PartyStatus.registering:
                        statusColor = Colors.blue;
                        statusText = 'Registering';
                        break;
                      case PartyStatus.active:
                        statusColor = Colors.green;
                        statusText = 'Scoring';
                        break;
                      case PartyStatus.locked:
                        statusColor = Colors.grey;
                        statusText = 'Locked';
                        break;
                    }
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.2),
                        child: Icon(
                          Icons.wine_bar,
                          color: statusColor,
                        ),
                      ),
                      title: Text(party.name),
                      subtitle: Text('${party.partyCode} • $statusText'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () async {
                        Navigator.pop(context);
                        await provider.loadParty(party.id);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HostDashboardScreen(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

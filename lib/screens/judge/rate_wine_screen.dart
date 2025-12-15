import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/party_provider.dart';
import '../../models/models.dart';

class RateWineScreen extends StatefulWidget {
  final Wine wine;

  const RateWineScreen({super.key, required this.wine});

  @override
  State<RateWineScreen> createState() => _RateWineScreenState();
}

class _RateWineScreenState extends State<RateWineScreen> {
  double _rating = 5.0;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load existing score if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PartyProvider>();
      final existingScore = provider.getScoreForWine(widget.wine.id);
      if (existingScore != null) {
        setState(() {
          _rating = existingScore.rating;
          _notesController.text = existingScore.notes ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveRating() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<PartyProvider>();
      await provider.submitScore(
        widget.wine.id,
        _rating,
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rating saved for Wine #${widget.wine.blindNumber}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wine #${widget.wine.blindNumber}'),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wine number display
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade900,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.wine_bar,
                    size: 48,
                    color: Colors.amber.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Wine #${widget.wine.blindNumber}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Rating section
            Text(
              'Your Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade900,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    _rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: _getRatingColor(_rating),
                    ),
                  ),
                  Text(
                    _getRatingLabel(_rating),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _getRatingColor(_rating),
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: _getRatingColor(_rating),
                      overlayColor: _getRatingColor(_rating).withOpacity(0.2),
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: _rating,
                      min: 0,
                      max: 10,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() => _rating = value);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0', style: TextStyle(color: Colors.grey.shade600)),
                      Text('10', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick rating buttons
            Text(
              'Quick Rate',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [0, 2, 4, 5, 6, 7, 8, 9, 10]
                  .map((rating) => _QuickRateButton(
                        rating: rating.toDouble(),
                        isSelected: _rating == rating.toDouble(),
                        onTap: () => setState(() => _rating = rating.toDouble()),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Notes section
            Text(
              'Tasting Notes (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade900,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Add your tasting notes here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Rating',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating < 4) return Colors.red;
    if (rating < 6) return Colors.orange;
    if (rating < 8) return Colors.amber.shade700;
    return Colors.green;
  }

  String _getRatingLabel(double rating) {
    if (rating < 2) return 'Poor';
    if (rating < 4) return 'Below Average';
    if (rating < 6) return 'Average';
    if (rating < 7) return 'Good';
    if (rating < 8) return 'Very Good';
    if (rating < 9) return 'Excellent';
    return 'Outstanding';
  }
}

class _QuickRateButton extends StatelessWidget {
  final double rating;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickRateButton({
    required this.rating,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.deepPurple.shade900 : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            rating.toInt().toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

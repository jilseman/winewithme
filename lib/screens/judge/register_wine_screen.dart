import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/party_provider.dart';

class RegisterWineScreen extends StatefulWidget {
  const RegisterWineScreen({super.key});

  @override
  State<RegisterWineScreen> createState() => _RegisterWineScreenState();
}

class _RegisterWineScreenState extends State<RegisterWineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _wineryController = TextEditingController();
  final _vintageController = TextEditingController();
  final _varietalController = TextEditingController();
  final _regionController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _wineryController.dispose();
    _vintageController.dispose();
    _varietalController.dispose();
    _regionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _registerWine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<PartyProvider>();
      await provider.registerWine(
        name: _nameController.text.trim(),
        winery: _wineryController.text.trim().isEmpty
            ? null
            : _wineryController.text.trim(),
        vintage: _vintageController.text.trim().isEmpty
            ? null
            : _vintageController.text.trim(),
        varietal: _varietalController.text.trim().isEmpty
            ? null
            : _varietalController.text.trim(),
        region: _regionController.text.trim().isEmpty
            ? null
            : _regionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wine registered successfully!'),
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
        title: const Text('Register Wine'),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Wine Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'These details will remain hidden until the host reveals results',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Wine Name *',
                  hintText: 'e.g., Chateau Margaux',
                  prefixIcon: const Icon(Icons.wine_bar),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the wine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wineryController,
                decoration: InputDecoration(
                  labelText: 'Winery',
                  hintText: 'e.g., Robert Mondavi',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _vintageController,
                      decoration: InputDecoration(
                        labelText: 'Vintage',
                        hintText: 'e.g., 2019',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _varietalController,
                      decoration: InputDecoration(
                        labelText: 'Varietal',
                        hintText: 'e.g., Cabernet',
                        prefixIcon: const Icon(Icons.local_florist),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: InputDecoration(
                  labelText: 'Region',
                  hintText: 'e.g., Napa Valley, California',
                  prefixIcon: const Icon(Icons.place),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any additional notes about this wine...',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerWine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade900,
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
                          'Register Wine',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/17/2026
*
*----------------------------------------------------------------------------*/


import 'package:flutter/material.dart';
import 'package:scores/data/extensions/color_extensions.dart';
import 'package:scores/data/extensions/icon_extensions.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/round_label.dart';
import 'package:scores/data/repositories/round_label_repository.dart';

class RoundLabelScreen extends StatefulWidget {
  final RoundLabelRepository roundLabelRepository;

  const RoundLabelScreen({super.key, 
          required this.roundLabelRepository});

  @override
  State<RoundLabelScreen> createState() => _RoundLabelScreenState();
}

//--------------------------------------------------------------

class _RoundLabelScreenState extends State<RoundLabelScreen> {
  List<RoundLabel> _roundLabels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoundLabels();
  }

//--------------------------------------------------------------
  
  Future<void> _loadRoundLabels() async {
    setState(() => _isLoading = true);
    final roundLabels = await widget.roundLabelRepository.getAll();
    setState(() {
      _roundLabels = roundLabels;
      _isLoading = false;
    });
  }

//--------------------------------------------------------------

  void _showRoundLabelDialog({RoundLabel? roundLabel}) {
    showDialog(
      context: context,
      builder: (context) => RoundLabelFormDialog(
        roundLabel: roundLabel,
        onSave: (newRoundLabel) async {
          if (roundLabel == null) {
            await widget.roundLabelRepository.create(newRoundLabel);
          } else {
            await widget.roundLabelRepository.update(newRoundLabel);
          }
          _loadRoundLabels();
        },
      ),
    );
  }

//--------------------------------------------------------------

  Future<void> _deleteRoundLabel(RoundLabel roundLabel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Round Label'),
        content: Text('Are you sure you want to delete "${roundLabel.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && roundLabel.id != null) {
      await widget.roundLabelRepository.delete(roundLabel.id!);
      _loadRoundLabels();
    }
  }

//--------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Round Labels'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _roundLabels.isEmpty
              ? const Center(child: Text('No round labels yet. Add one!'))
              : ListView.builder(
                  itemCount: _roundLabels.length,
                  itemBuilder: (context, index) {
                    final roundLabel = _roundLabels[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: roundLabel.color.toColor(),
                        child: Icon(
                          roundLabel.icon.toIcon(),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(roundLabel.name),
                      subtitle: roundLabel.description != null
                          ? Text(roundLabel.description!)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showRoundLabelDialog(roundLabel: roundLabel),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRoundLabel(roundLabel),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoundLabelDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

//--------------------------------------------------------------

class RoundLabelFormDialog extends StatefulWidget {
  final RoundLabel? roundLabel;
  final Function(RoundLabel) onSave;

  const RoundLabelFormDialog({
    super.key,
    this.roundLabel,
    required this.onSave,
  });

  @override
  State<RoundLabelFormDialog> createState() => _RoundLabelFormDialogState();
}

//--------------------------------------------------------------

class _RoundLabelFormDialogState extends State<RoundLabelFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.roundLabel?.name ?? '');
    _descriptionController = TextEditingController(text: widget.roundLabel?.description ?? '');
    _selectedColor = widget.roundLabel?.color.toColor() ?? Colors.blue;
    _selectedIcon = widget.roundLabel?.icon.toIcon() ?? Icons.sports_golf;
  }

//--------------------------------------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

//--------------------------------------------------------------

  void _save() {
    if (_formKey.currentState!.validate()) {
      final roundLabel = RoundLabel(
        id: widget.roundLabel?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        color: _selectedColor.toInt(),
        icon: _selectedIcon.toInt(),
      );
      widget.onSave(roundLabel);
      Navigator.pop(context);
    }
  }

//--------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.roundLabel == null ? 'Add Round Label' : 'Edit Round Label'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Color: '),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showColorPicker(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Text('Icon: '),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showIconPicker(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_selectedIcon, size: 32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

//--------------------------------------------------------------

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Colors.red,
              Colors.pink,
              Colors.purple,
              Colors.deepPurple,
              Colors.indigo,
              Colors.blue,
              Colors.lightBlue,
              Colors.cyan,
              Colors.teal,
              Colors.green,
              Colors.lightGreen,
              Colors.lime,
              Colors.yellow,
              Colors.amber,
              Colors.orange,
              Colors.deepOrange,
              Colors.brown,
              Colors.grey,
              Colors.blueGrey,
            ].map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: color == _selectedColor ? Colors.black : Colors.grey,
                      width: color == _selectedColor ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

//--------------------------------------------------------------

  void _showIconPicker() {
    // Common golf/sports related icons
    final icons = [
      Icons.sports_golf,
      Icons.sports,
      Icons.flag,
      Icons.sports_score,
      Icons.emoji_events,
      Icons.star,
      Icons.grade,
      Icons.workspace_premium,
      Icons.timer,
      Icons.schedule,
      Icons.calendar_today,
      Icons.trending_up,
      Icons.trending_down,
      Icons.show_chart,
      Icons.sports_tennis,
      Icons.sports_baseball,
      Icons.sports_basketball,
      Icons.circle,
      Icons.label,
      Icons.bookmark,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Icon'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: icons.map((icon) {
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIcon = icon);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(
                      color: icon == _selectedIcon ? Colors.black : Colors.grey,
                      width: icon == _selectedIcon ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 32),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  //---------------------------------------------------------------------------
  
}
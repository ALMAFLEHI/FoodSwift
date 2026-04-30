import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_item_model.dart';
import 'cart_controller.dart';

class EditCartItemSheet extends ConsumerStatefulWidget {
  final CartItem initialItem;
  final int index;

  const EditCartItemSheet({
    super.key,
    required this.initialItem,
    required this.index,
  });

  @override
  ConsumerState<EditCartItemSheet> createState() => _EditCartItemSheetState();
}

class _EditCartItemSheetState extends ConsumerState<EditCartItemSheet> {
  late String _spiceLevel;
  late String _portionSize;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _spiceLevel = widget.initialItem.spiceLevel;
    _portionSize = widget.initialItem.portionSize;
    _notesController = TextEditingController(text: widget.initialItem.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateCartItem() {
    final updatedItem = CartItem(
      id: widget.initialItem.id,
      dishName: widget.initialItem.dishName,
      price: widget.initialItem.price,
      imageUrl: widget.initialItem.imageUrl,
      spiceLevel: _spiceLevel,
      portionSize: _portionSize,
      notes: _notesController.text,
      restaurantId: widget.initialItem.restaurantId,
      restaurantName: widget.initialItem.restaurantName,
      foodType: widget.initialItem.foodType,
    );

    ref.read(cartProvider.notifier).updateItem(widget.index, updatedItem);

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cart item updated.')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _spiceLevel,
              decoration: const InputDecoration(labelText: 'Spice Level'),
              items: ['Mild', 'Medium', 'Spicy']
                  .map(
                    (level) =>
                        DropdownMenuItem(value: level, child: Text(level)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _spiceLevel = value!),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _portionSize,
              decoration: const InputDecoration(labelText: 'Portion Size'),
              items: ['Small', 'Regular', 'Large']
                  .map(
                    (size) => DropdownMenuItem(value: size, child: Text(size)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _portionSize = value!),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              onPressed: _updateCartItem,
            ),
          ],
        ),
      ),
    );
  }
}

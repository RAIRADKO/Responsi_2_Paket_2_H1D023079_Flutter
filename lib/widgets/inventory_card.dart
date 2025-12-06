import 'package:flutter/material.dart';
import 'package:responsi_mobile/constants.dart';
import 'package:responsi_mobile/models/inventory_model.dart';
import 'package:responsi_mobile/screens/edit_inventory_screen.dart';
import 'package:responsi_mobile/inventory_service.dart'; // <--- TAMBAHKAN INI

class InventoryCard extends StatelessWidget {
  final Inventory inventory;
  final VoidCallback onDelete;

  const InventoryCard({
    super.key,
    required this.inventory,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    inventory.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditInventoryScreen(inventory: inventory),
                        ),
                      );
                      if (result == true) onDelete();
                    } else if (value == 'delete') {
                      await _showDeleteConfirmation(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit', style: TextStyle(color: primaryColor)),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Rp${inventory.price.toString()}', Icons.attach_money),
            _buildInfoRow('${inventory.quantity} item', Icons.inventory_2),
            _buildInfoRow(inventory.formattedEntryDate, Icons.calendar_today),
            _buildInfoRow(
              inventory.formattedExpiryDate,
              Icons.hourglass_empty,
              color: _getExpiryColor(inventory.expiryDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color ?? Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getExpiryColor(String expiryDate) {
    final expiry = DateTime.parse(expiryDate);
    final now = DateTime.now();
    final daysLeft = expiry.difference(now).inDays;
    
    if (daysLeft < 0) return Colors.red; // Sudah expired
    if (daysLeft <= 3) return Colors.orange; // Hampir expired
    return Colors.grey; // Normal
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus', style: TextStyle(color: primaryColor)),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await InventoryService.deleteInventory(inventory.id);
                onDelete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil dihapus!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e')),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
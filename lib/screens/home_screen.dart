import 'package:flutter/material.dart';
import 'package:responsi_mobile/constants.dart';
import 'package:responsi_mobile/inventory_service.dart';
import 'package:responsi_mobile/models/inventory_model.dart';
import 'package:responsi_mobile/widgets/inventory_card.dart';
import 'package:responsi_mobile/auth_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Inventory> _inventories = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadInventories();
  }

  Future<void> _loadInventories() async {
    try {
      final inventories = await InventoryService.getInventories();
      setState(() {
        _inventories = inventories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadInventories();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout', style: TextStyle(color: primaryColor)),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AuthService.logout();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
          Fluttertoast.showToast(
            msg: 'Berhasil logout',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: 'Gagal logout: ${e.toString()}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaris Bahan Abimart'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/add_inventory'),
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCircle(
                color: primaryColor,
                size: 50.0,
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: _inventories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inventory_2, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'Belum ada data inventaris',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: _inventories.length,
                      itemBuilder: (context, index) {
                        return InventoryCard(
                          inventory: _inventories[index],
                          onDelete: _loadInventories,
                        );
                      },
                    ),
            ),
    );
  }
}
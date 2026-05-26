import 'package:flutter/material.dart';

import '../../../../models/facility.dart';
import '../providers/facility_provider.dart';
import '../widgets/facility_card.dart';
import '../../shared/widgets/manager_info_row.dart';

class ManagerFacilityView extends StatefulWidget {
  const ManagerFacilityView({super.key});

  @override
  State<ManagerFacilityView> createState() => _ManagerFacilityViewState();
}

class _ManagerFacilityViewState extends State<ManagerFacilityView> {
  final _provider = FacilityProvider();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _provider.fetchFacilities();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _openForm({Facility? facility}) {
    final nameController =
    TextEditingController(text: facility?.name ?? '');
    final addressController =
    TextEditingController(text: facility?.address ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A237E),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.business, color: Colors.amber),
                  const SizedBox(width: 10),
                  Text(
                    facility == null ? 'Thêm cơ sở' : 'Sửa cơ sở',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white24),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tên cơ sở',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    label: const Text('Hủy',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber),
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final address = addressController.text.trim();
                      if (name.isEmpty || address.isEmpty) return;
                      await _provider.saveFacility({
                        'uuid': facility?.uuid,
                        'name': name,
                        'address': address,
                      });
                      if (mounted) Navigator.pop(context);
                      _provider.fetchFacilities(isRefresh: true);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(Facility f) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A237E),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.business, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f.name ?? '',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white24),
              ManagerInfoRow(icon: Icons.home_work, title: 'Cơ sở', value: f.name ?? ''),
              ManagerInfoRow(icon: Icons.location_on, title: 'Địa chỉ', value: f.address ?? ''),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    label: const Text('Đóng',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openForm(facility: f);
                    },
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    label: const Text('Sửa',
                        style: TextStyle(color: Colors.amber)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok = await _provider.deleteFacility(f.uuid!);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa')),
                        );
                        _provider.fetchFacilities(isRefresh: true);
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Xóa',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý cơ sở'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      backgroundColor: const Color(0xFF0F123A),
      floatingActionButton: FloatingActionButton(
        heroTag: 'facility_manager_fab',
        backgroundColor: const Color(0xFFFFD740),
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(
        children: [
          if (_provider.isLoading && _provider.isFirstLoad)
            const LinearProgressIndicator(),
          Expanded(
            child: _provider.isLoading && _provider.isFirstLoad
                ? const SizedBox()
                : _provider.facilities.isEmpty
                ? const Center(
              child: Text('Không có cơ sở nào',
                  style: TextStyle(color: Colors.white70)),
            )
                : RefreshIndicator(
              onRefresh: () =>
                  _provider.fetchFacilities(isRefresh: true),
              child: ListView.builder(
                itemCount: _provider.facilities.length,
                itemBuilder: (context, index) => FacilityCard(
                  facility: _provider.facilities[index],
                  onTap: () =>
                      _showDetail(_provider.facilities[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
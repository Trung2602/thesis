import 'package:flutter/material.dart';

import '../../../../models/food.dart';
import '../providers/food_provider.dart';
import '../widgets/food_card.dart';
import '../../shared/widgets/manager_info_row.dart';
import '../../shared/widgets/manager_pagination.dart';

class ManagerFoodView extends StatefulWidget {
  const ManagerFoodView({super.key});

  @override
  State<ManagerFoodView> createState() => _ManagerFoodViewState();
}

class _ManagerFoodViewState extends State<ManagerFoodView> {
  final _provider = FoodProvider();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _provider.fetchFoods();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
        ),
      ),
    );
  }

  void _openForm({Food? food}) {
    final nameController = TextEditingController(text: food?.name ?? '');
    final codeController =
    TextEditingController(text: food?.code?.toString() ?? '');
    final categoryController =
    TextEditingController(text: food?.category ?? '');
    final caloriesController =
    TextEditingController(text: food?.calories100g?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A237E),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.restaurant, color: Colors.amber),
                  const SizedBox(width: 10),
                  Text(
                    food == null ? 'Thêm thực phẩm' : 'Sửa thực phẩm',
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
              _buildTextField(nameController, 'Tên thực phẩm'),
              _buildTextField(codeController, 'Mã thực phẩm',
                  keyboardType: TextInputType.number),
              _buildTextField(categoryController, 'Danh mục'),
              _buildTextField(caloriesController, 'Calories / 100g',
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
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
                      final body = {
                        'uuid': food?.uuid,
                        'name': nameController.text.trim(),
                        'code':
                        int.tryParse(codeController.text.trim()) ?? 0,
                        'category': categoryController.text.trim(),
                        'calories100g': double.tryParse(
                            caloriesController.text.trim()),
                      };
                      await _provider.saveFood(body, food == null);
                      if (mounted) Navigator.pop(context);
                      _provider.fetchFoods(
                          isRefresh: true, page: _provider.currentPage);
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

  void _showDetail(Food f) {
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
                  const Icon(Icons.restaurant, color: Colors.amber),
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
              ManagerInfoRow(icon: Icons.tag, title: 'Mã', value: f.code?.toString() ?? '-'),
              ManagerInfoRow(icon: Icons.category, title: 'Danh mục', value: f.category ?? '-'),
              ManagerInfoRow(
                icon: Icons.local_fire_department,
                title: 'Calories/100g',
                value: f.calories100g != null ? '${f.calories100g} kcal' : '-',
              ),
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
                      _openForm(food: f);
                    },
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    label: const Text('Sửa',
                        style: TextStyle(color: Colors.amber)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok = await _provider.deleteFood(f.uuid!);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa thực phẩm')),
                        );
                        _provider.fetchFoods(
                            isRefresh: true, page: _provider.currentPage);
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
        title: const Text('Quản lý thực phẩm'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      backgroundColor: const Color(0xFF0F123A),
      floatingActionButton: FloatingActionButton(
        heroTag: 'food_manager_fab',
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
                : _provider.foods.isEmpty
                ? const Center(
              child: Text('Không có thực phẩm nào',
                  style: TextStyle(color: Colors.white70)),
            )
                : RefreshIndicator(
              onRefresh: () => _provider.fetchFoods(
                  isRefresh: true, page: _provider.currentPage),
              child: ListView.builder(
                itemCount: _provider.foods.length,
                itemBuilder: (context, index) => FoodCard(
                  food: _provider.foods[index],
                  onTap: () => _showDetail(_provider.foods[index]),
                ),
              ),
            ),
          ),
          if (!_provider.isFirstLoad)
            ManagerPagination(
              currentPage: _provider.currentPage,
              totalPages: _provider.totalPages,
              onPrevious: _provider.currentPage > 0
                  ? () =>
                  _provider.fetchFoods(page: _provider.currentPage - 1)
                  : null,
              onNext: _provider.currentPage < _provider.totalPages - 1
                  ? () =>
                  _provider.fetchFoods(page: _provider.currentPage + 1)
                  : null,
              onGoToPage: (page) => _provider.fetchFoods(page: page),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../../../models/Exercise.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise_card.dart';
import '../../shared/widgets/manager_info_row.dart';
import '../../shared/widgets/manager_pagination.dart';

class ManagerExerciseView extends StatefulWidget {
  const ManagerExerciseView({super.key});

  @override
  State<ManagerExerciseView> createState() => _ManagerExerciseViewState();
}

class _ManagerExerciseViewState extends State<ManagerExerciseView> {
  final _provider = ExerciseProvider();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _provider.fetchExercises();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  // ───────────────────────── HELPERS ─────────────────────────
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
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

  // ───────────────────────── FORM ─────────────────────────
  void _openForm({Exercise? exercise}) {
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final forceController = TextEditingController(text: exercise?.force ?? '');
    final difficultyController =
    TextEditingController(text: exercise?.difficulty ?? '');
    final mechanicController =
    TextEditingController(text: exercise?.mechanic ?? '');
    final equipmentController =
    TextEditingController(text: exercise?.equipment ?? '');
    final categoryController =
    TextEditingController(text: exercise?.category ?? '');
    final primaryController = TextEditingController(
        text: exercise?.primaryMuscles?.join(', ') ?? '');
    final secondaryController = TextEditingController(
        text: exercise?.secondaryMuscles?.join(', ') ?? '');

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
                  const Icon(Icons.fitness_center, color: Colors.amber),
                  const SizedBox(width: 10),
                  Text(
                    exercise == null ? 'Thêm bài tập' : 'Sửa bài tập',
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
              _buildTextField(nameController, 'Tên bài tập'),
              _buildTextField(forceController, 'Lực (push/pull/static)'),
              _buildTextField(difficultyController,
                  'Độ khó (beginner/intermediate/expert)'),
              _buildTextField(mechanicController, 'Cơ học (compound/isolation)'),
              _buildTextField(equipmentController, 'Thiết bị'),
              _buildTextField(categoryController, 'Danh mục'),
              _buildTextField(
                  primaryController, 'Cơ chính (cách nhau bằng dấu phẩy)'),
              _buildTextField(
                  secondaryController, 'Cơ phụ (cách nhau bằng dấu phẩy)'),
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
                        'uuid': exercise?.uuid,
                        'name': nameController.text.trim(),
                        'force': forceController.text.trim(),
                        'difficulty': difficultyController.text.trim(),
                        'mechanic': mechanicController.text.trim(),
                        'equipment': equipmentController.text.trim(),
                        'category': categoryController.text.trim(),
                        'primaryMuscles': primaryController.text
                            .trim()
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                        'secondaryMuscles': secondaryController.text
                            .trim()
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                      };
                      await _provider.saveExercise(body, exercise == null);
                      if (mounted) Navigator.pop(context);
                      _provider.fetchExercises(
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

  // ───────────────────────── DETAIL ─────────────────────────
  void _showDetail(Exercise e) {
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
                  const Icon(Icons.fitness_center, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.name ?? '',
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
              ManagerInfoRow(icon: Icons.bolt, title: 'Lực', value: e.force ?? '-'),
              ManagerInfoRow(icon: Icons.signal_cellular_alt, title: 'Độ khó', value: e.difficulty ?? '-'),
              ManagerInfoRow(icon: Icons.accessibility_new, title: 'Cơ học', value: e.mechanic ?? '-'),
              ManagerInfoRow(icon: Icons.sports_gymnastics, title: 'Thiết bị', value: e.equipment ?? '-'),
              ManagerInfoRow(icon: Icons.featured_play_list_sharp, title: 'Danh mục', value: e.category ?? '-'),
              ManagerInfoRow(icon: Icons.star, title: 'Cơ chính', value: e.primaryMuscles?.join(', ') ?? '-'),
              ManagerInfoRow(icon: Icons.directions_run, title: 'Cơ phụ', value: e.secondaryMuscles?.join(', ') ?? '-'),
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
                      _openForm(exercise: e);
                    },
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    label: const Text('Sửa',
                        style: TextStyle(color: Colors.amber)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok = await _provider.deleteExercise(e.uuid!);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa bài tập')),
                        );
                        _provider.fetchExercises(
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

  // ───────────────────────── BUILD ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý bài tập'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      backgroundColor: const Color(0xFF0F123A),
      floatingActionButton: FloatingActionButton(
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
                : _provider.exercises.isEmpty
                ? const Center(
              child: Text('Không có bài tập nào',
                  style: TextStyle(color: Colors.white70)),
            )
                : RefreshIndicator(
              onRefresh: () => _provider.fetchExercises(
                  isRefresh: true, page: _provider.currentPage),
              child: ListView.builder(
                itemCount: _provider.exercises.length,
                itemBuilder: (context, index) => ExerciseCard(
                  exercise: _provider.exercises[index],
                  onTap: () =>
                      _showDetail(_provider.exercises[index]),
                ),
              ),
            ),
          ),
          if (!_provider.isFirstLoad)
            ManagerPagination(
              currentPage: _provider.currentPage,
              totalPages: _provider.totalPages,
              onPrevious: _provider.currentPage > 0
                  ? () => _provider.fetchExercises(
                  page: _provider.currentPage - 1)
                  : null,
              onNext: _provider.currentPage < _provider.totalPages - 1
                  ? () => _provider.fetchExercises(
                  page: _provider.currentPage + 1)
                  : null,
            ),
        ],
      ),
    );
  }
}
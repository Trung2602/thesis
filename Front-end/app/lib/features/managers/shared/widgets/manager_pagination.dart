import 'package:flutter/material.dart';

class ManagerPagination extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final void Function(int page)? onGoToPage;

  const ManagerPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
    this.onGoToPage,
  });

  @override
  State<ManagerPagination> createState() => _ManagerPaginationState();
}

class _ManagerPaginationState extends State<ManagerPagination> {
  late TextEditingController _pageController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _pageController =
        TextEditingController(text: '${widget.currentPage + 1}');
  }

  @override
  void didUpdateWidget(ManagerPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing) {
      _pageController.text = '${widget.currentPage + 1}';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _submitPage() {
    final input = int.tryParse(_pageController.text.trim());
    if (input != null && input >= 1 && input <= widget.totalPages) {
      widget.onGoToPage?.call(input - 1);
    } else {
      _pageController.text = '${widget.currentPage + 1}';
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: widget.onPrevious,
          ),
          SizedBox(
            width: 48,
            height: 36,
            child: TextField(
              controller: _pageController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
              onTap: () {
                setState(() => _isEditing = true);
                _pageController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _pageController.text.length,
                );
              },
              onSubmitted: (_) => _submitPage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '/ ${widget.totalPages}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }
}
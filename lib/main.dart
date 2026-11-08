import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F6_231A290127', 
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0468D7)),
      ),
      home: const HomeShell(),
    );
  }
}

// ===================================================================
// MODEL
// ===================================================================
class CongViec {
  final String id;
  final String tieuDe;
  final bool xong;

  const CongViec(this.tieuDe, {required this.id, this.xong = false});

  CongViec copyWith({String? id, String? tieuDe, bool? xong}) => CongViec(
        tieuDe ?? this.tieuDe,
        id: id ?? this.id,
        xong: xong ?? this.xong,
      );
}

// ===================================================================
// KHUNG ỨNG DỤNG: Scaffold + Drawer + NavigationBar
// ===================================================================
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  bool _hienDaXong = true;
  final TextEditingController _themController = TextEditingController();

  @override
  void dispose() {
    _themController.dispose();
    super.dispose();
  }

  final List<CongViec> _ds = [
    const CongViec('Nộp bài Lab A11', id: 'cv_1'),
    const CongViec('Ôn tập SQLite', id: 'cv_2', xong: true),
    const CongViec('Họp nhóm đồ án', id: 'cv_3'),
    const CongViec('Đọc tài liệu Flutter', id: 'cv_4', xong: true),
  ];

  List<CongViec> get _hienThi =>
      _hienDaXong ? _ds : _ds.where((c) => !c.xong).toList();

  static const _tieuDeTab = ['Công việc', 'Thống kê', 'Cài đặt'];

  // ---------------- Thao tác dữ liệu ----------------

  void _doiTrangThai(CongViec cv) {
    final i = _ds.indexOf(cv);
    if (i < 0) return; // phần tử đã bị xóa khỏi danh sách
    setState(() => _ds[i] = cv.copyWith(xong: !cv.xong));
  }

  /// Xóa kèm SnackBar có nút Hoàn tác.
  void _xoa(CongViec cv) {
    final i = _ds.indexOf(cv);
    if (i < 0) return;
    setState(() => _ds.removeAt(i));

    // Gỡ SnackBar đang hiện trước khi hiện cái mới, tránh xếp hàng chồng chất
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${cv.tieuDe}"'),
          action: SnackBarAction(
            label: 'HOÀN TÁC',
            onPressed: () => setState(() => _ds.insert(i, cv)),
          ),
        ),
      );
  }

  // ---------------- Hộp thoại ----------------

  /// AlertDialog xác nhận. Trả về true nếu người dùng đồng ý.
  Future<bool> _xacNhanXoa(CongViec cv) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${cv.tieuDe}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    // showDialog trả về null khi người dùng chạm ra ngoài để đóng
    return dongY ?? false;
  }

  /// Hộp thoại nhập liệu — trả về chuỗi người dùng gõ, hoặc null nếu hủy.
  Future<void> _themCongViec() async {
    _themController.clear();
    final formKey = GlobalKey<FormState>();

    final tieuDe = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm công việc'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: _themController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tên công việc',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Không được để trống' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              // Chỉ đóng hộp thoại khi dữ liệu hợp lệ
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, _themController.text.trim());
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (tieuDe == null || !mounted) return;
    setState(() => _ds.insert(
          0,
          CongViec(tieuDe, id: DateTime.now().microsecondsSinceEpoch.toString()),
        ));
  }

  /// BottomSheet — bảng trượt lên từ cạnh dưới, hợp cho danh sách hành động.
  void _moBangHanhDong(CongViec cv) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(cv.tieuDe,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(cv.xong ? Icons.undo : Icons.check),
              title: Text(cv.xong ? 'Đánh dấu chưa xong' : 'Đánh dấu đã xong'),
              onTap: () {
                Navigator.pop(sheetContext);
                _doiTrangThai(cv);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(sheetContext);
                final dongY = await _xacNhanXoa(cv);
                if (dongY && mounted) _xoa(cv);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Giao diện ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tieuDeTab[_tab]),
        // Có Drawer thì AppBar tự thêm nút ba gạch bên trái
        actions: [
          // PopupMenuButton = menu ba chấm, tương đương options menu của Android
          PopupMenuButton<String>(
            onSelected: (chon) {
              if (chon == 'loc') {
                setState(() => _hienDaXong = !_hienDaXong);
              } else if (chon == 'xoa_xong') {
                setState(() => _ds.removeWhere((c) => c.xong));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa các việc đã xong')),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'loc',
                child: Text(_hienDaXong ? 'Ẩn việc đã xong' : 'Hiện việc đã xong'),
              ),
              const PopupMenuItem(
                value: 'xoa_xong',
                child: Text('Xóa các việc đã xong'),
              ),
            ],
          ),
        ],
      ),

      // Drawer: ngăn kéo trượt từ cạnh trái
      drawer: NavigationDrawer(
        selectedIndex: _tab,
        onDestinationSelected: (i) {
          setState(() => _tab = i);
          Navigator.pop(context); // đóng ngăn kéo sau khi chọn
        },
        children: const [
          UserAccountsDrawerHeader(
            accountName: Text('Bùi Quang Duy'),
            accountEmail: Text('231A290127@vhu.edu.vn'),
            currentAccountPicture: CircleAvatar(child: Text('D')),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.checklist),
            label: Text('Công việc'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.bar_chart),
            label: Text('Thống kê'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.settings),
            label: Text('Cài đặt'),
          ),
        ],
      ),

      // NC1: Dùng IndexedStack để mỗi tab giữ nguyên vị trí cuộn
      body: IndexedStack(
        index: _tab,
        children: [
          _tabCongViec(),
          _tabThongKe(),
          _tabCaiDat(),
        ],
      ),

      // NavigationBar: thanh điều hướng dưới (Material 3), thay cho BottomNavigationBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Việc'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),

      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _themCongViec,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _tabCongViec() {
    final ds = _hienThi;
    if (ds.isEmpty) {
      return const Center(child: Text('Không có công việc nào'));
    }
    return ListView.builder(
      itemCount: ds.length,
      itemBuilder: (context, i) {
        final cv = ds[i];
        return Dismissible(
          key: ValueKey(cv.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _xoa(cv),
          child: ListTile(
            leading: Checkbox(
              value: cv.xong,
              onChanged: (_) => _doiTrangThai(cv),
            ),
            title: Text(
              cv.tieuDe,
              style: TextStyle(
                decoration: cv.xong ? TextDecoration.lineThrough : null,
                color: cv.xong ? Colors.grey : null,
              ),
            ),
            trailing: const Icon(Icons.more_vert),
            onTap: () => _moBangHanhDong(cv),
            onLongPress: () async {
              final dongY = await _xacNhanXoa(cv);
              if (dongY && mounted) _xoa(cv);
            },
          ),
        );
      },
    );
  }

  Widget _tabThongKe() {
    final xong = _ds.where((c) => c.xong).length;
    final tong = _ds.length;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$xong / $tong', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text('công việc đã hoàn thành'),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: LinearProgressIndicator(
              value: tong == 0 ? 0 : xong / tong,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabCaiDat() {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Hiện cả việc đã xong'),
          value: _hienDaXong,
          onChanged: (v) => setState(() => _hienDaXong = v),
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep),
          title: const Text('Xóa toàn bộ danh sách'),
          onTap: () async {
            final dongY = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xóa tất cả?'),
                content: Text('Toàn bộ ${_ds.length} công việc sẽ bị xóa.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Hủy'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Xóa hết'),
                  ),
                ],
              ),
            );
            if (dongY == true && mounted) {
              setState(() => _ds.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa toàn bộ')),
              );
            }
          },
        ),
        const AboutListTile(
          icon: Icon(Icons.info_outline),
          applicationName: 'Lab F6',
          applicationVersion: '1.0',
          child: Text('Giới thiệu'),
        ),
      ],
    );
  }
}

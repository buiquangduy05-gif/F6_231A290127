# Lab F6 - Dialog, SnackBar, Menu & Khung điều hướng Flutter

- **Họ và tên:** Bùi Quang Duy
- **MSSV:** 231A290127

## Các bài nâng cao đã thực hiện

### 1. NC1: Dùng `IndexedStack` để mỗi tab giữ nguyên vị trí cuộn
- Thay thế `switch (_tab)` ở thuộc tính `body` của `Scaffold` bằng widget `IndexedStack(index: _tab, children: [_tabCongViec(), _tabThongKe(), _tabCaiDat()])`.
- Giúp giữ nguyên trạng thái và vị trí cuộn của từng tab khi chuyển đổi qua lại trên `NavigationDrawer` và `NavigationBar`.

### 2. NC2: Thêm `Dismissible` vuốt một dòng sang trái để xóa, vẫn có Hoàn tác
- Bổ sung trường định danh duy nhất `id` cho model `CongViec` và sử dụng `ValueKey(cv.id)` ổn định cho mỗi phần tử.
- Bọc từng `ListTile` công việc trong widget `Dismissible` (`direction: DismissDirection.endToStart`) với nền đỏ và biểu tượng thùng rác.
- Khi vuốt sang trái (`onDismissed`), gọi hàm `_xoa(cv)` để xóa công việc và hiển thị `SnackBar` kèm nút **HOÀN TÁC** khôi phục lại đúng vị trí cũ.

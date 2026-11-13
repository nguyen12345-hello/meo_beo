# Meo Beo — CatAI Smart Pet Care

## Giao diện
- Luồng ứng dụng chính chỉ còn **2 màn hình**: đăng nhập/kết nối MQTT và giao diện chung.
- Giao diện chung gom tổng quan, trạng thái thiết bị, điều khiển, lịch tự động và camera vào một trang cuộn; không còn 4 tab điều hướng.
- Thiết kế mới theo phong cách pet-tech: nền sáng, xanh mint, thẻ bo góc, trạng thái động và hiệu ứng chuyển động nhẹ.
- Camera được đưa lên đầu trang chung; bỏ camera iPhone và lựa chọn nguồn camera.
- Một nút duy nhất tự mở `http://192.168.4.2/stream`; có chế độ liên tục, 1/5/10/30 phút và thời gian tùy chỉnh theo giây.
- Có thể dừng camera thủ công; bộ đếm tự dừng khi hết thời gian đã đặt.
- Giữ nguyên MQTT topics, cơ chế lưu cấu hình và lịch cho ăn/cấp nước.

## Chạy dự án
```bash
flutter pub get
flutter run
```

## Build iOS
Cần macOS với Xcode:
```bash
flutter build ios --release
```
Build IPA có thể dùng:
```bash
flutter build ipa --release
```
Mở `ios/Runner.xcworkspace` bằng Xcode để cấu hình Signing & Capabilities trước khi cài lên iPhone.

## Lưu ý MQTT
- iOS mặc định dùng MQTT TCP `1883` (TLS `8883`).
- Flutter Web dùng WebSocket, mặc định `9001`.
- Điền đúng IP máy chủ MQTT cùng mạng Wi-Fi với thiết bị.

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

<<<<<<< HEAD
## Quyền Mạng nội bộ (iOS)
iOS 14+ yêu cầu người dùng cấp quyền **Mạng nội bộ** trước khi app kết nối tới máy chủ MQTT (192.168.x.x) và camera ESP32 (192.168.4.2).
- `Info.plist` đã khai báo `NSLocalNetworkUsageDescription` và `NSBonjourServices`.
- `ios/Runner/AppDelegate.swift` kích hoạt hộp thoại xin quyền qua MethodChannel `meo_beo/local_network`.
- `lib/local_network_permission.dart` xin quyền khi mở app, trước khi kết nối MQTT và trước khi mở camera; nếu bị từ chối sẽ hiện hộp thoại có nút **Mở Cài đặt**.
- Nếu trước đó đã bấm "Không cho phép": Cài đặt > Meo Beo > bật **Mạng nội bộ**. Nếu hộp thoại không hiện, gỡ app rồi cài lại.
=======
## Quyền Mạng cục bộ (iOS)
iOS 14+ yêu cầu người dùng cấp quyền **Mạng cục bộ** trước khi app kết nối tới máy chủ MQTT (192.168.x.x) và camera ESP32 (192.168.4.2).
- `Info.plist` đã khai báo `NSLocalNetworkUsageDescription` và `NSBonjourServices`.
- `ios/Runner/AppDelegate.swift` kích hoạt hộp thoại xin quyền qua MethodChannel `meo_beo/local_network`.
- `lib/local_network_permission.dart` xin quyền khi mở app, trước khi kết nối MQTT và trước khi mở camera; nếu bị từ chối sẽ hiện hộp thoại có nút **Mở Cài đặt**.
- Nếu trước đó đã bấm "Không cho phép": Cài đặt > Meo Beo > bật **Mạng cục bộ**. Nếu hộp thoại không hiện, gỡ app rồi cài lại.
- Mục **Mạng cục bộ** chỉ xuất hiện trong Cài đặt > Meo Beo sau khi app đã thử truy cập mạng LAN lần đầu. App tự làm việc này khi mở (AppDelegate.swift). Nếu vẫn không thấy: gỡ hẳn app, khởi động lại iPhone, cài lại bản mới, mở app và bấm "Cho phép".
>>>>>>> 88e53c1 (final1)

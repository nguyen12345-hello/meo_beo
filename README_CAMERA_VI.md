# Meo Beo – giao diện camera iPhone / laptop / USB

## Điểm đã chỉnh
- Bổ sung màn hình Camera phong cách tối, có trạng thái, hiệu ứng chuyển động và khung xem video.
- Hỗ trợ camera trước/sau trên iPhone bằng quyền Camera của iOS.
- Hỗ trợ luồng camera MJPEG từ laptop hoặc webcam USB qua Wi-Fi.
- Ẩn các mã lệnh MQTT khỏi phần giao diện người dùng; phần MQTT điều khiển hiện có vẫn được giữ.
- Bố cục dùng SafeArea và cuộn dọc, phù hợp màn hình iPhone có Dynamic Island.

## 1. Cài dependencies Flutter
Mở Terminal tại thư mục dự án:
```bash
flutter pub get
```

## 2. Chạy trên iPhone
Mở `ios/Runner.xcworkspace` bằng Xcode, chọn iPhone 14 Pro Max hoặc thiết bị thật, thiết lập Signing & Capabilities rồi Run.
Lần đầu mở Camera, chọn Allow khi iOS hỏi quyền. Nếu đã từ chối: Settings > Privacy & Security > Camera > Meo Beo.

Lưu ý: cài ứng dụng lên iPhone thật cần cấu hình ký ứng dụng (Apple Development Team). Dự án không thể tự bỏ qua yêu cầu ký của Apple.

## 3. Dùng camera laptop / USB
Trên máy Windows đang cắm camera:
```bash
cd tools
py -m pip install -r requirements-camera.txt
py camera_stream_server.py
```
Terminal sẽ in địa chỉ dạng `http://192.168.1.20:8080/stream`.
- iPhone và máy tính phải kết nối cùng một mạng Wi-Fi.
- Trong app Meo Beo > Camera > Camera qua Wi-Fi, nhập địa chỉ đó rồi nhấn Kết nối.
- Nếu Windows Firewall hỏi, cho phép Python truy cập mạng Private.
- Có thể đổi camera bằng cách sửa URL thành `http://IP_MAY_TINH:8080/stream?camera=1` (hoặc 2, 3...).
- Để xem địa chỉ IP máy tính, chạy `ipconfig` và lấy IPv4 của card Wi-Fi.

Không nhập `127.0.0.1` trên iPhone: địa chỉ này trỏ về chính iPhone, không phải máy tính. Cũng không dùng `localhost` trên điện thoại.
Nếu không thấy hình, kiểm tra cùng Wi-Fi, IP máy tính, firewall và đảm bảo ứng dụng khác không chiếm camera.

## Giới hạn tích hợp
Màn hình này hiển thị camera iPhone hoặc luồng MJPEG từ máy tính. Nó chưa tự gửi khung hình sang máy chủ CatAI để chạy nhận diện AI; phần đó cần API nhận ảnh/video của máy chủ CatAI. URL RTSP/YouTube không phải luồng MJPEG và không được hỗ trợ trực tiếp ở chế độ camera mạng này.

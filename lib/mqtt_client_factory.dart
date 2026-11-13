// Tự chọn client MQTT theo nền tảng:
//  - iOS (và máy thật khác): kết nối TCP thường, cổng 1883
//  - Web: kết nối WebSocket, cổng 9001 (cần bật listener websockets trên Mosquitto)
export 'mqtt_client_factory_stub.dart'
    if (dart.library.io) 'mqtt_client_factory_io.dart'
    if (dart.library.js_interop) 'mqtt_client_factory_web.dart';

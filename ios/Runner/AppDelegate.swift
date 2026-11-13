<<<<<<< HEAD

import UIKit
import Flutter
=======
import UIKit
import Flutter
import Network

/// Kích hoạt hộp thoại xin quyền "Mạng nội bộ" (Local Network) của iOS và cho biết
/// người dùng đã cho phép hay chưa.
///
/// iOS không có API trực tiếp để hỏi trạng thái quyền này. Cách chuẩn (Apple DTS) là
/// vừa duyệt vừa đăng ký một dịch vụ Bonjour; cả hai thao tác đều cần quyền Local Network:
///  - Đăng ký dịch vụ thành công  -> đã được cho phép.
///  - NWBrowser chuyển sang .waiting -> bị từ chối.
/// Cần khai báo "_bonjour._tcp" và "_lnp._tcp" trong NSBonjourServices (Info.plist).
final class LocalNetworkAuthorization: NSObject, NetServiceDelegate {
    private var browser: NWBrowser?
    private var service: NetService?
    private var waiters: [(Bool) -> Void] = []
    private var timeout: DispatchWorkItem?

    /// Gọi trên main thread. Nhiều lần gọi đồng thời sẽ dùng chung một lần kiểm tra.
    func request(completion: @escaping (Bool) -> Void) {
        waiters.append(completion)
        if waiters.count > 1 { return }

        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        let browser = NWBrowser(for: .bonjour(type: "_bonjour._tcp", domain: nil), using: parameters)
        self.browser = browser
        browser.stateUpdateHandler = { [weak self] state in
            switch state {
            case .failed:
                self?.finish(false)
            case .waiting:
                // Người dùng đã từ chối quyền Mạng nội bộ.
                self?.finish(false)
            default:
                break
            }
        }
        browser.browseResultsChangedHandler = { _, _ in }

        let service = NetService(domain: "local.", type: "_lnp._tcp.", name: "LocalNetworkPrivacy", port: 1100)
        service.delegate = self
        self.service = service

        browser.start(queue: .main)
        service.publish()

        // Phòng trường hợp người dùng không trả lời hộp thoại: không treo vô hạn.
        let work = DispatchWorkItem { [weak self] in self?.finish(false) }
        timeout = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 120, execute: work)
    }

    private func finish(_ granted: Bool) {
        guard !waiters.isEmpty else { return }
        timeout?.cancel()
        timeout = nil
        browser?.cancel()
        browser = nil
        service?.stop()
        service = nil
        let pending = waiters
        waiters = []
        pending.forEach { $0(granted) }
    }

    func netServiceDidPublish(_ sender: NetService) {
        finish(true)
    }

    func netService(_ sender: NetService, didNotPublish errorDict: [String: NSNumber]) {
        finish(false)
    }
}
>>>>>>> d769f7474b21e8fe80c9e4bd19aa7f988fac606e

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

<<<<<<< HEAD
=======
    private let localNetwork = LocalNetworkAuthorization()
<<<<<<< HEAD
=======
    private var pokeConnections: [NWConnection] = []
    private var didPoke = false
>>>>>>> 88e53c1 (final1)

>>>>>>> d769f7474b21e8fe80c9e4bd19aa7f988fac606e
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)
<<<<<<< HEAD
=======
        registerLocalNetworkChannel()
<<<<<<< HEAD
=======

        // Khi app hiện lên màn hình, chủ động chạm vào mạng LAN một lần để iOS hiện hộp
        // thoại xin quyền và thêm mục "Mạng cục bộ" vào Cài đặt > Meo Beo.
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.pokeLocalNetwork()
        }
>>>>>>> 88e53c1 (final1)
>>>>>>> d769f7474b21e8fe80c9e4bd19aa7f988fac606e

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
<<<<<<< HEAD
=======

<<<<<<< HEAD
=======
    /// Thử kết nối tới vài địa chỉ mạng nội bộ (multicast mDNS, ESP32 192.168.4.2, router).
    /// Mọi kết nối tới địa chỉ LAN đều khiến iOS hỏi quyền Mạng cục bộ. Kết quả bỏ qua.
    private func pokeLocalNetwork() {
        if didPoke { return }
        didPoke = true

        let targets: [(String, UInt16, Bool)] = [
            ("224.0.0.251", 5353, true),
            ("192.168.4.2", 80, false),
            ("192.168.1.1", 80, false),
        ]
        for (host, port, isUDP) in targets {
            guard let p = NWEndpoint.Port(rawValue: port) else { continue }
            let conn = NWConnection(
                host: NWEndpoint.Host(host),
                port: p,
                using: isUDP ? .udp : .tcp
            )
            conn.stateUpdateHandler = { state in
                if isUDP, case .ready = state {
                    conn.send(content: Data([0]), completion: .contentProcessed { _ in })
                }
            }
            conn.start(queue: .main)
            pokeConnections.append(conn)
        }
        // Đóng các kết nối thăm dò sau vài giây.
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            self?.pokeConnections.forEach { $0.cancel() }
            self?.pokeConnections.removeAll()
        }
        // Đồng thời chạy luồng Bonjour để biết trạng thái cấp quyền.
        localNetwork.request { _ in }
    }

>>>>>>> 88e53c1 (final1)
    /// MethodChannel "meo_beo/local_network":
    ///  - request      -> Bool (true nếu đã được cấp quyền Mạng nội bộ)
    ///  - openSettings -> mở màn hình Cài đặt của ứng dụng
    private func registerLocalNetworkChannel() {
        let registrar: FlutterPluginRegistrar? = self.registrar(forPlugin: "MeoBeoLocalNetwork")
        guard let registrar = registrar else { return }

        let channel = FlutterMethodChannel(
            name: "meo_beo/local_network",
            binaryMessenger: registrar.messenger()
        )
        channel.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "request":
                guard let self = self else { result(false); return }
                self.localNetwork.request { granted in result(granted) }
            case "openSettings":
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
>>>>>>> d769f7474b21e8fe80c9e4bd19aa7f988fac606e
}

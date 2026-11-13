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

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private let localNetwork = LocalNetworkAuthorization()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)
        registerLocalNetworkChannel()

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

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
}

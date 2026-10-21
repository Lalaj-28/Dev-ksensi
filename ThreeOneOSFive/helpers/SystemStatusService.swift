import Foundation
import Combine

final class SystemStatusService: ObservableObject {
    static let shared = SystemStatusService()

    @Published var isSystemMaintenance = false
    @Published var maintenanceMessage = "Hệ thống đang tạm ngắt kết nối / bảo trì bởi Quản Trị Viên. Vui lòng quay lại sau!"

    private var heartbeatTimer: Timer?
    private let configEndpoint = "https://ewrergdf-default-rtdb.firebaseio.com/config.json"

    private init() {
        startHeartbeat()
        Task { @MainActor [weak self] in
            _ = await self?.checkSystemMaintenance()
        }
    }

    @MainActor
    func checkSystemMaintenance() async -> Bool {
        guard let url = URL(string: configEndpoint) else { return false }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 6.0

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let config = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return isSystemMaintenance
            }

            let isMaintenance = (config["is_maintenance"] as? Bool)
                ?? (config["app_killed"] as? Bool)
                ?? false

            if let message = config["maintenance_message"] as? String, !message.isEmpty {
                maintenanceMessage = message
            }

            isSystemMaintenance = isMaintenance
            return isMaintenance
        } catch {
            return isSystemMaintenance
        }
    }

    private func startHeartbeat() {
        stopHeartbeat()
        DispatchQueue.main.async { [weak self] in
            self?.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    _ = await self?.checkSystemMaintenance()
                }
            }
        }
    }

    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
}

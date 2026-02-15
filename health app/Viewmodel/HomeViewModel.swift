import Foundation
import Combine

final class HomeViewModel: ObservableObject {

    @Published var latestGlucose: BloodGlucoseModel?
    @Published var glucoseHistory: [BloodGlucoseModel] = []
    @Published var isAuthorized = false

    private let healthService = HealthKitService()


    func onAppear() {
        requestHealthPermission()
    }

    private func requestHealthPermission() {
        healthService.requestAuthorization { success in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    self.loadGlucoseData()
                }
            }
        }
    }

    private func loadGlucoseData() {
        healthService.fetchLatestGlucose { glucose in
            DispatchQueue.main.async {
                self.latestGlucose = glucose
            }
        }

        healthService.fetchGlucoseHistory { history in
            DispatchQueue.main.async {
                self.glucoseHistory = history
            }
        }
    }
}


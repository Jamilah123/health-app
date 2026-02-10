import Foundation
import Combine

final class RecordsViewModel: ObservableObject {

    @Published var records: [HealthRecord] = []

    private let healthService = HealthKitService()

    init() {
        loadRecords()
    }

    func loadRecords() {
        // سحب آخر قراءة سكر
        healthService.fetchLatestGlucose { [weak self] glucose in
            DispatchQueue.main.async {
                guard let self = self, let glucose = glucose else { return }
                self.records.append(HealthRecord(type: .glucose(value: glucose.value), date: glucose.date))
            }
        }

        // سحب تاريخ السكر
        healthService.fetchGlucoseHistory { [weak self] history in
            DispatchQueue.main.async {
                guard let self = self else { return }
                for item in history {
                    self.records.append(HealthRecord(type: .glucose(value: item.value), date: item.date))
                }
            }
        }
    }

    // لإضافة إبرة انسولين
    func addInsulin(units: Int, date: Date = Date()) {
        records.append(HealthRecord(type: .insulin(units: units), date: date))
    }
}


import Foundation
import Combine

final class RecordsStore: ObservableObject {

    static let shared = RecordsStore()

    @Published var records: [HealthRecord] = []

    private init() {}

    func addInsulin(units: Int) {
        let record = HealthRecord(
            type: .insulin(units: units),
            date: Date()
        )
        records.insert(record, at: 0)
    }

    func addGlucose(value: Double) {
        let record = HealthRecord(
            type: .glucose(value: value),
            date: Date()
        )
        records.insert(record, at: 0)
    }
}


import Foundation
import Combine

final class RecordsViewModel: ObservableObject {

    @Published var records: [HealthRecord] = []

    // إضافة جرعة إنسولين
    func addInsulin(units: Int) {
        let record = HealthRecord(type: .insulin(units: units), date: Date())
        records.append(record)
    }

    // إضافة قراءة سكر
    func addGlucose(value: Double, date: Date = Date()) {
        let record = HealthRecord(type: .glucose(value: value), date: date)
        records.append(record)
    }
}


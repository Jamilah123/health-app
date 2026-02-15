import Foundation
import Combine

final class RecordsStore: ObservableObject {

    static let shared = RecordsStore()
    private let key = "saved_health_records"

    @Published var records: [HealthRecord] = [] {
        didSet {
            save()
        }
    }

    private init() {
        load()
    }

    // MARK: - CRUD
    func addInsulin(units: Int) {
        let record = HealthRecord(
            id: UUID(),
            type: .insulin(units: units),
            date: Date()
        )
        records.insert(record, at: 0)
    }

    func addGlucose(value: Double) {
        let record = HealthRecord(
            id: UUID(),
            type: .glucose(value: value),
            date: Date()
        )
        records.insert(record, at: 0)
    }

    // MARK: - Persistence
    private func save() {
        do {
            let data = try JSONEncoder().encode(records)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Failed to save records:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            records = try JSONDecoder().decode([HealthRecord].self, from: data)
        } catch {
            print("❌ Failed to load records:", error)
        }
    }
}


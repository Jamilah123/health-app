import Foundation
import Combine

final class RecordsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var records: [HealthRecord] = []
    
    // MARK: - Private
    private var cancellables = Set<AnyCancellable>()
    private let store = RecordsStore.shared
    
    // MARK: - Init
    init() {
        bindStore()
    }
    
    // MARK: - Binding
    private func bindStore() {
        store.$records
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newRecords in
                self?.records = newRecords.sorted(by: { $0.date > $1.date })
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Functions
    
    /// إضافة جرعة إنسولين
    func addInsulin(units: Int) {
        store.addInsulin(units: units)
    }
    
    /// إضافة قراءة سكر
    func addGlucose(value: Double) {
        store.addGlucose(value: value)
    }
    
    /// حذف سجل
    func deleteRecord(_ record: HealthRecord) {
        if let index = store.records.firstIndex(of: record) {
            store.records.remove(at: index)
        }
    }
    
    /// حذف الكل (اختياري)
    func deleteAll() {
        store.records.removeAll()
    }
}



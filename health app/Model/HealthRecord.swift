import Foundation

// MARK: - نوع السجل
enum RecordType: Equatable {
    case insulin(units: Int)
    case glucose(value: Double)
}

// MARK: - نموذج السجل
struct HealthRecord: Identifiable {
    let id = UUID()
    let type: RecordType
    let date: Date
}


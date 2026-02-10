import Foundation

enum RecordType: Equatable {
    case insulin(units: Int)
    case glucose(value: Double)
}

struct HealthRecord: Identifiable, Equatable {
    let id = UUID()
    let type: RecordType
    let date: Date
}


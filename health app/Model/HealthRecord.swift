import Foundation

enum HealthRecordType: Codable, Equatable {
    case insulin(units: Int)
    case glucose(value: Double)

    enum CodingKeys: String, CodingKey {
        case insulin, glucose
    }

    enum InsulinKeys: String, CodingKey { case units }
    enum GlucoseKeys: String, CodingKey { case value }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.insulin) {
            let nested = try container.nestedContainer(keyedBy: InsulinKeys.self, forKey: .insulin)
            let units = try nested.decode(Int.self, forKey: .units)
            self = .insulin(units: units)
        } else {
            let nested = try container.nestedContainer(keyedBy: GlucoseKeys.self, forKey: .glucose)
            let value = try nested.decode(Double.self, forKey: .value)
            self = .glucose(value: value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .insulin(let units):
            var nested = container.nestedContainer(keyedBy: InsulinKeys.self, forKey: .insulin)
            try nested.encode(units, forKey: .units)

        case .glucose(let value):
            var nested = container.nestedContainer(keyedBy: GlucoseKeys.self, forKey: .glucose)
            try nested.encode(value, forKey: .value)
        }
    }
}

struct HealthRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let type: HealthRecordType
    let date: Date
}



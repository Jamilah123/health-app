import Foundation

public struct GlucoseRecord: Hashable, Codable {
    public var value: Double
    public var date: Date

    public init(value: Double, date: Date) {
        self.value = value
        self.date = date
    }
}

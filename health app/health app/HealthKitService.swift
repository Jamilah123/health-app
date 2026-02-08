import Foundation
import HealthKit

final class HealthKitService {

    private let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
            completion(false)
            return
        }

        healthStore.requestAuthorization(
            toShare: [],
            read: [glucoseType]
        ) { success, _ in
            completion(success)
        }
    }

    func fetchLatestGlucose(completion: @escaping (BloodGlucoseModel?) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
            completion(nil)
            return
        }

        let sort = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: type,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sort]
        ) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }

            // mg/dL unit for blood glucose
            let mgPerdL = HKUnit(from: "mg/dL")
            let value = sample.quantity.doubleValue(for: mgPerdL)
            completion(BloodGlucoseModel(value: value, date: sample.endDate))
        }

        healthStore.execute(query)
    }

    func fetchGlucoseHistory(limit: Int = 10,
                             completion: @escaping ([BloodGlucoseModel]) -> Void) {

        guard let type = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
            completion([])
            return
        }

        // Optional: sort newest first for consistency
        let sort = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: type,
            predicate: nil,
            limit: limit,
            sortDescriptors: [sort]
        ) { _, samples, _ in
            let quantitySamples = samples as? [HKQuantitySample] ?? []
            let mgPerdL = HKUnit(from: "mg/dL")
            let results: [BloodGlucoseModel] = quantitySamples.map { sample in
                let value = sample.quantity.doubleValue(for: mgPerdL)
                return BloodGlucoseModel(value: value, date: sample.endDate)
            }
            completion(results)
        }

        self.healthStore.execute(query)
    }
}

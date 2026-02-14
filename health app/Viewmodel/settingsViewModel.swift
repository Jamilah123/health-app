import Foundation
import HealthKit
import SwiftUI
import Combine
import UIKit

final class SettingsViewModel: ObservableObject {

    // MARK: - Nested Types
    enum SugarUnit: String, CaseIterable, Identifiable {
        case mgdl = "ملجم/دل"
        case mmol = "مليمول/لتر"

        var id: String { rawValue }
    }

    // MARK: - HealthKit
    private let healthStore = HKHealthStore()
    private let glucoseType = HKObjectType.quantityType(forIdentifier: .bloodGlucose)!

    // MARK: - Published State
    @Published var isAppleHealthConnected = false
    @Published var isLoadingHealth = false
    @Published var selectedSugarUnit: SugarUnit = .mgdl

    // MARK: - Init
    init() {
        checkAppleHealthStatus()
    }

    // MARK: - Check Status (الحالة الفعلية)
    func checkAppleHealthStatus() {
        let status = healthStore.authorizationStatus(for: glucoseType)

        DispatchQueue.main.async {
            self.isAppleHealthConnected = (status == .sharingAuthorized)
        }
    }

    // MARK: - Connect
    func connectAppleHealth() {
        guard !isLoadingHealth else { return }

        isLoadingHealth = true

        healthStore.requestAuthorization(
            toShare: [],
            read: [glucoseType]
        ) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.isLoadingHealth = false
                self?.checkAppleHealthStatus()
            }
        }
    }

    // MARK: - Export PDF
    func exportPDF() {
        fetchGlucoseData { [weak self] samples in
            guard let self = self else { return }

            let url = self.createPDF(from: samples)

            DispatchQueue.main.async {
                let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)

                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.windows.first?.rootViewController {
                    root.present(av, animated: true)
                }
            }
        }
    }

    // MARK: - Fetch Data
    private func fetchGlucoseData(completion: @escaping ([HKQuantitySample]) -> Void) {

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: glucoseType,
            predicate: nil,
            limit: 100,
            sortDescriptors: [sort]
        ) { _, samples, _ in
            completion(samples as? [HKQuantitySample] ?? [])
        }

        healthStore.execute(query)
    }

    // MARK: - Create PDF
    private func createPDF(from samples: [HKQuantitySample]) -> URL {

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("GlucoseReport.pdf")

        try? renderer.writePDF(to: url) { context in
            context.beginPage()

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]

            "Glucose Report".draw(at: CGPoint(x: 40, y: 40), withAttributes: titleAttributes)

            let unit = selectedSugarUnit == .mgdl
                ? HKUnit(from: "mg/dL")
                : HKUnit.moleUnit(with: .milli, molarMass: HKUnitMolarMassBloodGlucose)

            let values = samples.map { $0.quantity.doubleValue(for: unit) }

            let average = values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
            let maxValue = values.max() ?? 0
            let minValue = values.min() ?? 0

            var y: CGFloat = 90
            let font = UIFont.systemFont(ofSize: 14)

            "Average: \(formatValue(average))".draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: font])
            y += 20
            "Highest: \(formatValue(maxValue))".draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: font])
            y += 20
            "Lowest: \(formatValue(minValue))".draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: font])

            y += 40

            for sample in samples {

                let value = sample.quantity.doubleValue(for: unit)
                let formattedValue = formatValue(value)

                let date = DateFormatter.localizedString(
                    from: sample.startDate,
                    dateStyle: .medium,
                    timeStyle: .short
                )

                let line = "\(formattedValue)  -  \(date)"

                line.draw(at: CGPoint(x: 40, y: y), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 13)
                ])

                y += 18

                if y > 800 {
                    context.beginPage()
                    y = 40
                }
            }
        }

        return url
    }

    // MARK: - Format Value
    private func formatValue(_ value: Double) -> String {
        if selectedSugarUnit == .mgdl {
            return String(format: "%.0f mg/dL", value)
        } else {
            return String(format: "%.1f mmol/L", value)
        }
    }

    // MARK: - Open Settings
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

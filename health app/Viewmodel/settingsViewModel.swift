import Foundation
import HealthKit
import SwiftUI
import Combine

// MARK: - Model
public struct GlucoseRecord: Hashable {
    public let value: Double
    public let date: Date
}

// MARK: - ViewModel
@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Apple Health
    @Published var isAppleHealthConnected: Bool = false
    @Published var isLoadingHealth: Bool = false

    // MARK: - Preferences
    @Published var isDarkMode: Bool = false {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode") }
    }

    enum SugarUnit: String, CaseIterable {
        case mgdl = "mg/dL"
        case mmol = "mmol/L"
    }

    @Published var selectedSugarUnit: SugarUnit = .mgdl {
        didSet { UserDefaults.standard.set(selectedSugarUnit.rawValue, forKey: "sugarUnit") }
    }

    // MARK: - Data
    @Published var glucoseRecords: [GlucoseRecord] = []

    // MARK: - PDF Export
    @Published var isExportingPDF: Bool = false
    @Published var pdfURL: URL?
    @Published var showShareSheet: Bool = false

    private let healthStore = HKHealthStore()

    // MARK: - Init
    init() {
        // قراءة القيم المخزنة
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let savedUnit = UserDefaults.standard.string(forKey: "sugarUnit")
        self.selectedSugarUnit = SugarUnit(rawValue: savedUnit ?? "") ?? .mgdl

        checkAppleHealthStatus()
    }

    // MARK: - Apple Health Status
    func checkAppleHealthStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            isAppleHealthConnected = false
            return
        }

        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        let status = healthStore.authorizationStatus(for: glucoseType)
        isAppleHealthConnected = (status == .sharingAuthorized)
    }

    // MARK: - Connect Apple Health
    func connectAppleHealth() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        isLoadingHealth = true

        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        let readTypes: Set = [glucoseType]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, _ in
            DispatchQueue.main.async {
                self.isLoadingHealth = false
                self.isAppleHealthConnected = success
                if success {
                    self.fetchGlucoseRecords()
                }
            }
        }
    }

    // MARK: - Fetch Records
    func fetchGlucoseRecords() {
        guard isAppleHealthConnected else { return }

        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!

        let query = HKSampleQuery(
            sampleType: glucoseType,
            predicate: nil,
            limit: 200,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, samples, _ in
            guard let samples = samples as? [HKQuantitySample] else { return }
            DispatchQueue.main.async {
                let unit: HKUnit = (self.selectedSugarUnit == .mgdl) ? HKUnit(from: "mg/dL") : HKUnit(from: "mmol/L")
                self.glucoseRecords = samples.map { sample in
                    let value = sample.quantity.doubleValue(for: unit)
                    let date = sample.startDate
                    return GlucoseRecord(value: value, date: date)
                }
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Export PDF
    func exportPDF() {
        guard !glucoseRecords.isEmpty else { return }

        isExportingPDF = true

        let reportView = PDFReportView(records: glucoseRecords)
        let renderer = ImageRenderer(content: reportView)

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("GlucoseReport.pdf")
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)

        do {
            let data = pdfRenderer.pdfData { context in
                context.beginPage()
                if let cgImage = renderer.cgImage {
                    context.cgContext.draw(cgImage, in: pageRect)
                }
            }
            try data.write(to: url)
            self.pdfURL = url
            self.showShareSheet = true
        } catch {
            print("PDF Export Error:", error)
            self.pdfURL = nil
        }

        isExportingPDF = false
    }
}


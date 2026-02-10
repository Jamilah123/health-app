import SwiftUI
import Foundation

struct PDFReportView: View {

    let records: [GlucoseRecord]

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {

            // MARK: - Header
            VStack(alignment: .trailing, spacing: 6) {
                Text("تقرير مستوى السكر")
                    .font(.largeTitle)
                    .bold()

                Text("تاريخ الإصدار: \(dateFormatter.string(from: Date()))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("إجمالي القراءات: \(records.count)")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            Divider()

            // MARK: - Table Header
            HStack {
                Text("القيمة (ملجم/دسل)")
                    .bold()

                Spacer()

                Text("التاريخ والوقت")
                    .bold()
            }
            .font(.headline)
            .environment(\.layoutDirection, .rightToLeft)

            Divider()

            // MARK: - Records
            if records.isEmpty {
                Text("لا توجد بيانات مسجلة")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else {
                ForEach(records, id: \.self) { record in
                    HStack {
                        Text(String(format: "%.0f", record.value))
                            .monospacedDigit()

                        Spacer()

                        Text(dateTimeFormatter.string(from: record.date))
                    }
                    .font(.body)
                    .padding(.vertical, 6)
                    .environment(\.layoutDirection, .rightToLeft)

                    Divider()
                }
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: 612)          // عرض صفحة PDF (A4)
        .background(Color.white)    // مهم جدًا للـ PDF
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Formatters
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ar")
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }

    private var dateTimeFormatter: DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ar")
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }
}

#Preview {
    let sampleRecords: [GlucoseRecord] = [
        GlucoseRecord(value: 120, date: Date()),
        GlucoseRecord(value: 95, date: Date().addingTimeInterval(-3600)),
        GlucoseRecord(value: 140, date: Date().addingTimeInterval(-7200))
    ]
    return PDFReportView(records: sampleRecords)
}


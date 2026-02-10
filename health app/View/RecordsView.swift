import SwiftUI

struct RecordsView: View {
    @ObservedObject var viewModel: RecordsViewModel

    var body: some View {
        ZStack {
            // 🔹 الخلفية المميزة
            HealthBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer().frame(height: 40)
                    // 🔹 عنوان الصفحة
                    Text("السجل")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("تاريخ القراءات والجرعات")
                        .foregroundColor(.black)

                    // 🔹 تجميع السجلات حسب اليوم
                    ForEach(groupedRecords.keys.sorted(by: >), id: \.self) { day in
                        if let records = groupedRecords[day], !records.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {

                                Text(dayTitle(day))
                                    .font(.headline)

                                ForEach(records) { record in
                                    recordCard(record)
                                }

                            }
                            .padding(.top, 10)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Components
extension RecordsView {

    // 🔹 كرت لكل سجل
    private func recordCard(_ record: HealthRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                switch record.type {
                case .insulin(let units):
                    Text("جرعة إنسولين")
                        .font(.headline)
                    Text("\(units) وحدات")
                case .glucose(let value):
                    Text("قراءة سكر")
                        .font(.headline)
                    Text("\(Int(value)) mg/dL")
                }

                Text(record.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: icon(for: record))
                .foregroundColor(record.type == .insulin(units: 0) ? .blue : .red)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 3)
    }

    // 🔹 أيقونة حسب نوع السجل
    private func icon(for record: HealthRecord) -> String {
        switch record.type {
        case .insulin: return "syringe"
        case .glucose: return "drop.fill"
        }
    }

    // 🔹 تجميع السجلات حسب اليوم
    private var groupedRecords: [Date: [HealthRecord]] {
        Dictionary(grouping: viewModel.records) { Calendar.current.startOfDay(for: $0.date) }
    }

    // 🔹 عنوان اليوم: اليوم / أمس / التاريخ
    private func dayTitle(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "اليوم"
        } else if calendar.isDateInYesterday(date) {
            return "أمس"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview
#Preview {
    let vm = RecordsViewModel()
    vm.addInsulin(units: 5)
    return RecordsView(viewModel: vm)
}


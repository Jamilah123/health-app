import SwiftUI

struct RecordsView: View {
    @ObservedObject var viewModel: RecordsViewModel

    var body: some View {
        ZStack {
            HealthBackground()

            ScrollView {
                VStack(alignment: .trailing, spacing: 16) {
                    Spacer().frame(height: 40)

                    Text("السجل")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("تاريخ القراءات والجرعات")
                        .foregroundColor(.black)

                    ForEach(groupedRecords.keys.sorted(by: >), id: \.self) { day in
                        if let records = groupedRecords[day], !records.isEmpty {
                            VStack(alignment: .trailing, spacing: 12) {

                                Text(dayTitle(day))
                                    .font(.headline)

                                // 👇 هنا الترتيب الجديد
                                ForEach(sortedRecords(records)) { record in
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

    private func recordCard(_ record: HealthRecord) -> some View {
        HStack {

            VStack(alignment: .leading) {
                switch record.type {
                case .insulin(let units):
                    Text("\(units) وحدات")
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                case .glucose(let value):
                    Text("\(Int(value)) mg/dL")
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }

            Spacer()

            HStack(spacing: 10) {

                VStack(alignment: .trailing, spacing: 2) {
                    switch record.type {
                    case .insulin:
                        Text("جرعة إنسولين")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                    case .glucose:
                        Text("قراءة سكر")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    Text(record.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                if case .glucose = record.type {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title2)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "syringe")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(backgroundColor(for: record))
        .cornerRadius(20)
        .shadow(radius: 3)
    }

    private func sortedRecords(_ records: [HealthRecord]) -> [HealthRecord] {
        records.sorted { first, second in

            if case .insulin = first.type,
               case .glucose = second.type {
                return true
            }

            if case .glucose = first.type,
               case .insulin = second.type {
                return false
            }

            return first.date > second.date
        }
    }

    private func backgroundColor(for record: HealthRecord) -> Color {
        switch record.type {
        case .glucose:
            return Color("container2")
        case .insulin:
            return Color("container")
        }
    }

    private var groupedRecords: [Date: [HealthRecord]] {
        Dictionary(grouping: viewModel.records) {
            Calendar.current.startOfDay(for: $0.date)
        }
    }

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
    vm.addGlucose(value: 120)
    return RecordsView(viewModel: vm)
}


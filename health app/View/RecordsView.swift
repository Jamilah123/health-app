import SwiftUI

struct RecordsView: View {
    
    @ObservedObject var viewModel: RecordsViewModel
    
    var body: some View {
        ZStack {
            
            HealthBackground()
            
            VStack(alignment: .trailing, spacing: 16) {
                
                Spacer().frame(height: 40)
                
                Text("السجل")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // عرض الجرعات فقط
                if insulinRecords.isEmpty {
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.4))
                        
                        Text("لا توجد جرعات مسجلة")
                            .foregroundColor(.gray)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                } else {
                    
                    ScrollView {
                        VStack(spacing: 14) {
                            
                            ForEach(insulinRecords) { record in
                                insulinCard(record)
                            }
                            
                        }
                        .padding(.top, 10)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
    }
}

// MARK: - Components

extension RecordsView {
    
    // فلترة الإنسولين فقط وترتيب تنازلي
    private var insulinRecords: [HealthRecord] {
        viewModel.records
            .filter {
                if case .insulin = $0.type { return true }
                return false
            }
            .sorted { $0.date > $1.date }
    }
    
    // كرت الجرعة
    private func insulinCard(_ record: HealthRecord) -> some View {
        
        HStack {
            
            if case .insulin(let units) = record.type {
                Text("\(units) وحدات")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text(record.date.formatted(date: .omitted, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// MARK: - Preview

#Preview {
    let vm = RecordsViewModel()
    vm.addInsulin(units: 6)
    return RecordsView(viewModel: vm)
}

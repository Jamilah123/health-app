import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var glucose: GlucoseModel
    @Published var insulin: InsulinModel
    
    init() {
        // بيانات تجريبية
        self.glucose = GlucoseModel(
            level: 210,
            unit: "ملغ/دل",
            status: "مرتفع",
            lastUpdated: "آخر تحديث قبل 10 دقائق"
        )
        
        self.insulin = InsulinModel(
            lastDose: 7,
            lastTime: "الآن"
        )
    }
    
    func addNewInsulinDose() {
        // منطق تسجيل إبرة جديدة
        print("تم تسجيل إبرة جديدة")
    }
}

#Preview {
    HomeView()
}

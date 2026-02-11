import SwiftUI

struct ContentView: View {

    // 🔹 ViewModel للسجل
    @StateObject private var recordsVM = RecordsViewModel()

    var body: some View {
        TabView {

            // 🔹 تاب السجل
            RecordsView(viewModel: recordsVM)
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("السجل")
                }

            // 🔹 تاب المؤشرات / الرئيسية
            HomeView(recordsVM: recordsVM) // ⚡️ ربط HomeView بالسجل
                .tabItem {
                    Image(systemName: "lines.measurement.horizontal.aligned.bottom")
                    Text("المؤشرات")
                }

            // 🔹 تاب الإعدادات
            // 🔹 تاب الإعدادات
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("الإعدادات")
                }

        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}


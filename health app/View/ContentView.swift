import SwiftUI
import Combine

// MARK: - ContentView
struct ContentView: View {

    @StateObject private var recordsVM = RecordsViewModel()
    @StateObject private var settingsVM = SettingsViewModel() // ✅ جديد
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
            } else {
                MainTabView(recordsVM: recordsVM, settingsVM: settingsVM) // تمرير settingsVM
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut) {
                    showSplash = false
                }
            }
        }
    }
}

// MARK: - MainTabView
struct MainTabView: View {

    @ObservedObject var recordsVM: RecordsViewModel
    @ObservedObject var settingsVM: SettingsViewModel // ✅ جديد
    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("الإعدادات")
                }
                .tag(0)

            RecordsView(viewModel: recordsVM)
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("السجل")
                }
                .tag(2)
            
            HomeView(recordsVM: recordsVM, settingsVM: settingsVM) // ✅ تمرير settingsVM
                .tabItem {
                    Image(systemName: "lines.measurement.horizontal.aligned.bottom")
                    Text("المؤشرات")
                }
                .tag(1)
        }
        .environment(\.layoutDirection, .leftToRight)
        .accentColor(.black)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

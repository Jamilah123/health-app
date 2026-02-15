import SwiftUI

struct ContentView: View {

    @StateObject private var recordsVM = RecordsViewModel()
    @State private var showSplash = true
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
            } else {
                MainTabView(recordsVM: recordsVM)
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

struct MainTabView: View {

    @ObservedObject var recordsVM: RecordsViewModel
    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("الإعدادات")
                }
                .tag(0)

            HomeView(recordsVM: recordsVM)
                .tabItem {
                    Image(systemName: "lines.measurement.horizontal.aligned.bottom")
                    Text("المؤشرات")
                }
                .tag(1)

            RecordsView(viewModel: recordsVM)
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("السجل")
                }
                .tag(2)
        }
        .environment(\.layoutDirection, .leftToRight)
        .accentColor(.black)
    }
}



// ✅ Preview
#Preview {
    ContentView()
}



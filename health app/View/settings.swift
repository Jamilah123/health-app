import SwiftUI
import SwiftData

struct SettingsView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {

            // الخلفية
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 16) {

                // الهيدر
                VStack(alignment: .trailing, spacing: 6) {
                    Text("الإعدادات")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("تخصيص تجربتك")
                        .font(.subheadline)
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(.top, 70)
                .padding(.horizontal)
                
            }
        }
    }
}
#Preview {
    SettingsView()
}


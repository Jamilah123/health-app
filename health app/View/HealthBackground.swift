import SwiftUI

struct HealthBackground: View {
    var body: some View {
        Image("background") // اسم الصورة في Assets
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

#Preview {
    HealthBackground()
}


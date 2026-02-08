import SwiftUI

struct HealthBackground: View {
    var body: some View {
        ZStack {

            // 1️⃣ التدرج الأساسي
            LinearGradient(
                colors: [
                    Color(red: 198/255, green: 198/255, blue: 230/255),
                    Color(red: 158/255, green: 161/255, blue: 204/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 2️⃣ إضاءة ناعمة بالوسط (Radial)
            RadialGradient(
                colors: [
                    Color.white.opacity(0.45),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 420
            )

            // 3️⃣ تغميق خفيف من الأعلى
            LinearGradient(
                colors: [
                    Color.black.opacity(0.12),
                    Color.clear
                ],
                startPoint: .topTrailing,
                endPoint: .center
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HealthBackground()
}

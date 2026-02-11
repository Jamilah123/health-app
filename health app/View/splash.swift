import SwiftUI

struct SplashView: View {
    @State private var showText = false

    var body: some View {
        ZStack {
            // الخلفية
               Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {

                // الايقونة (موجودة من البداية)
                Image("icond")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.white)

                // الاسم (يتحرك)
                Text("وِزان")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : -30)
                    .animation(
                        .easeOut(duration: 0.8),
                        value: showText
                    )
            }
        }
        .onAppear {
            // تأخير بسيط قبل نزول الاسم
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showText = true
            }
        }
    }
}


// التصحيح هنا: يجب أن يكون الاسم مطابقاً للـ Struct فوق
#Preview {
    SplashView()
}

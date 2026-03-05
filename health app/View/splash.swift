import SwiftUI

struct SplashView: View {
    @State private var showText = false

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Image("icond")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.white)

                Text("وِزان")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(red: 0.42, green: 0.39, blue: 0.55))
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : -30)
                    .animation(
                        .easeOut(duration: 0.8),
                        value: showText
                    )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showText = true
            }
        }
    }
}


#Preview {
    SplashView()
}

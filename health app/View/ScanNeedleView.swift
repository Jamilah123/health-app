import SwiftUI

struct ScanNeedleView: View {

    @ObservedObject var recordsVM: RecordsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ScanNeedleViewModel()

    @State private var showCamera = false

    var body: some View {
        ZStack {

            HealthBackground()
            
            VStack(spacing: 30) {
                Spacer().frame(height: 80) // تحكم يدوي


                RoundedRectangle(cornerRadius: 30)
                    .fill(Color("Cam"))
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    .frame(width: 276, height: 340)
                    .cornerRadius(30)

                    .overlay(
                        Image(systemName: "camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70)
                            .foregroundColor(.black)
                            .font(.system(size: 70, weight: .bold)) // يجعل الخطوط سميكة

                        
                    )

                Spacer().frame(height: 80) // تحكم يدوي

                Button("التقط الصورة") {
                    showCamera = true
                }
                .foregroundColor(.white)
                .frame(width: 276, height: 50)
                .background(Color("container"))
                .cornerRadius(25)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                viewModel.process(image: image) { units in
                    if let units {
                        recordsVM.addInsulin(units: units)
                        dismiss() // يرجع للهوم
                    }
                }
            }
        }
    }
}

#Preview {
    ScanNeedleView(recordsVM: RecordsViewModel())
}

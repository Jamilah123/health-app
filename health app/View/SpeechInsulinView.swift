import SwiftUI

struct SpeechInsulinView: View {
    @ObservedObject var recordsVM: RecordsViewModel
    @Environment(\.dismiss) private var dismiss

    // Placeholder for recognized units from speech
    @State private var recognizedUnitsText: String = ""
    @State private var isListening: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            HealthBackground()

            VStack(spacing: 20) {
                Spacer().frame(height: 60)

                Text("تسجيل الجرعة بالصوت")
                    .font(.title2)
                    .fontWeight(.semibold)

                VStack(spacing: 12) {
                    TextField("الوحدات المقروءة", text: $recognizedUnitsText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 28, weight: .bold))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.4))
                        )

                    if let message = errorMessage {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button {
                        // Placeholder toggle for "listening"
                        isListening.toggle()
                        if isListening {
                            // Simulate a recognized value for now
                            // You can integrate real speech recognition later.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                if recognizedUnitsText.isEmpty {
                                    recognizedUnitsText = "5"
                                }
                                isListening = false
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: isListening ? "waveform.circle.fill" : "waveform.circle")
                            Text(isListening ? "جارٍ الاستماع..." : "ابدأ الاستماع")
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color("container"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }

                    Button {
                        if let units = Int(recognizedUnitsText), units > 0 {
                            recordsVM.addInsulin(units: units)
                            dismiss()
                        } else {
                            errorMessage = "الرجاء إدخال رقم صحيح للوحدات"
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("حفظ")
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color("buttoun2"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal)

                Button {
                    dismiss()
                } label: {
                    Text("إغلاق")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SpeechInsulinView(recordsVM: RecordsViewModel())
}

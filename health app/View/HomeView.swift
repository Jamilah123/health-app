import SwiftUI
import Combine

// MARK: - Home View
struct HomeView: View {

    @ObservedObject var recordsVM: RecordsViewModel
    @StateObject private var viewModel = HomeViewModel()

    @State private var showInsulinSheet = false
    @State private var showManualInput = false
    @State private var selectedOption: InsulinOption = .manual

    @State private var insulinUnits = ""
    @State private var lastInsulinUnits: Int?

    var body: some View {
        ZStack {

            HealthBackground()

            VStack(spacing: 20) {
                glucoseCard
                insulinCard
                chartCard
                Spacer()
            }
            .padding()

            // 🔥 Sheet اختيار الطريقة
            if showInsulinSheet {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showInsulinSheet = false
                    }

                InsulinCenterSheet(
                    selectedOption: $selectedOption,
                    isPresented: $showInsulinSheet,
                    showManualInput: $showManualInput
                )
            }

            // ✍️ إدخال يدوي
            if showManualInput {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showManualInput = false
                    }

                manualInputCard
            }
        }
        .animation(.easeInOut, value: showInsulinSheet)
        .animation(.easeInOut, value: showManualInput)
        .onAppear {
            viewModel.onAppear()
        }
    }
}

// MARK: - Components
extension HomeView {

    private var glucoseCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("مستوى السكر")
                .font(.headline)

            Text("\(Int(viewModel.latestGlucose?.value ?? 0))")
                .font(.system(size: 40, weight: .bold))

            Text("mg/dL")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 331, height: 159, alignment: .leading)
        .background(.white)
        .cornerRadius(25)
        .shadow(radius: 4)
    }

    // 🔹 كرت الإنسولين
    private var insulinCard: some View {
        VStack(spacing: 15) {

            HStack {
                Image(systemName: "syringe")
                Text("تسجيل جرعة إنسولين")
                    .font(.headline)
                Spacer()
            }

            // ✅ آخر إبرة (صار فوق)
            if let units = lastInsulinUnits {
                HStack {
                    Text("آخر إبرة: \(units) وحدات")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("الآن")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.blue.opacity(0.12))
                )
            }

            // 🔵 الزر الأزرق (صار تحت)
            Button {
                showInsulinSheet = true
            } label: {
                Text("تسجيل إبرة جديدة")
                    .foregroundColor(.white)
                    .frame(width: 276, height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(width: 331)
        .background(.white)
        .cornerRadius(25)
        .shadow(radius: 4)
    }

    // 🔹 مخطط سكر الدم (بدون أي مخطط أو أيقونة)
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("مخطط سكر الدم")
                .font(.headline)

            if viewModel.glucoseHistory.isEmpty {

                Text("لا توجد بيانات")
                    .foregroundColor(.gray)
                    .font(.subheadline)

            } else {

                ForEach(viewModel.glucoseHistory.prefix(5)) { item in
                    Text("• \(Int(item.value)) mg/dL")
                        .font(.subheadline)
                }
            }

            Spacer()
        }
        .padding()
        .frame(width: 331, height: 231, alignment: .topLeading)
        .background(.white)
        .cornerRadius(25)
        .shadow(radius: 4)
    }

    // 🔹 إدخال يدوي
    private var manualInputCard: some View {
        VStack(spacing: 20) {

            Text("إدخال الجرعة")
                .font(.headline)

            TextField("عدد الوحدات", text: $insulinUnits)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 28, weight: .bold))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.4))
                )

            Button("حفظ") {
                if let value = Int(insulinUnits) {
                    lastInsulinUnits = value
                    recordsVM.addInsulin(units: value) // ⬅️ ينحفظ في السجل
                    insulinUnits = ""
                    showManualInput = false
                }
            }

            .foregroundColor(.white)
            .frame(height: 45)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(25)

        }
        .padding(25)
        .frame(width: 300)
        .background(
            BlurView(style: .systemUltraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        )
        .shadow(radius: 20)
    }
}

// MARK: - Center Glass Sheet
struct InsulinCenterSheet: View {

    @Binding var selectedOption: InsulinOption
    @Binding var isPresented: Bool
    @Binding var showManualInput: Bool

    var body: some View {
        VStack(spacing: 20) {

            Text("طريقة تسجيل الإبرة")
                .font(.headline)

            HStack(spacing: 0) {
                option(title: "يدوي", option: .manual)
                option(title: "بالكاميرا", option: .camera)
            }
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.35))
            )
        }
        .padding(25)
        .frame(width: 300)
        .background(
            BlurView(style: .systemUltraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        )
        .shadow(radius: 20)
    }

    private func option(title: String, option: InsulinOption) -> some View {
        Button {
            selectedOption = option
            isPresented = false
            if option == .manual {
                showManualInput = true
            }
        } label: {
            Text(title)
                .font(.headline)
                .foregroundColor(selectedOption == option ? .black : .gray)
                .frame(maxWidth: .infinity, minHeight: 45)
                .background(
                    selectedOption == option
                    ? RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.6))
                    : nil
                )
        }
    }
}

// MARK: - Option Enum
enum InsulinOption {
    case manual
    case camera
}

// MARK: - Blur View
struct BlurView: UIViewRepresentable {

    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Preview
#Preview {
    HomeView(recordsVM: RecordsViewModel())
}

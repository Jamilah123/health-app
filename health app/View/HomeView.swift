import SwiftUI
import Combine

// MARK: - Home View
struct HomeView: View {

    @ObservedObject var recordsVM: RecordsViewModel
    @StateObject private var viewModel = HomeViewModel()

    @State private var showInsulinSheet = false
    @State private var showManualInput = false
    @State private var showVoiceInput = false
    @State private var selectedOption: InsulinOption = .manual

    @State private var insulinUnits = ""
    @State private var lastInsulinUnits: Int?

    private var glucoseStatus: (title: String, color: Color) {
        let value = viewModel.latestGlucose?.value ?? 0

        switch value {
        case ..<70:
            return ("منخفض", Color("low"))
        case 70..<180:
            return ("طبيعي", Color("natural"))
        default:
            return ("مرتفع", Color("high"))
        }
    }

    private var lastUpdatedText: String {
        guard let date = viewModel.latestGlucose?.date else {
            return "لا يوجد تحديث"
        }

        let minutes = Int(Date().timeIntervalSince(date) / 60)

        switch minutes {
        case ..<1:
            return "الآن"
        case 1:
            return "قبل دقيقة"
        case 2..<60:
            return "قبل \(minutes) دقائق"
        case 60..<120:
            return "قبل ساعة"
        default:
            let hours = minutes / 60
            return "قبل \(hours) ساعات"
        }
    }

    var body: some View {
        ZStack {
            HealthBackground()

            VStack(spacing: 30) {
                Spacer().frame(height: 80)
                glucoseCard
                insulinCard
                chartCard
                Spacer()
            }
            .padding()

            if showInsulinSheet {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { showInsulinSheet = false }

                InsulinCenterSheet(
                    selectedOption: $selectedOption,
                    isPresented: $showInsulinSheet,
                    showManualInput: $showManualInput,
                    showVoiceInput: $showVoiceInput
                )
            }

            if showManualInput {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { showManualInput = false }

                manualInputCard
            }
        }
        .animation(.easeInOut, value: showInsulinSheet)
        .animation(.easeInOut, value: showManualInput)
        .animation(.easeInOut, value: showVoiceInput)
        .onAppear { viewModel.onAppear() }

        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in }

        // 🎤 Voice Input
        .sheet(isPresented: $showVoiceInput) {
            SpeechInsulinView(recordsVM: recordsVM)
        }
    }
}

// MARK: - Components
extension HomeView {

    private var glucoseCard: some View {
        ZStack(alignment: .topLeading) {

            VStack(alignment: .trailing, spacing: 10) {
                Text("مستوى السكر")
                    .font(.headline)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("ملغ/دل")
                        .font(.headline)

                    Text("\(Int(viewModel.latestGlucose?.value ?? 0))")
                        .font(.system(size: 44, weight: .bold))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                Text("آخر تحديث \(lastUpdatedText)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(width: 331, height: 159, alignment: .trailing)
            .background(.white)
            .cornerRadius(25)
            .shadow(radius: 4)

            Text(glucoseStatus.title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(glucoseStatus.color)
                .clipShape(Capsule())
                .padding(16)
        }
    }

    private var insulinCard: some View {
        VStack(spacing: 15) {
            HStack {
                Spacer()
                Text("تسجيل جرعة إنسولين").font(.headline)
                Image(systemName: "syringe")
            }

            if let units = lastInsulinUnits {
                HStack {
                    Text("آخر إبرة: \(units) وحدات")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    HStack(spacing: 4) {
                        Text("الآن")
                            .font(.caption)
                            .foregroundColor(Color("TextGray"))
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(Color("TextGray"))
                    }
                }
                .padding()
                .frame(width: 276, height: 50)
                .background(RoundedRectangle(cornerRadius: 25).fill(Color("buttoun")))
            }

            Button {
                showInsulinSheet = true
            } label: {
                Text("تسجيل إبرة جديدة")
                    .foregroundColor(.white)
                    .frame(width: 276, height: 50)
                    .background(Color("buttoun2"))
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(width: 331)
        .background(.white)
        .cornerRadius(25)
        .shadow(radius: 4)
    }

    private var chartCard: some View {
        VStack(alignment: .trailing, spacing: 10) {
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
        .frame(width: 331, height: 231, alignment: .topTrailing)
        .background(.white)
        .cornerRadius(25)
        .shadow(radius: 4)
    }

    private var manualInputCard: some View {
        VStack(spacing: 20) {
            Text("إدخال الجرعة").font(.headline)

            TextField("عدد الوحدات", text: $insulinUnits)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 28, weight: .bold))
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.4)))

            Button("حفظ") {
                if let value = Int(insulinUnits) {
                    lastInsulinUnits = value
                    recordsVM.addInsulin(units: value)
                    insulinUnits = ""
                    showManualInput = false
                }
            }
            .foregroundColor(.white)
            .frame(height: 45)
            .frame(maxWidth: .infinity)
            .background(Color("container"))
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

// MARK: - Center Sheet
struct InsulinCenterSheet: View {

    @Binding var selectedOption: InsulinOption
    @Binding var isPresented: Bool
    @Binding var showManualInput: Bool
    @Binding var showVoiceInput: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("طريقة تسجيل الإبرة").font(.headline)
            HStack(spacing: 0) {
                option(title: "يدوي", option: .manual)
            }
            .background(RoundedRectangle(cornerRadius: 30).fill(Color.white.opacity(0.35)))
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

            if option == .manual { showManualInput = true }
            if option == .voice { showVoiceInput = true }

        } label: {
            Text(title)
                .font(.headline)
                .foregroundColor(selectedOption == option ? .black : .gray)
                .frame(maxWidth: .infinity, minHeight: 45)
                .background(
                    selectedOption == option
                    ? RoundedRectangle(cornerRadius: 25).fill(Color.white.opacity(0.6))
                    : nil
                )
        }
    }
}

// MARK: - Option Enum
enum InsulinOption {
    case manual
    case voice
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



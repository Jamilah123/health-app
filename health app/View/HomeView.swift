import SwiftUI
import Combine

// MARK: - Home View
struct HomeView: View {

    @ObservedObject var recordsVM: RecordsViewModel
    @ObservedObject var settingsVM: SettingsViewModel
    @StateObject private var viewModel = HomeViewModel()

    @State private var showManualInput = false
    @State private var showVoiceInput = false
    @State private var showTargetRangeSheet = false
    @State private var showInsulinAlertSheet = false
    @State private var showChartAnalysisSheet = false

    @State private var insulinUnits = ""
    @State private var lastInsulinUnits: Int?

    // MARK: - Glucose Status
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

    // MARK: - Last Updated
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
            
            // MARK: - Target Range Sheet
            if showTargetRangeSheet {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { showTargetRangeSheet = false }

                TargetRangeSheet()
                    .frame(maxWidth: 350)
                    .background(
                        BlurView(style: .systemUltraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    )
                    .shadow(radius: 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // MARK: - Insulin Alert Sheet
            if showInsulinAlertSheet {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { showInsulinAlertSheet = false }

                InsulinAlertSheet()
                    .frame(width: 300)
                    .background(
                        BlurView(style: .systemUltraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    )
                    .shadow(radius: 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // MARK: - Chart Analysis Sheet
            if showChartAnalysisSheet {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { showChartAnalysisSheet = false }

                ChartAnalysisSheet()
                    .frame(width: 300)
                    .background(
                        BlurView(style: .systemUltraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    )
                    .shadow(radius: 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // MARK: - Manual Input
            if showManualInput {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { showManualInput = false }

                manualInputCard
            }
        }
        .animation(.easeInOut, value: showManualInput)
        .animation(.easeInOut, value: showVoiceInput)
        .onAppear {
            viewModel.onAppear()
        }
        .sheet(isPresented: $showVoiceInput) {
            SpeechInsulinView(recordsVM: recordsVM)
        }
    }
}

// MARK: - Components
extension HomeView {

    private var glucoseCard: some View {
        let darkGrayCustom = Color(red: 88/255, green: 88/255, blue: 88/255)

        return ZStack(alignment: .topLeading) {

            VStack(alignment: .trailing, spacing: 10) {

                ZStack {
                    Text("مستوى السكر")
                        .font(.headline)
                        .foregroundColor(Color("text"))
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        Spacer()
                        Button {
                            withAnimation { showTargetRangeSheet = true }
                        } label: {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(darkGrayCustom)
                        }
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("ملغ/دل")
                        .font(.headline)
                        .foregroundColor(Color("text0"))

                    Text("\(Int(viewModel.latestGlucose?.value ?? 0))")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(Color("text0"))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                Text("آخر تحديث \(lastUpdatedText)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(width: 330, height: 160, alignment: .trailing)
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
        let darkGrayCustom = Color(red: 88/255, green: 88/255, blue: 88/255)

        return VStack(spacing: 12) {

            ZStack(alignment: .topTrailing) {

                VStack(spacing: 12) {

                    ZStack {
                        HStack {
                            HStack(spacing: 4) {
                                Text("الآن")
                                    .foregroundColor(darkGrayCustom)
                                    .font(.caption)

                                Image(systemName: "clock.fill")
                                    .foregroundColor(darkGrayCustom)
                                    .font(.caption)
                            }
                            Spacer()
                        }

                        Text("آخر جرعة إنسولين")
                            .font(.headline)
                            .foregroundColor(Color("text"))

                        HStack {
                            Spacer()
                            Button {
                                withAnimation { showInsulinAlertSheet = true }
                            } label: {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(darkGrayCustom)
                            }
                        }
                    }

                    if let units = lastInsulinUnits {
                        HStack(spacing: 6) {
                            Text("وحدات \(settingsVM.selectedSugarUnit.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(Color("text0"))

                            Text("\(units)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color("text0"))
                        }
                    } else {
                        Text("لا توجد جرعة مسجلة")
                            .foregroundColor(darkGrayCustom)
                            .font(.subheadline)
                    }

                    Button {
                        showManualInput = true
                    } label: {
                        Text("تسجيل إبرة جديدة")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color("newInj"))
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .frame(width: 330, height: 160)
            .background(.white)
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
    }

    private var chartCard: some View {
        let darkGrayCustom = Color(red: 88/255, green: 88/255, blue: 88/255)

        return VStack(alignment: .trailing, spacing: 10) {

            ZStack {
                Text("مخطط سكر الدم")
                    .font(.headline)
                    .foregroundColor(Color("text"))
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Spacer()
                    Button {
                        withAnimation { showChartAnalysisSheet = true }
                    } label: {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(darkGrayCustom)
                    }
                }
            }

            if viewModel.glucoseHistory.isEmpty {
                Text("لا توجد بيانات")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            } else {
                ForEach(viewModel.glucoseHistory.prefix(5)) { item in
                    Text("• \(Int(item.value)) mg/dL")
                        .font(.subheadline)
                        .foregroundColor(Color("text0"))
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

// MARK: - Sheets
struct TargetRangeSheet: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("النطاق المستهدف")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("عادةً بين 70 و 130 mg/dL قبل الأكل")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("استشر طبيبك لتحديد النطاق الأنسب لحالتك")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding(30)
    }
}

struct InsulinAlertSheet: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("تنبيه الأمان")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("تأكد من بقاء فاصل زمني كافٍ بين الجرعات\nلتجنب التراكم مما قد يسبب هبوطاً مفاجئاً في السكر")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding(30)
    }
}

struct ChartAnalysisSheet: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("تحليل البيانات")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("يراقب المخطط تقلبات السكر خلال اليوم\nالارتفاعات المفاجئة غالباً ما ترتبط بالوجبات\nبينما تعكس الانخفاضات تأثير النشاط البدني أو الإنسولين")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding(30)
    }
}

// MARK: - Enum
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

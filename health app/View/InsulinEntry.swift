import SwiftUI
import Combine

// MARK: - Model
struct InsulinEntry {
    let units: Int
    let date: Date
}

// MARK: - Insulin Entry View
struct InsulinEntryView: View {

    @State private var showOptions = false
    @State private var showManualInput = false
    @State private var insulinUnits = ""
    @State private var lastEntry: InsulinEntry?

    var body: some View {
        ZStack {

            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                insulinCard

                if let entry = lastEntry {
                    lastInjectionView(entry)
                }

                Spacer()
            }
            .padding()

            // اختيار الطريقة
            if showOptions {
                overlayBackground
                insulinOptionSheet
            }

            // إدخال يدوي
            if showManualInput {
                overlayBackground
                manualInputSheet
            }
        }
        .animation(.easeInOut, value: showOptions)
        .animation(.easeInOut, value: showManualInput)
    }
}

// MARK: - Components
extension InsulinEntryView {

    private var insulinCard: some View {
        VStack(spacing: 15) {

            HStack {
                Image(systemName: "syringe")
                Text("تسجيل جرعة إنسولين")
                    .font(.headline)
                Spacer()
            }

            Button {
                showOptions = true
            } label: {
                Text("تسجيل إبرة جديدة")
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(25)
        .shadow(radius: 4)
    }

    // خلفية التعتيم
    private var overlayBackground: some View {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
            .onTapGesture {
                showOptions = false
                showManualInput = false
            }
    }

    // Sheet الاختيار
    private var insulinOptionSheet: some View {
        VStack(spacing: 20) {

            Text("طريقة تسجيل الإبرة")
                .font(.headline)

            HStack(spacing: 0) {

                Button("يدوي") {
                    showOptions = false
                    showManualInput = true
                }
                .sheetButton(selected: true)

                Button("بالكاميرا") {
                    // لاحقاً
                }
                .sheetButton(selected: false)
            }
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.35))
            )
        }
        .padding()
        .frame(width: 300)
        .background(glassBackground)
        .cornerRadius(30)
    }

    // Sheet الإدخال اليدوي
    private var manualInputSheet: some View {
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
                if let units = Int(insulinUnits) {
                    lastEntry = InsulinEntry(units: units, date: Date())
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
        .padding()
        .frame(width: 300)
        .background(glassBackground)
        .cornerRadius(30)
    }

    // عرض آخر إبرة (مثل الصورة)
    private func lastInjectionView(_ entry: InsulinEntry) -> some View {
        HStack {
            Text("آخر إبرة: \(entry.units) وحدات")
                .font(.headline)

            Spacer()

            Text("الآن")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.blue.opacity(0.12))
        )
    }

    private var glassBackground: some View {
        // Reuse the existing BlurView defined in HomeView.swift
        BlurView(style: .systemUltraThinMaterial)
    }
}

// MARK: - Button Style
extension View {
    func sheetButton(selected: Bool) -> some View {
        self
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundColor(selected ? .black : .gray)
            .background(
                selected
                ? RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.6))
                : nil
            )
    }
}

// MARK: - Preview
#Preview {
    InsulinEntryView()
}

import Combine
import SwiftUI

struct SettingsView: View {

    @StateObject private var vm = SettingsViewModel()
    @State private var showSugarUnitSheet = false

    var body: some View {
        ZStack {
            Color("F8F8FF")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 37) {

                    header
                    accessSection
                    preferencesSection
                    dataSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Header
    var header: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Text("الإعدادات")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("تخصيص تجربتك")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .topTrailing)
        .padding(.top, 70)
    }

    // MARK: - Access
    var accessSection: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("الوصول")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .trailing)

            appleHealthContainer
        }
    }

    // MARK: - Preferences
    var preferencesSection: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("وحدة السكر")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .trailing)

            sugarUnitContainer
        }
    }

    // MARK: - Data
    var dataSection: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("تصدير البيانات ك ملف PDF")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .trailing)

            dataContainer
        }
    }

    // MARK: - Apple Health
    var appleHealthContainer: some View {
        Button {
            if !vm.isAppleHealthConnected {
                vm.connectAppleHealth()
            }
        } label: {
            settingsTile(height: 100) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Apple Health")
                        .font(.headline)

                    if vm.isLoadingHealth {
                        ProgressView().tint(.white)
                    } else {
                        Text(vm.isAppleHealthConnected ? "متصل" : "غير متصل")
                            .foregroundColor(vm.isAppleHealthConnected ? .green : .red)
                    }
                }

                Image("applehealth")
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sugar Unit (Exact Style Like Image)
    var sugarUnitContainer: some View {
        let outerBackground = Color(red: 0.94, green: 0.94, blue: 0.95)

        return ZStack {
            RoundedRectangle(cornerRadius: 35)
                .fill(outerBackground)

            HStack(spacing: 16) {
                ForEach(SettingsViewModel.SugarUnit.allCases) { unit in
                    let isSelected = vm.selectedSugarUnit == unit

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            vm.selectedSugarUnit = unit
                        }
                    } label: {
                        SugarUnitOptionView(unit: unit, isSelected: isSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
        }
        .frame(height: 130)
    }

    // MARK: - Data Export
    var dataContainer: some View {
        Button {
            vm.exportPDF()
        } label: {
            settingsTile(height: 80) {
                chevron
                VStack(alignment: .trailing) {
                    Text("تصدير الأن").font(.headline)
                   
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - UI Helpers
    var chevron: some View {
        Image(systemName: "chevron.left")
            .foregroundColor(.gray)
    }

    func settingsTile<Content: View>(
        height: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.buttoun)
            .frame(height: height)
            .overlay(
                HStack {
                    Spacer()
                    content()
                }
                .foregroundColor(.black)
                .padding(.horizontal, 24)
            )
    }
}

#Preview {
    SettingsView()
}

// MARK: - Design System Colors
extension Color {
    static let settingsContainer = Color.black.opacity(0.2)
}

// MARK: - Subviews
private struct SugarUnitOptionView: View {
    let unit: SettingsViewModel.SugarUnit
    let isSelected: Bool

    private var titleColor: Color {
        isSelected
        ? Color(red: 0.42, green: 0.38, blue: 0.73)
        : Color.gray
    }

    private var fillColor: Color {
        isSelected
        ? Color(red: 0.88, green: 0.86, blue: 0.95)
        : Color(red: 0.92, green: 0.92, blue: 0.93)
    }

    private var strokeColor: Color {
        isSelected
        ? Color(red: 0.65, green: 0.60, blue: 0.85)
        : Color.clear
    }

    private var subtitle: String {
        // Match enum case names in SettingsViewModel
        switch unit {
        case .mmol:
            return "الوحدة الدولية"
        case .mgdl:
            return "الأكثر شيوعاً"
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(unit.rawValue)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(titleColor)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(fillColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(strokeColor, lineWidth: 2)
        )
    }
}

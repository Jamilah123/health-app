import SwiftUI

struct SettingsView: View {

    @StateObject private var vm = SettingsViewModel()
    @State private var showSugarUnitSheet = false

    var body: some View {
        ZStack {

            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

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
            Text("التفضيلات")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .trailing)

            sugarUnitContainer
        }
    }

    // MARK: - Data
    var dataSection: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("البيانات")
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
            container(height: 100) {
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

    // MARK: - Sugar Unit
    var sugarUnitContainer: some View {
        Button {
            showSugarUnitSheet = true
        } label: {
            container(height: 60) {
                chevron
                VStack(alignment: .trailing) {
                    Text("وحدة السكر").font(.headline)
                    Text(vm.selectedSugarUnit.rawValue)
                        .opacity(0.7)
                }
            }
        }
        .buttonStyle(.plain)
        .confirmationDialog("وحدة القياس", isPresented: $showSugarUnitSheet) {
            ForEach(SettingsViewModel.SugarUnit.allCases, id: \.self) { unit in
                Button(unit.rawValue) {
                    vm.selectedSugarUnit = unit
                }
            }
        }
    }

    // MARK: - Data Export
    var dataContainer: some View {
        Button {
            vm.exportPDF()
        } label: {
            container(height: 80) {
                chevron
                VStack(alignment: .trailing) {
                    Text("البيانات").font(.headline)
                    Text("تحميل بياناتك كملف PDF").opacity(0.7)
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

    func container<Content: View>(
        height: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.container.opacity(0.7))
            .frame(height: height)
            .overlay(
                HStack {
                    Spacer()
                    content()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            )
    }
}


#Preview {
    SettingsView()
}


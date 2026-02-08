import SwiftUI
import SwiftData

struct HistoryView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {

            // الخلفية
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 16) {

                // الهيدر
                VStack(alignment: .trailing, spacing: 6) {
                    Text("السجل")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("تاريخ القراءات والجرعات")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(.top, 70)
                .padding(.horizontal)

                // السكر
                GlucoseCardView(value: "", time: "")

                // الانسولين
                InsulinCardView(dose: "", time: "")
            }
            .padding(.bottom, 40) // مساحة أسفل للكروت / TabBar
        }
    }
}

// MARK: - Glucose Card
struct GlucoseCardView: View {
    let value: String
    let time: String

    var body: some View {
        HStack {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Spacer()

            HStack(spacing: 8) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("قراءة السكر")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(time)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }

                Image(systemName: "barcode.viewfinder")
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.container.opacity(0.35))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                )
                .glassEffect(.clear.tint(.black.opacity(0.65)))
        )
        .padding(.horizontal)
    }
}

// MARK: - Insulin Card
struct InsulinCardView: View {
    let dose: String
    let time: String

    var body: some View {
        HStack {
            Text(dose)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Spacer()

            HStack(spacing: 8) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("جرعة انسولين")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(time)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }

                Image(systemName: "syringe.fill")
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.container2.opacity(0.35))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                )
                .glassEffect(.clear.tint(.black.opacity(0.65)))
        )
        .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    HistoryView()
}


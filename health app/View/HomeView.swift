import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            background
            
            VStack(spacing: 20) {
                glucoseCard
                insulinCard
                chartCard
                
                Spacer()
                
                bottomBar
            }
            .padding()
        }
    }
}

// MARK: - Background
extension HomeView {
    var background: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.78, green: 0.80, blue: 0.95),
                Color(red: 0.55, green: 0.57, blue: 0.80)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Glucose Card
extension HomeView {
    var glucoseCard: some View {
        VStack(alignment: .trailing, spacing: 12) {
            
            HStack {
                Text(viewModel.glucose.status)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .cornerRadius(12)
                
                Spacer()
            }
            
            Text("مستوى السكر")
                .font(.headline)
            
            Text("\(viewModel.glucose.level)")
                .font(.system(size: 40, weight: .bold))
            
            Text(viewModel.glucose.unit)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(viewModel.glucose.lastUpdated)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
    }
}

// MARK: - Insulin Card
extension HomeView {
    var insulinCard: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("تسجيل جرعة إنسولين")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "pencil")
            }
            
            HStack {
                Text("آخر إبرة: \(viewModel.insulin.lastDose) وحدات")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(viewModel.insulin.lastTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Button {
                viewModel.addNewInsulinDose()
            } label: {
                Text("تسجيل إبرة جديدة")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.35, green: 0.38, blue: 0.70))
                    .cornerRadius(14)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
    }
}

// MARK: - Chart Card
extension HomeView {
    var chartCard: some View {
        VStack(alignment: .trailing) {
            Text("مخطط سكر الدم")
                .font(.headline)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 150)
                .cornerRadius(12)
                .overlay(
                    Text("Chart Placeholder")
                        .foregroundColor(.gray)
                )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
    }
}

// MARK: - Bottom Bar
extension HomeView {
    var bottomBar: some View {
        HStack {
            Spacer()
            tabItem(icon: "gearshape", title: "الإعدادات")
            Spacer()
            tabItem(icon: "house.fill", title: "الرئيسية")
            Spacer()
            tabItem(icon: "doc.text", title: "السجل")
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
    }
    
    func tabItem(icon: String, title: String) -> some View {
        VStack {
            Image(systemName: icon)
            Text(title)
                .font(.caption)
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}


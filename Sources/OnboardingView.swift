import SwiftUI

struct OnboardingView: View {
    @ObservedObject var onboarding: OnboardingManager
    @State private var page = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<4) { i in
                    Circle()
                        .fill(i == page ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            TabView(selection: $page) {
                page1.tag(0)
                page2.tag(1)
                page3.tag(2)
                page4.tag(3)
            }
            .tabViewStyle(.automatic)
            
            HStack {
                if page > 0 {
                    Button("Back") { withAnimation { page -= 1 } }
                        .buttonStyle(.bordered)
                }
                Spacer()
                Button(page == 3 ? "Get Started" : "Next") {
                    if page == 3 {
                        onboarding.complete()
                    } else {
                        withAnimation { page += 1 }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .frame(width: 500, height: 400)
    }
    
    var page1: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 70))
                .foregroundColor(.accentColor)
            Text("Welcome to\nReminderly")
                .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
            Text("Never miss an important moment.\nSet reminders that repeat when you need them.")
                .font(.body).foregroundColor(.secondary).multilineTextAlignment(.center)
        }.padding()
    }
    
    var page2: some View {
        VStack(spacing: 20) {
            Image(systemName: "repeat")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            Text("Flexible Repeat")
                .font(.title).fontWeight(.bold)
            VStack(spacing: 10) {
                FeatureItem(icon: "bell", text: "One-time alerts")
                FeatureItem(icon: "repeat", text: "Daily / Weekly / Monthly / Yearly")
                FeatureItem(icon: "calendar.badge.clock", text: "Exact date & time")
            }
        }.padding()
    }
    
    var page3: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            Text("Organize & Search")
                .font(.title).fontWeight(.bold)
            VStack(spacing: 10) {
                FeatureItem(icon: "folder", text: "Categories: Work, Personal, Health...")
                FeatureItem(icon: "magnifyingglass", text: "Search across all reminders")
                FeatureItem(icon: "arrow.up.arrow.down", text: "Filter by status")
            }
        }.padding()
    }
    
    var page4: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            Text("You're All Set!")
                .font(.title).fontWeight(.bold)
            Text("Start adding reminders and\nnever forget what matters.")
                .font(.body).foregroundColor(.secondary).multilineTextAlignment(.center)
        }.padding()
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(text)
        }
        .frame(maxWidth: 280, alignment: .leading)
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

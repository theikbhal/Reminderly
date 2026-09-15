import Foundation

class OnboardingManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    
    private let key = "Reminderly_Onboarding"
    
    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: key)
    }
    
    func complete() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: key)
    }
}

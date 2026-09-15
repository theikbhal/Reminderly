import Foundation

// MARK: - Models

struct Reminder: Codable, Identifiable {
    var id = UUID()
    var title: String
    var body: String
    var date: Date
    var repeatType: RepeatType
    var category: String
    var isCompleted: Bool
    var createdAt: Date
    var notificationID: String
    
    init(title: String, body: String = "", date: Date, repeatType: RepeatType = .none, category: String = "General", isCompleted: Bool = false) {
        self.title = title
        self.body = body
        self.date = date
        self.repeatType = repeatType
        self.category = category
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.notificationID = UUID().uuidString
    }
}

enum RepeatType: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .none: return "bell"
        case .daily: return "repeat"
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        case .yearly: return "calendar.badge.plus"
        case .custom: return "slider.horizontal.3"
        }
    }
}

struct ReminderCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    
    static let defaultCategories: [ReminderCategory] = [
        ReminderCategory(name: "General", icon: "bell.fill", color: "blue"),
        ReminderCategory(name: "Work", icon: "briefcase.fill", color: "orange"),
        ReminderCategory(name: "Personal", icon: "person.fill", color: "purple"),
        ReminderCategory(name: "Health", icon: "heart.fill", color: "red"),
        ReminderCategory(name: "Finance", icon: "dollarsign.circle.fill", color: "green"),
        ReminderCategory(name: "Family", icon: "house.fill", color: "pink"),
    ]
}

// MARK: - Store

class ReminderStore: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var categories: [ReminderCategory] = ReminderCategory.defaultCategories
    
    private let remindersKey = "Reminderly_Reminders"
    private let categoriesKey = "Reminderly_Categories"
    
    init() {
        load()
    }
    
    var sortedReminders: [Reminder] {
        reminders.sorted { $0.date < $1.date }
    }
    
    var upcomingReminders: [Reminder] {
        reminders.filter { $0.date > Date() && !$0.isCompleted }.sorted { $0.date < $1.date }
    }
    
    var completedReminders: [Reminder] {
        reminders.filter { $0.isCompleted }.sorted { $0.date > $1.date }
    }
    
    var overdueReminders: [Reminder] {
        reminders.filter { $0.date < Date() && !$0.isCompleted }
    }
    
    func add(_ reminder: Reminder) {
        reminders.append(reminder)
        scheduleNotification(for: reminder)
        save()
    }
    
    func update(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            cancelNotification(for: reminders[index])
            reminders[index] = reminder
            scheduleNotification(for: reminder)
            save()
        }
    }
    
    func delete(_ reminder: Reminder) {
        cancelNotification(for: reminder)
        reminders.removeAll { $0.id == reminder.id }
        save()
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            cancelNotification(for: reminders[index])
        }
        reminders.remove(atOffsets: offsets)
        save()
    }
    
    func toggleComplete(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isCompleted.toggle()
            if reminders[index].isCompleted {
                cancelNotification(for: reminders[index])
            } else {
                scheduleNotification(for: reminders[index])
            }
            save()
        }
    }
    
    func search(query: String) -> [Reminder] {
        guard !query.isEmpty else { return sortedReminders }
        return reminders.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.body.localizedCaseInsensitiveContains(query) ||
            $0.category.localizedCaseInsensitiveContains(query)
        }
    }
    
    func reminders(for category: String) -> [Reminder] {
        reminders.filter { $0.category == category }
    }
    
    // MARK: - Notifications
    
    func scheduleNotification(for reminder: Reminder) {
        guard !reminder.isCompleted else { return }
        NotificationManager.shared.schedule(reminder)
    }
    
    func cancelNotification(for reminder: Reminder) {
        NotificationManager.shared.cancel(id: reminder.notificationID)
    }
    
    func rescheduleAll() {
        for reminder in reminders where !reminder.isCompleted {
            scheduleNotification(for: reminder)
        }
    }
    
    // MARK: - Persistence
    
    func save() {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: remindersKey)
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: remindersKey),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = decoded
        }
    }
}

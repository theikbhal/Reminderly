import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ReminderStore
    @EnvironmentObject var onboarding: OnboardingManager
    @State private var selectedTab: AppTab = .all
    @State private var searchText = ""
    @State private var showAddSheet = false
    
    enum AppTab: String, CaseIterable, Identifiable {
        case all = "All"
        case today = "Today"
        case upcoming = "Upcoming"
        case overdue = "Overdue"
        case completed = "Done"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .all: return "tray.full"
            case .today: return "calendar.today"
            case .upcoming: return "clock"
            case .overdue: return "exclamationmark.triangle"
            case .completed: return "checkmark.circle"
            }
        }
    }
    
    var body: some View {
        Group {
            if onboarding.hasCompletedOnboarding {
                mainApp
            } else {
                OnboardingView(onboarding: onboarding)
            }
        }
    }
    
    var mainApp: some View {
        NavigationSplitView {
            // Sidebar
            List {
                Section("Reminders") {
                    ForEach(AppTab.allCases) { tab in
                        Label(tab.rawValue, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                
                Section("Categories") {
                    ForEach(store.categories) { cat in
                        Label(cat.name, systemImage: cat.icon)
                            .tag(cat.name)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 180)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        } detail: {
            DetailView(selectedTab: $selectedTab, searchText: $searchText, showAddSheet: $showAddSheet)
                .environmentObject(store)
        }
        .searchable(text: $searchText, prompt: "Search reminders...")
        .sheet(isPresented: $showAddSheet) {
            AddReminderSheet()
                .environmentObject(store)
        }
    }
}

// MARK: - Detail View

struct DetailView: View {
    @EnvironmentObject var store: ReminderStore
    @Binding var selectedTab: ContentView.AppTab
    @Binding var searchText: String
    @Binding var showAddSheet: Bool
    @State private var selectedReminder: Reminder?
    @State private var showEditSheet = false
    
    var filteredReminders: [Reminder] {
        if !searchText.isEmpty {
            return store.search(query: searchText)
        }
        
        switch selectedTab {
        case .all:
            return store.sortedReminders
        case .today:
            return store.sortedReminders.filter { Calendar.current.isDateInToday($0.date) }
        case .upcoming:
            return store.upcomingReminders
        case .overdue:
            return store.overdueReminders
        case .completed:
            return store.completedReminders
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(selectedTab.rawValue)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(filteredReminders.count) reminder\(filteredReminders.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showAddSheet = true }) {
                    Label("New Reminder", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Divider()
            
            // Reminder List
            if filteredReminders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No Reminders")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Tap + to create a new reminder")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredReminders) { reminder in
                        ReminderRow(reminder: reminder)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedReminder = reminder
                                showEditSheet = true
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.delete(reminder)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    store.toggleComplete(reminder)
                                } label: {
                                    Label(reminder.isCompleted ? "Undo" : "Done", systemImage: reminder.isCompleted ? "arrow.uturn.backward" : "checkmark")
                                }
                                .tint(reminder.isCompleted ? .orange : .green)
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let reminder = selectedReminder {
                EditReminderSheet(reminder: reminder)
                    .environmentObject(store)
            }
        }
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    @EnvironmentObject var store: ReminderStore
    let reminder: Reminder
    
    var categoryColor: Color {
        switch reminder.category {
        case "Work": return .orange
        case "Personal": return .purple
        case "Health": return .red
        case "Finance": return .green
        case "Family": return .pink
        default: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { store.toggleComplete(reminder) }) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(reminder.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                    .strikethrough(reminder.isCompleted)
                    .foregroundColor(reminder.isCompleted ? .secondary : .primary)
                
                if !reminder.body.isEmpty {
                    Text(reminder.body)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Text(reminder.date, style: .date)
                    Text(reminder.date, style: .time)
                    
                    if reminder.repeatType != .none {
                        Text("• \(reminder.repeatType.rawValue)")
                            .foregroundColor(categoryColor)
                    }
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(reminder.category)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(categoryColor.opacity(0.2))
                    .cornerRadius(4)
                
                if reminder.date < Date() && !reminder.isCompleted {
                    Text("Overdue")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

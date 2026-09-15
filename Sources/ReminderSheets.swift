import SwiftUI

struct AddReminderSheet: View {
    @EnvironmentObject var store: ReminderStore
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var noteText = ""
    @State private var date = Date()
    @State private var repeatType: RepeatType = .none
    @State private var category = "General"
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New Reminder")
                .font(.title2)
                .fontWeight(.bold)
            
            Form {
                TextField("Title", text: $title)
                TextField("Notes (optional)", text: $noteText)
                DatePicker("Date & Time", selection: $date)
                Picker("Repeat", selection: $repeatType) {
                    ForEach(RepeatType.allCases) { type in
                        Label(type.rawValue, systemImage: type.icon).tag(type)
                    }
                }
                Picker("Category", selection: $category) {
                    ForEach(store.categories) { cat in
                        Text(cat.name).tag(cat.name)
                    }
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Add Reminder") {
                    let reminder = Reminder(title: title, body: noteText, date: date, repeatType: repeatType, category: category)
                    store.add(reminder)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty)
            }
        }
        .padding()
        .frame(width: 420, height: 420)
    }
}

struct EditReminderSheet: View {
    @EnvironmentObject var store: ReminderStore
    @Environment(\.dismiss) var dismiss
    let reminder: Reminder
    @State private var title: String
    @State private var noteText: String
    @State private var date: Date
    @State private var repeatType: RepeatType
    @State private var category: String
    @State private var showDeleteConfirm = false
    
    init(reminder: Reminder) {
        self.reminder = reminder
        _title = State(initialValue: reminder.title)
        _noteText = State(initialValue: reminder.body)
        _date = State(initialValue: reminder.date)
        _repeatType = State(initialValue: reminder.repeatType)
        _category = State(initialValue: reminder.category)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Edit Reminder")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showDeleteConfirm = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
            }
            
            Form {
                TextField("Title", text: $title)
                TextField("Notes (optional)", text: $noteText)
                DatePicker("Date & Time", selection: $date)
                Picker("Repeat", selection: $repeatType) {
                    ForEach(RepeatType.allCases) { type in
                        Label(type.rawValue, systemImage: type.icon).tag(type)
                    }
                }
                Picker("Category", selection: $category) {
                    ForEach(store.categories) { cat in
                        Text(cat.name).tag(cat.name)
                    }
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save") {
                    var updated = reminder
                    updated.title = title
                    updated.body = noteText
                    updated.date = date
                    updated.repeatType = repeatType
                    updated.category = category
                    store.update(updated)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty)
            }
        }
        .padding()
        .frame(width: 420, height: 420)
        .alert("Delete Reminder?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                store.delete(reminder)
                dismiss()
            }
        }
    }
}

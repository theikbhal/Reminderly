import Foundation

class ExportManager {
    static func exportJSON(_ reminders: [Reminder]) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(reminders),
              let json = String(data: data, encoding: .utf8) else { return nil }
        return json
    }
    
    static func exportCSV(_ reminders: [Reminder]) -> String {
        var csv = "id,title,body,date,repeat,category,completed,created\n"
        for r in reminders {
            let dateStr = ISO8601DateFormatter().string(from: r.date)
            let createdStr = ISO8601DateFormatter().string(from: r.createdAt)
            csv += "\"\(r.id)\",\"\(r.title)\",\"\(r.body)\",\"\(dateStr)\",\"\(r.repeatType.rawValue)\",\"\(r.category)\",\(r.isCompleted),\"\(createdStr)\"\n"
        }
        return csv
    }
    
    static func exportMarkdown(_ reminders: [Reminder]) -> String {
        var md = "# Reminderly Export\n\nGenerated: \(Date())\n\n"
        md += "| Title | Date | Repeat | Category | Done |\n"
        md += "|-------|------|--------|----------|------|\n"
        for r in reminders.sorted(by: { $0.date < $1.date }) {
            let status = r.isCompleted ? "✅" : "⏳"
            md += "| \(r.title) | \(r.date.formatted()) | \(r.repeatType.rawValue) | \(r.category) | \(status) |\n"
        }
        md += "\n**Total:** \(reminders.count) reminders\n"
        return md
    }
    
    static func exportSQL(_ reminders: [Reminder]) -> String {
        var sql = """
        -- Reminderly Database
        -- Generated: \(Date())
        
        CREATE TABLE IF NOT EXISTS reminders (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            body TEXT,
            date TEXT NOT NULL,
            repeat_type TEXT,
            category TEXT,
            is_completed INTEGER DEFAULT 0,
            created_at TEXT
        );
        
        CREATE INDEX IF NOT EXISTS idx_reminders_date ON reminders(date);
        CREATE INDEX IF NOT EXISTS idx_reminders_category ON reminders(category);
        
        """
        for r in reminders {
            sql += "INSERT INTO reminders (id, title, body, date, repeat_type, category, is_completed, created_at) VALUES ('\(r.id.uuidString)', '\(r.title.replacingOccurrences(of: "'", with: "''"))', '\(r.body.replacingOccurrences(of: "'", with: "''"))', '\(ISO8601DateFormatter().string(from: r.date))', '\(r.repeatType.rawValue)', '\(r.category)', \(r.isCompleted ? 1 : 0), '\(ISO8601DateFormatter().string(from: r.createdAt))');\n"
        }
        return sql
    }
}

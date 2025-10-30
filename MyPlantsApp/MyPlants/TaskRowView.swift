import SwiftUI

struct TaskRowView: View {
    let task: CareTask
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName(for: task.eventType))
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(iconBackgroundColor(for: task.dueDate))
                .cornerRadius(12)

            VStack(alignment: .leading) {
                Text(task.plantName)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                Text(task.eventType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Text(formattedDate(task.dueDate))
                .font(.subheadline)
                .foregroundColor(dateColor(for: task.dueDate))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(dateColor(for: task.dueDate).opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.vertical, 8)
    }
    
    // Helper functions for styling
    private func iconName(for eventType: CareEventType) -> String {
        switch eventType {
        case .watered:
            return "drop.fill"
        case .fertilized:
            return "leaf.fill"
        default:
            return "calendar.badge.plus"
        }
    }
    
    private func iconBackgroundColor(for date: Date) -> Color {
        if Calendar.current.isDateInToday(date) || date < Date() {
            return .accentYellow
        }
        return .primaryGreen
    }
    
    private func formattedDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if date < Date() {
            let daysOverdue = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
            return "\(daysOverdue+1)d overdue"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    private func dateColor(for date: Date) -> Color {
        if date < Date() && !Calendar.current.isDateInToday(date) {
            return .red
        }
        return .textSecondary
    }
}



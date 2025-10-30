import SwiftUI

struct ScheduleView: View {
    
    @StateObject private var viewModel = ScheduleViewModel()
    @State private var mode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                // Section for upcoming tasks
                Section(header: Text("Upcoming Tasks")) {
                    if viewModel.upcomingTasks.isEmpty {
                        Text("No upcoming tasks. Your plants are all happy!")
                            .foregroundColor(.textSecondary)
                    } else {
                        ForEach(viewModel.upcomingTasks) { task in
                            HStack {
                                if mode.isEditing {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.primaryGreen)
                                        .font(.title2)
                                        .onTapGesture {
                                            viewModel.completeTask(task: task)
                                        }
                                }
                                TaskRowView(task: task)
                            }
                        }
                    }
                }
                
                // Section for tasks completed today
                Section(header: Text("Completed Today")) {
                    if viewModel.completedTodayTasks.isEmpty {
                        Text("No tasks completed yet today.")
                            .foregroundColor(.textSecondary)
                    } else {
                        ForEach(viewModel.completedTodayTasks) { entry in
                            // We need to find the plant associated with this entry
                            // This is a bit inefficient but fine for small numbers.
                            // A better model would have a direct link from JournalEntry to Plant.
                            if let plantName = entry.plant.first?.customName {
                                completedTaskRow(plantName: plantName, entry: entry)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Care Schedule")
            .toolbar {
                // The EditButton toggles the 'mode' state variable
                EditButton()
            }
            .environment(\.editMode, $mode)
        }
    }
    
    // A simple view for a completed task row
    private func completedTaskRow(plantName: String, entry: JournalEntry) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.gray)
            VStack(alignment: .leading) {
                Text(plantName)
                    .strikethrough()
                Text(entry.eventType.rawValue)
                    .font(.caption)
            }
            .foregroundColor(.textSecondary)
            Spacer()
            Text(entry.date, style: .time)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    ScheduleView()
}

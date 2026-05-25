//
//  RemindersSection.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/8/22.
//

import SwiftUI

extension TaskEditor {
    struct RemindersSection: View {
        @EnvironmentObject private var task: DATask
        @Environment(\.presentingField) private var presentingField
        
        private var remindersByDate: [Date: [Binding<Date>]] {
            var remindersByDate: [Date: [Binding<Date>]] = [:]
            for reminder in $task.reminders {
                let truncDate = Calendar.current.startOfDay(for: reminder.wrappedValue)
                if remindersByDate[truncDate] == nil {
                    remindersByDate[truncDate] = [reminder]
                } else {
                    remindersByDate[truncDate]?.append(reminder)
                }
            }
            return remindersByDate
        }
        
        var body: some View {
            VStack {
                List {
                    ForEach(remindersByDate.keys.sorted(by: <), id: \.id) { date in
                        Section(date.formatted(date: .long, time: .omitted)) {
                            ForEach(remindersByDate[date]?.sorted {$0.wrappedValue < $1.wrappedValue} ?? [], id: \.id) { $reminder in
                                ReminderRow(reminder: $reminder)
                            }
                        }
                        
                    }
                    
                    Button {
                        let newReminder = Date.now
                        task.reminders.append(newReminder)
                        presentingField?.wrappedValue = .reminders(newReminder.id)
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.title2)
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .listRowBackground(Rectangle().foregroundColor(.gray))
                    
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        
        
    }
}

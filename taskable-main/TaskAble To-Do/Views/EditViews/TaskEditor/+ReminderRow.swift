//
//  ReminderRowView.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/30/22.
//

import SwiftUI

extension TaskEditor {
    struct ReminderRow: View {
        @Binding var reminder: Date
        @State private var privateReminder: Date = .now
        
        @EnvironmentObject private var task: DATask
        
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.presentingField) private var presentingField
        
        @State private var presenting = false
        
        private var isPresenting: Bool {
            presentingField?.wrappedValue == .reminders(reminder.id)
        }
        
        let dateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            return dateFormatter
        }()
        
        var body: some View {
            Button {
                presentingField?.wrappedValue
                = isPresenting ? nil : .reminders(reminder.id)
            } label: {
                HStack {
                    Text(reminder, formatter: dateFormatter)
                        .foregroundStyle(
                            colorScheme == .light
                            ? ( isPresenting
                                ? Color(uiColor: .gray)
                                : Color(uiColor: .black) )
                            : ( isPresenting
                                ? Color(uiColor: .lightGray)
                                : Color(uiColor: .white) )
                        )
                        .font(.title3)
                    Spacer()
                    Button {
                        task.reminders.removeAll(where: {$0.id == reminder.id})
                    } label: {
                        Image(systemName: "multiply.square.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isPresenting)
                }
            }
            .toggleableFieldEditor(
                height: presenting ? 395 : 0,
                binding: $presenting
            ) {
                VStack {
                    DatePicker("", selection: $privateReminder)
                        .datePickerStyle(.graphical)
                        .onAppear {
                            privateReminder = reminder
                        }
                        .frame(height: 345, alignment: .top)
                    HStack {
                        Button(role: .cancel) {
                            privateReminder = reminder
                            presentingField?.wrappedValue = nil
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                        }
                        .tint(.red)
                        
                        
                        Button {
                            reminder = privateReminder
                            presentingField?.wrappedValue = nil
                        } label: {
                            Text("Confirm")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.bordered)
                    .frame(alignment: .top)
                }
                // Put done and cancel buttons
                // - Will prevent "jumping" around while scrolling through the times
            }
            .padding(.top, 4)
            .animation(.easeInOut, value: presenting)
            .onChange(of: isPresenting) { newValue in
                presenting = newValue
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

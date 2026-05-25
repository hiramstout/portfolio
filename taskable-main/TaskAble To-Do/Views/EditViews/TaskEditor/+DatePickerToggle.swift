//
//  DatePicker.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/30/22.
//

import SwiftUI
extension TaskEditor {
    struct DatePickerToggle: View {
        enum DatePickerType: String {
            case dueDate = "Due Date"
            case deferDate = "Defer Date"
        }
        private enum DueDateType: String, CaseIterable, Identifiable {
            case strict = "Strict"
            case flexible = "Flexible"
            var id: String { self.rawValue }
        }
        
        let datePickerType: DatePickerType
        
        @EnvironmentObject private var task: DATask
        @EnvironmentObject private var fields: FieldData
        @Environment(\.colorScheme) private var colorScheme

        @State private var dueDateType: DueDateType = .strict
        @State private var date: Date = .now
        @State private var hasDate = false
        
        var isPresenting: Bool {
            fields.presenting?.key == keypath
        }
        var keypath: PartialKeyPath<TaskEditor.FieldData> {
            switch datePickerType {
            case .dueDate:
                return \.dueDate
            case .deferDate:
                return \.deferDate
            }
        }

        
        var body: some View {
            Group {
                
                VStack {
                    Button {
                        withAnimation {
                            fields.presenting = isPresenting ? nil : (keypath, nil)
                        }
                    } label: {
                        // Change text to label with icon and current value
                        Toggle(datePickerType.rawValue,
                               isOn: $hasDate)
                            .listSectionSeparator(.hidden)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                    if hasDate && isPresenting {
                        if datePickerType == .dueDate {
                            Picker(selection: $dueDateType) {
                                ForEach(DueDateType.allCases) { dueDateType in
                                    Text(dueDateType.rawValue).tag(dueDateType)
                                }
                            } label: {
                                Text("Type")
                            }
                            .pickerStyle(.segmented)
                        }
                        if datePickerType == .deferDate || dueDateType == .strict {
                            DatePicker("", selection: $date)
                                .datePickerStyle(.wheel)
                                .listSectionSeparator(.hidden)
                        }
                        if dueDateType == .flexible {
                            EmptyView()
                        }
                    }
                }
                .onAppear {
                    switch datePickerType {
                    case .dueDate:
                        switch task.dueDate {
                        case .strict(let date):
                            self.date = date
                        case .flexible(_, _):
                            dueDateType = .flexible
                        default:
                            self.date = .now
                        }
                        hasDate = task.dueDate != nil
                    case .deferDate:
                        if let deferDate = task.deferDate {
                            self.date = deferDate
                        } else {
                            self.date = .now
                        }
                        hasDate = task.deferDate != nil
                    }
                    
                }
                .onChange(of: dueDateType) { newValue in
                    switch newValue {
                    case .strict:
                        date = .now
                    case .flexible:
                        task.dueDate = .flexible(0, nil)
                    }
                }
                .onChange(of: date) { newValue in
                    switch datePickerType {
                    case .dueDate:
                        if dueDateType == .strict {
                            task.dueDate = .strict(newValue)
                        }
                    case .deferDate:
                        task.deferDate = newValue
                    }
                }
                .onChange(of: hasDate) { newValue in
                    if datePickerType == .dueDate {
                        if hasDate {
                            task.dueDate = .strict(.now)
                        } else {
                            task.dueDate = nil
                        }
                    } else {
                        if hasDate {
                            task.deferDate = .now
                        } else {
                            task.deferDate = nil
                        }
                    }
                }
                
            }
        }
    }
}

//
//  DueDateToggle.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/27/22.
//

import SwiftUI

extension TaskEditor {
    struct DueDateChip: View {
        private enum DueDateType: String, CaseIterable, Identifiable {
            case strict = "Strict"
            case flexible = "Flexible"
            var id: String { self.rawValue }
        }
        
        @EnvironmentObject private var task: DATask
        
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.presentingField) private var presentingField

        @State private var dueDateType: DueDateType = .strict
        @State private var strictDate: Date = .now
        @State private var hasDate = false
        @State private var presenting = false
        
        
        private var isPresenting: Bool {
            presentingField?.wrappedValue == .dueDate
        }
        
        let dateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            return dateFormatter
        }()

        var body: some View {
            Button {
                if hasDate {
                        presentingField?.wrappedValue = isPresenting ? nil : .dueDate
                }
            } label: {
                // Change text to label with icon and current value
                Toggle(isOn: $hasDate) {
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 25))
                            .bold()
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(.red)
                        VStack {
                            HStack {
                                Text("Due Date")
                                Spacer()
                            }
                            switch task.dueDate {
                            case .strict(let date):
                                HStack {
                                    Text(date, formatter: dateFormatter)
                                        .font(.caption.leading(.tight))
                                        .foregroundColor(.accentColor)
                                    Spacer()
                                }
                            default:
                                EmptyView()
                            }
                        }
                    }
                }
                .foregroundColor(colorScheme == .light ? .black : .white)
                .frame(height: 35)
            }
            .padding(.top, 7)
            .listRowInsets(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
            .padding(.horizontal, 8)
            .safeAreaInset(edge: .bottom, spacing: 0) {
            
                VStack {
                    Picker(selection: $dueDateType) {
                        ForEach(DueDateType.allCases) { dueDateType in
                            Text(dueDateType.rawValue).tag(dueDateType)
                        }
                    } label: {
                        Text("Type")
                    }
                    .padding(.top, 6)
                    .pickerStyle(.segmented)
                    switch dueDateType {
                    case .strict:
                        DatePicker("", selection: $strictDate)
                            .datePickerStyle(.graphical)
                            .listSectionSeparator(.hidden)
                    case .flexible:
                        EmptyView()
                    }
                }
                
                .modifier(AnimatingCellHeight(height: isPresenting ? 395 : 0, binding: $presenting))
            }
            .listRowSeparator(.hidden)
            .onAppear {
                switch task.dueDate {
                case .strict(let date):
                    strictDate = date
                case .flexible(_, _):
                    dueDateType = .flexible
                default:
                    strictDate = .now
                }
                hasDate = task.dueDate != nil
            }
            .onChange(of: dueDateType) { newValue in
                switch newValue {
                case .strict:
                    task.dueDate = .strict(strictDate)
                case .flexible:
                    task.dueDate = .flexible(0, nil)
                }
            }
            .onChange(of: strictDate) { newValue in
                if dueDateType == .strict && hasDate {
                    task.dueDate = .strict(newValue)
                }
            }
            .onChange(of: hasDate) { hasDate in
                if hasDate && task.dueDate == nil {
                    task.dueDate = .strict(.now)
                    presentingField?.wrappedValue = .dueDate
                } else if !hasDate {
                    if isPresenting {
                        presentingField?.wrappedValue = nil
                    }
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + .milliseconds(10)) {
                        task.dueDate = nil
                    }
                }
            }
            .onChange(of: isPresenting) { newValue in
                presenting = newValue
            }
        }
        
    }
}

//
//  DeferDateChip.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/27/22.
//

import SwiftUI

extension TaskEditor {
    struct DeferDateChip: View {
        typealias AnimatableData = CGFloat
        private enum DueDateType: String, CaseIterable, Identifiable {
            case strict = "Strict"
            case flexible = "Flexible"
            var id: String { self.rawValue }
        }
        
        @EnvironmentObject private var task: DATask
        
        @Environment(\.presentingField?.projectedValue) private var presentingField
        @Environment(\.colorScheme) private var colorScheme

        @State private var date: Date = .now
        @State private var hasDate = false
        @State private var presenting = false
        
        
        private var isPresenting: Bool {
            presentingField?.wrappedValue == .deferDate
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
                    presentingField?.wrappedValue = isPresenting ? nil : .deferDate
                }
            } label: {
                // Change text to label with icon and current value
                Toggle(isOn: $hasDate) {
                    
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 25))
                            .bold()
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.gray)
                        VStack {
                            Spacer()
                            HStack {
                                Text("Defer Date")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                                Spacer()
                            }
                            switch task.deferDate {
                            case .some:
                                HStack {
                                    Text(date, formatter: dateFormatter)
                                        .font(.caption.leading(.tight))
                                        .foregroundColor(.accentColor)
                                    Spacer()
                                }
                            case .none:
                                EmptyView()
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 35)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
            .padding(.top, 7)
            .padding(.horizontal, 8)
            .listRowSeparator(.hidden)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                DatePicker("", selection: $date)
                    .datePickerStyle(.graphical)
                    .modifier(AnimatingCellHeight(height: isPresenting ? 355 : 0, binding: $presenting))
            }
            .safeAreaInset(edge: .top, alignment: .trailing, spacing: 0) {
                Divider()
                    .foregroundStyle(.secondary)
                    .padding(.trailing, -13)
                    .padding(.leading, 49)
            }
            .onAppear {
                if let deferDate = task.deferDate {
                    date = deferDate
                }
                hasDate = task.deferDate != nil
            }
            .onChange(of: date) { newValue in
                task.deferDate = newValue
            }
            .onChange(of: hasDate) { hasDate in
                if hasDate && task.deferDate == nil {
                    task.deferDate = date
                    presentingField?.wrappedValue = .deferDate
                    
                } else if !hasDate {
                    if isPresenting {
                            presentingField?.wrappedValue = nil
                    }
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + .milliseconds(10)) {
                        task.deferDate = nil
                    }
                }
            }
            .onChange(of: isPresenting) { newValue in
                presenting = newValue
            }
        }
    }
    
}

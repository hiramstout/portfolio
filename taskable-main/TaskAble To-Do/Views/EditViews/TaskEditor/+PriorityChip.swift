//
//  +PriorityToggle.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/4/22.
//

import SwiftUI

extension TaskEditor {
    struct PriorityChip: View {
        @EnvironmentObject private var task: DATask
        
        @Environment(\.presentingField) private var presentingField
        @Environment(\.colorScheme) private var colorScheme
        
        @State private var priority: DATask.Priority = .low
        @State private var hasPriority = false
        @State private var presenting = false
        
        private var isPresenting: Bool { presentingField?.wrappedValue == .priority }
        
        var body: some View {
            Button {
                if hasPriority {
                    presentingField?.wrappedValue = !isPresenting ? .priority : nil
                }
            } label: {
                Toggle(isOn: $hasPriority)  {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 25))
                            .bold()
                        Spacer()
                        VStack {
                            HStack {
                                Text("Priority")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                                Spacer()
                            }
                            
                            HStack {
                                switch task.priority {
                                case .some:
                                    Text(priority.name)
                                        .font(.caption.leading(.tight))
                                        .foregroundColor(.accentColor)
                                    Spacer()
                                case .none:
                                    EmptyView()
                                }
                            }
                        }
                        .animation(.easeInOut, value: task.priority == nil)
                        Spacer()
                    }
                }
                .frame(height: 35)
            }
            .toggleableFieldEditor(
                height: presenting ? 50 : 0,
                binding: $presenting
            ) {
                Picker("Priority", selection: $priority) {
                    ForEach(DATask.Priority.allCases) { priority in
                        Text(priority.name).tag(priority)
                    }
                }
                .padding(.top, 5)
                .pickerStyle(.segmented)
            }
            .onChange(of: priority) { newValue in
                task.priority = newValue
            }
            .onAppear {
                hasPriority = (task.priority != nil) ? true : false
                priority = task.priority ?? .low
            }
            .onChange(of: hasPriority) { hasPriority in
                if hasPriority && task.priority == nil {
                    task.priority = .low
                        presentingField?.wrappedValue = .priority
                } else if !hasPriority {
                    if isPresenting {
                            presentingField?.wrappedValue = nil
                    }
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + .milliseconds(10)) {
                        
                        task.priority = nil
                    }
                    
                }
            }
            .onChange(of: isPresenting) { newValue in
                    presenting = newValue
            }
        }
    }
}

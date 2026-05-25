//
//  DurationToggle.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/1/22.
//

import SwiftUI

extension TaskEditor{
    struct DurationChip: View {
        @EnvironmentObject private var task: DATask
        
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.presentingField) private var presentingField
        
        @State var duration = DurationData()
        @State var hasDuration = false
        @State private var presenting = false
        
        private var isPresenting: Bool {
            presentingField?.wrappedValue == .duration
        }
        
        var body: some View {
            Button {
                if hasDuration {
                    presentingField?.wrappedValue = isPresenting ? nil : .duration
                }
            } label: {
                // Change text to label with icon and current value
                Toggle(isOn: $hasDuration) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 25))
                            .bold()
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(.cyan)
                            .padding(.trailing, 1)
                        VStack {
                            HStack {
                                Text("Duration")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                                Spacer()
                            }
                            switch task.duration {
                            case .some:
                                HStack {
                                    Text("\(duration.hours) h \(duration.minutes) m" )
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
            }
            .padding(.top, 7)
            .padding(.horizontal, 8)
            .listRowInsets(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HStack(spacing: 0) {
                    NumPickerWheel(
                        numArray: Array(0..<24),
                        title: "Hours",
                        selection: $duration.hours)
                    Spacer()
                    NumPickerWheel(
                        numArray: Array(0..<60),
                        title: "Min",
                        selection: $duration.minutes)
                }
                .modifier(AnimatingCellHeight(height: isPresenting ? 200 : 0, binding: $presenting))
            }
            .safeAreaInset(edge: .top, alignment: .trailing, spacing: 0) {
                Divider()
                    .foregroundStyle(.secondary)
                    .padding(.trailing, -13)
                    .padding(.leading, 49)
            }
            .onChange(of: duration) { newValue in
                if hasDuration {
                    task.duration = newValue.rawValue
                }
            }
            .onAppear {
                if let duration = task.duration {
                    self.duration = DurationData(rawValue: duration)
                }
                hasDuration = task.duration != nil
            }
            .onChange(of: hasDuration) { hasDuration in
                if hasDuration && task.duration == nil {
                    task.duration = duration.rawValue
                        presentingField?.wrappedValue = .duration
                } else if !hasDuration {
                    task.duration = nil
                    if isPresenting {
                        presentingField?.wrappedValue = nil
                    }
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + .milliseconds(10)) {
                        task.duration = nil
                    }
                }
            }
            .onChange(of: isPresenting) { newValue in
                    presenting = newValue
            }
        }
        
        struct NumPickerWheel: View {
            let numArray: Array<Int>
            let title: String
            @Binding var selection: Int
            
            var body: some View {
                ZStack {
                    HStack {
                        Spacer()
                        Text(title)
                            .padding(.trailing, 32)
                    }
                    Picker(title, selection: $selection) {
                        ForEach(numArray, id: \.self) { num in
                            HStack {
                                Text("\(num)")
                                    .padding(.leading, 25)
                                Spacer()
                            }
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
        }
        
        struct DurationData: Hashable, RawRepresentable {
            var minutes = 1
            var hours = 0
            
            var rawValue: TimeInterval {
                TimeInterval(minutes * 60 + hours * (60 * 60))
            }
            
            init!(rawValue: Double) {
                hours = Int(rawValue/(60*60))
                minutes = Int(rawValue/60)
            }
            init(minutes: Int = 0, hours: Int = 0) {
                self.minutes = minutes
                self.hours = hours
            }
        }
    }
}

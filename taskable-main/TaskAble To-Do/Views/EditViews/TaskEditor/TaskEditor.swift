//
//  TaskEditView.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/29/22.
//


// TODO: Update title field to have an edit button and put a "complete" button to the right

import SwiftUI
import CoreData

struct TaskEditor: View {
    enum PresentingField: Equatable {
        case reminders(Double)
        case priority
        case deferDate
        case dueDate
        case duration
    }
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.rootContext) private var rootContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var taskConfig: ChildContextConfig<DATask>
    
    @State private var presenting: PresentingField? = .none
    
    // TODO: Cancel and Done nav buttons only should show on primary view
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Form {
                    Section {
                        TextField("Title", text: $taskConfig.object.title)
                            .textFieldClearable(text: $taskConfig.object.title)
                        ZStack {
                            TextEditor(text: $taskConfig.object.notes)
                                .font(.subheadline)
                                .frame(minHeight: 50)
                                
                            if taskConfig.object.notes.isEmpty {
                                HStack {
                                    VStack {
                                        Text("Notes")
                                            .foregroundColor(Color(.placeholderText))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 8)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    Section("Organization") {
                        HeaderSection()
                    }
                    Section("Time") {
                        
                        DueDateChip()
                        DeferDateChip()
                        DurationChip()
                        // Add text for how many reminders are remaining
                        NavigationLink {
                            RemindersSection()
                                .environmentObject(taskConfig.object)
                                .environment(\.presentingField, $presenting.animation(.easeInOut))
                        } label: {
                            HStack {
                                Image(systemName: "alarm.fill")
                                    .font(.system(size: 25))
                                    .bold()
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(Color(uiColor: .systemTeal))
                                    .padding(.leading, 2)
                                Spacer(minLength: 10)
                                VStack {
                                    HStack {
                                        Text("Reminders")
                                        Spacer()
                                    }
                                    HStack {
                                        switch taskConfig.object.reminders.count {
                                        case 0:
                                            EmptyView()
                                        default:
                                            Text("\(taskConfig.object.reminders.count) total scheduled")
                                                .font(.caption.leading(.tight))
                                                .foregroundColor(.accentColor)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                        .safeAreaInset(edge: .top, alignment: .trailing, spacing: 0) {
                            Divider()
                                .foregroundStyle(.secondary)
                                .padding(.trailing, -30)
                                .padding(.leading, 41)
                                .padding(.top, -4)
                        }
                    }
                    Section("Tags") {
                        TagSection()
                    }
                }
                .environment(\.presentingField, $presenting.animation(.easeInOut))
                .environmentObject(taskConfig.object)
                .environment(\.managedObjectContext, moc)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        try! taskConfig.childContext.save()
                        try! rootContext.save()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        
        
    }
    
    struct AnimatingCellHeight: Animatable, ViewModifier {
        var height: CGFloat
        @Binding var binding: Bool
        
        init(height: CGFloat, binding: Binding<Bool>) {
            self.height = height
            self._binding = binding
        }
        
        var animatableData: CGFloat {
            get { height }
            set { height = newValue }
        }

        func body(content: Content) -> some View {
            VStack {
                Spacer()
                content
                    .frame(height: animatableData, alignment: .top)
                    .clipped()
                    .disabled(!binding)
            }
            .animation(.easeInOut, value: binding)
        }
    }
    
    struct TogglableFieldEditor<EditorInset: View>: ViewModifier {
        var editorInset: EditorInset
        var height: CGFloat
        @Binding var binding: Bool
        
        init(height: CGFloat, binding: Binding<Bool>, @ViewBuilder _ editorInset: ()->EditorInset) {
            self.editorInset = editorInset()
            self.height = height
            self._binding = binding
        }
        
        func body(content: Content) -> some View {
            content
                .padding(.top, 5)
                .listRowInsets(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
                .padding(.horizontal, 7)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    editorInset
                        .modifier(AnimatingCellHeight(height: height, binding: $binding))
                }
        }
    }
}

extension View {
    func toggleableFieldEditor<EditorInset: View>(
        height: CGFloat,
        binding: Binding<Bool>,
        @ViewBuilder _ editorInset: ()->EditorInset
    ) -> some View {
        self.body
            .modifier(TaskEditor.TogglableFieldEditor(height: height, binding: binding, editorInset))
    }
}

//struct TaskEditView_Previews: PreviewProvider {
//    static let dataController = DataController(inMemory: true)
//
//    static var previews: some View {
//        TaskEditor()
//            .environment(\.managedObjectContext, dataController.container.viewContext)
//
//    }
//}

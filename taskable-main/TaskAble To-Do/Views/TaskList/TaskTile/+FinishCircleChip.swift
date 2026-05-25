//
//  +FinishCircleChip.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/25/22.
//

import SwiftUI

extension TaskTile {
    struct FinishCircleChip: View, Animatable {
        
        @Binding var animatableData: AnimatableData
        
        @EnvironmentObject private var task: DATask
        
        @Environment(\.managedObjectContext) private var moc
        @Environment(\.colorScheme) private var colorScheme
        
        private let buttonWidth: CGFloat = 36
        private let buttonPadding: CGFloat = 12
        
        var Placeholder: some View {
            Circle()
                .frame(width: buttonWidth, alignment: .center)
                .padding(.horizontal, buttonPadding)
                .foregroundStyle(.clear)
        }
        private var primary: Color {
            Color(
                red: Self.completedPrimaryComponents.red * animatableData
                + Self.unCompletedPrimaryComponents.red * (1 - animatableData),
                green: Self.completedPrimaryComponents.green * animatableData
                + Self.unCompletedPrimaryComponents.green * (1 - animatableData),
                blue: Self.completedPrimaryComponents.blue * animatableData
                + Self.unCompletedPrimaryComponents.blue * (1 - animatableData),
                opacity: Self.completedPrimaryComponents.alpha * animatableData
                + Self.unCompletedPrimaryComponents.alpha * (1 - animatableData)
            )
        }
        private var secondary: Color {
            let completedSecondary = (colorScheme == .light)
                ? Self.completedSecondaryComponentsLight
                :  Self.completedSecondaryComponentsDark
            let unCompletedSecondary = Self.unCompletedSecondaryComponents
            return Color(
                red: completedSecondary.red * animatableData
                + unCompletedSecondary.red * (1 - animatableData),
                green: completedSecondary.green * animatableData
                + unCompletedSecondary.green * (1 - animatableData),
                blue: completedSecondary.blue * animatableData
                + unCompletedSecondary.blue * (1 - animatableData),
                opacity: completedSecondary.alpha * animatableData
                + unCompletedSecondary.alpha * (1 - animatableData)
            )
        }
        
        var body: some View {
            Button {
                switch task.status {
                case .completed:
                    withAnimation(.linear(duration: 0.15)) {
                        animatableData = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                        task.status = .needsDesignation
                        try! moc.save()
                    }
                default:
                    withAnimation(.linear(duration: 0.15)) {
                        animatableData = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                        task.status = .completed
                        try! moc.save()
                    }
                }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        primary,
                        secondary
                    )
                    .font(.system(size: buttonWidth))
                    .fontWeight(.bold)
                    .frame(width: buttonWidth, alignment: .center)
                    .padding(.horizontal, buttonPadding)
                    .overlay {
                        Circle()
                            .stroke(Color(uiColor: .darkGray), lineWidth: 2.0)
                            .frame(width: buttonWidth)
                    }
            }
            .onAppear {
                animatableData = task.status == .completed ? 1 : 0
            }
        }
        
        struct ColorComponents {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
        }
        
        private static let completedPrimaryComponents: ColorComponents = {
            var completedPrimary = ColorComponents()
            guard UIColor.systemFill
                .withAlphaComponent(0.8)
                .getRed(
                    &completedPrimary.red,
                    green: &completedPrimary.green,
                    blue: &completedPrimary.blue,
                    alpha: &completedPrimary.alpha
            ) == true else {
                fatalError("unable to convert completed primary color")
            }
            return completedPrimary
        }()
        private static let completedSecondaryComponentsLight: ColorComponents = {
            var completedSecondary = ColorComponents()
            var color: UIColor = UIColor()
            UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
                color = UIColor(named: "Status: Green (Completed)")!
            }
            
            guard color.getRed(
                &completedSecondary.red,
                green: &completedSecondary.green,
                blue: &completedSecondary.blue,
                alpha: &completedSecondary.alpha
            ) == true else {
                fatalError("unable to convert completed secondary color")
            }
            return completedSecondary
        }()
        private static let completedSecondaryComponentsDark: ColorComponents = {
            var completedSecondary = ColorComponents()
            var color: UIColor = UIColor()
            UITraitCollection(userInterfaceStyle: .dark).performAsCurrent {
                color = UIColor(named: "Status: Green (Completed)")!
            }
            
            guard color.getRed(
                &completedSecondary.red,
                green: &completedSecondary.green,
                blue: &completedSecondary.blue,
                alpha: &completedSecondary.alpha
            ) == true else {
                fatalError("unable to convert completed secondary color")
            }
            return completedSecondary
        }()
        private static let unCompletedPrimaryComponents = ColorComponents(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0
        )
        private static let unCompletedSecondaryComponents: ColorComponents = {
            var unCompletedSecondary = ColorComponents()
            guard UIColor.systemFill
                .getRed(
                    &unCompletedSecondary.red,
                    green: &unCompletedSecondary.green,
                    blue: &unCompletedSecondary.blue,
                    alpha: &unCompletedSecondary.alpha
            ) == true else {
                fatalError("unable to convert uncompleted secondary color")
            }
            return unCompletedSecondary
        }()
    }
}

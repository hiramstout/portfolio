//
//  ArticleTile.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 2/23/23.
//

import SwiftUI

struct ArticleTile: View {
    var body: some View {
        VStack {
            ZStack {
                Image("Article Background")
                    .resizable()
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 15).inset(by: 5))
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(lineWidth: 5)
                    .foregroundStyle(.thinMaterial)
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(height: 110)
                            .foregroundStyle(.regularMaterial)
                        HStack {
                            VStack {
                                Image(systemName: "list.bullet.rectangle.portrait.fill")
                                    .symbolRenderingMode(.monochrome)
                                    .padding(.leading)
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 35))
                                    .frame(alignment: .topLeading)
                            }
                            VStack {
                                HStack{
                                    Text("More than Just Motivation")
                                        .padding(.top, 13)
                                        .font(.title2)
                                    Spacer()
                                }
                                HStack {
                                    Text("Learn about executive function - and how there is more to your success than determination and brute force")
                                        .font(.subheadline)
                                    Spacer()
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    .frame(height: 110, alignment: .top)
                    Spacer()
                }
                
                .clipShape(RoundedRectangle(cornerRadius: 15).inset(by: 5))
            }
            .padding(.horizontal, 10)
            .frame(height: 350)
            Spacer()
        }
    }
}

struct ArticleTile_Previews: PreviewProvider {
    static var previews: some View {
        ArticleTile()
    }
}

//
//  ContextMenuBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 23/04/24.
//

import SwiftUI

struct ContextMenuBootCamp: View {
    var body: some View {
        VStack(alignment:.leading,spacing: 10.0) {
            Image(systemName: "house.fill")
                .font(.title)
            Text("SwiftUI Thinking")
                .font(.headline)
            Text("How to use context Menu")
                .font(.subheadline)
        }
        .foregroundColor(Color.white)
        .padding(30)
        .background(Color.red.cornerRadius(10.0))
        .contextMenu(menuItems: {
            Button(action: {
                
            }
            , label: {
                Label("Button 1", systemImage: "flame.fill")
            })
            Text("Edit")
            Text("Add")
            Text("Remove")
        })
        
    }
}

#Preview {
    ContextMenuBootCamp()
}

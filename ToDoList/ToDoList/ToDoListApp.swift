//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Jaideep Singh on 29/05/24.
//

import SwiftUI

@main
struct ToDoListApp: App {
     @State var listViewModel : ListViewModel = ListViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                ListView()
            }
            .environmentObject(listViewModel)
            
        }
    }
}

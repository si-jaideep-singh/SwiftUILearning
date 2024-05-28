//
//  ViewModelBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 24/04/24.
//

import SwiftUI


struct fruitModel : Identifiable{
    let id: String = UUID().uuidString
    let name: String
    let count : Int
    
}

struct ViewModelBootCamp: View {
    @State var fruits : [fruitModel] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(fruits){
                    fruit in
                    HStack {
                        Text("\(fruit.count)")
                        Text(fruit.name)
                    }
                }
                .onDelete(perform: deleteFruits)
            }
             .listStyle(.grouped)
            .onAppear() {
                getfruits()
            }
        }
    }
    
    
    func deleteFruits(index : IndexSet){
        fruits.remove(atOffsets: index)
    }
    
    
    func getfruits() {
        let fruit1 = fruitModel(name: "Orange", count: 10)
        let fruit2 = fruitModel(name: "Banana", count: 100)
        let fruit3 = fruitModel(name: "Grapes", count: 50)
        
        fruits.append(fruit1)
        fruits.append(fruit2)
        fruits.append(fruit3)
    }
}


#Preview {
    ViewModelBootCamp()
}

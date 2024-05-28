//
//  ListsBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 22/04/24.
//

import SwiftUI

struct ListsBootCamp: View {
    @State var fruits : [String] = ["apple","orange","peaches","banana"]
    @State var veggies : [String] = ["potato","tomato","cabbage","bringal"]
    var body: some View {
        NavigationView{
            List{
                Section(header:Text("Fruits")) {
                    ForEach(fruits,id: \.self) {
                        fruit in
                        Text(fruit.capitalized)
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: move)
                    .listRowBackground(Color.red)
                }
                Section(header:Text("Veggies")) {
                    ForEach(veggies,id: \.self) {
                        veggies in
                        Text(veggies.capitalized)
                    }
                }
                
            }
            
            .listStyle(.insetGrouped)
            .navigationTitle("Grocery List")
            .navigationBarItems(leading: EditButton(),trailing: addButton)
            .accentColor(.red)
            
        }
        
    }
    
    var addButton : some View {
        Button("Add",action :{
            add()
        })
    }
    
    func add(){
        fruits.append("Cocunut")

    }
    
    func delete(indexSet: IndexSet) {
        fruits.remove(atOffsets: indexSet)
    }
    
    func move(indices : IndexSet , newOffSet : Int)
    {
        fruits.move(fromOffsets: indices, toOffset: newOffSet)
    }
}

#Preview {
    ListsBootCamp()
}

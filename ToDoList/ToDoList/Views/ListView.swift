//
//  ListView.swift
//  ToDoList
//
//  Created by Jaideep Singh on 29/05/24.
//

import SwiftUI

struct ListView: View {
    
    @EnvironmentObject var listviewModel : ListViewModel
    
    var body: some View {
        List {
            ForEach(listviewModel.items){item in
                ListRowView(item: item)
                    .onTapGesture {
                        withAnimation(.linear){
                            listviewModel.updateItem(item: item)
                        }
                    }
                
            }
            .onDelete(perform: listviewModel.deleteItem)
            .onMove(perform: listviewModel.moveItem)
            
            
        }
        .listStyle(PlainListStyle())
        .navigationTitle("To do List 📝")
        .navigationBarItems(leading: EditButton(),
                            trailing: NavigationLink("Add", destination:AddView()))
    }
}

#Preview {
    NavigationView {
        ListView()
    }
    .environmentObject(ListViewModel())
}


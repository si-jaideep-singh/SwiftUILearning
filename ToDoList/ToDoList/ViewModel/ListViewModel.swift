//
//  ListViewModel.swift
//  ToDoList
//
//  Created by Jaideep Singh on 29/05/24.
//

import Foundation

class ListViewModel : ObservableObject{
    @Published var items: [ItemModel] = [] {
        didSet{
            saveItem()
        }
    }
    let itemKey : String = "items_list"
    
    init(){
        getItems()
        
    }
    func getItems() {
//        let newItems = [ItemModel(title: "This is first item", isComplete: false),
//                        ItemModel(title: "This is second item", isComplete: true),
//                        ItemModel(title: "Third" , isComplete: true)]
//        
//        items.append(contentsOf: newItems)
        guard let data = UserDefaults.standard.data(forKey: itemKey) else {
            return
        }
       guard let savedItems = try? JSONDecoder().decode([ItemModel].self,from :data) else { return }
        self.items = savedItems
    }
    
    func deleteItem(indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
        saveItem()
    }
    
    func moveItem(from:IndexSet,to: Int){
        items.move(fromOffsets: from, toOffset: to)
        saveItem()
    }
    
    func AddItem(title : String)
    {
        let newItem = ItemModel(title: title, isComplete: false)
        items.append(newItem)
        saveItem()
    }
    
    func updateItem(item : ItemModel) {
        if let index = items.firstIndex(where: { $0.id == item.id}){
            items[index] = item.updateCompletion()
            saveItem()
        }
        
    }
    
    func saveItem() {
        if let encodedData =  try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encodedData, forKey: itemKey)
        }
        
    }
}

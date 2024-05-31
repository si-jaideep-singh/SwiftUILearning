//
//  ItemModel.swift
//  ToDoList
//
//  Created by Jaideep Singh on 29/05/24.
//

import Foundation


struct ItemModel : Identifiable,Codable {
    var id:String =  UUID().uuidString
    let title:String
    let isComplete:Bool
    
    init( id: String = UUID().uuidString, title: String, isComplete: Bool) {
        self.id = UUID().uuidString
        self.title = title
        self.isComplete = isComplete
    }
    
    func updateCompletion() -> ItemModel{
        return ItemModel(id: id, title: title, isComplete: !isComplete)
    }
    
}

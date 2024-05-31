//
//  ListRowView.swift
//  ToDoList
//
//  Created by Jaideep Singh on 29/05/24.
//

import SwiftUI
 
struct ListRowView: View {
    let item : ItemModel
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .foregroundColor(item.isComplete ? .green : .white)
            Text(item.title)
            Spacer()
        }
        .font(.title2)
        .padding(.vertical,10)
    }
}


struct ListRowView_Previews : PreviewProvider {
    static var item1 = ItemModel(title: "First item!", isComplete: false)
    static var item2 = ItemModel(title: "Second item", isComplete: true)
    
    static var previews: some View {
        Group{
            ListRowView(item: item1)
            ListRowView(item: item2)
        }
        .previewLayout(.sizeThatFits)
       
    }
}

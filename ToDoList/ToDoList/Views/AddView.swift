//
//  AddView.swift
//  ToDoList
//
//  Created by Jaideep Singh on 29/05/24.
//

import SwiftUI

struct AddView: View {
    @State var textfieldText : String = ""
   @Environment(\.presentationMode) var PresentationMode
   @EnvironmentObject var listViewModel : ListViewModel
    
    @State var alertTitle: String = ""
    @State var showAlert:Bool = false
    var body: some View {
        ScrollView {
            VStack {
                TextField("Type something here...",text: $textfieldText)
                    .padding(.horizontal)
                    .frame(height: 55)
                    .background(Color.secondary)
                    .cornerRadius(10)
                
                Button(action:saveButtonPressed, label: {
                    Text("Save".uppercased())
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                })
                
            }
           
            .padding()
           
               
            
        }
        .navigationTitle("Add an item 🖊️ ")
        .alert(isPresented: $showAlert, content: getAlert)
    }
    func saveButtonPressed(){
        
        if isAppropriate(){
            
            listViewModel.AddItem(title: textfieldText)
//            presenationMode.wrappedValue.dismiss()
            PresentationMode.wrappedValue.dismiss()
          
            
        }
     
    }
    
    func isAppropriate() ->Bool{
        if textfieldText.count < 3 {
            alertTitle = "Your new todo item must be a 3 characters atleast"
            showAlert.toggle()
            return  false
        }
        return true
    }
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
        
    }
}

#Preview {
    NavigationView{
        AddView()
    }
}

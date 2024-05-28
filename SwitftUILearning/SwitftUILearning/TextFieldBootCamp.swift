//
//  TextFieldBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 23/04/24.
//

import SwiftUI

struct TextFieldBootCamp: View {
    @State var textfield : String = ""
    @State var dataarray : [String] = []
    var body: some View {
        
        NavigationView {
            VStack  {
                TextField("Enter your Name", text: $textfield)
                    .padding()
                    .background(Color.gray.opacity(0.3).cornerRadius(10))
                    .foregroundColor(.red)
                    .font(.headline)
                
                Button(action:
                         {
                        if appropriateText() {
                            SaveText()
                            }
                    else {
                        Alert(title: Text("Check"))
                    }
                   
                }, label: {
                    Text("Save".uppercased())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.cornerRadius(10))
                        .foregroundColor(.white)
                        .font(.headline)
                })
                
                ForEach(dataarray, id: \.self, content: {
                    data in
                    Text(data)
                })
                
                
                Spacer()
                
            }
            .navigationTitle("TextField BootCamp")
            .padding()
            
        }
    }
    func appropriateText() -> Bool
    {
        if textfield.count >= 3 {
            return true
        }
        else {
            return false
        }
    }
    
    func SaveText(){
        dataarray.append(textfield)
        textfield = ""
        
    }
}

#Preview {
    TextFieldBootCamp()
}

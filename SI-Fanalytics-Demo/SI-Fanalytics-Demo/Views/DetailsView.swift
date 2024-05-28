//
//  DetailsView.swift
//  SI-Fanalytics-Demo
//
//  Created by Jaideep Singh on 15/05/24.
//

import SwiftUI

struct DetailsView: View {
    @State private var textField1: String = ""
      @State private var textField2: String = ""
      @State private var textField3: String = ""
      @State private var textField4: String = ""

      var body: some View {
          VStack {
             
              TextField("FirstName", text: $textField1)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .padding()
              TextField("LastName.", text: $textField2)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .padding()
              TextField("Mob", text: $textField3)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .padding()
              TextField("Email", text: $textField4)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .padding()

              
              Button(action: {
                 
                  print("Submit button tapped!")
              }) {
                  Text("Submit")
                      .padding()
                      .background(Color.blue)
                      .foregroundColor(Color.white)
                      .cornerRadius(8)
              }
              .padding()
          }
          .padding()
      }
  }

#Preview {
    DetailsView()
}

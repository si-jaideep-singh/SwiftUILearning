//
//  loginView.swift
//  SI-Fanalytics-Demo
//
//  Created by Jaideep Singh on 15/05/24.
//

import SwiftUI

struct loginView: View {
    var body: some View {
        buttonview()
        
       
            }
        }
#Preview {
    loginView()
}

struct buttonview:View {
    var body: some View {
        VStack {
          Text("Choose an Option")
                    .font(.title)
                    .padding()
                
        HStack {
                    Button(action: {
                        
                        print("First button tapped!")
                    }) {
                        Text("Login")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    Button(action: {
                        
                    }) {
                        Text("Logout")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(Color.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .padding()
       
       }
}

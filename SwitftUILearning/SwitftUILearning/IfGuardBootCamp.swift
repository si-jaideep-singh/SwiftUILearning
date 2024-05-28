//
//  IfGuardBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 24/04/24.
//

import SwiftUI

struct IfGuardBootCamp: View {
    @State var displayText : String? = nil
    @State var currentUserID : String? = nil
    @State var isLoading : Bool = false
    
    var body: some View {
        NavigationView {
            VStack{
                Text("Here we are participating safe coding")
                if let text = displayText {
                    Text(text)
                        .font(.title)
                }
                Spacer()
                
            }
            .navigationTitle("Jaideep")
            .onAppear(){
                loadData()
                
            }
        }
    }
    
    func loadData()  {
        
        if let userID = currentUserID {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                displayText = "Hello World \(userID)"
                isLoading = false
                }
        }
        else {
            displayText = "Error,There is no userId"
            
        }
        
        
        }
}

#Preview {
    IfGuardBootCamp()
}

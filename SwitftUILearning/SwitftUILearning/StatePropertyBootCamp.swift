//
//  StatePropertyBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 18/04/24.
//

import SwiftUI

struct StatePropertyBootCamp: View {
    @State var backgroundColor :Color = Color.green
    @State var Title : String = "Hello Jaideep"
    @State var count:Int = 0
    var body: some View {
        ZStack{
           backgroundColor
            
            VStack(spacing:20){
                Text(Title)
                Text("Count: \(count)")
                HStack{
                    Button("Button 1"){
                        backgroundColor = .red
                        Title = "Button 1 was Pressed"
                        count += 1
                        
                    }
                    Button("Button 2"){
                        backgroundColor = .yellow
                        Title = "Button 2 was Pressed"
                        count -= 1
                        
                        }
                }
                
            }
            
            .foregroundColor(.white)
        }
    }
}
#Preview {
    StatePropertyBootCamp()
}

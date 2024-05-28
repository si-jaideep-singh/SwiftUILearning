//
//  ButtonsBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 18/04/24.
//

import SwiftUI

struct ButtonsBootCamp: View {
    @State var title : String = "Hello This is jaideep"
    var body: some View {
       
        VStack(spacing:20) {
            Text(title)
            
            Button("Press me") {
                self.title = "Button was Pressed"
            
            }
            
            Button(action: {
                self.title = "Button #2 was Pressed"
            }, label: {
                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
            })
        }
    }
}

#Preview {
    ButtonsBootCamp()
}

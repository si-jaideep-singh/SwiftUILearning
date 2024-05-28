//
//  BindingPropertyBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 18/04/24.
//

import SwiftUI

struct BindingPropertyBootCamp: View {
    @State var backgroundColor : Color = Color.red
    @State var title:String = ""
    var body: some View {
        ZStack {
            backgroundColor
            VStack {
                Text("This is title")
                    .foregroundColor(.white)
                ButtonView(backgroundColor: $backgroundColor)
            }
        }
    }
}

struct ButtonView : View {
    @Binding var backgroundColor: Color
    @State var buttonColor: Color = Color.blue
    
    var body: some View{
        Button(action: {
            backgroundColor = Color.orange
            buttonColor = Color.pink
            
        }
         ,label: {
            /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
                .foregroundColor(.white)
                .padding()
                .padding(.horizontal)
                .background(buttonColor)
                .cornerRadius(10)
        })

    }
}


#Preview {
    BindingPropertyBootCamp()
}

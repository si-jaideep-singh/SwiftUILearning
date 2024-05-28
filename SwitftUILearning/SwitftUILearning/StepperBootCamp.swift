//
//  StepperBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 23/04/24.
//

import SwiftUI

struct StepperBootCamp: View {
    @State var steppperValue : Int = 10
    @State var widthincrement : CGFloat = 0
    @State var sliderValue : CGFloat = 10
    var body: some View {
        
//        Stepper("Stepper : \(steppperValue)", value: $steppperValue)
//            .padding(50)
//        
//        RoundedRectangle(cornerRadius: 25.0)
//            .frame(width: 100 + widthincrement,height: 100)
//        
//        
//        Stepper("Stepper 2")
//                
//                    {
//            widthincrement += 10
//            
//        }
//                onDecrement: {
//            widthincrement -= 10
//            
//        }
        Text("Rating")
        Text("\(sliderValue)")
        Slider(value: $sliderValue)
            
//
        }
    
}

#Preview {
    StepperBootCamp()
}

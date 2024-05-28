//
//  InitializerBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 18/04/24.
//

import SwiftUI

struct InitializerBootCamp: View {
    
    let backgroundColor : Color
    let count: Int
    let title:String
    
    init(count: Int, fruit: Fruit) {
        self.count = count
        
        if fruit == .apple{
            self.backgroundColor = .red
            self.title = "Apples"
        }
        else {
            self.backgroundColor = .orange
            self.title = "Oranges"
        }
    }
        
        enum Fruit {
            case apple
            case orange
        }
    
    
    var body: some View {
        VStack{
            Text("\(count)")
                .font(.largeTitle)
                .foregroundColor(Color.white)
                .underline()
          
            Text("\(title)")
                .font(.headline)
                .foregroundColor(.white)
            
            
        }
        // .padding()
        .frame(width: 150,height: 150)
        .background(backgroundColor)
        .cornerRadius(10.0)
        
    
    
    }
}

#Preview {
    HStack{
        InitializerBootCamp(count: 10, fruit: .apple)
        InitializerBootCamp(count: 10, fruit: .orange)
    }
}

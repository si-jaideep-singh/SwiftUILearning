//
//  TextBootcamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 15/04/24.
//

import SwiftUI

struct TextBootcamp: View {
    var body: some View {
        Text("Hello, World! This is Jaideepsingh Chauhan")
           .font(.largeTitle)
            .fontWeight(.heavy)
           // .font(.caption)
           // .strikethrough(true,color: Color.white)
           // .font(.system(size: 10, weight: .semibold, design: .rounded))
            //.baselineOffset(1)
            //.kerning(10)
            .multilineTextAlignment(.leading)
            .foregroundColor(.gray)
          //  .underline(true,color: .red)
            //  .frame(width : 100, height : 20 ,alignment: .center)
        
    }
}

#Preview {
    TextBootcamp()
}

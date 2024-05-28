//
//  ForEachBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 18/04/24.
//

import SwiftUI

struct ForEachBootCamp: View {
    let data : [String] = ["HI", "Hello","Bye"]
    let myString: String = "Hello"
    var body: some View {
       
            VStack(alignment:.leading) {
                ForEach(data.indices) {
                    index in Text("\(index): \(data[index])")
                }
                
                ForEach(0..<100){index in
                    Circle()
                        .frame(height: 50)
                    
                }
            }
            .background(Color.red)
        }
    }


#Preview {
    ForEachBootCamp()
}

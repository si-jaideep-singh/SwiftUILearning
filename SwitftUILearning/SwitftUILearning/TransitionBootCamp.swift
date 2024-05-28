//
//  TransitionBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 19/04/24.
//

import SwiftUI

struct TransitionBootCamp: View {
    @State var showView : Bool = false
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack{
                Button("Button"){
                    showView.toggle()
                }
                Spacer()
            }
            if showView {
                RoundedRectangle(cornerRadius: 30.0)
                    .frame(height:UIScreen.main.bounds.height * 0.5)
                    .transition(.slide)
                    .animation(.easeInOut(duration: 5))
            }
        }
    }
}

#Preview {
    TransitionBootCamp()
}

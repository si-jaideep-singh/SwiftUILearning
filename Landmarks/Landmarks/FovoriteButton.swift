//
//  FovoriteButton.swift
//  Landmarks
//
//  Created by Jaideep Singh on 04/04/24.
//

import SwiftUI

struct FovoriteButton: View {
    @Binding var isSet : Bool
    
    var body: some View {
        Button{
            isSet.toggle()
        }
    label:{
        Label("Toggle Favorite", systemImage: isSet ? "star.fill":"star")
            .labelStyle(.iconOnly)
            .foregroundStyle(isSet ? .yellow : .gray)
       }
    }
}

#Preview {
    FovoriteButton(isSet: .constant(true))
}

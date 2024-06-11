//
//  Fixtures.swift
//  SampleProjectSwiftUI
//
//  Created by Jaideep Singh on 07/06/24.
//

import SwiftUI

struct Fixtures: View {
    var body: some View {
        GeometryReader { geometry in
                   VStack {
                       detailsView
                       scoreview
                       bottomView
                   }
                   .frame(width: geometry.size.width, height: geometry.size.height)
                   .background(
                       Image("live_bg")
                           .resizable()
                           .scaledToFill()
                           .frame(width: geometry.size.width, height: geometry.size.height)
                           .clipped()
                   )
               }
               .frame(height: 330) // Set a fixed height for the parent view
           }
    
    
    var scoreview: some View{
        VStack{
            HStack(spacing:0){
                Image("KKR")
                    .resizable()
                    .frame(width: 38,height: 38)
                Text("180/1")
                    .font(.custom(CustomFonts.RubikLight.name, size: 20))
                    .foregroundColor(Color(AppColorName.white_FFFFFF.name))
                Text("(3.0)")
                    .font(.custom(CustomFonts.RubikLight.name, size: 12))
                    .foregroundColor(Color(AppColorName.white_FFFFFF.name))
                
                Spacer()
               Text("VS")
                   .frame(width: 30,height: 30)
                    .font(.custom(CustomFonts.RubikLight.name, size: 12))
                    .foregroundColor(Color(AppColorName.white_FFFFFF.name))
                    .background(Color.gray)
                    .cornerRadius(15)
                   
                    
                Spacer()
                Image("Punjab")
                    .resizable()
                    .frame(width: 38,height: 38)
                Text("180/1")
                    .font(.custom(CustomFonts.RubikBold.name, size: 20))
                    .foregroundColor(Color(AppColorName.white_FFFFFF.name))
                Text("(3.0)")
                    .font(.custom(CustomFonts.RubikLight.name, size: 12))
                    .foregroundColor(Color(AppColorName.white_FFFFFF.name))
                
                
                
                
            }
            .padding()
            HStack{
                Text("Kokkata Knight Riders won by 3 wickets")
                    .font(.custom(CustomFonts.RubikBold.name, size: 12))
                    .foregroundColor(Color(AppColorName.white_FFFFFF.name))
            }
            HStack{
                Text("Powered BY")
                    .font(.custom(CustomFonts.RubikBold.name, size: 12))
                    .foregroundColor(Color(AppColorName.white_FFFFFF.name))
                Spacer()
                Image("Sponsor")
            }
            .padding()
        }
        
    }
    
    var detailsView: some View {
        HStack {
            Text("17 may 2023")
                .font(.custom(CustomFonts.RubikLight.name, size: 12))
                .foregroundColor(Color(AppColorName.white_FFFFFF.name))
           Spacer()
            Text("live")
           
        }
        .padding()
    }
    var bottomView: some View{
        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
           Image("matchcenter")
        })
    }
}



#Preview {
    Fixtures()
}

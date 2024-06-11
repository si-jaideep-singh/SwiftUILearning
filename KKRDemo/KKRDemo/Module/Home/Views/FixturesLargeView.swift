//
//  FixturesLargeView.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 10/06/24.
//

import SwiftUI

struct FixturesLargeView: View {
    var body: some View {
        VStack{
            headerView
        }
    }
    
    var headerView : some View{
        VStack{
            
            HStack{
                Text("Fixtures")
                    .font(.custom(CustomFonts.RubikSemiBold.name, size: 25))
                    .foregroundColor(Color(AppColorName.black_000000.name))
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image("btn_addtocalendar")
                })
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image("btn_download")
                })
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image("view_all_img")
                })
            }
            .padding()
            Fixtures()
        }
    }
}

#Preview {
    FixturesLargeView()
}

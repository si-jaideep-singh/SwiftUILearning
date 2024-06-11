//
//  NewsViews.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 10/06/24.
//

import SwiftUI

struct NewsViews: View {
    var body: some View {
        ZStack(){
                newsInnerView
              
                newsdetailview
           
        }
        .frame(height: 350)
        .background(Color.gray)
        
     
        
       
    }
    
    var newsInnerView : some View
    {
        Image("virat")
                .resizable()
                .frame(width: UIScreen.main.bounds.width,height: 239)
               // .aspectRatio(contentMode: .fit)
                .cornerRadius(20)
          
               
            
            
        
    }
    var newsdetailview : some View{
        VStack(alignment: .leading,spacing: 10){
        
          
            Text("Match Higtlights")
                .font(.custom(CustomFonts.RubikMedium .name,size: 12))
                .foregroundColor(Color(AppColorName.purple_3A225D.name))
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
            
            
                .background {
                    Color(AppColorName.grey_EFEFEF.name)
                    
                }
                .cornerRadius(15)
              
           
            
            Text("KKR vs LSG: Key battles, best bowlers & best batters IPL match...")
                .font(.custom(CustomFonts.RubikMedium .name,size: 15))
                .foregroundColor(Color(AppColorName.purple_3A225D.name))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(.top, 5)

            
            Text("KKR vs LSG: Key battles, best bowlers & best batters IPL match...")
                .font(.custom(CustomFonts.RubikMedium .name,size: 12))
                .foregroundColor(Color(AppColorName.black_2A2A2A.name))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(.top, 5)


            HStack{
                Text("21 May,2024")
                
                    .font(.subheadline)
                Spacer()
                Button(action: {}
                ){
                    Image(AppImagesName.yellow_likebtn.rawValue)
               
                    
                }
                
                
                Rectangle()
                    .frame(width: 2,height: 20)
                Button(action: {}
                ){
                    Image(AppImagesName.btn_share.name)
                    
                }
           
                
            }
        }
     
        .padding()
        
        .frame(width: 320,height: 164)
        .background(Color.red)
        .cornerRadius(10)
        .offset(y : 120)
    }
    
}

#Preview {
    NewsViews()
}

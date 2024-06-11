//
//  VideosView.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 10/06/24.
//

import SwiftUI

struct VideoslargeView: View {
    var body: some View {
              Image("virat")
                .resizable()
                .aspectRatio(3/2,contentMode: .fit)
           
         
                .overlay {
                   TextOverlayView()
                    Image(AppImagesName.play_icon.name)
                     .padding(.bottom,60)
                     .padding(.leading)
                }
                .cornerRadius(10)
                .padding(10)
              
      
        }
        
    }

struct TextOverlayView: View {
    var gradient = Image("black_gradient")
        .resizable()
    
    var body: some View {
            ZStack(alignment: .bottomLeading) {
                
               gradient
              
                    
                VStack(alignment: .leading) {
                    Text("Knights TV")
                        .foregroundColor(.yellow)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                    
                    
                        .background {
                            Color.black
                            }
                        .cornerRadius(15)
                       
                    
                    
                    HStack {
                        Text("KKR vs LSG: Key battles, best bowlers & best batters for IPL match today ")
   
                        }
                    HStack {
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
//                    .padding(.leading,15)
                    .padding(.bottom,15)
                    .padding(.trailing,15)
                    
                    
                }
                .padding(.leading,15)
            }
            .foregroundColor(.white)
        }
    }


#Preview {
    VideoslargeView()
}

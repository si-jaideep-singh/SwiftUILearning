//
//  ListingView.swift
//  SampleProjectSwiftUI
//
//  Created by Jaideep Singh on 05/06/24.
//

import SwiftUI
struct ListingView: View {
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical){
                VStack{
                    
                    PageView(pages: [
                        ShowcaseCard(landmark: landmarks[0]),
                        ShowcaseCard(landmark: landmarks[1])
                    ])
                    
                    
                    
                    Spacer()
                    NavigationLink(destination: NewsDetailsView()){
                        ScrollableView()
                        }
                    
                }
                
                Spacer()
            }
            
        }
    }
}
struct ScrollableView:View {
    
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            VStack(alignment:.leading){
                HStack() {
                    Text("Latest Articles & Press")
                        .font(.custom(CustomFonts.RubikSemiBold.name, size: 18))
                        .padding(.leading)
                        .padding(.top)
                    Spacer()
                    NavigationLink(destination: NewsListingView()){
                        //                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image("viewall_btn")
                        //                    })
                            .padding(.top,10)
                            .padding(.trailing,15)
                    }
                }
                    
                    
                    ScrollView(.horizontal,showsIndicators: false){
                        HStack {
                            ForEach(0..<10){
                                _ in NewsItem()
                                
                            }
                            
                        }
                        
                    }
                }
                VStack(alignment:.leading){
                    HStack {
                        Text("Featured Articles")
                            .font(.custom(CustomFonts.RubikSemiBold.name, size: 18))
                            .padding(.leading)
                            .padding(.top)
                        
                        Spacer()
                        NavigationLink(destination: NewsListingView()){
                            //                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image("viewall_btn")
                            //                    })
                                .padding(.top,10)
                                .padding(.trailing,15)
                        }
                    }
                    
                    ScrollView(.horizontal,showsIndicators: false){
                        VStack(alignment:.leading) {
                            
                            HStack {
                                ForEach(0..<10){
                                    _ in NewsItem()
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        
    }

#Preview {
    ListingView()
}



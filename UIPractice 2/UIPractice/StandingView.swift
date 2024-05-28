//
//  StandingView.swift
//  UIPractice
//
//  Created by Jaideep Singh on 13/05/24.
//

import SwiftUI

struct StandingView: View {
    @State var backgroundcolor: Color = Color.color
    let repeatCount = 20
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack{
                backgroundcolor
                VStack(alignment: .leading, spacing: 10) {
                    HStack(){
                        VStack(spacing:0) {
                            StaticRankView()
                            ForEach(0..<repeatCount) {_ in
                                StaticRankInfoView()
                                Spacer(minLength: 2)
                            }
                        }
                      
                        HStack(spacing:40){
                            Spacer(minLength: 20)
                            VStack{
                                ScrollView(.horizontal){
                                    HScrollableRowHeader()
                                    ForEach(0..<repeatCount) {_ in
                                        HScrollableRow()
                                    }
                                }
                            }
                        }
                    }
                    
                    .padding()
                  .ignoresSafeArea(.all)
                  .navigationTitle("Standings")
                }
            }
        }
    }
        
    
    
    struct StaticRankView: View {
        var body: some View {
            VStack(alignment:.leading, spacing:30) {
                HStack(alignment: .center) {
                    Text("Rank")
                }
                .padding()
                .foregroundColor(.white)
                .font(.headline)
            }
        }
    }
    
    struct HScrollableRow: View {
        var body: some View {
            ScrollView(.horizontal,showsIndicators: false) {
                HStack(alignment:.center,spacing: 60) {
                    Text("51")
                    Text("101")
                    Text("10000")
                    Spacer(minLength: 5)
                    VStack {
                        Text("12")
                            .fontWeight(.bold)
                        Text("Rodryo")
                            .fontWeight(.semibold)
                    }
                    Spacer(minLength: 20)
                    
                    Text("0.9")
                    Spacer()
                    Text("1")
                    Spacer(minLength: 2)
                    Text("2")
                    
                    
                    Text("Not Played Yet")
                    Spacer()
                    VStack {
                        Text("Played")
                            .fontWeight(.bold)
                        Text("MD 2")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundColor(.white)
                .font(.subheadline)
                .padding()
            }
        }
    }
    
    struct HScrollableRowHeader: View {
        var body: some View {
            ScrollView([.horizontal,],showsIndicators: false) {
                HStack(spacing: 10) {
                    HStack {
                        Text("MD 3")
                        VStack(alignment:.leading) {
                            Text("🔺")
                            Text("🔻")
                        }
                        .font(.footnote)
                        
                    }
                     
                    HStack {
                        Text("Total pts")
                        
                        VStack(alignment:.leading) {
                            Text("🔺")
                            Text("🔻")
                        }
                        .font(.footnote)
                        
                    }
                    Spacer(minLength: 10)
                    
                    HStack {
                        Text("Rank")
                        
                        VStack(alignment:.leading) {
                            Text("🔺")
                            Text("🔻")
                        }
                        .font(.footnote)
                        
                    }
                    Spacer(minLength: 10)
                    
                    HStack {
                        Text("Md Top Performer")
                        
                        VStack(alignment:.leading) {
                            Text("🔺")
                            Text("🔻")
                        }
                        .font(.footnote)
                        
                    }
                    Spacer(minLength: 20)
                    HStack {
                        Text("Md pts per 1M")
                        
                        VStack(alignment:.leading) {
                            Text("🔺")
                            Text("🔻")
                        }
                        .font(.footnote)
                        
                    }
                    Spacer(minLength: 15)
                    HStack {
                        Text("Md transfers")
                        
                        VStack(alignment:.leading) {
                            Text("🔺")
                            Text("🔻")
                        }
                        .font(.footnote)
                        
                    }
                    
                    Spacer()
                    Text("Md Stubs")
                    
                    
                    Spacer(minLength: 30)
                    Text("Limitless")
                    Spacer(minLength: 120)
                    Text("WildCard")
                    }
                
                .foregroundColor(.white)
                .font(.subheadline)
                
            }
        }
    }
    
    
    struct StaticRankInfoView: View {
        var body: some View {
            HStack {
                VStack {
                    Text("1")
                    Text("🔺")
                }
                Text("😠")
                
                VStack(alignment:.leading) {
                    Text("Final FantasyXI")
                        .fontWeight(.bold)
                    Text("Rich")
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(Color.white)
            .font(.subheadline)
            .padding(.leading,0)
            
        }
    }
}

#Preview {
    StandingView()
}

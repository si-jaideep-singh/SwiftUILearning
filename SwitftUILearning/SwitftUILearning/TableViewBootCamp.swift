//
//  TableViewBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 23/04/24.
//

import SwiftUI

struct TableViewBootCamp: View {
    @State var tabItem : Int = 0
    var body: some View {
        
        TabView(selection :$tabItem ) {
           HomeView(selectedTab: $tabItem)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home Tab")
                }
                .tag(0)
            Text("Browse Tab")
                .tabItem {
                  Image(systemName: "globe")
                    Text("Browse")
                }
                .tag(1)
            Text(" Profile Tab")
                .tabItem {
                  Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
            
            
        }
    
        
    }
}

#Preview {
    TableViewBootCamp()
}

struct HomeView: View {
    @Binding var selectedTab : Int
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            Text("Home Tab")
                .font(.largeTitle)
                .foregroundStyle(.white)
            
            Button(action: {
                selectedTab = 2
            }, label: {
                Text("Go to Profile")
                    .font(.headline)
                    .padding()
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(10)
            })
            
        }
        
        //            Text("Home")
       
    }
}

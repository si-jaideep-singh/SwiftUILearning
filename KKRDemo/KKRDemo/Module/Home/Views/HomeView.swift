//
//  HomeView.swift
//  SampleProjectSwiftUI
//
//  Created by Darshana Kamble on 28/05/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        // TabBar()
        ScrollView(.vertical){
        VStack{
          
            FixturesLargeView()
             NewsViews()
         
            VideoesView()
                       
           
        }
          
          
          
    }
       
            
           
        
        
    }
}


#Preview {
    
    NavigationView {
        HomeView()
    }
        
}

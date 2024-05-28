//
//  CustomModelBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 24/04/24.
//

import SwiftUI



struct userModel : Identifiable{
    var id: String = UUID().uuidString
    
   // var id: ObjectIdentifier
    
    let displayName : String
    let userName : String
    let folowerCount : Int
    let isverified : Bool
}


struct CustomModelBootCamp: View {
//    @State var users : [String] = ["Jaideep", "kamlesh", "Sunny","Rahul"]
    @State var users : [userModel] = [userModel(displayName: "Jaideep", userName: "jaid@123", folowerCount: 1000, isverified: true),
                                      userModel(displayName: "Rahul", userName: "rah@123", folowerCount: 1000, isverified: false),userModel(displayName: "Sunny", userName: "sunn@123", folowerCount: 1000, isverified: true),userModel(displayName: "Rohan", userName: "ro@123", folowerCount: 1000, isverified: false)
    
    
    ]
    
    var body: some View {
        NavigationView {
            List{
                ForEach(users) {
                    user in
                    HStack(spacing: 15) {
                        Circle()
                            .frame(width: 35,height: 35)
                        
                        HStack {
                            VStack(alignment: .leading){
                                Text(user.displayName)
                                    .font(.headline)
                                Text( "@\(user.userName)")
                                    .foregroundColor(.gray)
                              
                                
                            }
                            Spacer()
                            if user.isverified{
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.blue)
                                    .padding(.trailing ,10)
                            }
                           
                            VStack {
                                Text("\(user.folowerCount)")
                                    .font(.headline)
                                Text("Followers")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                           
                        }
                        
                    }
//                    padding(10)
                    .padding(.vertical,10)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Users")
        }
  }
}

#Preview {
    CustomModelBootCamp()
}

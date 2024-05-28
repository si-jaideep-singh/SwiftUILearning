//
//  AlertBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 23/04/24.
//

import SwiftUI

struct AlertBootCamp: View {
    @State var showAlert : Bool = false
    @State var backgroundColor : Color = Color.yellow
    @State var alertType : MyAlerts? = nil
   // @State var title : String = ""
   // @State var message : String = ""
    
    
    enum MyAlerts {
        case error
        case success
    }
    var body: some View {
        ZStack {
            
            backgroundColor.ignoresSafeArea()
            VStack {
                Button("Button 1" ) {
//                   title = "Error Uploading a Video"
//                   message = "This video could not be uploaded"
                    MyAlerts.error
                    showAlert.toggle()
                }
                Button("Button 2") {
//                    title = "Error Uploading a Photo"
//                    message = "This Photo could not be uploaded"
                    MyAlerts.success
                    showAlert.toggle()
                }
               
                    //Alert(title: Text(" There is an Error"))
                    
            }
            
            .alert(isPresented: $showAlert, content: {
                getAlert()
            })
        }
    }
    
    
    func getAlert() -> Alert {
//        Alert(title:Text("There is an error"),
//              message: Text("Please look into it"),
//              primaryButton: .destructive(Text("Cancel"), action: {
//            backgroundColor = .red
//        }),
//              secondaryButton: .default(Text("Delete")))
//        return Alert(title: Text(title),
//                     message: Text(message),
//                     dismissButton: .default(Text("Ok"))
        
        switch alertType {
        case  .error:
            return Alert(title: Text("Error Occured"),
                         message: Text("Plase look into it"),
                         primaryButton: .cancel(Text("Cancel")),
                         secondaryButton: .destructive(Text("Delete")))
        case .success:
            return Alert(title:Text("Error Aaya"),
                         message: Text("Solve Karo"),
                         primaryButton: .default(Text("Bhai Bhai")),
                         secondaryButton: .default(Text("Delete karo")))
            
        default:
            return Alert(title: Text("Hello Jaideep ,you have to Work Hard"))
            
            
        }
            
        
        
        
    }
}

#Preview {
    AlertBootCamp()
}

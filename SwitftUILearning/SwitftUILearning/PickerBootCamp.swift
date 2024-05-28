//
//  PickerBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 23/04/24.
//

//import SwiftUI
//
//struct PickerBootCamp: View {
//    @State var selection : String = "1"
//    
//    var body: some View {
//        VStack{
//            HStack{
//                Text("Age:")
//                Text(selection)
//            }
//            
//            Picker(selection: $selection ,
//                   label: Text("Picker"),
//                   content :{
//                //            Text("1").tag("1")
//                //            Text("2").tag("2")
//                //            Text("3").tag("3")
//                //            Text("4").tag("4")
//                //            Text("5").tag("5")
//                //            Text("6").tag("6")
//                //
//                ForEach(18..<100) {
//                    number in
//                    Text("\(number)")
//                    font(.headline)
//                        .foregroundColor(.red)
//                        .tag("\(number)")
//                }
//                
//            })
//            .pickerStyle(.wheel)
//        }
//    }
//}
//
//#Preview {
//    PickerBootCamp()
//}

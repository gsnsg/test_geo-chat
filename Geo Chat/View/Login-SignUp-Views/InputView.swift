//
//  InputView.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import SwiftUI


struct InputView: View {
    
    // Types for TextField whether it is secure or not
    enum TextFieldType {
        case text, password
    }
    
    @Binding var text: String
    
    var header: String
    var description: String
    var textFieldType: TextFieldType
  
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(header)
                .font(.system(.headline))
            if textFieldType == .text {
                TextField(description, text: $text)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
            } else {
                SecureField(description, text: $text)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                
            }
            
        }.padding(.bottom)
       
    }
}


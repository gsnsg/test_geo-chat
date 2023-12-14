//
//  ButtonTextView.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import SwiftUI

struct ButtonTextView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .medium))
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.primaryButtonColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ButtonTextView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonTextView(text: "Login")
    }
}

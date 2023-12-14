//
//  CustomBackButton.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import SwiftUI

struct CustomBackButton: View {
    @Binding var dismissParentView: Bool
    
    var body: some View {
        Button(action: {
            self.dismissParentView = true;
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.primaryButtonColor)
        }
    }
}


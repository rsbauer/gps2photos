//
//  CheckedItem.swift
//  gps2photos
//
//  Created by Astro on 1/27/21.
//

import FontAwesomeSwiftUI
import SwiftUI

struct CheckedItem: View {
    var text: String
    var flagValue: Int
    var disabledColor: Color = .gray
    var enableIcon = AwesomeIcon.check.rawValue
    var disableIcon = AwesomeIcon.check.rawValue
    
    @Binding var criteria: Int
    
    var body: some View {
        HStack {
            Text(isEnabled() ? enableIcon : disableIcon)
                .font(.awesome(style: .solid, size: 15))
                .foregroundColor(isEnabled() ? .green : disabledColor)
            Text(text)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
        }
    }
    
    private func isEnabled() -> Bool {
        return criteria & flagValue == flagValue
    }
}

struct CheckedItemBool: View {
    var text: String
    var disabledColor: Color = .gray
    var enableIcon = AwesomeIcon.check.rawValue
    var disableIcon = AwesomeIcon.check.rawValue

    @Binding var isEnabled: Bool

    var body: some View {
        HStack {
            Text(isEnabled ? enableIcon : disableIcon)
                .font(.awesome(style: .solid, size: 15))
                .foregroundColor(isEnabled ? .green : disabledColor)
            Text(text)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
        }
    }
}

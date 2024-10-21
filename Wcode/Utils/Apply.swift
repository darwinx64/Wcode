//
//  Apply.swift
//  Wcode
//
//  Created by paige on 10/21/24.
//

import SwiftUI

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

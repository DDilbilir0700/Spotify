//
//  Settings.swift
//
//  Created by Deniz Dilbilir on 29/11/2023.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}

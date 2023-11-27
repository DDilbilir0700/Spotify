//
//  CategoriesResponder.swift
//
//  Created by Deniz Dilbilir on 25/12/2023.
//

import Foundation

struct CategoriesResponder: Codable {
    let categories: Categories
   
}

struct Categories: Codable {
    let items: [Items]
}

struct Items: Codable {
    let id: String
    let name: String
    let icons: [Image]
}



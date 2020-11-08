//
//  ReadMeApp.swift
//  ReadMe
//
//  Created by Максим Окунеев on 11/7/20.
//

import SwiftUI

@main
struct ReadMeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Library())
        }
    }
}

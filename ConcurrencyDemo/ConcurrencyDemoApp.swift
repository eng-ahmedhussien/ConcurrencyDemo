//
//  ConcurrencyDemoApp.swift
//  ConcurrencyDemo
//
//  Created by ahmed hussien on 13/05/2024.
//

import SwiftUI

@main
struct ConcurrencyDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DownloadImageAsyncView()
        }
    }
}

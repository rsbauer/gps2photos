//
//  AppDelegate.swift
//  gps2photos
//
//  Created by Astro on 1/24/21.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var prefWindow: NSWindow?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func openPreferences(_ menuItem: NSMenuItem) {
        if prefWindow == nil {
            prefWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
        }

        if self.prefWindow?.isVisible == true {
            return
        }

        let preferencesView = PreferencesView()

        prefWindow?.isReleasedWhenClosed = false
        prefWindow?.center()
        prefWindow?.setFrameAutosaveName("Preferences Window")
        prefWindow?.contentView = NSHostingView(rootView: preferencesView)
        prefWindow?.makeKeyAndOrderFront(nil)
    }

}


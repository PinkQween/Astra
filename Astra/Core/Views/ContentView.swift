//
//  ContentView.swift
//  Astra
//
//  Created by Hanna Skairipa on 3/16/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var gameCenterManager = GameCenterManager()
    @StateObject private var accessorySetupKitManager = AccessorySetupKitManager()
    
    var body: some View {
        VStack {
            if gameCenterManager.isAuthenticated {
                Text("You are authenticated with Game Center")
                    .padding()
                
                Button(action: {
                    Task {
                        await gameCenterManager.submitScore(score: 100)
                    }
                }) {
                    Text("Submit Score")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    gameCenterManager.showLeaderboard()
                }) {
                    Text("Show Leaderboard")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
            } else {
                Text(gameCenterManager.authenticationInProgress ? "Authenticating..." : "Authentication failed or canceled. Try again.")
                    .padding()
                
                if !gameCenterManager.authenticationInProgress {
                    Button(action: {
                        gameCenterManager.isAuthenticated = false
                        gameCenterManager.authenticatePlayer()
                    }) {
                        Text("Retry Authentication")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .onAppear {
            print("View appeared, attempting to authenticate...")
            Task {
                gameCenterManager.authenticatePlayer()
            }
            
            accessorySetupKitManager.showAccessoryPicker()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

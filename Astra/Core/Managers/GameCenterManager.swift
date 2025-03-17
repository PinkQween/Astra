//
//  GameCenterManager.swift
//  Astra
//
//  Created by Hanna Skairipa on 3/16/25.
//

import GameKit

/// Manages Game Center authentication and leaderboard interactions.
///
/// This class handles user authentication, score submissions, and displaying leaderboards.
@MainActor
class GameCenterManager: ObservableObject {
    /// Indicates whether the player is authenticated with Game Center.
    @Published var isAuthenticated = false
    
    /// Tracks if authentication is in progress.
    @Published var authenticationInProgress = false
    
    /// Tracks if authentication has failed.
    @Published var authenticationFailed = false
    
    /// Authenticates the local player with Game Center.
    ///
    /// If the player is not already authenticated, this method starts the authentication process.
    /// If successful, `isAuthenticated` is set to `true`; otherwise, an error is logged.
    func authenticatePlayer() {
        let localPlayer = GKLocalPlayer.local
        print("Checking authentication...")

        if !localPlayer.isAuthenticated {
            authenticationInProgress = true
            authenticationFailed = false
            print("Authentication not done, starting...")
            
            localPlayer.authenticateHandler = { viewController, error in
                if let error = error {
                    print("Authentication error: \(error.localizedDescription)")
                    self.isAuthenticated = false
                    self.authenticationInProgress = false
                    self.authenticationFailed = true
                    return
                }
                
                if let viewController = viewController {
                    DispatchQueue.main.async {
                        self.presentAuthenticationSheet(viewController)
                    }
                } else {
                    print("Authentication successful.")
                    self.isAuthenticated = true
                    self.authenticationInProgress = false
                    self.authenticationFailed = false
                }
            }
        } else {
            print("Already authenticated.")
            self.isAuthenticated = true
            self.authenticationInProgress = false
        }
    }
    
    /// Presents the Game Center authentication sheet.
    ///
    /// - Parameter viewController: The view controller that handles authentication.
    private func presentAuthenticationSheet(_ viewController: UIViewController) {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }),
           let rootViewController = window.rootViewController {
            rootViewController.present(viewController, animated: true, completion: nil)
        } else {
            print("Root view controller not found.")
        }
    }
    
    /// Submits a player's score to the Game Center leaderboard.
    ///
    /// - Parameter score: The score to be submitted.
    func submitScore(score: Int) async {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated.")
            return
        }
        
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: ["com.hannaskairipa.doner.leaderboard"])
            guard let leaderboard = leaderboards.first else {
                print("Leaderboard not found.")
                return
            }

            try await leaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local)
            print("Score submitted successfully!")
        } catch {
            print("Failed to submit score: \(error.localizedDescription)")
        }
    }
    
    /// Displays the Game Center leaderboard UI.
    func showLeaderboard() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        let gcViewController = GKGameCenterViewController(leaderboardID: "com.hannaskairipa.doner.leaderboard", playerScope: .global, timeScope: .allTime)
        gcViewController.gameCenterDelegate = GameCenterHelper.shared
        rootViewController.present(gcViewController, animated: true)
    }
}

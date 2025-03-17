//
//  GameCenterHelper.swift
//  Astra
//
//  Created by Hanna Skairipa on 3/16/25.
//

import GameKit

/// A helper class for managing Game Center UI interactions.
///
/// This class provides a singleton instance to handle Game Center's UI,
/// such as dismissing the leaderboard and achievement views.
class GameCenterHelper: NSObject, GKGameCenterControllerDelegate {
    /// Shared singleton instance of `GameCenterHelper`.
    static let shared = GameCenterHelper()

    /// Dismisses the Game Center view controller when the user finishes interacting with it.
    ///
    /// - Parameter gameCenterViewController: The presented Game Center view controller.
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

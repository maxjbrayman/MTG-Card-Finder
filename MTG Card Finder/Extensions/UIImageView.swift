//
//  UIImageView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/3/26.
//

import UIKit

extension UIImageView {
    func loadImage(from string: String?) {
        Task {
            do {
                guard let string, let url = URL(string: string) else { return }
                
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.image = image
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

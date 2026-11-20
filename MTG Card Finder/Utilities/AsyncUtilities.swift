//
//  AsyncUtilities.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/13/26.
//

enum AsyncUtilities {
    static func debounce(delay: Duration, task: inout Task<Void, Never>?, action: @escaping () -> Void) {
        task?.cancel()
        task = Task {
            do {
                try await Task.sleep(for: delay)
                action()
            } catch {
                return
            }
        }
    }
}

//
//  LoadState.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/3/26.
//

enum LoadState<T> {
    case idle
    case loading
    case success(T)
    case error(String, T? = nil)
    case refreshing(T? = nil)
    case paginating(T)
}

//
//  FeedViewControllerLocalisations.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

import Foundation
import EssentialFeed
import XCTest

extension FeeUIIntegrationTests {
    func localised(_ key:String, file: StaticString = #filePath,
                          line: UInt = #line ) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let localisedTitle = bundle.localizedString(forKey: key, value: nil, table: table)
        XCTAssertNotEqual(key, localisedTitle,"missing localised value for the key")
        return localisedTitle
    }
}

//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialApp
//
//  Created by Kouv on 08/01/2025.
//
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance:AnyObject,file: StaticString = #filePath,
                                     line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance,"should have been deallocated but possible memory leak",file: file,line: line)
        }
    }
}

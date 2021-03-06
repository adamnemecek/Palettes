//
//  CachingIncrementalStoreTests.swift
//  Palettes
//
//  Created by Andrew Shepard on 1/12/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import XCTest
import CoreData

class CachingIncrementalStoreTests: XCTestCase {
//    private static var __once: () = {
//                expectation.fulfill()
//            }()
    var managedObjectContext: NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
        
        self.removeSQLCache()
        
        let storeType = CachingIncrementalStore.storeType
        self.managedObjectContext = TestingContextProvider.contextWithStoreType(storeType)
        
        XCTAssertNotNil(managedObjectContext, "context should not be nil")
    }
    
    override func tearDown() {
        self.removeSQLCache()
        super.tearDown()
    }
    
    func testRemoteObjectsCanBeFetched() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Palette")
        request.fetchLimit = 30
        request.sortDescriptors = Palette.defaultSortDescriptors
        
        let expectation = self.expectation(description: "save notification should be observed")
        
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: nil, queue: nil) { (notification) -> Void in
//            struct Static {
//                static var onceToken : Int = 0
//            }
//            _ = CachingIncrementalStoreTests.__once
//        }
        
        do {
            guard let results = try managedObjectContext?.fetch(request) as? [Palette] else {
                fatalError()
            }
            
            XCTAssertLessThanOrEqual(results.count, 0, "there should be no cached results")
        }
        catch {
            XCTFail("fetch request should not fail")
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func removeSQLCache() -> Void {
        let path = CachingIncrementalStore.storeType + ".sqlite"
        let url = URL.applicationDocumentsDirectory().appendingPathComponent(path)
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            // no-op
        }
    }
}

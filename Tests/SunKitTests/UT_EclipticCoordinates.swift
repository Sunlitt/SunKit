//
//  UT_EclipticCoordinates.swift
//  
//
//  Created by Davide Biancardi on 18/11/22.
//

import XCTest
@testable import SunKit
import SwiftUI

final class UT_EclipticCoordinates: XCTestCase {

    /// Test of ecliptic2Equatorial
    func testOfecliptic2Equatorial() throws {
    
    //Test1: Convert ecliptic coordinates with latitude = −3.956258 and longitude = 65.059853. Expected Equatorial coordinates are declination = 17.248880 and right ascension = 4.257714.
        
        //Step1:
        let eclipticCoordinatesUnderTest: EclipticCoordinates = .init(eclipticLatitude: .init(degrees: -3.956258), eclipticLongitude: .init(degrees: 65.059853))
        
        //Step2: Saving expected values in output for both right ascension and declination
        let expectedRightAscension = 4.257714
        let expectedDeclination = 17.248880
        
        let rightAscension = eclipticCoordinatesUnderTest.ecliptic2Equatorial().rightAscension!.degrees
        let declination = eclipticCoordinatesUnderTest.ecliptic2Equatorial().declination.degrees
        
        //Step3: Check if output of the funciton under test is close to expected output for both right ascension and declination
        XCTAssertTrue(abs(rightAscension - expectedRightAscension) < 0.1)
        XCTAssertTrue(abs(declination - expectedDeclination) < 0.1)
        
        
        
    }

}

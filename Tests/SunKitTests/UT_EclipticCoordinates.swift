//
//  UT_EclipticCoordinates.swift
//
//
//  Copyright 2023 Leonardo Bertinelli, Davide Biancardi, Raffaele Fulgente, Clelia Iovine, Nicolas Mariniello, Fabio Pizzano
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

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

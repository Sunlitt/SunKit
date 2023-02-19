//
//  UT_HorizonCoordinates.swift
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

final class UT_HorizonCoordinates: XCTestCase {
    
    /// Test of horizon2Equatorial
    func testOfhorizon2Equatorial() throws {
        
    //Test1: Converting altitude 40° and azimuth 115° to equatorial coordinates for an observer at 38° N latitude. Expected out shall be hour angle = 21.031560h and declination = 8.084044°.
        
        //Step1:
        let horizonCoordinatesUnderTest: HorizonCoordinates = .init(altitude: .degrees(40), azimuth: .degrees(115))
        
        //Step2:
        let equatorialCoordinates = horizonCoordinatesUnderTest.horizon2Equatorial(latitude: .init(degrees: 38))
        
        //Step3:
        let expectedDeclination = 8.084044
        let expectedHourAngleDecimal = 21.031560
        
        //Step4: Converting hour angle in decimal
        let hourAngleDecimal = equatorialCoordinates.hourAngle!.degrees / 15
        
        //Step5: Check if declination and hour angle are closo to their respective expected outputs
        XCTAssertTrue(abs(equatorialCoordinates.declination.degrees - expectedDeclination) < 0.1)
        XCTAssertTrue(abs(hourAngleDecimal - expectedHourAngleDecimal) < 0.1)
    }
}

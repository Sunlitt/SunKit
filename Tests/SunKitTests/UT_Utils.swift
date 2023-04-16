//
//  UT_Utils.swift
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


final class UT_Utils: XCTestCase {

    /// Test of mod
    func testOfmod() throws {
        
     //Test1: -100 % 4 shall be equal to 4
        //Step1: call function under test and check that it returns 4
        var a = -100
        var n = 8
        XCTAssertTrue(4 == mod(a, n))
     //Test2: -400 % 360 shall be equal to 320
        //Step1: call function under test and check that it returns 320
        a = -400
        n = 360
        XCTAssertTrue(320 == mod(a, n))
    //Test3: 270 % 180 shall be equal to 90
        //Step1: call function under test and check that it returns 90
        a = 270
        n = 180
        XCTAssertTrue(90 == mod(a, n))
    }
    
    /// Test of jdFromDate
    func testOfjdFromDate() throws{
        
      //Test1:  For 5/6/2010 at noon UT, his JD number shall be 2455323.0
        //Step1: Creating UTC date
        let dateUnderTest = createDateUTC(day: 6, month: 5, year: 2010, hour: 12, minute: 0, seconds: 0)
        
        //Step2:Call function under test, check that it returns expected output
        XCTAssertTrue(2455323.0 == jdFromDate(date: dateUnderTest))
    }
    
    /// Test of dateFromJD
    func testOfdateFromJD() throws{
        
      //Test1: 2455323.0 Jd number shall be quals to date 5/6/2010 at noon UT
        //Step1: Creating jd number under test
        let jdNumberTest = 2455323.0
        
        //Step2:Call function under test, check that it returns expected output
        let expectedOutput = createDateUTC(day: 6, month: 5, year: 2010, hour: 12, minute: 0, seconds: 0)
        XCTAssertTrue(expectedOutput == dateFromJd(jd: jdNumberTest))
    }

    /// Test of extendMod
    func testOfExtendedMod() throws {

    //Test4: -270.8 % 180 shall be equal to 89.2
        var a: Double = -270.8
        var n = 180

        XCTAssertTrue(abs(89.2 - extendedMod(a,n)) < 0.1)

    //Test2: -0.8 % 1  shall be equal to 0.2
        a = -0.8
        n = 1

        XCTAssertTrue(abs(0.2 - extendedMod(a,n)) < 0.1)

    //Test3: 390.5 % 360  shall be equal to 30.5
        a = 390.5
        n = 360

        XCTAssertTrue(30.5 == extendedMod(a,n))

    //Test4: 0.3 % 1  shall be equal to 0.3
        a = 0.3
        n = 1

        XCTAssertTrue(0.3 == extendedMod(a,n))

    //Test1: -100 % 4 shall be equal to 4
        //Step1: call function under test and check that it returns 4
        a = -100
        n = 8
        
        XCTAssertTrue(4 == extendedMod(a, n))
    //Test2: -400 % 360 shall be equal to 320
        //Step1: call function under test and check that it returns 320
        a = -400
        n = 360
        XCTAssertTrue(320 == extendedMod(a, n))
    //Test3: 270 % 180 shall be equal to 90
        //Step1: call function under test and check that it returns 90
        a = 270
        n = 180
        XCTAssertTrue(90 == extendedMod(a, n))
    }
    
    /// Test of uT2GST
    func testOfuT2GST() throws{
        
        //Test2: Convert 23h30m00s UT to GST for February 7, 2010. UseSameTimeZone equals False.
        
        //Step1: Creating 7/02/2010 23h30m UTC
        let dateUnderTest = createDateUTC(day: 7, month: 2, year: 2010, hour: 23, minute: 30, seconds: 0)
        
        //Step2: Set variable "expectedOutput" to the expect output
        let expectedOutput: HMS = HMS.init(decimal: 8.698091)
        
        //Step3: Call function under test and check that it returns a value which differs from expected output up to 0.01
        XCTAssert(abs(uT2GST(dateUnderTest).hMS2Decimal() - expectedOutput.hMS2Decimal()) < 0.01)
    }
    
    /// Test of gST2LST
    func testOfgST2LST() throws{
        
      //Test1: Converting GST to LST requires knowing an observer’s longitude. Assume that the GST is 2h03m41s  for an observer at 40° W longitude.
        
        //Step1: Creating 7/02/2010 2h03m41s with current time zone(i.e the one set on your device)
        let gstHMS: HMS = .init(hours: 2, minutes: 03, seconds: 41)
        let longitudeUnderTest: Angle = .init(degrees: -40)
        
        //Step2: Set variable "expectedOutput" to the expected output
        let expectedOutput = 23.3994722
        
        //Step3: Call function under test and check that it returns a value which differs from expected output up to 0.01
        let output = gST2LST(gstHMS, longitude: longitudeUnderTest).hMS2Decimal()
        XCTAssert(abs(expectedOutput - output) < 0.01)
        
    }
    
    
    
}

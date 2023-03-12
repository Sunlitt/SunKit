//
//  UT_SunLitt.swift
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
import Foundation
import CoreLocation
@testable import SunKit

final class UT_SunLitt: XCTestCase {
    
    //Test suite created for SunLitt App.

    /*--------------------------------------------------------------------
     Thresholds. UTs will pass if |output - expectedOutput| < threshold
     *-------------------------------------------------------------------*/
    static let sunAzimuthThreshold: Double = 0.5
    static let sunAltitudeThreshold: Double = 0.5
    static let sunSetRiseThresholdInSeconds: Double = 300 //5 minutes in seconds
    static let sunEquinoxesAndSolsticesThresholdInSeconds:Double = 1200 //20 minutes in seconds
    
    /*--------------------------------------------------------------------
     Naples timezone and location
     *-------------------------------------------------------------------*/
    static let naplesLocation: CLLocation = .init(latitude: 40.84014, longitude: 14.25226)
    static let timeZoneNaples = 1
    static let timeZoneNaplesDaylightSaving = 2
    
    /*--------------------------------------------------------------------
     Tokyo timezone and location
     *-------------------------------------------------------------------*/
    static let tokyoLocation: CLLocation = .init(latitude: 35.68946, longitude: 139.69172)
    static let timeZoneTokyo = 9
    
    /*--------------------------------------------------------------------
     Louisa USA timezone and location
     *-------------------------------------------------------------------*/
    static let louisaLocation: CLLocation = .init(latitude: 38, longitude: -78)
    static let timeZoneLouisa = -5
    static let timeZoneLouisaDaylightSaving = -4
    
    /*--------------------------------------------------------------------
     Tromso circumpolar timezone and location
     *-------------------------------------------------------------------*/
    static let tromsoLocation: CLLocation = .init(latitude: 69.6489, longitude: 18.95508)
    static let timeZoneTromso = 1
    static let timeZoneTromsoDaylightSaving = 2
    
    /*--------------------------------------------------------------------
     Mumbai  timezone and location
     *-------------------------------------------------------------------*/
    static let mumbaiLocation: CLLocation = .init(latitude: 18.94017, longitude: 72.83489)
    static let timeZoneMumbai = 5.5
    
  
    /// Test of  Sun azimuth, sunrise, sunset, afternoon golden hour start and afternoon golden hour end
    /// Value for expected results have been taken from SunCalc.org
    func testOfSun() throws {
        
        /*--------------------------------------------------------------------
         Naples
         *-------------------------------------------------------------------*/
        
        //Test1: 19/11/22 20:00. Timezone +1.
        
        //Step1: Creating Sun instance in Naples and with timezone +1
        var sunUnderTest = Sun.init(location: UT_Sun.naplesLocation, timeZone: Double(UT_Sun.timeZoneNaples),useSameTimeZone: true)
        
        //Step2: Setting 19/11/22 20:00 as date. (No daylight saving)
        var dateUnderTest = createDateCurrentTimeZone(day: 19, month: 11, year: 2022, hour: 20, minute: 00, seconds: 00)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Saving expected outputs
        var expectedAzimuth = 275.84
        var expectedAltitude = -37.34
        
        var expectedSunRise = createDateCurrentTimeZone(day: 19, month: 11, year: 2022, hour: 6, minute: 54, seconds: 12)
        var expectedSunset = createDateCurrentTimeZone(day: 19, month: 11, year: 2022, hour: 16, minute: 42, seconds: 07)
        
        var expectedGoldenHourStart = createDateCurrentTimeZone(day: 19, month: 11, year: 2022, hour: 16, minute: 00, seconds: 00)
        var expectedGoldenHourEnd = createDateCurrentTimeZone(day: 19, month: 11, year: 2022, hour: 16, minute: 59, seconds: 00)
        
        var expectedFirstLight = createDateCurrentTimeZone(day: 19, month: 11, year: 2022, hour: 6, minute: 24, seconds: 51)
        var expectedLastLight = createDateCurrentTimeZone(day: 19, month: 11, year: 2022, hour: 17, minute: 11, seconds: 28)
        
        var expectedSolarNoon = createDateCurrentTimeZone(day: 19, month: 11, year: 2022, hour: 11, minute: 48, seconds: 21)

        //Step4: Check if the output are close to the expected ones
        
        XCTAssertTrue(abs(expectedAzimuth - sunUnderTest.azimuth.degrees) <  UT_Sun.sunAzimuthThreshold)
        XCTAssertTrue(abs(expectedAltitude - sunUnderTest.altitude.degrees) <  UT_Sun.sunAltitudeThreshold)
       
        XCTAssertTrue(abs(expectedSunRise.timeIntervalSince1970 - sunUnderTest.sunrise.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedSunset.timeIntervalSince1970 - sunUnderTest.sunset.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedGoldenHourStart.timeIntervalSince1970 - sunUnderTest.goldenHourStart.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedGoldenHourEnd.timeIntervalSince1970 - sunUnderTest.goldenHourEnd.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedFirstLight.timeIntervalSince1970 - sunUnderTest.firstLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedLastLight.timeIntervalSince1970 - sunUnderTest.lastLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedSolarNoon.timeIntervalSince1970 - sunUnderTest.solarNoon.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        
        //Test: 31/12/2024 15:32. Timezone +1. Leap Year.
        
        //Step1: Creating Sun instance in Naples and with timezone +1
        sunUnderTest = Sun.init(location: UT_Sun.naplesLocation, timeZone: Double(UT_Sun.timeZoneNaples),useSameTimeZone: true)
        
        //Step2: Setting 31/12/2024 15:32 as date. (No daylight saving)
        dateUnderTest = createDateCurrentTimeZone(day: 31, month: 12, year: 2024, hour: 15, minute: 32, seconds: 00)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Saving expected outputs
        expectedAzimuth = 226.99
        expectedAltitude = 10.35
        
        expectedSunRise = createDateCurrentTimeZone(day: 31, month: 12, year: 2024, hour: 7, minute: 26, seconds: 57)
        expectedSunset = createDateCurrentTimeZone(day: 31, month: 12, year: 2024, hour: 16, minute: 45, seconds: 32)
        
        expectedGoldenHourStart = createDateCurrentTimeZone(day: 31, month: 12, year: 2024, hour: 16, minute: 02, seconds: 00)
        expectedGoldenHourEnd = createDateCurrentTimeZone(day: 31, month: 12, year: 2024, hour: 17, minute: 05, seconds: 00)
        
        expectedFirstLight = createDateCurrentTimeZone(day: 31, month: 12, year: 2024, hour: 6, minute: 56, seconds: 24)
        expectedLastLight = createDateCurrentTimeZone(day: 31, month: 12, year: 2024, hour: 17, minute: 16, seconds: 06)
        
        expectedSolarNoon = createDateCurrentTimeZone(day: 31, month: 12, year: 2024, hour: 12, minute: 06, seconds: 11)

        //Step4: Check if the output are close to the expected ones
        
        XCTAssertTrue(abs(expectedAzimuth - sunUnderTest.azimuth.degrees) <  UT_Sun.sunAzimuthThreshold)
        XCTAssertTrue(abs(expectedAltitude - sunUnderTest.altitude.degrees) <  UT_Sun.sunAltitudeThreshold)
       
        XCTAssertTrue(abs(expectedSunRise.timeIntervalSince1970 - sunUnderTest.sunrise.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedSunset.timeIntervalSince1970 - sunUnderTest.sunset.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedGoldenHourStart.timeIntervalSince1970 - sunUnderTest.goldenHourStart.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedGoldenHourEnd.timeIntervalSince1970 - sunUnderTest.goldenHourEnd.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedFirstLight.timeIntervalSince1970 - sunUnderTest.firstLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedLastLight.timeIntervalSince1970 - sunUnderTest.lastLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedSolarNoon.timeIntervalSince1970 - sunUnderTest.solarNoon.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        
        
        /*--------------------------------------------------------------------
         Tokyo
         *-------------------------------------------------------------------*/
        
        //Test: 1/08/22 16:50. Timezone +9.
        
        //Step1: Creating sun instance in Tokyo and with timezone +9
        sunUnderTest = Sun.init(location: UT_Sun.tokyoLocation, timeZone: Double(UT_Sun.timeZoneTokyo),useSameTimeZone: true)
        
        //Step2: Setting 1/08/22 16:50 as date.
        dateUnderTest = createDateCurrentTimeZone(day: 1, month: 8, year: 2022, hour: 16, minute: 50, seconds: 00)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Saving expected outputs
        expectedAzimuth = 276.98
        expectedAltitude = 21.90
        
        expectedSunRise = createDateCurrentTimeZone(day: 1, month: 8, year: 2022, hour: 4, minute: 48, seconds: 29)
        expectedSunset = createDateCurrentTimeZone(day: 1, month: 8, year: 2022, hour: 18, minute: 46, seconds: 15)
        
        expectedGoldenHourStart = createDateCurrentTimeZone(day: 1, month: 8, year: 2022, hour: 18, minute: 11, seconds: 00)
        expectedGoldenHourEnd = createDateCurrentTimeZone(day: 1, month: 8, year: 2022, hour: 19, minute: 04, seconds: 00)
        
        expectedFirstLight = createDateCurrentTimeZone(day: 1, month: 8, year: 2022, hour: 4, minute: 20, seconds: 39)
        expectedLastLight = createDateCurrentTimeZone(day: 1, month: 8, year: 2022, hour: 19, minute: 14, seconds: 00)
        
        expectedSolarNoon = createDateCurrentTimeZone(day: 1, month: 8, year: 2022, hour: 11, minute: 47, seconds: 36)

        //Step4: Check if the output are close to the expected ones
        
        XCTAssertTrue(abs(expectedAzimuth - sunUnderTest.azimuth.degrees) <  UT_Sun.sunAzimuthThreshold)
        XCTAssertTrue(abs(expectedAltitude - sunUnderTest.altitude.degrees) <  UT_Sun.sunAltitudeThreshold)
       
        XCTAssertTrue(abs(expectedSunRise.timeIntervalSince1970 - sunUnderTest.sunrise.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedSunset.timeIntervalSince1970 - sunUnderTest.sunset.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedGoldenHourStart.timeIntervalSince1970 - sunUnderTest.goldenHourStart.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedGoldenHourEnd.timeIntervalSince1970 - sunUnderTest.goldenHourEnd.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedFirstLight.timeIntervalSince1970 - sunUnderTest.firstLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedLastLight.timeIntervalSince1970 - sunUnderTest.lastLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedSolarNoon.timeIntervalSince1970 - sunUnderTest.solarNoon.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
      
        /*--------------------------------------------------------------------
         Louisa USA
         *-------------------------------------------------------------------*/
        
        //Test:  1/01/15 22:00. Timezone -5.
        
        //Step1: Creating sun instance in Louisa and with timezone -5 (No daylight saving)
        sunUnderTest = Sun.init(location: UT_Sun.louisaLocation, timeZone: Double(UT_Sun.timeZoneLouisa),useSameTimeZone: true)
        
        //Step2: Setting 1/01/15 22:00 as date. (No daylight saving)
        dateUnderTest = createDateCurrentTimeZone(day: 1, month: 1, year: 2015, hour: 22, minute: 00, seconds: 00)
        sunUnderTest.setDate(dateUnderTest)

        //Step3: Saving expected outputs
        expectedAzimuth = 287.62
        expectedAltitude = -57.41
        
        expectedSunRise = createDateCurrentTimeZone(day: 1, month: 1, year: 2015, hour: 7, minute: 27, seconds: 29)
        expectedSunset = createDateCurrentTimeZone(day: 1, month: 1, year: 2015, hour: 17, minute: 03, seconds: 25)
        
        expectedGoldenHourStart = createDateCurrentTimeZone(day: 1, month: 1, year: 2015, hour: 16, minute: 22, seconds: 00)
        expectedGoldenHourEnd = createDateCurrentTimeZone(day: 1, month: 1, year: 2015, hour: 17, minute: 22, seconds: 00)
        
        expectedFirstLight = createDateCurrentTimeZone(day: 1, month: 1, year: 2015, hour: 6, minute: 58, seconds: 28)
        expectedLastLight = createDateCurrentTimeZone(day: 1, month: 1, year: 2015, hour: 17, minute: 32, seconds: 27)
        
        expectedSolarNoon = createDateCurrentTimeZone(day: 1, month: 1, year: 2015, hour: 12, minute: 15, seconds: 23)

        //Step4: Check if the output are close to the expected ones
        
        XCTAssertTrue(abs(expectedAzimuth - sunUnderTest.azimuth.degrees) <  UT_Sun.sunAzimuthThreshold)
        XCTAssertTrue(abs(expectedAltitude - sunUnderTest.altitude.degrees) <  UT_Sun.sunAltitudeThreshold)
       
        XCTAssertTrue(abs(expectedSunRise.timeIntervalSince1970 - sunUnderTest.sunrise.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedSunset.timeIntervalSince1970 - sunUnderTest.sunset.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedGoldenHourStart.timeIntervalSince1970 - sunUnderTest.goldenHourStart.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedGoldenHourEnd.timeIntervalSince1970 - sunUnderTest.goldenHourEnd.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedFirstLight.timeIntervalSince1970 - sunUnderTest.firstLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedLastLight.timeIntervalSince1970 - sunUnderTest.lastLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedSolarNoon.timeIntervalSince1970 - sunUnderTest.solarNoon.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        
        /*--------------------------------------------------------------------
         Tromso circumpolar
         *-------------------------------------------------------------------*/
        
        //Test: 19/01/22 17:31. Timezone +1.
        
        //Step1: Creating sun instance in Tromso and with timezone +1 (No daylight saving)
        sunUnderTest = Sun.init(location: UT_Sun.tromsoLocation, timeZone: Double(UT_Sun.timeZoneTromso),useSameTimeZone: true)
        
        //Step2: Setting 19/01/22 17:31 as date. (No daylight saving)
        dateUnderTest = createDateCurrentTimeZone(day: 19, month: 1, year: 2022, hour: 17, minute: 31, seconds: 00)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Saving expected outputs
        expectedAzimuth = 257.20
        expectedAltitude = -16.93
        
        expectedSunRise = createDateCurrentTimeZone(day: 19, month: 1, year: 2022, hour: 10, minute: 41, seconds: 46)
        expectedSunset = createDateCurrentTimeZone(day: 19, month: 1, year: 2022, hour: 13, minute: 08, seconds: 48)
        expectedFirstLight = createDateCurrentTimeZone(day: 19, month: 1, year: 2022, hour: 08, minute: 45, seconds: 30)
        expectedLastLight = createDateCurrentTimeZone(day: 19, month: 1, year: 2022, hour: 15, minute: 05, seconds: 08)
        
        expectedSolarNoon = createDateCurrentTimeZone(day: 19, month: 1, year: 2022, hour: 11, minute: 54, seconds: 52)

        //Step4: Check if the output are close to the expected ones
        
        XCTAssertTrue(abs(expectedAzimuth - sunUnderTest.azimuth.degrees) <  UT_Sun.sunAzimuthThreshold)
        XCTAssertTrue(abs(expectedAltitude - sunUnderTest.altitude.degrees) <  UT_Sun.sunAltitudeThreshold)
       
        XCTAssertTrue(abs(expectedSunRise.timeIntervalSince1970 - sunUnderTest.sunrise.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedSunset.timeIntervalSince1970 - sunUnderTest.sunset.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedFirstLight.timeIntervalSince1970 - sunUnderTest.firstLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedLastLight.timeIntervalSince1970 - sunUnderTest.lastLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedSolarNoon.timeIntervalSince1970 - sunUnderTest.solarNoon.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        
    }
    
    

}

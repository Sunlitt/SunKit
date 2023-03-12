//
//  UT_Sun.swift
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

final class UT_Sun: XCTestCase {
    
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
    
    
    /// Test of  a sun ionstance whenm you play with timezones and change location
    func testOfSunWhenTimezoneChanges() throws {
        
        //Step1: Creating Sun instance in Naples and with timezone +1
        var timeZoneNaples: TimeZone = .init(secondsFromGMT: UT_Sun.timeZoneNaples * Int(SECONDS_IN_ONE_HOUR)) ?? .current
        var sunUnderTest = Sun.init(location: UT_Sun.naplesLocation, timeZone: timeZoneNaples)
        
        //Step2: Setting 19/11/22 20:00 as date. (No daylight saving)
        var dateUnderTest = createDateCustomTimeZone(day: 19, month: 11, year: 2022, hour: 20, minute: 00, seconds: 00,timeZone: timeZoneNaples)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Change location and timezone
        let timeZoneTokyo: TimeZone = .init(secondsFromGMT: UT_Sun.timeZoneTokyo * Int(SECONDS_IN_ONE_HOUR)) ?? .current
        sunUnderTest.setLocation(UT_Sun.tokyoLocation, timeZoneTokyo)
        
        //Step4: Saving expected outputs for all the date
        var expectedDate = createDateCustomTimeZone(day: 20, month: 11, year: 2022, hour: 4, minute: 00, seconds: 00,timeZone: timeZoneTokyo)
        
        //Step5: Check if output of sunUnderTest.date matches the expected output
        XCTAssertTrue(expectedDate == sunUnderTest.date)
        
    
        
    }
    
    
    /// Test of  Sun azimuth, sunrise, sunset, afternoon golden hour start and afternoon golden hour end
    /// Value for expected results have been taken from SunCalc.org
    func testOfSun() throws {
        
        /*--------------------------------------------------------------------
         Naples
         *-------------------------------------------------------------------*/
        
        //Test1: 19/11/22 20:00. Timezone +1.
        
        //Step1: Creating Sun instance in Naples and with timezone +1
        var timeZoneUnderTest: TimeZone = .init(secondsFromGMT: UT_Sun.timeZoneNaples * Int(SECONDS_IN_ONE_HOUR)) ?? .current
        var sunUnderTest = Sun.init(location: UT_Sun.naplesLocation, timeZone: timeZoneUnderTest)
        
        //Step2: Setting 19/11/22 20:00 as date. (No daylight saving)
        var dateUnderTest = createDateCustomTimeZone(day: 19, month: 11, year: 2022, hour: 20, minute: 00, seconds: 00,timeZone: timeZoneUnderTest)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Saving expected outputs
        var expectedAzimuth = 275.84
        var expectedAltitude = -37.34
        
        var expectedSunRise = createDateCustomTimeZone(day: 19, month: 11, year: 2022, hour: 6, minute: 54, seconds: 12,timeZone: timeZoneUnderTest)
        var expectedSunset = createDateCustomTimeZone(day: 19, month: 11, year: 2022, hour: 16, minute: 42, seconds: 07,timeZone: timeZoneUnderTest)
        
        var expectedGoldenHourStart = createDateCustomTimeZone(day: 19, month: 11, year: 2022, hour: 16, minute: 00, seconds: 00,timeZone: timeZoneUnderTest)
        var expectedGoldenHourEnd = createDateCustomTimeZone(day: 19, month: 11, year: 2022, hour: 16, minute: 59, seconds: 00,timeZone: timeZoneUnderTest)
        
        var expectedFirstLight = createDateCustomTimeZone(day: 19, month: 11, year: 2022, hour: 6, minute: 24, seconds: 51,timeZone: timeZoneUnderTest)
        var expectedLastLight = createDateCustomTimeZone(day: 19, month: 11, year: 2022, hour: 17, minute: 11, seconds: 28,timeZone: timeZoneUnderTest)
        
        var expectedSolarNoon = createDateCustomTimeZone(day: 19, month: 11, year: 2022, hour: 11, minute: 48, seconds: 21,timeZone: timeZoneUnderTest)

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
        timeZoneUnderTest = .init(secondsFromGMT: UT_Sun.timeZoneNaples * Int(SECONDS_IN_ONE_HOUR)) ?? .current
        
        sunUnderTest = Sun.init(location: UT_Sun.naplesLocation, timeZone: timeZoneUnderTest)
        
        //Step2: Setting 31/12/2024 15:32 as date. (No daylight saving)
        dateUnderTest = createDateCustomTimeZone(day: 31, month: 12, year: 2024, hour: 15, minute: 32, seconds: 00,timeZone: timeZoneUnderTest)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Saving expected outputs
        expectedAzimuth = 226.99
        expectedAltitude = 10.35
        
        expectedSunRise = createDateCustomTimeZone(day: 31, month: 12, year: 2024, hour: 7, minute: 26, seconds: 57,timeZone: timeZoneUnderTest)
        expectedSunset = createDateCustomTimeZone(day: 31, month: 12, year: 2024, hour: 16, minute: 45, seconds: 32,timeZone: timeZoneUnderTest)
        
        expectedGoldenHourStart = createDateCustomTimeZone(day: 31, month: 12, year: 2024, hour: 16, minute: 02, seconds: 00,timeZone: timeZoneUnderTest)
        expectedGoldenHourEnd = createDateCustomTimeZone(day: 31, month: 12, year: 2024, hour: 17, minute: 05, seconds: 00,timeZone: timeZoneUnderTest)
        
        expectedFirstLight = createDateCustomTimeZone(day: 31, month: 12, year: 2024, hour: 6, minute: 56, seconds: 24,timeZone: timeZoneUnderTest)
        expectedLastLight = createDateCustomTimeZone(day: 31, month: 12, year: 2024, hour: 17, minute: 16, seconds: 06,timeZone: timeZoneUnderTest)
        
        expectedSolarNoon = createDateCustomTimeZone(day: 31, month: 12, year: 2024, hour: 12, minute: 06, seconds: 11,timeZone: timeZoneUnderTest)

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
        timeZoneUnderTest = .init(secondsFromGMT: UT_Sun.timeZoneTokyo * Int(SECONDS_IN_ONE_HOUR)) ?? .current
        sunUnderTest = Sun.init(location: UT_Sun.tokyoLocation, timeZone: timeZoneUnderTest)
        
        //Step2: Setting 1/08/22 16:50 as date.
        dateUnderTest = createDateCustomTimeZone(day: 1, month: 8, year: 2022, hour: 16, minute: 50, seconds: 00,timeZone: timeZoneUnderTest)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Saving expected outputs
        expectedAzimuth = 276.98
        expectedAltitude = 21.90
        
        expectedSunRise = createDateCustomTimeZone(day: 1, month: 8, year: 2022, hour: 4, minute: 48, seconds: 29,timeZone: timeZoneUnderTest)
        expectedSunset = createDateCustomTimeZone(day: 1, month: 8, year: 2022, hour: 18, minute: 46, seconds: 15,timeZone: timeZoneUnderTest)
        
        expectedGoldenHourStart = createDateCustomTimeZone(day: 1, month: 8, year: 2022, hour: 18, minute: 11, seconds: 00,timeZone: timeZoneUnderTest)
        expectedGoldenHourEnd = createDateCustomTimeZone(day: 1, month: 8, year: 2022, hour: 19, minute: 04, seconds: 00,timeZone: timeZoneUnderTest)
        
        expectedFirstLight = createDateCustomTimeZone(day: 1, month: 8, year: 2022, hour: 4, minute: 20, seconds: 39,timeZone: timeZoneUnderTest)
        expectedLastLight = createDateCustomTimeZone(day: 1, month: 8, year: 2022, hour: 19, minute: 14, seconds: 00,timeZone: timeZoneUnderTest)
        
        expectedSolarNoon = createDateCustomTimeZone(day: 1, month: 8, year: 2022, hour: 11, minute: 47, seconds: 36,timeZone: timeZoneUnderTest)

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
        timeZoneUnderTest = .init(secondsFromGMT: UT_Sun.timeZoneLouisa * Int(SECONDS_IN_ONE_HOUR)) ?? .current
        sunUnderTest = Sun.init(location: UT_Sun.louisaLocation, timeZone: timeZoneUnderTest)
        
        //Step2: Setting 1/01/15 22:00 as date. (No daylight saving)
        dateUnderTest = createDateCustomTimeZone(day: 1, month: 1, year: 2015, hour: 22, minute: 00, seconds: 00,timeZone: timeZoneUnderTest)
        sunUnderTest.setDate(dateUnderTest)

        //Step3: Saving expected outputs
        expectedAzimuth = 287.62
        expectedAltitude = -57.41
        
        expectedSunRise = createDateCustomTimeZone(day: 1, month: 1, year: 2015, hour: 7, minute: 27, seconds: 29,timeZone: timeZoneUnderTest)
        expectedSunset = createDateCustomTimeZone(day: 1, month: 1, year: 2015, hour: 17, minute: 03, seconds: 25,timeZone: timeZoneUnderTest)
        
        expectedGoldenHourStart = createDateCustomTimeZone(day: 1, month: 1, year: 2015, hour: 16, minute: 22, seconds: 00,timeZone: timeZoneUnderTest)
        expectedGoldenHourEnd = createDateCustomTimeZone(day: 1, month: 1, year: 2015, hour: 17, minute: 22, seconds: 00,timeZone: timeZoneUnderTest)
        
        expectedFirstLight = createDateCustomTimeZone(day: 1, month: 1, year: 2015, hour: 6, minute: 58, seconds: 28,timeZone: timeZoneUnderTest)
        expectedLastLight = createDateCustomTimeZone(day: 1, month: 1, year: 2015, hour: 17, minute: 32, seconds: 27,timeZone: timeZoneUnderTest)
        
        expectedSolarNoon = createDateCustomTimeZone(day: 1, month: 1, year: 2015, hour: 12, minute: 15, seconds: 23,timeZone: timeZoneUnderTest)

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
        timeZoneUnderTest = .init(secondsFromGMT: UT_Sun.timeZoneTromso * Int(SECONDS_IN_ONE_HOUR)) ?? .current
        sunUnderTest = Sun.init(location: UT_Sun.tromsoLocation, timeZone: timeZoneUnderTest)
        
        //Step2: Setting 19/01/22 17:31 as date. (No daylight saving)
        dateUnderTest = createDateCustomTimeZone(day: 19, month: 1, year: 2022, hour: 17, minute: 31, seconds: 00,timeZone: timeZoneUnderTest)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Saving expected outputs
        expectedAzimuth = 257.20
        expectedAltitude = -16.93
        
        expectedSunRise = createDateCustomTimeZone(day: 19, month: 1, year: 2022, hour: 10, minute: 41, seconds: 46,timeZone: timeZoneUnderTest)
        expectedSunset = createDateCustomTimeZone(day: 19, month: 1, year: 2022, hour: 13, minute: 08, seconds: 48,timeZone: timeZoneUnderTest)
        expectedFirstLight = createDateCustomTimeZone(day: 19, month: 1, year: 2022, hour: 08, minute: 45, seconds: 30,timeZone: timeZoneUnderTest)
        expectedLastLight = createDateCustomTimeZone(day: 19, month: 1, year: 2022, hour: 15, minute: 05, seconds: 08,timeZone: timeZoneUnderTest)
        
        expectedSolarNoon = createDateCustomTimeZone(day: 19, month: 1, year: 2022, hour: 11, minute: 54, seconds: 52,timeZone: timeZoneUnderTest)

        //Step4: Check if the output are close to the expected ones
        
        XCTAssertTrue(abs(expectedAzimuth - sunUnderTest.azimuth.degrees) <  UT_Sun.sunAzimuthThreshold)
        XCTAssertTrue(abs(expectedAltitude - sunUnderTest.altitude.degrees) <  UT_Sun.sunAltitudeThreshold)
       
        XCTAssertTrue(abs(expectedSunRise.timeIntervalSince1970 - sunUnderTest.sunrise.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedSunset.timeIntervalSince1970 - sunUnderTest.sunset.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedFirstLight.timeIntervalSince1970 - sunUnderTest.firstLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedLastLight.timeIntervalSince1970 - sunUnderTest.lastLight.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        XCTAssertTrue(abs(expectedSolarNoon.timeIntervalSince1970 - sunUnderTest.solarNoon.timeIntervalSince1970) <  UT_Sun.sunSetRiseThresholdInSeconds)
        
        
        /*--------------------------------------------------------------------
         Mumbai
         *-------------------------------------------------------------------*/
        
        //Test: 12/03/23 14:46. Timezone +5.5.
        
        //Step1: Creating Sun instance in Mumbai and with timezone +5.5
        timeZoneUnderTest = .init(secondsFromGMT: Int(UT_Sun.timeZoneMumbai * SECONDS_IN_ONE_HOUR)) ?? .current
        sunUnderTest = Sun.init(location: UT_Sun.mumbaiLocation, timeZone: timeZoneUnderTest)
        
        //Step2: Setting 12/03/23 14:46 as date.
        dateUnderTest = createDateCustomTimeZone(day: 12, month: 3, year: 2023, hour: 14, minute: 46, seconds: 00,timeZone: timeZoneUnderTest)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Saving expected outputs
        expectedAzimuth = 235.41
        expectedAltitude = 53.51
        
        expectedSunRise = createDateCustomTimeZone(day: 12, month: 3, year: 2023, hour: 6, minute: 49, seconds: 35,timeZone: timeZoneUnderTest)
        expectedSunset = createDateCustomTimeZone(day: 12, month: 3, year: 2023, hour: 18, minute: 47, seconds: 42,timeZone: timeZoneUnderTest)
        expectedFirstLight = createDateCustomTimeZone(day: 12, month: 3, year: 2023, hour: 6, minute: 27, seconds: 59,timeZone: timeZoneUnderTest)
        expectedLastLight = createDateCustomTimeZone(day: 12, month: 3, year: 2023, hour: 19, minute: 09, seconds: 19,timeZone: timeZoneUnderTest)
        
        expectedSolarNoon = createDateCustomTimeZone(day: 12, month: 3, year: 2023, hour: 12, minute: 48, seconds: 31,timeZone: timeZoneUnderTest)

        //Step4: Check if the output are close to the expected ones
        
    }
    
    func testOfEquinoxesAndSolstices() throws {
        
        //Test: 19/01/22 17:31. Timezone +1. Naples
        
        //Step1: Creating sun instance in Naples and with timezone +1 (No daylight saving)
        let timeZoneUnderTest: TimeZone = .init(secondsFromGMT: UT_Sun.timeZoneNaples * Int(SECONDS_IN_ONE_HOUR)) ?? .current
        let timeZoneDaylightSaving: TimeZone = .init(secondsFromGMT: UT_Sun.timeZoneNaplesDaylightSaving * Int(SECONDS_IN_ONE_HOUR)) ?? .current
        let sunUnderTest = Sun.init(location: UT_Sun.naplesLocation, timeZone: timeZoneUnderTest)
        
        //Step2: Setting 19/01/22 17:31 as date. (No daylight saving)
        let dateUnderTest = createDateCustomTimeZone(day: 19, month: 1, year: 2022, hour: 17, minute: 31, seconds: 00,timeZone: timeZoneUnderTest)
        sunUnderTest.setDate(dateUnderTest)
        
        //Step3: Saving expected outputs
    
        let expectedMarchEquinox = createDateCustomTimeZone(day: 20, month: 3, year: 2022, hour: 16, minute: 33, seconds: 00,timeZone: timeZoneUnderTest)
        let expectedJuneSolstice = createDateCustomTimeZone(day: 21, month: 6, year: 2022, hour: 11, minute: 13, seconds: 00,timeZone: timeZoneDaylightSaving)
        let expectedSeptemberEquinox = createDateCustomTimeZone(day: 23, month: 09, year: 2022, hour: 03, minute: 03, seconds: 00,timeZone: timeZoneDaylightSaving)
        let expectedDecemberSolstice = createDateCustomTimeZone(day: 21, month: 12, year: 2022, hour: 22, minute: 47, seconds: 00,timeZone: timeZoneUnderTest)

        //Step4: Check if the output are close to the expected ones
        XCTAssertTrue(abs(expectedMarchEquinox.timeIntervalSince1970 - sunUnderTest.marchEquinox.timeIntervalSince1970)
                      <  UT_Sun.sunEquinoxesAndSolsticesThresholdInSeconds)
 
        XCTAssertTrue(abs(expectedJuneSolstice.timeIntervalSince1970 - sunUnderTest.juneSolstice.timeIntervalSince1970)
                      <  UT_Sun.sunEquinoxesAndSolsticesThresholdInSeconds)
        
        XCTAssertTrue(abs(expectedSeptemberEquinox.timeIntervalSince1970 - sunUnderTest.septemberEquinox.timeIntervalSince1970)
                      <  UT_Sun.sunEquinoxesAndSolsticesThresholdInSeconds)
       
        XCTAssertTrue(abs(expectedDecemberSolstice.timeIntervalSince1970 - sunUnderTest.decemberSolstice.timeIntervalSince1970)
                      <  UT_Sun.sunEquinoxesAndSolsticesThresholdInSeconds)
    }
    
    
    
    
    
    
    func testPerformance() throws {
        // Performance of setDate function that will refresh all the sun variables
        
        //Step1: Creating sun instance in Naples with timezone +1
        let sunUnderTest = Sun.init(location: UT_Sun.naplesLocation, timeZone: Double(UT_Sun.timeZoneNaples))
        
        //Step2: Setting 19/11/22 20:00 as date.
        let dateUnderTest = createDateCurrentTimeZone(day: 19, month: 11, year: 2022, hour: 20, minute: 00, seconds: 00)
        
        self.measure {
            sunUnderTest.setDate(dateUnderTest)
        }
    }
}

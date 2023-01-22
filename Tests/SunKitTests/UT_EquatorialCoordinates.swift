//
//  UT_EquatorialCoordinates.swift
//  
//
//  Created by Davide Biancardi on 17/11/22.
//

import XCTest
@testable import SunKit

final class UT_EquatorialCoordinates: XCTestCase {

    
    /// Test of EquatorialCoordinates init
    func testOfInitEquatorialCoordinates() throws {
        
    //Test1: Consider a star whose right ascension is 3h24m06s and declination = −0°30'30''. Suppose the LST for an observer is 18h.Calculate the corresponding hour angle.
        
        //Step1:
        let declinationUnderTest: Angle = .init(degrees: DMS.init(degrees:0 , minutes: 30, seconds: 30,isANegativeZero: true).dMS2Decimal())
        let rightAscensionUnderTest: Angle = .init(degrees: HMS.init(hours: 3, minutes: 24, seconds: 06).hMS2Decimal())
        var equatorialCoordinatesUnderTest: EquatorialCoordinates = .init(declination: declinationUnderTest, rightAscension: rightAscensionUnderTest)
        //Step2: Converting hour Angle from angle to decimal
        let hourAngleDecimal = equatorialCoordinatesUnderTest.setHourAngleFrom(lstDecimal: 18)!.degrees   / 15
        
        //Step3:
        XCTAssertTrue(abs(hourAngleDecimal - 14.598333) < 0.1)
        
    }
    
    
    /// Test of equatorial2Horizon
    func testOfequatorial2Horizon() throws {
        
        
    //Test1: Convert equatorial coordinates with declination = 17.248880 and right ascension = 4.257714. Expected horizon coordinates are altitude = 68°52 and Azimuth = 192°11′. For an observer at 38° N and LST is 4.562547h
        
        //Step1:
        var equatorialCoordinatesUnderTest: EquatorialCoordinates = .init(declination: .init(degrees: 17.248880), rightAscension: .init(degrees: 4.257714))
        var latitudeUnderTest: Angle = .init(degrees: 38)
        let lstUnderTest = 4.562547
        
        //Step2: Saving expected values in output for both azimuth and altitude
        var expectedAltitude = DMS.init(degrees: 68, minutes: 52, seconds: 0).dMS2Decimal()
        var expectedAzimuth = DMS.init(degrees: 192, minutes: 11, seconds: 0).dMS2Decimal()
        
        var azimuth = equatorialCoordinatesUnderTest.equatorial2Horizon(lstDecimal: lstUnderTest, latitude: latitudeUnderTest)!.azimuth.degrees
        var altitude = equatorialCoordinatesUnderTest.equatorial2Horizon(lstDecimal: lstUnderTest, latitude: latitudeUnderTest)!.altitude.degrees
        
        //Step3: Check if output of the function under test is close to expected output for both azimuth and altitude
        XCTAssertTrue(abs(azimuth - expectedAzimuth) < 0.1)
        XCTAssertTrue(abs(altitude - expectedAltitude) < 0.1)
        
        
    //Test2: Suppose a star is located at δ = −0°30′30′′, H = 16h29m45s. For an observer at 25° N latitude. Expected output shall be Azimuth = 80°31′31′′ ,and −20°34′40′′.
        
        //Step4: 
        let hourAngleDecimal = HMS.init(hours: 16, minutes: 29, seconds: 45).hMS2Decimal()
        let hourAngle: Angle = .init(degrees: hourAngleDecimal * 15)
        latitudeUnderTest = .degrees(25)
        let declinationUnderTest: Angle = .init(degrees: DMS.init(degrees: 0, minutes: 30, seconds: 30,isANegativeZero: true).dMS2Decimal())
        
        //Step5: Creating a new instance of EquatorialCoordinates initialized with declinaiton and hour angle under test
        equatorialCoordinatesUnderTest = .init(declination: declinationUnderTest, hourAngle: hourAngle)
        
        //Step6: Saving expected values in output for both azimuth and altitude
        expectedAltitude = DMS.init(degrees: -20, minutes: 34, seconds: 40).dMS2Decimal()
        expectedAzimuth = DMS.init(degrees: 80, minutes: 31, seconds: 31).dMS2Decimal()
        
        azimuth = equatorialCoordinatesUnderTest.equatorial2Horizon(latitude: latitudeUnderTest)!.azimuth.degrees
        altitude = equatorialCoordinatesUnderTest.equatorial2Horizon(latitude: latitudeUnderTest)!.altitude.degrees
        
        //Step7: Check if output of the function under test is close to expected output for both azimuth and altitude
        XCTAssertTrue(abs(azimuth - expectedAzimuth) < 0.1)
        XCTAssertTrue(abs(altitude - expectedAltitude) < 0.1)
    }
    
    /// Test of equatorial2Ecliptic
    func testOfequatorial2Ecliptic() throws {
        
    //Test1: Given Jupiter’s equatorial coordinates of right ascension 12h18m47.5s, declination −0°43′35.5'', and the standard epoch J2000, compute Jupiter’s ecliptic coordinates.Expected output shall be eclipitc latitude = 1°12′00.0′′ and  ecliptic longitude = 184°36′00.0′′
        
        //Step1:
        let rightAscensionUnderTest = HMS.init(hours: 12, minutes: 18, seconds: 47.5).hMS2Decimal()
        let declinationUnderTest = DMS.init(degrees: 0, minutes: 43, seconds: 35.5,isANegativeZero: true).dMS2Decimal()
        let equatorialCoordinatesUnderTest: EquatorialCoordinates = .init(declination: .degrees(declinationUnderTest), rightAscension: .degrees(rightAscensionUnderTest))
        
        let eclipticCoordinates = equatorialCoordinatesUnderTest.equatorial2Ecliptic() ?? .init(eclipticLatitude: .zero, eclipticLongitude: .zero)
        
        //Step2: Saving expected values in output for both latitude and longitude
        let expectedLatitude = DMS.init(degrees: 1, minutes: 12, seconds: 0).dMS2Decimal()
        let expectedLongitude = DMS.init(degrees: 184, minutes: 36, seconds: 0).dMS2Decimal()
       
        //Step3: Check if output of the function under test is close to expected output for both latitude and longitude
        XCTAssertTrue(abs(expectedLatitude - eclipticCoordinates.eclipticLatitude.degrees) < 0.1)
        XCTAssertTrue(abs(expectedLongitude - eclipticCoordinates.eclipticLongitude.degrees) < 0.1)
    }  
}

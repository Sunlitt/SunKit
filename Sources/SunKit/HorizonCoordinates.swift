//
//  HoorizonCoordinates.swift
//  
//
//  Created by Davide Biancardi on 05/11/22.
//

import Foundation


public struct HorizonCoordinates{
    
    public var altitude: Angle
    public var azimuth: Angle
     

    /// Converts horizon coordinates to equatorial coordinates
    /// - Returns: Equatorial coordinates of the instance.
    public func horizon2Equatorial(latitude: Angle) -> EquatorialCoordinates{
        
        let tZeroHorizonToEquatorial = sin(altitude.radians) * sin(latitude.radians) + cos(altitude.radians) * cos(latitude.radians) * cos(azimuth.radians)
        let declination: Angle = .init(radians:asin(tZeroHorizonToEquatorial))
        
        let tOneHorizonToEquatorial = sin(altitude.radians) - sin(latitude.radians) * sin(declination.radians)
        
        let tTwoHorizonToEquatorial = tOneHorizonToEquatorial / (cos(latitude.radians) * cos(declination.radians))
        
        var hourAngle: Angle = .init(radians: acos(tTwoHorizonToEquatorial))
        
        if sin(altitude.radians) >= 0{
            hourAngle.degrees = 360 - hourAngle.degrees
        }
        return .init(declination: declination, hourAngle: hourAngle)
    }
}

//
//  EclipticCoordinates.swift
//  
//
//  Created by Davide Biancardi on 05/11/22.
//

import Foundation


public struct EclipticCoordinates {
    
    public static let obliquityOfTheEcliptic: Angle = .init(degrees: 23.439292)
    
    public var eclipticLatitude: Angle //beta
    public var eclipticLongitude: Angle //lambda
    
    /// Converts ecliptic coordinatates to equatorial coordinates
    /// - Returns: Equatorial coordinates of the instance
    public func ecliptic2Equatorial() -> EquatorialCoordinates{
        
        //Step4:
        let tEclipticToEquatorial: Angle = .init(radians: sin(eclipticLatitude.radians) * cos(EclipticCoordinates.obliquityOfTheEcliptic.radians) + cos(eclipticLatitude.radians) * sin(EclipticCoordinates.obliquityOfTheEcliptic.radians) * sin(eclipticLongitude.radians))
        
        //Step5:
        let moonDeclination: Angle = .init(radians: asin(tEclipticToEquatorial.radians))
        
        //Step6:
        let yEclipticToEquatorial = sin(eclipticLongitude.radians) * cos(EclipticCoordinates.obliquityOfTheEcliptic.radians) - tan(eclipticLatitude.radians) * sin(EclipticCoordinates.obliquityOfTheEcliptic.radians)
        
        //Step7:
        let xEclipticToEquatorial = cos(eclipticLongitude.radians)
        
        //Step8:
        var r: Angle = .init(radians: atan(yEclipticToEquatorial / xEclipticToEquatorial))
        
        //Step9:
        switch (yEclipticToEquatorial >= 0,xEclipticToEquatorial >= 0){
            
        case (true, true):
            break
        case (true,false):
            r.degrees += 180
        case(false,true):
            r.degrees += 360
        case(false,false):
            r.degrees += 180
        }
        
        let alfa: Angle  = .init(degrees: r.degrees / 15)
        let delta: Angle = .init(degrees: moonDeclination.degrees)
        
        return .init(declination: delta, rightAscension: alfa)
    }
}

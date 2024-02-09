//
//  HoorizonCoordinates.swift
//  
//
//   Copyright 2024 Leonardo Bertinelli, Davide Biancardi, Raffaele Fulgente, Clelia Iovine, Nicolas Mariniello, Fabio Pizzano
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

import Foundation

public struct HorizonCoordinates: Equatable, Hashable, Codable, Sendable {
    
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

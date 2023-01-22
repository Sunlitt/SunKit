//
//  EquatorialCoordinates.swift
//  
//
//  Created by Davide Biancardi on 05/11/22.
//

import Foundation



public struct EquatorialCoordinates{
    
    private(set) var rightAscension: Angle?  // rightAscension.degrees refers to h format
    private(set) var declination: Angle     //delta
    private(set) var hourAngle: Angle?
    
    init(declination: Angle,rightAscension: Angle, hourAngle: Angle){
        self.declination = declination
        self.rightAscension = rightAscension
        self.hourAngle = hourAngle
    }
    
    init(declination: Angle,rightAscension: Angle){
        self.declination = declination
        self.rightAscension = rightAscension
        self.hourAngle = nil
    }
    
    init(declination: Angle,hourAngle: Angle){
        self.declination = declination
        self.hourAngle = hourAngle
        self.rightAscension = nil
    }
    
    init(declination: Angle){
        self.declination = declination
    }
    
    /// To set right ascension we need LST and right ascension. If right ascension is nill we can't set it.
    /// - Parameter lstDecimal: Local Sideral Time in decimal
    /// - Returns: The value of hour angle just been set. Nil if right ascension  is also nil
   public mutating func setHourAngleFrom(lstDecimal: Double) -> Angle?{
        
       guard let rightAscension = self.rightAscension else {return nil}
       
        var hourAngleDecimal = lstDecimal - rightAscension.degrees
        if hourAngleDecimal < 0 {
            hourAngleDecimal += 24
        }
       self.hourAngle = .init(degrees: hourAngleDecimal * 15)
       
       return self.hourAngle
    }
    
    /// To set right ascension we need LST and hour angle. If hour angle is nill we can't set it.
    /// - Parameter lstDecimal: Local Sideral Time in decimal
    /// - Returns: The value of right ascension just been set. Nil if hour angle is also nil
    public mutating func setRightAscensionFrom(lstDecimal: Double) -> Angle?{
         
        guard let hourAngle = self.hourAngle else {return nil}
        
        let hourAngleDecimal = hourAngle.degrees / 15
        
        self.rightAscension = .init(degrees: lstDecimal - hourAngleDecimal)
       
        return self.rightAscension
     }


    /// Converts Equatorial coordinates to Horizon coordinates.
    ///
    /// Since horizon coordinates depend on the position, we need also  latitude parameter to create an EquatorialCoordinates instance.
    ///
    /// - Parameters:
    ///   - lstDecimal: Local Sidereal Time in decimal format.
    ///   - latitude: Latitude of the observer
    /// - Returns: Horizon coordinates for the given latitude and LST. Nil if hour angle cannot be computed due to the miss right ascnsion information
    public mutating func equatorial2Horizon(lstDecimal: Double,latitude: Angle) -> HorizonCoordinates?{
        
        guard let _ = setHourAngleFrom(lstDecimal: lstDecimal) else {return nil}
        
        //Step4:
        let tZeroEquatorialToHorizon = sin(declination.radians) * sin(latitude.radians) + cos(declination.radians) * cos(latitude.radians) * cos(hourAngle!.radians)
        
        //Step5:
        let altitude: Angle = .init(radians: asin(tZeroEquatorialToHorizon))
        
        //Step6:
        let tOneEquatorialToHorizon = sin(declination.radians) - sin(latitude.radians) * sin(altitude.radians)
        
        //Step7:
        let tTwoEquatorialToHorizon = tOneEquatorialToHorizon / (cos(latitude.radians) * cos(altitude.radians))
        
        //Step8:
        var azimuth: Angle = .init(radians: acos(tTwoEquatorialToHorizon))
        if sin(hourAngle!.radians) >= 0{
            azimuth.degrees = 360 - azimuth.degrees
        }
        
        return .init(altitude: altitude, azimuth: azimuth)
    }
    
    /// Converts Equatorial coordinates to Horizon coordinates.
    ///
    /// Since horizon coordinates depend on the position, we need also latitude parameter to create an EquatorialCoordinates instance.
    ///
    /// - Parameters:
    ///   - latitude: Latitude of the observer
    /// - Returns: Horizon coordinates for the given latitude. Nil if hour angle is not defined.
    public func equatorial2Horizon(latitude: Angle) -> HorizonCoordinates?{
        
        guard let _ = self.hourAngle else {return nil}
        
        //Step4:
        let tZeroEquatorialToHorizon = sin(declination.radians) * sin(latitude.radians) + cos(declination.radians) * cos(latitude.radians) * cos(hourAngle!.radians)
        
        //Step5:
        let altitude: Angle = .init(radians: asin(tZeroEquatorialToHorizon))
        
        //Step6:
        let tOneEquatorialToHorizon = sin(declination.radians) - sin(latitude.radians) * sin(altitude.radians)
        
        //Step7:
        let tTwoEquatorialToHorizon = tOneEquatorialToHorizon / (cos(latitude.radians) * cos(altitude.radians))
        
        //Step8:
        var azimuth: Angle = .init(radians: acos(tTwoEquatorialToHorizon))
        if sin(hourAngle!.radians) >= 0{
            azimuth.degrees = 360 - azimuth.degrees
        }
        
        return .init(altitude: altitude, azimuth: azimuth)
    }
    
    public func equatorial2Ecliptic() -> EclipticCoordinates?{
        
        guard var rightAscension = rightAscension else {return nil}
      
        rightAscension.degrees = rightAscension.degrees * 15 //from h format to degrees
        
        //Step5:
        let tEquatorialToEcliptic: Angle = .init(radians: sin(declination.radians) * cos(EclipticCoordinates.obliquityOfTheEcliptic.radians) - cos(declination.radians) * sin(EclipticCoordinates.obliquityOfTheEcliptic.radians) * sin(rightAscension.radians))
        
        //Step6:
        let eclipticLatitude: Angle = .init(radians: asin(tEquatorialToEcliptic.radians))
        
        //Step7:
        let yEquatorialToEcliptic = sin(rightAscension.radians) * cos(EclipticCoordinates.obliquityOfTheEcliptic.radians) + tan(declination.radians) * sin(EclipticCoordinates.obliquityOfTheEcliptic.radians)
        
        //Step8:
        let xEquatorialToEcliptic = cos(rightAscension.radians)
        
        //Step9:
        var r: Angle = .init(radians: atan(yEquatorialToEcliptic / xEquatorialToEcliptic))
        
        //Step9:
        switch (yEquatorialToEcliptic >= 0,xEquatorialToEcliptic >= 0){
            
        case (true, true):
            break
        case (true,false):
            r.degrees += 180
        case(false,true):
            r.degrees += 360
        case(false,false):
            r.degrees += 180
        }
    
        let eclipticLongitude: Angle = .init(degrees: r.degrees)
        
        return .init(eclipticLatitude: eclipticLatitude, eclipticLongitude: eclipticLongitude)
    }
}

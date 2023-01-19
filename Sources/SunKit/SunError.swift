//
//  SunError.swift
//  litt
//
//  Created by Davide Biancardi on 25/05/22.
//

import Foundation

public enum SunError: Error {
    case unableToGenerateStartOfTheYear(from: Date)
    case unableToGenerateDaysPassedFromStartOfTheYear(from: Date , to: Date)
    case unableToGenerateLocalSolarDate(from: Date, byAdding: Double)
    case unableToGenerateLocalSolarTimeMinute(from: Date)
    case azimuthIsInfinite
    case undefiniedError(description : String)
    case unableToGenerateSunriseDate(from: Date)
    case unableToGenerateSunsetDate(from: Date)
    case unableToGenerateGoldenHourStart(from: Date)
    case unableToGenerateGoldenHourFinish(from: Date)
    case unableToGenerateSolarNoon(from: Date)
    case unableToGenerateLastLight(from: Date)
    case unableToGenerateFirstLight(from: Date)
    case readableError(description : String)
    case noError
    
    public func description() -> String {
        switch self {
        case .unableToGenerateStartOfTheYear(let from):
            return "unableToGenerateStartOfTheYear from the date \(from)"
            
        case .unableToGenerateDaysPassedFromStartOfTheYear(let from, let to):
            return "unableToGenerateDaysPassedFromStartOfTheYear from \(from) to \(to)"
            
        case .unableToGenerateLocalSolarDate(let from, let byAdding):
            return "unableToGenerateLocalSolarDate from \(from) by adding \(byAdding)"
            
        case .unableToGenerateLocalSolarTimeMinute(let from):
            return "unableToGenerateLocalSolarTimeMinute from \(from)"
            
        case .undefiniedError(let description):
            return ("Undefined error with description \(description)")
            
        case .azimuthIsInfinite:
            return "azimuthIsInfinite"
            
        case .unableToGenerateSunriseDate(let date):
            return "Unable to generate sunrise date from \(date)"
            
        case .unableToGenerateSunsetDate(let date):
            return "Unable to generate sunset date from \(date)"
            
        case .unableToGenerateGoldenHourStart(let date):
            return "Unable to generate golden hour start date from \(date)"
            
        case .unableToGenerateGoldenHourFinish(let date):
            return "Unable to generate golden hour finish date from \(date)"
            
        case .unableToGenerateSolarNoon(let date):
            return "Unable to generate solar noon from \(date)"
            
        case .unableToGenerateLastLight(let date):
            return "Unable to generate last light from \(date)"
        
        case .unableToGenerateFirstLight(let date):
            return "Unable to generate first light from \(date)"
            
        case .readableError(let description):
            return description
            
        case .noError:
            return "No error :)"
        }
    }
}

public enum LocationError: Error {
    case noHeadingAvaiable
    case undefiniedError(description: String)
    case noError
    
    public func description() -> String {
        switch self {
        case .noHeadingAvaiable:
            return "No heading available"
            
        case .undefiniedError(let description):
            return ("Undefined error with description \(description)")
            
        case .noError:
            return "No error :)"
        }
    }
}

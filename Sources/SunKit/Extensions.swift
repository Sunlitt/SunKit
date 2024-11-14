//
//  Extensions.swift
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
import CoreLocation

//It consents us too loop between two dates for n as interval time
extension Date: @retroactive Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }
    
    func toString(_ timeZone: TimeZone) -> String {
        let df = DateFormatter()
        df.timeZone = timeZone
        let custom = DateFormatter.dateFormat(fromTemplate: "MMdd HH:mm",
                                              options: 0,
                                              locale: Locale(identifier: "en"))
        df.dateFormat = custom
        return df.string(from: self)
    }
    
    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}

extension Calendar {
    func numberOfDaysSinceStartOfTheYear(for date: Date) -> Int {
        let startOfTheYear: Date = startOfYear(date)
        let startOfTheDay = startOfDay(for: date)
        let numberOfDays = dateComponents([.day], from: startOfTheYear, to: startOfTheDay)
        
        return numberOfDays.day! + 1
    }
    
    func startOfYear(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.year], from: date))!
    }
    
}

extension TimeZone {
    
    func offset(_ date: Date) -> Double {
        let res =
        Int(self.secondsFromGMT(for: date))
        + Int(self.daylightSavingTimeOffset(for: date))
        - Int(Calendar.current.timeZone.secondsFromGMT(for: date))
        - Int(Calendar.current.timeZone.daylightSavingTimeOffset(for: date))
        return Double(res)/SECONDS_IN_ONE_HOUR
        
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

extension CLLocationCoordinate2D: Codable {
    internal enum Keys: CodingKey {
        case latitude
        case longitude
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

//
//  Angle.swift
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


import Foundation

public struct Angle: Equatable, Hashable, Codable, Sendable {
        
    public static var zero: Angle = .init()
    
    public init() {
        _radians = 0
    }
    
    public init(radians: Double) {
        _radians = radians
    }
  
    public init(degrees: Double) {
        _radians = degrees * Double.pi / 180.0
    }
        
    public var degrees: Double {
        get { _radians * 180.0 / Double.pi }
        set { _radians = newValue * Double.pi / 180 }
    }
    
    public var radians: Double {
        get { _radians }
        set { _radians = newValue }
    }
    
    private var _radians: Double
    
    public static func degrees(_ value: Double) -> Angle {
        .init(degrees: value)
    }
    
    public static func radians(_ value: Double) -> Angle {
        .init(radians: value)
    }

}

//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct Location {
  public let longitude: Float
  public let latitude: Float
  public let elevation: Float
  public var timezone: Int

  public var coordinates: (Double, Double, Double) {
    return (Double(longitude), Double(latitude), Double(elevation))
  }

  public static var primeMeridian = Location(
    longitude: 0, latitude: 0, elevation: 102
  )
  
  public init(longitude: Float, latitude: Float, elevation: Float) {
    self.longitude = longitude
    self.latitude = latitude
    self.elevation = elevation
    self.timezone = Int(longitude) / 15
  }

  public init(_ coords: (Double, Double, Double)) {
    self.longitude = Float(coords.0)
    self.latitude = Float(coords.1)
    self.elevation = Float(coords.2)
    self.timezone = Int(coords.0) / 15
  } 
}

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
  public let longitude: Double
  public let latitude: Double
  public let elevation: Double
  public var timezone: Int

  public var coordinates: (Double, Double, Double) {
    return (longitude, latitude, elevation)
  }

  public static var primeMeridian = Location(
    longitude: 0, latitude: 0, elevation: 102, timezone: 0
  )
  
  public init(longitude: Double, latitude: Double, elevation: Double, timezone: Int) {
    self.longitude = longitude
    self.latitude = latitude
    self.elevation = elevation
    self.timezone = timezone
  }

  public init(_ coords: (Double, Double, Double), timezone: Int) {
    self.longitude = coords.0
    self.latitude = coords.1
    self.elevation = coords.2
    self.timezone = timezone
  } 
}

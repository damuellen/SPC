//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation

public struct MeteoData {
  
  public let temperature, dni, windSpeed: Float
  public let wetBulbTemperature: Float? = nil
  
  /// Linear interpolation function for meteo data values
  static func interpolate(from fromData: MeteoData,
                          to toData: MeteoData, with lerp: Float) -> MeteoData {
    
    if lerp >= 1 { return toData }
    
    let dni = fromData.dni + (lerp * (toData.dni - fromData.dni)),
    temperature = fromData.temperature
      + (lerp * (toData.temperature - fromData.temperature)),
    windSpeed = fromData.windSpeed
      + (lerp * (toData.windSpeed - fromData.windSpeed))
    
    return MeteoData(
      dni: dni, temperature: temperature, windSpeed: windSpeed)
  }
  
  public init(dni: Float, temperature: Float, windSpeed: Float) {
    self.dni = dni
    self.temperature = temperature
    self.windSpeed = windSpeed
  }
}
// meteo-data interpolation:
/*
do {
  var K = 8760
  var N = 0
  var intJ = 0
  
  for intN in 1 ... K {
    if intN = 1 {  //first data
      let a_dni = Meteo(intN).dni
      let b_dni = (Meteo(intN + 1).dni - Meteo(intN).dni) / 2 + Meteo(intN).dni
      let m_dni = (b_dni - a_dni)
      let Aprime_dni = (2 * Meteo(intN).dni - m_dni) / 2
      
      var IntMin = 0
      for intX in 1 ... 6 {//SIM.MTOperiod = 6 for 10 minutes interval interpolation
        intJ = intJ + 1
        IntMin = IntMin + 1
        IntMeteo(intJ).dni = m_dni * intX / 6 + Aprime_dni
        
        IntAtime(intJ).day = Atime(intN).day
        IntAtime(intJ).Hour = Atime(intN).Hour
        IntAtime(intJ).minutes = (IntMin - 1) * 10
      }
    } else { //rest of the data
      var a_dni = (Meteo(intN).dni - Meteo(intN - 1).dni) / 2 + Meteo(intN - 1).dni
      var b_dni = (Meteo(intN + 1).dni - Meteo(intN).dni) / 2 + Meteo(intN).dni
      if a_dni <= 0 || b_dni <= 0 {
        a_dni = 0
        b_dni = 0
      }
      var m_dni = (b_dni - a_dni)
      var Aprime_dni = (2 * Meteo(intN).dni - m_dni) / 2
      var Bprime_dni = Aprime_dni + m_dni
      if Aprime_dni < 0 {
        Bprime_dni = Bprime_dni + Aprime_dni
        Aprime_dni = 0
        m_dni = Bprime_dni - Aprime_dni
      }
      if Bprime_dni < 0 {
        Aprime_dni = Aprime_dni + Bprime_dni
        Bprime_dni = 0
        m_dni = Bprime_dni - Aprime_dni
      }
      
      var IntMin = 0
      for intX in 1 ... 6 {//SIM.MTOperiod = 6 for 10 minutes interval interpolation
        intJ = intJ + 1
        IntMin = IntMin + 1
        if Aprime_dni >= 0 {
          IntMeteo(intJ).dni = m_dni * (intX * 2 - 1) / 12 + Aprime_dni
        } else {
          IntMeteo(intJ).dni = m_dni * intX / 6
        }
        
        IntAtime(intJ).day = Atime(intN).day
        IntAtime(intJ).Hour = Atime(intN).Hour
        IntAtime(intJ).minutes = (IntMin - 1) * 10
      }
    }
  }
  for K in 1 ... intJ {
    //Meteo(K).dni = format(IntMeteo(K).dni, "0.####")
    
    //Atime(K).day = IntAtime(K).day
    //Atime(K).Hour = IntAtime(K).Hour
    //Atime(K).minutes = IntAtime(K).minutes
  }
  K = K - 1
}
*/
public class MeteoDataSource {
  
  public let data: [MeteoData]
  
  public let location: Location
  public let year: Int?
  public let timeZone: Int?
  
  init(data: [MeteoData], location: Location, year: Int?, timeZone: Int?) {
    self.data = data
    self.location = location
    self.year = year
    self.timeZone = timeZone
  }
}

public struct Location {
  public let longitude: Double
  public let latitude: Double
  public let elevation: Double
  
  public init(longitude: Double, latitude: Double, elevation: Double) {
    self.longitude = longitude
    self.latitude = latitude
    self.elevation = elevation
  }
}

/*
 period        : Integer      'Validity period [sec]
 dni           : Single       'Normal Direct Insolation
 ICosTheta     : Single       'I * COS(Theta)
 theta         : Single       'Incident angle [rad]
 SinPE         : Single       'SIN(PE)
 PE            : Single       'Tracking Angle
 Tamb          : Single       'ambient Temperature [øC]
 WS            : Single       'Wind speed [m/sec]
 WD            : Single       'Wind direction 0° is north
 V1            : Single       'elevation
 V2            : Single       'azimuth
 soltime       : Single
 WBT           : Single       'wet bulb temperature
 phi           : Double       'Integration of Fresnel
 GHI           : Single       'for OU1 PV
 */

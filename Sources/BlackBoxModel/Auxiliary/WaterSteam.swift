import CIAPWSIF97
/// IAPWS formulations of the thermodynamic properties of water and steam.
public enum WaterSteam {

  /// temperature on boiling point curve.
  public static func temperature(p pressure: Double) -> Temperature {
    let p = pressure / 10
    return Temperature(Ts_p(p))
  }

  /// specific enthalpy [kJ/kg] on the boiling point curve.
  public static func enthalpyLiquid(p pressure: Double) -> Double {
    let p = pressure / 10
    let t = Ts_p(p)
    return h_pT(p, t, 1)
  }
  
  /// specific enthalpy [kJ/kg] on the dew point curve.
  public static func enthalpyVapor(p pressure: Double) -> Double {
    let p = pressure / 10
    let t = Ts_p(p)
    return h_pT(p, t, 2)
  }

  public static func enthalpy(p pressure: Double, t temperature: Temperature) -> Double {
    let p = pressure / 10
    let t = temperature.kelvin
    let r = region_pT(p, t)
    return h_pT(p, t, r)
  }

  public static func temperature(p pressure: Double, h enthalpy: Double) -> Temperature {
    let p = pressure / 10
    let h = enthalpy
    return Temperature(T_ph(p, h))
  }    
}

import Foundation
import Utilities

public struct Parameter {
  public var ranges: [ClosedRange<Double>]

  public init(
    CSP_loop_nr: ClosedRange<Double> = 0...200.0,
    TES_thermal_cap: ClosedRange<Double> = 0...8000.0,
    PB_nom_gross_cap: ClosedRange<Double> =  0...250.0,
    PV_AC_cap: ClosedRange<Double> = 200...800.0,
    PV_DC_cap: ClosedRange<Double> = 400...1000.0,
    CCU_CO2_nom_prod: ClosedRange<Double> = 1000...1000.0,
    CO2_storage_cap: ClosedRange<Double> = 10000...10000.0,
    El_boiler_cap: ClosedRange<Double> = 0...200.0,
    EY_var_net_nom_cons: ClosedRange<Double> = 180...180,
    Hydrogen_storage_cap: ClosedRange<Double> =  0...0.0, 
    Heater_cap: ClosedRange<Double> =  0...1000.0, 
    MethDist_Meth_nom_prod: ClosedRange<Double> = 5...50.0,
    RawMeth_storage_cap: ClosedRange<Double> = 100_000...100_000.0,
    BESS_cap: ClosedRange<Double> = 0...0.0,
    Grid_export_max: ClosedRange<Double> = 0...0.0,
    Grid_import_max: ClosedRange<Double> = 0...0.0
  ) {
    self.ranges = [
      CSP_loop_nr, // [0]
      TES_thermal_cap, // [1]
      PB_nom_gross_cap, // [2]
      PV_AC_cap, // [3]
      PV_DC_cap, // [4]
      EY_var_net_nom_cons, // [5]
      Hydrogen_storage_cap, // [6]
      Heater_cap, // [7]
      CCU_CO2_nom_prod, // [8]
      CO2_storage_cap, // [9]
      RawMeth_storage_cap, // [10] 
      MethDist_Meth_nom_prod, // [11]
      El_boiler_cap,  // [12]
      BESS_cap, // [13]
      Grid_export_max, // [14]
      Grid_import_max // [15]
    ]
  }

  subscript(i: Int) -> ClosedRange<Double> {
    get { ranges[i] } 
    set { ranges[i] = newValue }
  }
}

public struct InputParameter: Codable {
  public var CSP_loop_nr_min: Double
  public var CSP_loop_nr_max: Double
  public var TES_thermal_cap_min: Double
  public var TES_thermal_cap_max: Double
  public var PB_nom_gross_cap_min: Double
  public var PB_nom_gross_cap_max: Double
  public var PV_AC_cap_min: Double
  public var PV_AC_cap_max: Double
  public var PV_DC_cap_min: Double
  public var PV_DC_cap_max: Double
  public var EY_var_net_nom_cons_min: Double
  public var EY_var_net_nom_cons_max: Double
  public var Hydrogen_storage_cap_min: Double
  public var Hydrogen_storage_cap_max: Double
  public var Heater_cap_min: Double
  public var Heater_cap_max: Double
  public var CCU_CO2_nom_prod_min: Double
  public var CCU_CO2_nom_prod_max: Double
  public var CO2_storage_cap_min: Double
  public var CO2_storage_cap_max: Double
  public var RawMeth_storage_cap_min: Double
  public var RawMeth_storage_cap_max: Double
  public var MethDist_Meth_nom_prod_min: Double
  public var MethDist_Meth_nom_prod_max: Double
  public var El_boiler_cap_min: Double
  public var El_boiler_cap_max: Double
  public var BESS_cap_min: Double
  public var BESS_cap_max: Double

  public init(ranges: [ClosedRange<Double>]) {
    self.CSP_loop_nr_min = ranges[0].lowerBound
    self.CSP_loop_nr_max = ranges[0].upperBound
    self.TES_thermal_cap_min = ranges[1].lowerBound
    self.TES_thermal_cap_max = ranges[1].upperBound
    self.PB_nom_gross_cap_min = ranges[2].lowerBound
    self.PB_nom_gross_cap_max = ranges[2].upperBound
    self.PV_AC_cap_min = ranges[3].lowerBound
    self.PV_AC_cap_max = ranges[3].upperBound
    self.PV_DC_cap_min = ranges[4].lowerBound
    self.PV_DC_cap_max = ranges[4].upperBound
    self.EY_var_net_nom_cons_min = ranges[5].lowerBound
    self.EY_var_net_nom_cons_max = ranges[5].upperBound
    self.Hydrogen_storage_cap_min = ranges[6].lowerBound
    self.Hydrogen_storage_cap_max = ranges[6].upperBound
    self.Heater_cap_min = ranges[7].lowerBound
    self.Heater_cap_max = ranges[7].upperBound
    self.CCU_CO2_nom_prod_min = ranges[8].lowerBound
    self.CCU_CO2_nom_prod_max = ranges[8].upperBound
    self.CO2_storage_cap_min = ranges[9].lowerBound
    self.CO2_storage_cap_max = ranges[9].upperBound
    self.RawMeth_storage_cap_min = ranges[10].lowerBound
    self.RawMeth_storage_cap_max = ranges[10].upperBound
    self.MethDist_Meth_nom_prod_min = ranges[11].lowerBound
    self.MethDist_Meth_nom_prod_max = ranges[11].upperBound
    self.El_boiler_cap_min = ranges[12].lowerBound
    self.El_boiler_cap_max = ranges[12].upperBound
    self.BESS_cap_min = ranges[13].lowerBound
    self.BESS_cap_max = ranges[13].upperBound
  }

  public var ranges: [ClosedRange<Double>] { [
    CSP_loop_nr_min...CSP_loop_nr_max, // [0]
    TES_thermal_cap_min...TES_thermal_cap_max, // [1]
    PB_nom_gross_cap_min...PB_nom_gross_cap_max, // [2]
    PV_AC_cap_min...PV_AC_cap_max, // [3]
    PV_DC_cap_min...PV_DC_cap_max, // [4]
    EY_var_net_nom_cons_min...EY_var_net_nom_cons_max, // [5]
    Hydrogen_storage_cap_min...Hydrogen_storage_cap_max, // [6]
    Heater_cap_min...Heater_cap_max, // [7]
    CCU_CO2_nom_prod_min...CCU_CO2_nom_prod_max, // [8]
    CO2_storage_cap_min...CO2_storage_cap_max, // [9]
    RawMeth_storage_cap_min...RawMeth_storage_cap_max, // [10] 
    MethDist_Meth_nom_prod_min...MethDist_Meth_nom_prod_max, // [11]
    El_boiler_cap_min...El_boiler_cap_max,  // [12]
    BESS_cap_min...BESS_cap_max, // [13]
    0.0...0.0, // [14]
    0.0...0.0] // [15]
  }
}
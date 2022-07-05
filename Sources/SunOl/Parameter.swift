import Foundation
import Utilities

public struct Parameter: Codable {
  public var ranges: [ClosedRange<Double>]

  public init(
    BESS_cap_ud: ClosedRange<Double>,
    CCU_CO2_nom_prod_ud: ClosedRange<Double>,
    CO2_storage_cap_ud: ClosedRange<Double>,
    CSP_loop_nr_ud: ClosedRange<Double>,
    El_boiler_cap_ud: ClosedRange<Double>,
    EY_var_net_nom_cons_ud: ClosedRange<Double>,
    Grid_export_max_ud: ClosedRange<Double>,
    Grid_import_max_ud: ClosedRange<Double>,
    Hydrogen_storage_cap_ud: ClosedRange<Double>,
    Heater_cap_ud: ClosedRange<Double>,
    MethDist_Meth_nom_prod_ud: ClosedRange<Double>,
    // MethSynt_RawMeth_nom_prod_ud: ClosedRange<Double>,
    PB_nom_gross_cap_ud: ClosedRange<Double>,
    PV_AC_cap_ud: ClosedRange<Double>,
    PV_DC_cap_ud: ClosedRange<Double>,
    RawMeth_storage_cap_ud: ClosedRange<Double>,
    TES_thermal_cap_ud: ClosedRange<Double>
  ) {
    self.ranges = [
      CSP_loop_nr_ud, // [0]
      TES_thermal_cap_ud, // [1]
      PB_nom_gross_cap_ud, // [2]
      PV_AC_cap_ud, // [3]
      PV_DC_cap_ud, // [4]
      EY_var_net_nom_cons_ud, // [5]
      Hydrogen_storage_cap_ud, // [6]
      Heater_cap_ud, // [7]
      CCU_CO2_nom_prod_ud, // [8]
      CO2_storage_cap_ud, // [9]
      // MethSynt_RawMeth_nom_prod_ud,
      RawMeth_storage_cap_ud, // [10]
      MethDist_Meth_nom_prod_ud, // [11]
      El_boiler_cap_ud, // [12]
      BESS_cap_ud, // [13]
      Grid_export_max_ud, // [14]
      Grid_import_max_ud // [15]
    ]
  }

  subscript(i: Int) -> ClosedRange<Double> {
    get { ranges[i] } 
    set { ranges[i] = newValue }
  }
}

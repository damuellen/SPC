import Foundation
import Utilities

public struct Parameter: Codable {
  public var ranges: [ClosedRange<Float>]

  public init(
    BESS_cap_ud: ClosedRange<Float>,
    CCU_CO2_nom_prod_ud: ClosedRange<Float>,
    CO2_storage_cap_ud: ClosedRange<Float>,
    CSP_loop_nr_ud: ClosedRange<Float>,
    El_boiler_cap_ud: ClosedRange<Float>,
    EY_var_net_nom_cons_ud: ClosedRange<Float>,
    Grid_export_max_ud: ClosedRange<Float>,
    Grid_import_max_ud: ClosedRange<Float>,
    Hydrogen_storage_cap_ud: ClosedRange<Float>,
    Heater_cap_ud: ClosedRange<Float>,
    MethDist_Meth_nom_prod_ud: ClosedRange<Float>,
    // MethSynt_RawMeth_nom_prod_ud: ClosedRange<Float>,
    PB_nom_gross_cap_ud: ClosedRange<Float>,
    PV_AC_cap_ud: ClosedRange<Float>,
    PV_DC_cap_ud: ClosedRange<Float>,
    RawMeth_storage_cap_ud: ClosedRange<Float>,
    TES_thermal_cap_ud: ClosedRange<Float>
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
      El_boiler_cap_ud,  // [12]
      BESS_cap_ud, // [13]
      Grid_export_max_ud, // [14]
      Grid_import_max_ud // [15]
    ]
  }

  subscript(i: Int) -> ClosedRange<Float> {
    get { ranges[i] } 
    set { ranges[i] = newValue }
  }
}

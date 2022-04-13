import Foundation
import Utilities

public struct Parameter: Codable {
  public var ranges: [ClosedRange<Double>]

  public init(
    BESS_cap_ud: ClosedRange<Double>,
    CCU_C_O_2_nom_prod_ud: ClosedRange<Double>,
    C_O_2_storage_cap_ud: ClosedRange<Double>,
    CSP_loop_nr_ud: ClosedRange<Double>,
    El_boiler_cap_ud: ClosedRange<Double>,
    EY_var_net_nom_cons_ud: ClosedRange<Double>,
    Grid_export_max_ud: ClosedRange<Double>,
    Grid_import_max_ud: ClosedRange<Double>,
    Hydrogen_storage_cap_ud: ClosedRange<Double>,
    Heater_cap_ud: ClosedRange<Double>,
    MethDist_Meth_nom_prod_ud: ClosedRange<Double>,
    MethSynt_RawMeth_nom_prod_ud: ClosedRange<Double>,
    PB_nom_gross_cap_ud: ClosedRange<Double>,
    PV_AC_cap_ud: ClosedRange<Double>,
    PV_DC_cap_ud: ClosedRange<Double>,
    RawMeth_storage_cap_ud: ClosedRange<Double>,
    TES_full_load_hours_ud: ClosedRange<Double>
  ) {
    self.ranges = [
      CSP_loop_nr_ud,
      TES_full_load_hours_ud,
      PB_nom_gross_cap_ud,
      PV_AC_cap_ud,
      PV_DC_cap_ud,
      EY_var_net_nom_cons_ud,
      Hydrogen_storage_cap_ud,
      Heater_cap_ud,
      CCU_C_O_2_nom_prod_ud,
      C_O_2_storage_cap_ud,
      MethSynt_RawMeth_nom_prod_ud,
      RawMeth_storage_cap_ud,
      MethDist_Meth_nom_prod_ud,
      El_boiler_cap_ud,
      BESS_cap_ud,
      Grid_export_max_ud,
      Grid_import_max_ud
    ]
  }

  subscript(i: Int) -> ClosedRange<Double> {
    get { ranges[i] } 
    set { ranges[i] = newValue }
  }
}

extension ClosedRange where Bound == Double {
  func normalized(value: Double) -> Double {
    if lowerBound == upperBound { return 1 }
    precondition((0...1).contains(value))
    return (value - lowerBound) / (upperBound - lowerBound)
  }

  func denormalized(value: Double) -> Double {
    return lowerBound + value * (upperBound - lowerBound)
  }
}

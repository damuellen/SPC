import Foundation
import Utilities

struct SunOl {
  var CSP_Loop_Nr = 113.0
  var PV_DC_Cap = 818.0
  var PV_AC_Cap = 613.0
  var Heater_cap = 239.0
  var TES_Full_Load_Hours = 14.0
  var EY_Nominal_elec_input = 280.0
  var EY_aux_elec_input = 0.0
  var Meth_nominal_aux_electr_cons = 0.0
  var PB_Nominal_gross_cap = 250.0
  var BESS_cap = 100.0
  var H2_storage_cap = 100.0
  var Meth_nominal_hour_prod_cap = 14.8
  var El_boiler_cap = 100.0
  var grid_max_export = 70.0
  var grid_max_import: Double { grid_max_export }
  var BESS_max_Charging_cap = 50.0

  struct Heater {
    var eff = 0.96
    var cap = 239.0
  }

  struct Battery {
    var cap = 100.0
    var charging_eff = 0.7
    var charging_cap = 50.0
  }

  struct PowerBlock {
    private var ref_gross_cap = (nominal: 200.0, low: 63.0, min: 25.0, maxExport: 25.0)
    private var ref_heat_input = (nominal: 463.485, low: 168.787, min: 85.512, maxExport: 112.349)
    private var ref_aux_heat_prod: (nominal: Double, low: Double, min: Double, maxExport: Double) = (
      56.911135799999997, 26.901868399999998, 17.902553200000003, 56.911135799999997  // (23.333*2775.4-15.167*167.6-8.167*649.6)/1000.0,
      // (10.778*2775.4-8.278*167.6-2.5*649.6)/1000.0,
      // (7.194*2775.4-5.414*167.6-1.78*649.6)/1000.0,
      // (23.333*2775.4-15.167*167.6-8.167*649.6)/1000.0
    )

    var min_op_hours = 5.0
    var nominal_gross_cap = 250.0
    var nominal_gross_eff = 0.4713
    var Ratio_Heat_input_vs_output = 0.6176
    var aux_cons_perc = 0.05
    var max_heat_input = 569.855
    var min_heat_input = 91.4943
    var min_el_cap_perc = 0.125
    var minimum_gross_cap = 31.25
    var cold_start_energyperc = 2.0
    var warm_start_energyperc = 0.4
    var hot_start_energyperc = 0.05
    var warm_start_duration = 6.0
    var cold_start_duration = 48.0
    var th = Polynomial([-1.52794811, 4.61474612, -5.27135243, 2.81011828, 0.37443614].reversed())
    var el = Polynomial([-1.29372858006, 3.79919335925, -4.21508179486, 2.20137842450, 0.50823859118].reversed())

    lazy var nominal_heat_input = nominal_gross_cap / nominal_gross_eff
    lazy var cold_start_heat_req = nominal_heat_input * cold_start_energyperc
    lazy var warm_start_heat_req = nominal_heat_input * warm_start_energyperc
    lazy var hot_start_heat_req = nominal_heat_input * hot_start_energyperc

    mutating func proportion(nominal_gross_cap: Double, EY: electrolysis, nominal_heatConsumption: Double) {
      if nominal_gross_cap == 0 {
        self.nominal_gross_cap = 0
        max_heat_input = 0
        min_heat_input = 0
        minimum_gross_cap = 0
        nominal_gross_eff = 0
        th = Polynomial([0])
        el = Polynomial([0])
        return
      }

      minimum_gross_cap = nominal_gross_cap * min_el_cap_perc

      let gross_cap = [  // A29-A33
        ref_gross_cap.nominal, ((((ref_gross_cap.min + ref_gross_cap.nominal) / 2) + ref_gross_cap.nominal) / 2),
        ((ref_gross_cap.min + ref_gross_cap.nominal) / 2), ref_gross_cap.low, ref_gross_cap.min,
      ]
      let load_perc = gross_cap.map { $0 / ref_gross_cap.nominal }  // B

      let heat_input = load_perc.map { $0 * nominal_gross_cap }  // D

      let factor = seek(goal: 0) { (ref_heat_input.min - ref_aux_heat_prod.min * $0) - (ref_heat_input.maxExport - ref_aux_heat_prod.maxExport * $0) }

      let no_extraction = [  // B
        ref_heat_input.nominal - ref_aux_heat_prod.nominal * factor,
        ((((ref_heat_input.min + ref_heat_input.nominal) / 2) + ref_heat_input.nominal) / 2)
          - ((((ref_aux_heat_prod.min + ref_aux_heat_prod.nominal) / 2) + ref_aux_heat_prod.nominal) / 2) * factor,
        ((ref_heat_input.min + ref_heat_input.nominal) / 2) - ((ref_aux_heat_prod.min + ref_aux_heat_prod.nominal) / 2) * factor,
        ref_heat_input.low - ref_aux_heat_prod.low * factor, ref_heat_input.min - ref_aux_heat_prod.min * factor,
      ]

      let ref_eff = zip(gross_cap, no_extraction).map(/)  // C
      let gross = zip(heat_input, ref_eff).map(/)  // E
      let eff = zip(heat_input, gross).map(/)  // K
      let eff_factor = eff.map { $0 / eff[0] }  // L
      let thermal_load_perc = gross.map { $0 / gross[0] }  // J
      let steam_extraction = load_perc.map {
        min(EY.heat_input, EY.heat_input * $0 * nominal_gross_cap * (1.0 - aux_cons_perc) / (EY.net_elec_input + EY.aux_elec_input))
          + nominal_heatConsumption
      }  // F
      th = Polynomial.fit(x: thermal_load_perc, y: eff_factor, order: 4)!
      el = Polynomial.fit(x: load_perc, y: eff_factor, order: 4)!
      Ratio_Heat_input_vs_output = factor * (no_extraction[0] / ref_aux_heat_prod.nominal) / (gross[0] / steam_extraction[0])
      max_heat_input = gross[0] + steam_extraction[0] * Ratio_Heat_input_vs_output
      min_heat_input = minimum_gross_cap / (nominal_gross_eff * el(min_el_cap_perc))
      nominal_gross_eff = eff[0]
      self.nominal_gross_cap = nominal_gross_cap
    }
  }

  struct electrolysis {
    private(set) var electrEnergy_per_tH2 = 55.0, min_cap_rate = 0.1, net_elec_input = 180.0, aux_elec_input = 2.7, heat_input = 40.0

    lazy var gross_elec_input = net_elec_input + aux_elec_input
    lazy var min_elec_input = gross_elec_input * min_cap_rate

    mutating func proportion(net_elec_input: Double) -> Double {
      let ratio = net_elec_input / self.net_elec_input
      self.net_elec_input = net_elec_input
      aux_elec_input *= ratio
      heat_input *= ratio
      return aux_elec_input
    }
  }

  struct MethanolPlant {
    private(set) var H2_cons = 20000.0, prod_cap = 100_000.0, min_cap_perc = 0.4, nominal_hour_prod_cap = 14.8

    lazy var nominal_heatConsumption = nominal_hour_prod_cap / Ref_meth_hour_prod_cap * 10.0
    lazy var nominal_aux_electr_cons = nominal_hour_prod_cap / Ref_meth_hour_prod_cap * 10.0
    lazy var max_H2_Cons = nominal_hour_prod_cap / prod_cap * H2_cons
    lazy var min_H2_Cons = min_cap_perc * nominal_hour_prod_cap / prod_cap * H2_cons
    lazy var Ref_meth_hour_prod_cap = prod_cap / (334 * 24)

    mutating func proportion(nominal_hour_prod_cap: Double) { self.nominal_hour_prod_cap = nominal_hour_prod_cap }
  }

  struct PV {
    var Ref_AC_cap = 510.0
    var Ref_DC_cap = 683.4
    var AC_Cap = 613.0
    var DC_Cap = 818.0
  }

  #if DEBUG
  var results: Results
  #endif
  init(values: [Double]) {
    #if DEBUG
    self.results = .init()
    #endif
    self.CSP_Loop_Nr = values[0]
    self.PV_DC_Cap = values[1]
    self.PV_AC_Cap = values[2]
    self.Heater_cap = values[3]
    self.TES_Full_Load_Hours = values[4]
    self.EY_Nominal_elec_input = values[5]
    self.PB_Nominal_gross_cap = values[6]
    self.BESS_cap = values[7]
    self.H2_storage_cap = values[8]
    self.Meth_nominal_hour_prod_cap = values[9]
    self.El_boiler_cap = values[10]
    self.grid_max_export = values[11]
  }

  @discardableResult
  mutating func callAsFunction(
    _ Q_Sol_MW_thLoop: [Double], _ Reference_PV_plant_power_at_inverter_inlet_DC: [Double],
    _ Reference_PV_MV_power_at_transformer_outlet: [Double], rows: inout [String]
  ) -> (Q_solar_before_dumping: [Double], PV_MV_power_at_transformer_outlet: [Double], aux_elec_for_CSP_SF_PV_Plant: [Double]) {    
    var PV = PV()
    PV.AC_Cap = PV_AC_Cap
    PV.DC_Cap = PV_DC_Cap

    let indices = Reference_PV_MV_power_at_transformer_outlet.indices
    let Q_solar_before_dumping = Q_Sol_MW_thLoop.map { $0 * CSP_Loop_Nr }
    let maximum = Reference_PV_MV_power_at_transformer_outlet.max() ?? 0
    let Inverter_power_fraction = Reference_PV_MV_power_at_transformer_outlet.map { max(0, $0 / maximum) }
    let Inverter_eff = indices.map {
      return iff(
        Reference_PV_MV_power_at_transformer_outlet[$0] < maximum,
        max(Reference_PV_MV_power_at_transformer_outlet[$0], 0) / Reference_PV_plant_power_at_inverter_inlet_DC[$0], 0)
    }
    let inverter = zip(Inverter_power_fraction, Inverter_eff).filter { $0.0 > 0 && $0.0 < 1 }.sorted(by: { $0.0 < $1.0 })
    let chunks = inverter.chunked { Int($0.0 * 100) == Int($1.0 * 100) }
    let eff1 = chunks.map { bin in bin.reduce(0.0) { $0 + $1.1 } / Double(bin.count) }
    let eff2 = zip(stride(from: 0.01, through: 1, by: 0.01), eff1).map { PV.AC_Cap * $0.0 / $0.1 / PV.DC_Cap }
    let LL = Polynomial.fit(x: Array(eff2[...20]), y: Array(eff1[...20]), order: 6)!
    let ML = Polynomial.fit(x: Array(eff2[8...22]), y: Array(eff1[8...22]), order: 3)!
    let HL = Polynomial.fit(x: Array(eff2[20...]), y: Array(eff1[20...]), order: 4)!

    let E_PV_total_Scaled_DC =  // J
      Reference_PV_plant_power_at_inverter_inlet_DC.map { $0 * PV.DC_Cap / PV.Ref_DC_cap }


    let PV_MV_power_at_transformer_outlet: [Double] = indices.map {  // K
      let load = E_PV_total_Scaled_DC[$0] / PV.DC_Cap
      let value: Double
      if load > 0.2 {
        value = E_PV_total_Scaled_DC[$0] * HL(load)
      } else if load > 0.1 {
        value = E_PV_total_Scaled_DC[$0] * ML(load)
      } else if load > 0 {
        value = E_PV_total_Scaled_DC[$0] * LL(load)
      } else {
        value = Reference_PV_MV_power_at_transformer_outlet[$0] / PV.Ref_AC_cap * PV.AC_Cap
      }
      return min(PV_AC_Cap, value)
    }

    let CSP_aux_elec_perc = 0.01

    let aux_elec_for_CSP_SF_PV_Plant: [Double] = indices.map {  // L
      Q_solar_before_dumping[$0] * CSP_aux_elec_perc + max(0, -PV_MV_power_at_transformer_outlet[$0])
    }
    #if DEBUG
    results.compare(Q_solar_before_dumping, with: "I")
    results.compare(PV_MV_power_at_transformer_outlet, with: "K")
    results.compare(aux_elec_for_CSP_SF_PV_Plant, with: "L")
    #endif

    #if DEBUG
    rows[0] += "Q solar before dumping, "
    + "PV MV power at transformer outlet, "
    + "aux elec for CSP SF PV Plant, "

    for i in indices.dropFirst() {
      rows[i] +=
        String(format: "%G, ", Q_solar_before_dumping[i])
      + String(format: "%G, ", PV_MV_power_at_transformer_outlet[i])
      + String(format: "%G, ", aux_elec_for_CSP_SF_PV_Plant[i])
    }
    #endif

    return (Q_solar_before_dumping, PV_MV_power_at_transformer_outlet, aux_elec_for_CSP_SF_PV_Plant)
  }

  mutating func callAsFunction(
    _ pr_meth_plant_op: inout [Double],
    _ Q_solar_before_dumping: [Double],
    _ PV_MV_power_at_transformer_outlet: [Double],
    _ aux_elec_for_CSP_SF_PV_Plant: [Double],
    rows: inout [String]
  ) {
    var Heater = Heater()
    Heater.cap = Heater_cap

    var BESS = Battery()
    BESS.charging_cap = BESS_max_Charging_cap
    BESS.cap = BESS_cap

    var Meth = MethanolPlant()
    Meth.proportion(nominal_hour_prod_cap: Meth_nominal_hour_prod_cap)
    Meth_nominal_aux_electr_cons = Meth.nominal_aux_electr_cons
    var EY = electrolysis()
    EY_aux_elec_input = EY.proportion(net_elec_input: EY_Nominal_elec_input)
    var PB = PowerBlock()
    PB.proportion(nominal_gross_cap: PB_Nominal_gross_cap, EY: EY, nominal_heatConsumption: Meth.nominal_heatConsumption)
    let PB_Ratio_Heat_input_vs_output = PB.Ratio_Heat_input_vs_output
    let TES_Thermal_capacity = TES_Full_Load_Hours * PB.nominal_heat_input

    let TES_aux_elec_perc = 0.01
    let TES_dead_mass_ratio = 0.1
    // TES_salt_mass = TES_Thermal_capacity * 1000.0 * 3600.0 / (846.9867739 - 451.6806344) / 1000.0 * (1.0 + TES_dead_mass_ratio)

    let El_boiler_eff = 0.99

    let PB_heat_input_at_min_aux =
      (EY.min_elec_input + Meth.min_cap_perc * Meth.nominal_aux_electr_cons) / (1 - PB.aux_cons_perc)
      / (PB.nominal_gross_eff
        * PB.el((EY.min_elec_input + Meth.min_cap_perc * Meth.nominal_aux_electr_cons) / (1 - PB.aux_cons_perc) / PB.nominal_gross_cap))
    let PB_eff_at_min_Op =
      max(PB.minimum_gross_cap, (EY.min_elec_input + Meth.min_cap_perc * Meth.nominal_aux_electr_cons) / (1 - PB.aux_cons_perc))
      / max(PB.min_heat_input, PB_heat_input_at_min_aux)
    let TES_Thermal_cap = TES_Full_Load_Hours * PB.nominal_heat_input

    let indices = PV_MV_power_at_transformer_outlet.indices

    let zeroes = Array(repeating: 0.0, count: indices.count)
    var pr_EY_Meth_heatConsumption = zeroes  // O
    var pr_el_boiler_op_for_EY_Meth_heat = zeroes  // P
    var pr_EY_Meth_el_cons = zeroes  // Q

  //var PV_elec_avail_after_eHeater_sum: Float = 0
  //var PV_electrical_input_to_heater_sum: Float = 0
  var Q_solar_before_dumping_sum: Float = 0
  var TES_total_thermal_input_sum: Float = 0
  var Q_solar_avail_sum: Float = 0
  var gross_elec_from_PB_sum: Float = 0
  var aux_steam_provided_by_PB_SF_sum: Float = 0
  var elec_from_grid_sum: Float = 0
  var elec_to_grid_sum: Float = 0
  var H2_to_meth_production_effective_MTPH_sum: Float = 0
  var Q_Sol_aux_steam_dumped_sum: Float = 0
  var EY_aux_heatConsumption_sum: Float = 0
  var EY_aux_heatConsumption_covered_by_PB_SF_sum: Float = 0
  var meth_plant_heatConsumption_sum: Float = 0
  var meth_plant_heatConsumption_covered_by_heat_from_PB_SF_sum: Float = 0
  var Produced_thermal_energy_sum: Float = 0
  var Heat_to_aux_directly_from_CSP_sum: Float = 0
  var Heat_to_aux_from_PB_sum: Float = 0
  var Total_SF_heat_dumped_sum: Float = 0
  var net_elec_above_max_consumers_sum: Float = 0
  var aux_elec_missing_due_to_grid_limit_sum: Float = 0
  var PB_startup_heatConsumption_effective_count = 0
  var TES_discharge_effective_count = 0
  var EY_plant_start_count = 0
  var meth_plant_start_count = 0
  var gross_operating_point_of_EY_count = 0
  var H2_to_meth_production_effective_MTPH_count = 0

  var TES_thermal_input_by_CSP_sum: Float = 0
  var meth_produced_MTPH_sum: Float = 0
  var avail_total_net_elec_sum: Float = 0

  var TES_salt_mass = 0.0

  }
}

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
      BESS_cap_ud,
      CCU_C_O_2_nom_prod_ud,
      C_O_2_storage_cap_ud,
      CSP_loop_nr_ud,
      El_boiler_cap_ud,
      EY_var_net_nom_cons_ud,
      Grid_export_max_ud,
      Grid_import_max_ud,
      Hydrogen_storage_cap_ud,
      Heater_cap_ud,
      MethDist_Meth_nom_prod_ud,
      MethSynt_RawMeth_nom_prod_ud,
      PB_nom_gross_cap_ud,
      PV_AC_cap_ud,
      PV_DC_cap_ud,
      RawMeth_storage_cap_ud,
      TES_full_load_hours_ud
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

extension Array where Element == ClosedRange<Double> {
  func randomValues(count: Int) -> [[Double]] {
    (1...count).map { _ in map { range in Double.random(in: range) } }
  }
}


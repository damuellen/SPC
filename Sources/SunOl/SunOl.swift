import Foundation
import Helpers
import Physics


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
  var Meth_nominal_hourly_prod_cap = 14.8
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
      th = Polynomial.fit(x: thermal_load_perc, y: eff_factor)
      el = Polynomial.fit(x: load_perc, y: eff_factor)
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
    private(set) var H2_cons = 20000.0, prod_cap = 100_000.0, min_cap_perc = 0.4, nominal_hourly_prod_cap = 14.8

    lazy var nominal_heatConsumption = nominal_hourly_prod_cap / Ref_meth_hourly_prod_cap * 10.0
    lazy var nominal_aux_electr_cons = nominal_hourly_prod_cap / Ref_meth_hourly_prod_cap * 10.0
    lazy var max_H2_Cons = nominal_hourly_prod_cap / prod_cap * H2_cons
    lazy var min_H2_Cons = min_cap_perc * nominal_hourly_prod_cap / prod_cap * H2_cons
    lazy var Ref_meth_hourly_prod_cap = prod_cap / (334 * 24)

    mutating func proportion(nominal_hourly_prod_cap: Double) { self.nominal_hourly_prod_cap = nominal_hourly_prod_cap }
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
    self.Meth_nominal_hourly_prod_cap = values[9]
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
    let LL = Polynomial.fit(x: Array(eff2[...20]), y: Array(eff1[...20]), degree: 6)
    let ML = Polynomial.fit(x: Array(eff2[8...22]), y: Array(eff1[8...22]), degree: 3)
    let HL = Polynomial.fit(x: Array(eff2[20...]), y: Array(eff1[20...]), degree: 4)

    let E_PV_total_Scaled_DC =  // J
      Reference_PV_plant_power_at_inverter_inlet_DC.map { $0 * PV.DC_Cap / PV.Ref_DC_cap }
    // var chunked = E_PV_total_Scaled_DC.chunked { !($0 == 0 && $1 > 0) }
    // let s = chunked.removeFirst()
    // chunked[chunked.endIndex - 1].append(contentsOf: s)
    // let sumOfDay = chunked.map(sum)
    // let dayNight = chunked.map { ($0.count, $0.endIndex - $0.firstIndex(of: 0)!) }

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

  @discardableResult
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
    Meth.proportion(nominal_hourly_prod_cap: Meth_nominal_hourly_prod_cap)
    Meth_nominal_aux_electr_cons = Meth.nominal_aux_electr_cons
    var EY = electrolysis()
    EY_aux_elec_input = EY.proportion(net_elec_input: EY_Nominal_elec_input)
    var PB = PowerBlock()
    PB.proportion(nominal_gross_cap: PB_Nominal_gross_cap, EY: EY, nominal_heatConsumption: Meth.nominal_heatConsumption)
    PB_Ratio_Heat_input_vs_output = PB.Ratio_Heat_input_vs_output
    TES_Thermal_capacity = TES_Full_Load_Hours * PB.nominal_heat_input

    let TES_aux_elec_perc = 0.01
    let TES_dead_mass_ratio = 0.1
    TES_salt_mass = TES_Thermal_capacity * 1000.0 * 3600.0 / (846.9867739 - 451.6806344) / 1000.0 * (1.0 + TES_dead_mass_ratio)

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

    for i in indices.dropFirst() {
      pr_EY_Meth_heatConsumption[i] = max(
        0.0,
        min(
          iff(Q_solar_before_dumping[i] >= Meth.nominal_heatConsumption * pr_meth_plant_op[i], Q_solar_before_dumping[i], 0),
          max(
            0,
            min(
              PV_MV_power_at_transformer_outlet[i] - aux_elec_for_CSP_SF_PV_Plant[i] - Meth.nominal_aux_electr_cons * pr_meth_plant_op[i],
              EY.gross_elec_input)) / EY.gross_elec_input * EY.heat_input + Meth.nominal_heatConsumption * pr_meth_plant_op[i],
          EY.heat_input
            + iff(
              PV_MV_power_at_transformer_outlet[i] - aux_elec_for_CSP_SF_PV_Plant[i] >= Meth.nominal_aux_electr_cons * pr_meth_plant_op[i],
              Meth.nominal_heatConsumption * pr_meth_plant_op[i], 0)))
      let w =
        (PV_MV_power_at_transformer_outlet[i] + pr_EY_Meth_heatConsumption[i] / El_boiler_eff - aux_elec_for_CSP_SF_PV_Plant[i]
          - (Meth.nominal_heatConsumption / El_boiler_eff + Meth.nominal_aux_electr_cons) * pr_meth_plant_op[i])
        / (EY.gross_elec_input + EY.heat_input / El_boiler_eff) * EY.heat_input + Meth.nominal_heatConsumption * pr_meth_plant_op[i]
        - pr_EY_Meth_heatConsumption[i]
      pr_el_boiler_op_for_EY_Meth_heat[i] = max(
        0,
        min(
          El_boiler_eff * El_boiler_cap, max(0, EY.heat_input + Meth.nominal_heatConsumption * pr_meth_plant_op[i] - pr_EY_Meth_heatConsumption[i]),
          max(0, iff(PV_MV_power_at_transformer_outlet[i] > 0, w, 0)), EY.heat_input + Meth.nominal_heatConsumption * pr_meth_plant_op[i]))
      pr_EY_Meth_el_cons[i] = max(  // Q
        0,
        min(
          iff(
            PV_MV_power_at_transformer_outlet[i] - aux_elec_for_CSP_SF_PV_Plant[i] - pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_eff
              >= Meth.nominal_aux_electr_cons * pr_meth_plant_op[i],
            PV_MV_power_at_transformer_outlet[i] - aux_elec_for_CSP_SF_PV_Plant[i] - pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_eff, 0),
          max(
            0,
            min(Q_solar_before_dumping[i] + pr_el_boiler_op_for_EY_Meth_heat[i] - Meth.nominal_heatConsumption * pr_meth_plant_op[i], EY.heat_input))
            / EY.heat_input * EY.gross_elec_input
            + iff(
              Q_solar_before_dumping[i] + pr_el_boiler_op_for_EY_Meth_heat[i] >= Meth.nominal_heatConsumption * pr_meth_plant_op[i],
              Meth.nominal_aux_electr_cons * pr_meth_plant_op[i], 0), EY.gross_elec_input + Meth.nominal_aux_electr_cons * pr_meth_plant_op[i]))
    }
    #if DEBUG
    results.compare(pr_EY_Meth_heatConsumption, with: "O")
    results.compare(pr_el_boiler_op_for_EY_Meth_heat, with: "P")
    results.compare(pr_EY_Meth_el_cons, with: "Q")
    #endif
    var PV_electrical_input_to_heater = zeroes  // R
    var TES_thermal_input_by_heater = zeroes  // S
    var TES_thermal_input_by_CSP = zeroes  // T
    var TES_total_thermal_input = zeroes  // U
    var Q_solar_avail = zeroes  // V
    var PV_elec_avail_after_eHeater = zeroes  // W

    var TES_charging_aux_elec_cons = zeroes  // X
    var SF_TES_charge_PV_aux_cons_not_covered_by_PV = zeroes  // Y
    var aux_coverage_by_PB = zeroes  // M
    var SF_TES_charge_PV_aux_cons_covered_by_PV = zeroes  // Z

    var PV_elec_avail_after_TES_charging = zeroes  // AA
    var Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op = zeroes  // AB
    var Steam_extraction_matching_max_net_elec_request = zeroes  // AC
    var min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions = zeroes  // AD
    var steam_extraction_matching_min_op_case = zeroes  // AE
    var pr_PB_eff_excl_extraction_at_min_EY_pr_Meth = zeroes  // AF

    var pr_PB_heat_input_based_on_avail_heat = zeroes  // AG
    var pr_PB_eff_excl_extraction_at_discharge_load = zeroes  // AH
    var pr_TES_discharging_aux_elec_cons = zeroes  // AI
    var pr_Ey_op_by_PB = zeroes  // AJ
    var Check_calc_PB_heat_input_based_on_EY_op = zeroes  // AK
    var pr_heat_request_for_aux_consumers_by_PB = zeroes  // AL
    var TES_storage_level = zeroes  // AM
    var PB_op_mode = zeroes  // AN
    PB_op_mode[0] = -1
    var PB_startup_heatConsumption_calculated = zeroes  // AO
    var PB_startup_heatConsumption_effective = zeroes  // AP
    var TES_discharge_effective = zeroes  // AQ
    var TES_discharging_aux_elec_cons = zeroes  // AR

    let Ratio_CSP_vs_Heater = 1.315007
    for i in indices.dropFirst() {
      TES_storage_level[i] = iff(  // AM
        TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - TES_discharge_effective[i - 1] - PB_startup_heatConsumption_effective[i - 1]
          < 0.01, 0,
        TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - TES_discharge_effective[i - 1] - PB_startup_heatConsumption_effective[i - 1])

      PV_electrical_input_to_heater[i] = max(  // R
        0,
        min(
          Heater.cap, (Q_solar_before_dumping[i] - pr_EY_Meth_heatConsumption[i]) * Ratio_CSP_vs_Heater / Heater.eff,
          (PV_MV_power_at_transformer_outlet[i] - aux_elec_for_CSP_SF_PV_Plant[i] - pr_EY_Meth_el_cons[i])
            * (1 - TES_aux_elec_perc * Heater.eff * (1 + 1 / Ratio_CSP_vs_Heater)),
          (TES_Thermal_cap - TES_storage_level[i]) / (1 + 1 / Ratio_CSP_vs_Heater) / Heater.eff))

      TES_thermal_input_by_heater[i] = PV_electrical_input_to_heater[i] * Heater.eff  // S
      TES_thermal_input_by_CSP[i] = TES_thermal_input_by_heater[i] / Ratio_CSP_vs_Heater  // T
      TES_total_thermal_input[i] = TES_thermal_input_by_CSP[i] + TES_thermal_input_by_heater[i]
      Q_solar_avail[i] = Q_solar_before_dumping[i] - TES_thermal_input_by_CSP[i]
      PV_elec_avail_after_eHeater[i] = max(0, PV_MV_power_at_transformer_outlet[i] - PV_electrical_input_to_heater[i])
      TES_charging_aux_elec_cons[i] = TES_total_thermal_input[i] * TES_aux_elec_perc + aux_elec_for_CSP_SF_PV_Plant[i]
      SF_TES_charge_PV_aux_cons_not_covered_by_PV[i] = max(0, TES_charging_aux_elec_cons[i] - PV_elec_avail_after_eHeater[i])
      SF_TES_charge_PV_aux_cons_covered_by_PV[i] = TES_charging_aux_elec_cons[i] - SF_TES_charge_PV_aux_cons_not_covered_by_PV[i]
      aux_coverage_by_PB[i] = iff(
        (EY.min_elec_input + pr_meth_plant_op[i] * Meth.nominal_aux_electr_cons + SF_TES_charge_PV_aux_cons_not_covered_by_PV[i])
          > PB.nominal_gross_cap * (1 - PB.aux_cons_perc),
        iff(
          (pr_meth_plant_op[i] * Meth.nominal_aux_electr_cons + SF_TES_charge_PV_aux_cons_not_covered_by_PV[i]) > PB.nominal_gross_cap
            * (1 - PB.aux_cons_perc), 0, pr_meth_plant_op[i] * Meth.nominal_aux_electr_cons + SF_TES_charge_PV_aux_cons_not_covered_by_PV[i]),
        EY.min_elec_input + pr_meth_plant_op[i] * Meth.nominal_aux_electr_cons + SF_TES_charge_PV_aux_cons_not_covered_by_PV[i])
      PV_elec_avail_after_TES_charging[i] = max(0, PV_elec_avail_after_eHeater[i] - SF_TES_charge_PV_aux_cons_covered_by_PV[i])
      Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] =  // AB
        max(
          0,
          min(
            EY.gross_elec_input + Meth_nominal_aux_electr_cons * pr_meth_plant_op[i] + SF_TES_charge_PV_aux_cons_not_covered_by_PV[i]
              + pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_eff - PV_elec_avail_after_TES_charging[i],
            iff(
              PB.nominal_gross_cap * (1 - PB.aux_cons_perc) < EY.min_elec_input + Meth_nominal_aux_electr_cons * pr_meth_plant_op[i]
                + SF_TES_charge_PV_aux_cons_not_covered_by_PV[i] + pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_eff
                - PV_elec_avail_after_TES_charging[i],
              iff(
                PB.nominal_gross_cap * (1 - PB.aux_cons_perc) < Meth_nominal_aux_electr_cons * pr_meth_plant_op[i]
                  + SF_TES_charge_PV_aux_cons_not_covered_by_PV[i] + pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_eff
                  - PV_elec_avail_after_TES_charging[i], 0,
                Meth_nominal_aux_electr_cons * pr_meth_plant_op[i] + SF_TES_charge_PV_aux_cons_not_covered_by_PV[i]
                  + pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_eff - PV_elec_avail_after_TES_charging[i]),
              PB.nominal_gross_cap * (1 - PB.aux_cons_perc))))

      // Output sum
      Steam_extraction_matching_max_net_elec_request[i] =  // AC
        iff(
          pr_EY_Meth_el_cons[i] == 0 && Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] > 0,
          pr_meth_plant_op[i] * Meth.nominal_heatConsumption
            + iff(
              Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] >= EY.min_elec_input + Meth.nominal_aux_electr_cons
                * pr_meth_plant_op[i] + SF_TES_charge_PV_aux_cons_not_covered_by_PV[i] + pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_eff
                - PV_elec_avail_after_TES_charging[i],
              (Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] - SF_TES_charge_PV_aux_cons_not_covered_by_PV[i] - pr_meth_plant_op[i]
                * Meth.nominal_aux_electr_cons) / EY.gross_elec_input * EY.heat_input, 0),
          max(
            0,
            (Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] - SF_TES_charge_PV_aux_cons_not_covered_by_PV[i]) / EY.gross_elec_input
              * EY.heat_input))
      if PB.nominal_heat_input > 0 {
        min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i] =  // AD
          aux_coverage_by_PB[i] / (1 - PB.aux_cons_perc)
          / (PB.nominal_gross_eff * (PB.el(aux_coverage_by_PB[i] / (1 - PB.aux_cons_perc) / PB.nominal_gross_cap)))
          * (1 + TES_aux_elec_perc / PB_eff_at_min_Op)
      }

      steam_extraction_matching_min_op_case[i] =  // AE
        iff(pr_EY_Meth_el_cons[i] == 0, pr_meth_plant_op[i] * Meth.nominal_heatConsumption + EY.min_cap_rate * EY.heat_input, 0)
      if PB.nominal_heat_input > 0 {
        pr_PB_eff_excl_extraction_at_min_EY_pr_Meth[i] =  // AF
          PB.nominal_gross_eff * PB.th(min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i] / PB.nominal_heat_input)
      }

      let AB = Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op
      let Q = pr_EY_Meth_el_cons
      let count = countiff(PV_MV_power_at_transformer_outlet[i...].prefix(16), { $0 < EY.min_elec_input })
      let Y = SF_TES_charge_PV_aux_cons_not_covered_by_PV
      let AO = PB_startup_heatConsumption_calculated
      let AD = min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions
      let AE = steam_extraction_matching_min_op_case
      // AG
      pr_PB_heat_input_based_on_avail_heat[i] = iff(
        (AB[i] >= PB.minimum_gross_cap * (1 - PB.aux_cons_perc) && AB[i - 1] < PB.minimum_gross_cap * (1 - PB.aux_cons_perc) && Q[i] > 0),
        iff(
          TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - AO[i - 1] < PB.min_op_hours * (AD[i] + PB.Ratio_Heat_input_vs_output * AE[i]),
          0,
          min(
            PB.max_heat_input,
            max((TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - AO[i - 1]) / count, AD[i] + PB.Ratio_Heat_input_vs_output * AE[i]))),
        iff(
          (Q[i - 1] > 0 && Q[i] == 0 && AB[i] >= PB.minimum_gross_cap * (1 - PB.aux_cons_perc)),
          iff(
            TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - AO[i - 1] - pr_PB_heat_input_based_on_avail_heat[i - 1]
              < (PB.min_op_hours - 1) * (AD[i] + PB.Ratio_Heat_input_vs_output * AE[i]), 0,
            min(
              PB.max_heat_input,
              max(
                (TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - AO[i - 1] - pr_PB_heat_input_based_on_avail_heat[i - 1]) / count,
                AD[i] + PB.Ratio_Heat_input_vs_output * AE[i]))),
          iff(
            (PV_elec_avail_after_TES_charging[i] > EY.gross_elec_input + Meth.nominal_aux_electr_cons * pr_meth_plant_op[i] - PB.minimum_gross_cap
              * (1 - PB.aux_cons_perc) || TES_storage_level[i - 1] == 0 || AB[i] == 0), 0,
            pr_PB_heat_input_based_on_avail_heat[i - 1]
              + ((pr_PB_heat_input_based_on_avail_heat[i - 1] > 0)
                ? ((Y[i] - Y[i - 1]) / pr_PB_eff_excl_extraction_at_min_EY_pr_Meth[i]
                  + (Meth.nominal_heatConsumption * PB.Ratio_Heat_input_vs_output + Meth.nominal_aux_electr_cons
                    / pr_PB_eff_excl_extraction_at_min_EY_pr_Meth[i]) * (-pr_meth_plant_op[i - 1] + pr_meth_plant_op[i]))
                : 0))))
      pr_PB_eff_excl_extraction_at_discharge_load[i] = iff(  // AH
        min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i] == 0 || pr_PB_heat_input_based_on_avail_heat[i] == 0, 0,
        PB.th(
          (pr_PB_heat_input_based_on_avail_heat[i] - PB.Ratio_Heat_input_vs_output * steam_extraction_matching_min_op_case[i]
            / (min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i] + steam_extraction_matching_min_op_case[i])
            * pr_PB_heat_input_based_on_avail_heat[i]) / PB.nominal_heat_input) * PB.nominal_gross_eff)

      pr_TES_discharging_aux_elec_cons[i] = pr_PB_heat_input_based_on_avail_heat[i] * TES_aux_elec_perc
      pr_Ey_op_by_PB[i] = iff(  // AJ
        pr_PB_heat_input_based_on_avail_heat[i] == 0 || pr_PB_eff_excl_extraction_at_discharge_load[i] == 0, 0,
        (pr_PB_heat_input_based_on_avail_heat[i]
          - iff(pr_EY_Meth_el_cons[i] == 0, PB.Ratio_Heat_input_vs_output * Meth.nominal_heatConsumption * pr_meth_plant_op[i], 0)
          - ((pr_TES_discharging_aux_elec_cons[i] + SF_TES_charge_PV_aux_cons_not_covered_by_PV[i]
            + iff(pr_EY_Meth_el_cons[i] == 0, Meth.nominal_aux_electr_cons * pr_meth_plant_op[i], 0)) / (1 - PB.aux_cons_perc)
            / pr_PB_eff_excl_extraction_at_discharge_load[i]))
          / (PB.Ratio_Heat_input_vs_output * EY.heat_input / EY.gross_elec_input + 1 / (1 - PB.aux_cons_perc)
            / pr_PB_eff_excl_extraction_at_discharge_load[i]))

      Check_calc_PB_heat_input_based_on_EY_op[i] = iff(  // AK
        pr_Ey_op_by_PB[i] == 0 || pr_Ey_op_by_PB[i] < EY.min_elec_input, 0,
        (SF_TES_charge_PV_aux_cons_not_covered_by_PV[i] + pr_TES_discharging_aux_elec_cons[i] + pr_Ey_op_by_PB[i]
          + iff(pr_EY_Meth_el_cons[i] > 0, 0, Meth.nominal_aux_electr_cons * pr_meth_plant_op[i])) / (1 - PB.aux_cons_perc)
          / PB.el(
            ((SF_TES_charge_PV_aux_cons_not_covered_by_PV[i] + pr_TES_discharging_aux_elec_cons[i] + pr_Ey_op_by_PB[i]
              + iff(pr_EY_Meth_el_cons[i] > 0, 0, Meth.nominal_aux_electr_cons * pr_meth_plant_op[i])) / (1 - PB.aux_cons_perc) / PB.nominal_gross_cap)
          ) / PB.nominal_gross_eff
          + (pr_Ey_op_by_PB[i] / EY.gross_elec_input * EY.heat_input
            + iff(pr_EY_Meth_el_cons[i] > 0, 0, Meth.nominal_heatConsumption * pr_meth_plant_op[i])) * PB.Ratio_Heat_input_vs_output)
      pr_heat_request_for_aux_consumers_by_PB[i] = max(  // AL
        0,
        iff(
          pr_Ey_op_by_PB[i] == 0 || Check_calc_PB_heat_input_based_on_EY_op[i] == 0 || pr_EY_Meth_el_cons[i] > 0, 0,
          pr_Ey_op_by_PB[i] / (EY.gross_elec_input) * EY.heat_input
            + iff(pr_EY_Meth_el_cons[i] > 0, 0, pr_meth_plant_op[i] * Meth.nominal_heatConsumption)))

      /*
       TES_storage_level[i] = iff(  // AM
       TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - TES_discharge_effective[i - 1] - PB.startup_heatConsumption_effective[i - 1] < 0.01, 0,
       TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - TES_discharge_effective[i - 1] - PB.startup_heatConsumption_effective[i - 1])
       */
      PB_op_mode[i] = iff(  // AN
        Check_calc_PB_heat_input_based_on_EY_op[i - 1] == 0 && Check_calc_PB_heat_input_based_on_EY_op[i] > 0
          && TES_storage_level[i] > Check_calc_PB_heat_input_based_on_EY_op[i], -1,
        iff(
          Check_calc_PB_heat_input_based_on_EY_op[i - 1] > 0 && Check_calc_PB_heat_input_based_on_EY_op[i] > 0, 0,
          iff(
            Check_calc_PB_heat_input_based_on_EY_op[i - 1] > 0 && Check_calc_PB_heat_input_based_on_EY_op[i] == 0 && PB_op_mode[i - 1] == 0, 1,
            PB_op_mode[i - 1] + 1)))
      PB_startup_heatConsumption_calculated[i] = iff(
        PB_op_mode[i] < 1, 0,
        iff(
          PB_op_mode[i] <= PB.warm_start_duration, PB.hot_start_heat_req,
          iff(PB_op_mode[i] <= PB.cold_start_duration, PB.warm_start_heat_req, PB.cold_start_heat_req)))
      PB_startup_heatConsumption_effective[i] = iff(
        PB_op_mode[i] == -1,
        iff(
          PB_op_mode[i - 1] <= PB.warm_start_duration, PB.hot_start_heat_req,
          iff(PB_op_mode[i - 1] <= PB.cold_start_duration, PB.warm_start_heat_req, PB.cold_start_heat_req)), 0)
      TES_discharge_effective[i] = iff(
        min(
          Check_calc_PB_heat_input_based_on_EY_op[i] + pr_heat_request_for_aux_consumers_by_PB[i] * PB.Ratio_Heat_input_vs_output,
          TES_storage_level[i] + TES_total_thermal_input[i], PB.max_heat_input,
          iff(TES_storage_level[i] == 0, 0, Check_calc_PB_heat_input_based_on_EY_op[i])) < PB.min_heat_input + PB.Ratio_Heat_input_vs_output
          * (pr_meth_plant_op[i] * Meth.nominal_heatConsumption),
        iff(
          TES_discharge_effective[i - 1] > 0 || PV_elec_avail_after_TES_charging[i] == 0
            || PV_elec_avail_after_TES_charging[i] > EY.net_elec_input - PB.min_el_cap_perc * PB.nominal_gross_cap,
          min(
            TES_storage_level[i],
            Check_calc_PB_heat_input_based_on_EY_op[i] + pr_heat_request_for_aux_consumers_by_PB[i] * PB.Ratio_Heat_input_vs_output), 0),
        min(
          Check_calc_PB_heat_input_based_on_EY_op[i] + pr_heat_request_for_aux_consumers_by_PB[i] * PB.Ratio_Heat_input_vs_output,
          TES_storage_level[i] + TES_total_thermal_input[i], PB.max_heat_input,
          iff(TES_storage_level[i] == 0, 0, Check_calc_PB_heat_input_based_on_EY_op[i])))
      TES_discharging_aux_elec_cons[i] = TES_discharge_effective[i] * TES_aux_elec_perc
    }
    #if DEBUG
    results.compare(PV_electrical_input_to_heater, with: "R")
    results.compare(TES_thermal_input_by_heater, with: "S")
    results.compare(TES_thermal_input_by_CSP, with: "T")
    results.compare(TES_total_thermal_input, with: "U")
    results.compare(Q_solar_avail, with: "V")
    results.compare(PV_elec_avail_after_eHeater, with: "W")
    results.compare(TES_charging_aux_elec_cons, with: "X")
    results.compare(SF_TES_charge_PV_aux_cons_not_covered_by_PV, with: "Y")
    results.compare(SF_TES_charge_PV_aux_cons_covered_by_PV, with: "Z")
    results.compare(PV_elec_avail_after_TES_charging, with: "AA")
    results.compare(Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op, with: "AB")
    results.compare(Steam_extraction_matching_max_net_elec_request, with: "AC")
    results.compare(min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions, with: "AD")
    results.compare(steam_extraction_matching_min_op_case, with: "AE")
    results.compare(pr_PB_eff_excl_extraction_at_min_EY_pr_Meth, with: "AF")
    results.compare(pr_PB_heat_input_based_on_avail_heat, with: "AG")
    results.compare(pr_PB_eff_excl_extraction_at_discharge_load, with: "AH")
    results.compare(pr_TES_discharging_aux_elec_cons, with: "AI")
    results.compare(pr_Ey_op_by_PB, with: "AJ")
    results.compare(Check_calc_PB_heat_input_based_on_EY_op, with: "AK")
    results.compare(pr_heat_request_for_aux_consumers_by_PB, with: "AL")
    results.compare(TES_storage_level, with: "AM")
    results.compare(PB_op_mode, with: "AN")
    results.compare(PB_startup_heatConsumption_effective, with: "AP")
    results.compare(TES_discharge_effective, with: "AQ")
    results.compare(TES_discharging_aux_elec_cons, with: "AR")
    #endif
    var extracted_steam = zeroes  // AS
    var Heat_avail_for_elec_generation = zeroes  // AT
    var gross_elec_from_PB = zeroes  // AU
    var PB_aux_cons = zeroes  // AV
    var PB_aux_cons_not_covered_by_PB = zeroes  // AW
    var aux_cons_covered_by_PB = zeroes  // AX
    var Net_elec_from_PB = zeroes  // AY
    var total_net_elec_avail = zeroes  // AZ
    var aux_cons_not_covered = zeroes  // BA
    var TES_disch_Cons_covered = zeroes  // BB
    var aux_steam_provided_by_PB_SF = zeroes  // BC
    var avail_total_net_elec = zeroes  // BD
    var pr_min_meth_heatConsumption = zeroes  // BE
    var pr_meth_heatConsumption_not_covered_by_PB_SF = zeroes  // BF
    var pr_meth_heatConsumption_covered_by_PB_SF = zeroes  // BG
    var pr_min_meth_elec_cons = zeroes  // BH
    var aux_cons_not_covered_by_PB_SF_incl = zeroes  // BI not used
    var pr_meth_elec_cons_covered_by_PB_SF = zeroes  // BJ
    var pr_meth_heatConsumption_not_covered_by_aux_boiler = zeroes
    var pr_meth_heatConsumption_covered_by_aux_boiler = zeroes
    var aux_boiler_cap_avail_after_pr_meth_cons = zeroes
    var grid_cap_avail_after_pr_meth = zeroes
    var aux_steam_avail_after_pr_meth_cons = zeroes
    var total_net_elec_avail_after_pr_meth_cons = zeroes
    var total_steam_avail_for_EY_after_pr_meth_cons = zeroes  //BQ
    for i in indices.dropFirst() {
      extracted_steam[i] =  // AS
        max(
          0,
          iff(
            Check_calc_PB_heat_input_based_on_EY_op[i] > 0 && TES_discharge_effective[i] > 0 && pr_EY_Meth_el_cons[i] == 0.0,
            iff(pr_EY_Meth_el_cons[i] > 0, 0, Meth.nominal_heatConsumption * pr_meth_plant_op[i])
              + (pr_Ey_op_by_PB[i] + TES_discharge_effective[i] - Check_calc_PB_heat_input_based_on_EY_op[i]) / EY.gross_elec_input * EY.heat_input, 0
          ))
      Heat_avail_for_elec_generation[i] =  // AT
        max(0, TES_discharge_effective[i] - extracted_steam[i] * PB.Ratio_Heat_input_vs_output)

      if PB.nominal_heat_input > 0 {
        gross_elec_from_PB[i] =  // AU
          min(
            PB.nominal_gross_cap,
            Heat_avail_for_elec_generation[i] * (PB.th(Heat_avail_for_elec_generation[i] / PB.nominal_heat_input) * PB.nominal_gross_eff))
      }
      PB_aux_cons[i] = gross_elec_from_PB[i] * PB.aux_cons_perc
      PB_aux_cons_not_covered_by_PB[i] = max(0, PB_aux_cons[i] - gross_elec_from_PB[i])
      aux_cons_covered_by_PB[i] = PB_aux_cons[i] - PB_aux_cons_not_covered_by_PB[i]
      Net_elec_from_PB[i] = gross_elec_from_PB[i] - aux_cons_covered_by_PB[i]
      total_net_elec_avail[i] = max(0, PV_elec_avail_after_TES_charging[i] + Net_elec_from_PB[i])
      aux_cons_not_covered[i] = max(
        0,
        SF_TES_charge_PV_aux_cons_not_covered_by_PV[i] + TES_discharging_aux_elec_cons[i] + PB_aux_cons_not_covered_by_PB[i] - total_net_elec_avail[i]
      )
      TES_disch_Cons_covered[i] = min(
        SF_TES_charge_PV_aux_cons_not_covered_by_PV[i] + TES_discharging_aux_elec_cons[i] + PB_aux_cons_not_covered_by_PB[i], total_net_elec_avail[i])
      aux_steam_provided_by_PB_SF[i] = extracted_steam[i] + Q_solar_avail[i]

      avail_total_net_elec[i] = max(0, -TES_disch_Cons_covered[i] + total_net_elec_avail[i])
      pr_min_meth_heatConsumption[i] = Meth.nominal_heatConsumption * pr_meth_plant_op[i]
      pr_meth_heatConsumption_not_covered_by_PB_SF[i] = max(0, pr_min_meth_heatConsumption[i] - aux_steam_provided_by_PB_SF[i])
      pr_meth_heatConsumption_covered_by_PB_SF[i] = pr_min_meth_heatConsumption[i] - pr_meth_heatConsumption_not_covered_by_PB_SF[i]
      pr_min_meth_elec_cons[i] = Meth.nominal_aux_electr_cons * pr_meth_plant_op[i]
      aux_cons_not_covered_by_PB_SF_incl[i] = max(0, pr_min_meth_elec_cons[i] + aux_cons_not_covered[i] - avail_total_net_elec[i])
      pr_meth_elec_cons_covered_by_PB_SF[i] = min(pr_min_meth_elec_cons[i] + aux_cons_not_covered[i], avail_total_net_elec[i])
      pr_meth_heatConsumption_not_covered_by_aux_boiler[i] = max(
        0, pr_meth_heatConsumption_not_covered_by_PB_SF[i] - El_boiler_cap * El_boiler_eff,
        (pr_meth_heatConsumption_not_covered_by_PB_SF[i] / El_boiler_eff - avail_total_net_elec[i] - grid_max_import
          + pr_meth_elec_cons_covered_by_PB_SF[i]) * El_boiler_eff)

      pr_meth_heatConsumption_covered_by_aux_boiler[i] =
        pr_meth_heatConsumption_not_covered_by_PB_SF[i] - pr_meth_heatConsumption_not_covered_by_aux_boiler[i]
      aux_boiler_cap_avail_after_pr_meth_cons[i] = max(
        0,
        min(
          El_boiler_cap * El_boiler_eff - pr_meth_heatConsumption_covered_by_aux_boiler[i],
          (avail_total_net_elec[i] + grid_max_import - pr_meth_elec_cons_covered_by_PB_SF[i] - pr_meth_heatConsumption_covered_by_aux_boiler[i]
            / El_boiler_eff) * El_boiler_eff))
      grid_cap_avail_after_pr_meth[i] =
        grid_max_import
        - max(
          0, -(avail_total_net_elec[i] - pr_meth_elec_cons_covered_by_PB_SF[i] - pr_meth_heatConsumption_covered_by_aux_boiler[i] / El_boiler_eff))
      aux_steam_avail_after_pr_meth_cons[i] = aux_steam_provided_by_PB_SF[i] - pr_meth_heatConsumption_covered_by_PB_SF[i]
      total_net_elec_avail_after_pr_meth_cons[i] = max(
        0, avail_total_net_elec[i] - pr_meth_elec_cons_covered_by_PB_SF[i] - pr_meth_heatConsumption_covered_by_aux_boiler[i] / El_boiler_eff)
      let avail = min(
        total_net_elec_avail_after_pr_meth_cons[i] / (EY.gross_elec_input + EY.heat_input / El_boiler_eff) * EY.heat_input,
        aux_boiler_cap_avail_after_pr_meth_cons[i] + aux_steam_avail_after_pr_meth_cons[i],
        (grid_cap_avail_after_pr_meth[i] + total_net_elec_avail_after_pr_meth_cons[i]) * El_boiler_eff + aux_steam_avail_after_pr_meth_cons[i])
      total_steam_avail_for_EY_after_pr_meth_cons[i] = iff(
        aux_steam_avail_after_pr_meth_cons[i] < EY.heat_input * EY.min_cap_rate, iff(avail < EY.heat_input * EY.min_cap_rate, 0, avail),
        aux_steam_avail_after_pr_meth_cons[i])
    }
    var gross_operating_point_of_EY = zeroes  // BR
    var EY_plant_start = zeroes  // BS
    var EY_aux_elec_cons = zeroes  // BT
    var Net_elec_to_EY = zeroes  // BU
    var aux_elec_cons_not_covered = zeroes  // BV
    var EY_aux_elec_cons_covered = zeroes  // BW
    var elec_avail_after_EY_elec_cons = zeroes  // BX
    var EY_aux_heatConsumption = zeroes  // BY
    var EY_aux_heatConsumption_not_covered_by_PB_SF = zeroes  // BZ
    var EY_aux_heatConsumption_covered_by_PB_SF = zeroes  // CA
    var PB_SF_aux_heat_avail_after_EY = zeroes  // CB
    var elec_used_to_cover_EY_aux_heat = zeroes  // CC
    var aux_electr_not_covered_by_plant = zeroes  // CD
    var elec_to_cover_EY_aux_heatConsumption_covered_by_plant = zeroes  // CE
    var aux_boiler_cap_avail_after_EY = zeroes  // CF
    var grid_cap_avail_after_EY = zeroes  // CG
    var elec_avail_after_total_EY = zeroes  // CH
    var Amount_of_H2_produced_MTPH = zeroes  // CI

    for i in indices.dropFirst() {
      gross_operating_point_of_EY[i] = max(
        0,
        min(
          EY.gross_elec_input, total_steam_avail_for_EY_after_pr_meth_cons[i] / EY.heat_input * EY.gross_elec_input,
          total_net_elec_avail_after_pr_meth_cons[i]
            - max(0, (total_steam_avail_for_EY_after_pr_meth_cons[i] - aux_steam_avail_after_pr_meth_cons[i]) / El_boiler_eff)))
      EY_plant_start[i] = iff(gross_operating_point_of_EY[i - 1] == 0 && gross_operating_point_of_EY[i] > 0, 1, 0)
      EY_aux_elec_cons[i] = gross_operating_point_of_EY[i] / EY.gross_elec_input * EY.aux_elec_input
      Net_elec_to_EY[i] = gross_operating_point_of_EY[i] - EY_aux_elec_cons[i]
      aux_elec_cons_not_covered[i] = max(0, gross_operating_point_of_EY[i] + aux_cons_not_covered[i] - avail_total_net_elec[i])
      EY_aux_elec_cons_covered[i] = min(aux_cons_not_covered[i] + EY_aux_elec_cons[i], avail_total_net_elec[i] - Net_elec_to_EY[i])
      elec_avail_after_EY_elec_cons[i] = max(0, avail_total_net_elec[i] - EY_aux_elec_cons_covered[i] - Net_elec_to_EY[i])
      EY_aux_heatConsumption[i] = EY.heat_input * Net_elec_to_EY[i] / EY.net_elec_input
      EY_aux_heatConsumption_not_covered_by_PB_SF[i] = max(0, EY_aux_heatConsumption[i] - aux_steam_provided_by_PB_SF[i])
      EY_aux_heatConsumption_covered_by_PB_SF[i] = EY_aux_heatConsumption[i] - EY_aux_heatConsumption_not_covered_by_PB_SF[i]
      PB_SF_aux_heat_avail_after_EY[i] = aux_steam_provided_by_PB_SF[i] - EY_aux_heatConsumption_covered_by_PB_SF[i]
      elec_used_to_cover_EY_aux_heat[i] = EY_aux_heatConsumption_not_covered_by_PB_SF[i] / El_boiler_eff
      aux_electr_not_covered_by_plant[i] = max(0, elec_used_to_cover_EY_aux_heat[i] + aux_elec_cons_not_covered[i] - elec_avail_after_EY_elec_cons[i])
      elec_to_cover_EY_aux_heatConsumption_covered_by_plant[i] = min(  // CE
        elec_used_to_cover_EY_aux_heat[i] + aux_elec_cons_not_covered[i], elec_avail_after_EY_elec_cons[i])
      aux_boiler_cap_avail_after_EY[i] = max(  // CF
        0,
        min(
          El_boiler_cap * El_boiler_eff - EY_aux_heatConsumption_not_covered_by_PB_SF[i],
          (elec_avail_after_EY_elec_cons[i] + grid_max_import - elec_to_cover_EY_aux_heatConsumption_covered_by_plant[i]) * El_boiler_eff))
      grid_cap_avail_after_EY[i] =  // CG
        grid_max_import - max(0, -(elec_avail_after_EY_elec_cons[i] - elec_to_cover_EY_aux_heatConsumption_covered_by_plant[i]))
      elec_avail_after_total_EY[i] =  // CH
        elec_avail_after_EY_elec_cons[i] - elec_to_cover_EY_aux_heatConsumption_covered_by_plant[i]
      Amount_of_H2_produced_MTPH[i] = Net_elec_to_EY[i] / EY.electrEnergy_per_tH2  // CI
    }
    #if DEBUG
    results.compare(extracted_steam, with: "AS")
    results.compare(Heat_avail_for_elec_generation, with: "AT")
    results.compare(gross_elec_from_PB, with: "AU")
    results.compare(PB_aux_cons, with: "AV")
    results.compare(PB_aux_cons_not_covered_by_PB, with: "AW")
    results.compare(aux_cons_covered_by_PB, with: "AX")
    results.compare(Net_elec_from_PB, with: "AY")
    results.compare(total_net_elec_avail, with: "AZ")
    results.compare(aux_cons_not_covered, with: "BA")
    results.compare(TES_disch_Cons_covered, with: "BB")
    results.compare(aux_steam_provided_by_PB_SF, with: "BC")
    results.compare(avail_total_net_elec, with: "BD")
    results.compare(pr_min_meth_heatConsumption, with: "BE")
    results.compare(pr_meth_heatConsumption_not_covered_by_PB_SF, with: "BF")
    results.compare(pr_meth_heatConsumption_covered_by_PB_SF, with: "BG")
    results.compare(pr_min_meth_elec_cons, with: "BH")
    results.compare(aux_cons_not_covered_by_PB_SF_incl, with: "BI")
    results.compare(pr_meth_elec_cons_covered_by_PB_SF, with: "BJ")
    results.compare(pr_meth_heatConsumption_not_covered_by_aux_boiler, with: "BK")
    results.compare(pr_meth_heatConsumption_covered_by_aux_boiler, with: "BL")
    results.compare(aux_boiler_cap_avail_after_pr_meth_cons, with: "BM")
    results.compare(grid_cap_avail_after_pr_meth, with: "BN")
    results.compare(aux_steam_avail_after_pr_meth_cons, with: "BO")
    results.compare(total_net_elec_avail_after_pr_meth_cons, with: "BP")
    results.compare(total_steam_avail_for_EY_after_pr_meth_cons, with: "BQ")
    results.compare(gross_operating_point_of_EY, with: "BR")
    results.compare(EY_plant_start, with: "BS")
    results.compare(EY_aux_elec_cons, with: "BT")
    results.compare(Net_elec_to_EY, with: "BU")
    results.compare(aux_elec_cons_not_covered, with: "BV")
    results.compare(EY_aux_elec_cons_covered, with: "BW")
    results.compare(elec_avail_after_EY_elec_cons, with: "BX")
    results.compare(EY_aux_heatConsumption, with: "BY")
    results.compare(EY_aux_heatConsumption_not_covered_by_PB_SF, with: "BZ")
    results.compare(EY_aux_heatConsumption_covered_by_PB_SF, with: "CA")
    results.compare(PB_SF_aux_heat_avail_after_EY, with: "CB")
    results.compare(elec_used_to_cover_EY_aux_heat, with: "CC")
    results.compare(aux_electr_not_covered_by_plant, with: "CD")
    results.compare(elec_to_cover_EY_aux_heatConsumption_covered_by_plant, with: "CE")
    results.compare(aux_boiler_cap_avail_after_EY, with: "CF")
    results.compare(grid_cap_avail_after_EY, with: "CG")
    results.compare(elec_avail_after_total_EY, with: "CH")
    results.compare(Amount_of_H2_produced_MTPH, with: "CI")
    #endif
    let COUNT = 39
    var H2_storage_level_MT = zeroes  // CJ
    var H2_to_meth_production_calculated_MTPH = zeroes  // CK
    var H2_to_meth_production_effective_MTPH = zeroes  // CL

    for i in indices.dropFirst() {  // CJ CK CL
      H2_storage_level_MT[i] = min(  // CJ
        H2_storage_level_MT[i - 1] + Amount_of_H2_produced_MTPH[i - 1] - H2_to_meth_production_effective_MTPH[i - 1], H2_storage_cap)
      let count = countiff(Amount_of_H2_produced_MTPH[i...].prefix(17), { $0 < Meth.min_H2_Cons })
      H2_to_meth_production_calculated_MTPH[i] =  // CK
        iff(
          Amount_of_H2_produced_MTPH[i - 1] >= Meth.min_H2_Cons && Amount_of_H2_produced_MTPH[i] < Meth.min_H2_Cons,
          max(
            Meth.min_H2_Cons,
            min(
              (Amount_of_H2_produced_MTPH[i] + H2_storage_level_MT[i]) / count,
              (H2_storage_level_MT[i] + sum(Amount_of_H2_produced_MTPH[i...].prefix(COUNT))) / Double(COUNT))),
          iff(Amount_of_H2_produced_MTPH[i] >= Meth.min_H2_Cons, 0.0, H2_to_meth_production_calculated_MTPH[i - 1]))
      let c = countiff(Amount_of_H2_produced_MTPH[i...].prefix(25), { $0 < Meth.min_H2_Cons })
      let avg: Double
      if c > 0 {
        avg = (H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i]) / c
      } else {
        avg = average(Amount_of_H2_produced_MTPH[i...].prefix(25))
      }
      H2_to_meth_production_effective_MTPH[i] =  // CL
        max(
          0,
          min(
            (elec_avail_after_total_EY[i] + PB_SF_aux_heat_avail_after_EY[i] / El_boiler_eff + grid_cap_avail_after_EY[i]
              - aux_electr_not_covered_by_plant[i]) / (Meth.nominal_aux_electr_cons + Meth.nominal_heatConsumption / El_boiler_eff)
              * Meth.max_H2_Cons, (grid_cap_avail_after_EY[i] + elec_avail_after_total_EY[i]) / Meth.nominal_aux_electr_cons * Meth.max_H2_Cons,
            iff(
              Meth.nominal_heatConsumption > 0,
              (aux_boiler_cap_avail_after_EY[i] + PB_SF_aux_heat_avail_after_EY[i]) / Meth.nominal_heatConsumption * Meth.max_H2_Cons,
              Meth.max_H2_Cons),
            iff(H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i] < Meth.min_H2_Cons, 0, H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i]),
            Meth.max_H2_Cons,
            max(
              H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i] - H2_storage_cap, Meth.min_H2_Cons, H2_to_meth_production_calculated_MTPH[i],
              iff(
                H2_to_meth_production_calculated_MTPH[i] > 0, 0,
                min(
                  (H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i]) / countiff(Amount_of_H2_produced_MTPH[i...].prefix(2), { $0 == 0 })
                    * Meth.min_H2_Cons,
                  iff(H2_storage_level_MT[i] < 10 * Meth.min_H2_Cons, average(Amount_of_H2_produced_MTPH[i...].prefix(2)), Meth.max_H2_Cons), avg)))))
    }
    #if DEBUG
    results.compare(H2_storage_level_MT, with: "CJ")
    results.compare(H2_to_meth_production_calculated_MTPH, with: "CK")
    results.compare(H2_to_meth_production_effective_MTPH, with: "CL")
    #endif
    var H2_dumping_MTPH = zeroes  // CM
    var meth_plant_start = zeroes  // CN
    var meth_produced_MTPH = zeroes  // CO
    var meth_plant_aux_elec_cons = zeroes  // CP
    var aux_elec_not_covered_by_plant = zeroes  // CQ
    var meth_plant_aux_elec_covered_by_plant = zeroes  // CR
    var elec_avail_after_meth_plant_aux_elec = zeroes  // CS
    var meth_plant_heatConsumption = zeroes  // CT
    var meth_plant_heatConsumption_not_covered_by_heat_from_PB_SF = zeroes  // CU
    var meth_plant_heatConsumption_covered_by_heat_from_PB_SF = zeroes  // CV
    var PB_SF_aux_heat_avail_after_met = zeroes  // CW
    var elec_needed_for_not_yet_covered_meth_plant_aux_heat = zeroes  // CX
    var aux_elec_not_covered_by_plant2 = zeroes  // CY
    var elec_to_cover_addtl_meth_aux_heat_cov_by_plant = zeroes  // CZ
    var elec_avail_after_meth_plant_heatConsumption = zeroes  // DA
    var total_elec_used_to_produce_aux_steam = zeroes  // DB
    var aux_steam_missing_due_to_aux_boiler_cap_limit = zeroes  // DC
    var total_aux_elec_demand = zeroes  // DD
    var total_aux_elec_demand_covered = zeroes  // DE

    for i in indices.dropFirst() {  // CM -- DM
      H2_dumping_MTPH[i] =  // CM
        max(H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i] - H2_to_meth_production_effective_MTPH[i] - H2_storage_cap, 0)
      meth_plant_start[i] =  // CN
        iff(H2_to_meth_production_effective_MTPH[i - 1] == 0 && H2_to_meth_production_effective_MTPH[i] > 0, 1, 0)
      meth_produced_MTPH[i] =  // CO
        H2_to_meth_production_effective_MTPH[i] / Meth.H2_cons * Meth.prod_cap
      meth_plant_aux_elec_cons[i] =  // CP
        meth_produced_MTPH[i] / Meth.nominal_hourly_prod_cap * Meth.nominal_aux_electr_cons
      aux_elec_not_covered_by_plant[i] =  // CQ
        max(0, meth_plant_aux_elec_cons[i] + aux_electr_not_covered_by_plant[i] - elec_avail_after_total_EY[i])
      meth_plant_aux_elec_covered_by_plant[i] =  // CR
        min(meth_plant_aux_elec_cons[i] + aux_electr_not_covered_by_plant[i], elec_avail_after_total_EY[i])
      elec_avail_after_meth_plant_aux_elec[i] =  // CS
        elec_avail_after_total_EY[i] - meth_plant_aux_elec_covered_by_plant[i]
      meth_plant_heatConsumption[i] =  // CT
        meth_produced_MTPH[i] / Meth.nominal_hourly_prod_cap * Meth.nominal_heatConsumption
      meth_plant_heatConsumption_not_covered_by_heat_from_PB_SF[i] =  // CU
        max(0, meth_plant_heatConsumption[i] - PB_SF_aux_heat_avail_after_EY[i])
      meth_plant_heatConsumption_covered_by_heat_from_PB_SF[i] =  // CV
        min(meth_plant_heatConsumption[i], PB_SF_aux_heat_avail_after_EY[i])
      PB_SF_aux_heat_avail_after_met[i] =  // CW
        PB_SF_aux_heat_avail_after_EY[i] - meth_plant_heatConsumption_covered_by_heat_from_PB_SF[i]
      elec_needed_for_not_yet_covered_meth_plant_aux_heat[i] =  // CX
        meth_plant_heatConsumption_not_covered_by_heat_from_PB_SF[i] / El_boiler_eff
      aux_elec_not_covered_by_plant2[i] =  // CY
        max(0, elec_needed_for_not_yet_covered_meth_plant_aux_heat[i] + aux_elec_not_covered_by_plant[i] - elec_avail_after_meth_plant_aux_elec[i])
      elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i] =  // CZ
        min(elec_needed_for_not_yet_covered_meth_plant_aux_heat[i] + aux_elec_not_covered_by_plant[i], elec_avail_after_meth_plant_aux_elec[i])
      elec_avail_after_meth_plant_heatConsumption[i] =  // DA
        elec_avail_after_meth_plant_aux_elec[i] - elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i]
      total_elec_used_to_produce_aux_steam[i] =  // DB
        elec_used_to_cover_EY_aux_heat[i] + elec_needed_for_not_yet_covered_meth_plant_aux_heat[i]
      aux_steam_missing_due_to_aux_boiler_cap_limit[i] =  // DC
        max(0, total_elec_used_to_produce_aux_steam[i] - El_boiler_cap) * El_boiler_eff
      total_aux_elec_demand[i] =  // DD
        elec_needed_for_not_yet_covered_meth_plant_aux_heat[i] + meth_plant_aux_elec_cons[i] + elec_used_to_cover_EY_aux_heat[i] + EY_aux_elec_cons[i]
        + PB_aux_cons[i] + TES_discharging_aux_elec_cons[i] + TES_charging_aux_elec_cons[i]
      total_aux_elec_demand_covered[i] =  // DE
        elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i] + meth_plant_aux_elec_covered_by_plant[i]
        + elec_to_cover_EY_aux_heatConsumption_covered_by_plant[i] + EY_aux_elec_cons_covered[i] + aux_cons_covered_by_PB[i]
        + TES_disch_Cons_covered[i] + SF_TES_charge_PV_aux_cons_covered_by_PV[i]
    }
    #if DEBUG
    results.compare(H2_dumping_MTPH, with: "CM")
    results.compare(meth_plant_start, with: "CN")
    results.compare(meth_produced_MTPH, with: "CO")
    results.compare(meth_plant_aux_elec_cons, with: "CP")
    results.compare(aux_elec_not_covered_by_plant, with: "CQ")
    results.compare(meth_plant_aux_elec_covered_by_plant, with: "CR")
    results.compare(elec_avail_after_meth_plant_aux_elec, with: "CS")
    results.compare(meth_plant_heatConsumption, with: "CT")
    results.compare(meth_plant_heatConsumption_not_covered_by_heat_from_PB_SF, with: "CU")
    results.compare(meth_plant_heatConsumption_covered_by_heat_from_PB_SF, with: "CV")
    results.compare(PB_SF_aux_heat_avail_after_met, with: "CW")
    results.compare(elec_needed_for_not_yet_covered_meth_plant_aux_heat, with: "CX")
    results.compare(aux_elec_not_covered_by_plant2, with: "CY")
    results.compare(elec_to_cover_addtl_meth_aux_heat_cov_by_plant, with: "CZ")
    results.compare(elec_avail_after_meth_plant_heatConsumption, with: "DA")
    results.compare(total_elec_used_to_produce_aux_steam, with: "DB")
    results.compare(aux_steam_missing_due_to_aux_boiler_cap_limit, with: "DC")
    results.compare(total_aux_elec_demand, with: "DD")
    results.compare(total_aux_elec_demand_covered, with: "DE")
    #endif
    var Bat_charging = zeroes  // DF
    var Bat_storage_level_MWh = zeroes  // DG
    var Bat_discharging = zeroes  // DH

    for i in indices.dropFirst() {
      Bat_storage_level_MWh[i] =  // DG
        max(0, min(BESS.cap, Bat_storage_level_MWh[i - 1] + Bat_charging[i - 1] * BESS.charging_eff - Bat_discharging[i - 1]))
      Bat_charging[i] =  // DF
        max(0, min((BESS.cap - Bat_storage_level_MWh[i]) / BESS.charging_eff, elec_avail_after_meth_plant_heatConsumption[i], BESS_max_Charging_cap))
      Bat_discharging[i] =  // DH
        max(0, min(Bat_storage_level_MWh[i], aux_elec_not_covered_by_plant2[i], BESS_max_Charging_cap * BESS.charging_eff))
    }
    var elec_from_grid = zeroes  // DI
    var aux_elec_missing_due_to_grid_limit = zeroes  // DJ
    var elec_to_grid = zeroes  // DK
    var elec_dumped_due_to_grid_limit = zeroes  // DL
    var Q_Sol_aux_steam_dumped = zeroes  // DM

    for i in indices.dropFirst() {
      elec_from_grid[i] =  // DI
        max(
          0,
          min(
            aux_elec_not_covered_by_plant2[i] + Bat_charging[i] - elec_avail_after_meth_plant_heatConsumption[i] - Bat_discharging[i], grid_max_import
          ))
      aux_elec_missing_due_to_grid_limit[i] =  // DJ
        max(
          0,
          aux_elec_not_covered_by_plant2[i] + Bat_charging[i] - elec_avail_after_meth_plant_heatConsumption[i] - Bat_discharging[i] - grid_max_import)
      elec_to_grid[i] =  // DK
        max(
          0,
          min(
            -(aux_elec_not_covered_by_plant2[i] + Bat_charging[i] - elec_avail_after_meth_plant_heatConsumption[i] - Bat_discharging[i]),
            grid_max_export))
      elec_dumped_due_to_grid_limit[i] =  // DL
        max(
          0,
          -(aux_elec_not_covered_by_plant[i] + Bat_charging[i] - elec_avail_after_meth_plant_heatConsumption[i] - Bat_discharging[i])
            - grid_max_export)
      Q_Sol_aux_steam_dumped[i] =  // DM
        max(0, PB_SF_aux_heat_avail_after_met[i])
    }
    #if DEBUG
    results.compare(Bat_charging, with: "DF")
    results.compare(Bat_storage_level_MWh, with: "DG")
    results.compare(Bat_discharging, with: "DH")
    results.compare(elec_from_grid, with: "DI")
    results.compare(aux_elec_missing_due_to_grid_limit, with: "DJ")
    results.compare(elec_to_grid, with: "DK")
    results.compare(elec_dumped_due_to_grid_limit, with: "DL")
    results.compare(Q_Sol_aux_steam_dumped, with: "DM")
    #endif

    var Heat_to_aux_directly_from_CSP = zeroes
    var Heat_to_aux_from_PB = zeroes
    var Total_SF_heat_dumped = zeroes
    var net_elec_above_max_consumers = zeroes
    for i in indices.dropFirst() {
      Heat_to_aux_directly_from_CSP[i] = min(
        meth_plant_heatConsumption_covered_by_heat_from_PB_SF[i] + EY_aux_heatConsumption_covered_by_PB_SF[i], Q_solar_avail[i])
      Heat_to_aux_from_PB[i] = max(
        0, min(meth_plant_heatConsumption_covered_by_heat_from_PB_SF[i] + EY_aux_heatConsumption_covered_by_PB_SF[i], extracted_steam[i]))
      Total_SF_heat_dumped[i] = max(
        0, min(Q_Sol_aux_steam_dumped[i], Q_solar_before_dumping[i] - TES_thermal_input_by_CSP[i] - Heat_to_aux_directly_from_CSP[i]))
      net_elec_above_max_consumers[i] = max(0, avail_total_net_elec[i] - Heater.cap - EY.gross_elec_input - Meth.nominal_aux_electr_cons)
    }
#if DEBUG
    rows[0] += "pr meth plant op, "
    + "pr EY Meth heatConsumption, "
    + "pr el boiler op for EY Meth heat, "
    + "pr EY Meth el cons, "
    + "PV electrical input to heater, "
    + "TES thermal input by heater, "
    + "TES thermal input by CSP, "
    + "TES total thermal input, "
    + "Q solar avail, "
    + "PV elec avail after eHeater, "
    + "TES charging aux elec cons, "
    + "SF TES charge PV aux cons not covered by PV, "
    + "SF TES charge PV aux cons covered by PV, "
    + "PV elec avail after TES charging, "
    + "Max net elec request from EY Meth aux to PB after pr PV EY op, "
    + "Steam extraction matching max net elec request, "
    + "min PB heat request from EY Meth aux to PB without extractions, "
    + "steam extraction matching min op case, "
    + "pr PB eff excl extraction at min EY pr Meth, "
    + "pr PB heat input based on avail heat, "
    + "pr PB eff excl extraction at discharge load, "
    + "pr TES discharging aux elec cons, "
    + "pr Ey op by PB, "
    + "Check calc PB heat input based on EY op, "
    + "pr heat request for aux consumers by PB, "
    + "TES storage level, "
    + "PB op mode, "
    + "PB startup heatConsumption effective, "
    + "TES discharge effective, "
    + "TES discharging aux elec cons, "
    + "extracted steam, "
    + "Heat avail for elec generation, "
    + "gross elec from PB, "
    + "PB aux cons, "
    + "PB aux cons not covered by PB, "
    + "aux cons covered by PB, "
    + "Net elec from PB, "
    + "total net elec avail, "
    + "aux cons not covered, "
    + "TES disch Cons covered, "
    + "aux steam provided by PB SF, "
    + "avail total net elec, "
    + "pr min meth heatConsumption, "
    + "pr meth heatConsumption not covered by PB SF, "
    + "pr meth heatConsumption covered by PB SF, "
    + "pr min meth elec cons, "
    + "aux cons not covered by PB SF incl, "
    + "pr meth elec cons covered by PB SF, "
    + "pr meth heatConsumption not covered by aux boiler, "
    + "pr meth heatConsumption covered by aux boiler, "
    + "aux boiler cap avail after pr meth cons, "
    + "grid cap avail after pr meth, "
    + "aux steam avail after pr meth cons, "
    + "total net elec avail after pr meth cons, "
    + "total steam avail for EY after pr meth cons, "
    + "gross operating point of EY, "
    + "EY plant start, "
    + "EY aux elec cons, "
    + "Net elec to EY, "
    + "aux elec cons not covered, "
    + "EY aux elec cons covered, "
    + "elec avail after EY elec cons, "
    + "EY aux heatConsumption, "
    + "EY aux heatConsumption not covered by PB SF, "
    + "EY aux heatConsumption covered by PB SF, "
    + "PB SF aux heat avail after EY, "
    + "elec used to cover EY aux heat, "
    + "aux electr not covered by plant, "
    + "elec to cover EY aux heatConsumption covered by plant, "
    + "aux boiler cap avail after EY, "
    + "grid cap avail after EY, "
    + "elec avail after total EY, "
    + "Amount of H2 produced MTPH, "
    + "H2 dumping MTPH, "
    + "meth plant start, "
    + "meth produced MTPH, "
    + "meth plant aux elec cons, "
    + "aux elec not covered by plant, "
    + "meth plant aux elec covered by plant, "
    + "elec avail after meth plant aux elec, "
    + "meth plant heatConsumption, "
    + "meth plant heatConsumption not covered by heat from PB SF, "
    + "meth plant heatConsumption covered by heat from PB SF, "
    + "PB SF aux heat avail after met, "
    + "elec needed for not yet covered meth plant aux heat, "
    + "aux elec not covered by plant2, "
    + "elec to cover addtl meth aux heat cov by plant, "
    + "elec avail after meth plant heatConsumption, "
    + "total elec used to produce aux steam, "
    + "aux steam missing due to aux boiler cap limit, "
    + "total aux elec demand, "
    + "total aux elec demand covered, "
    + "Bat charging, "
    + "Bat storage level MWh, "
    + "Bat discharging, "
    + "elec from grid, "
    + "aux elec missing due to grid limit, "
    + "elec to grid, "
    + "elec dumped due to grid limit, "
    + "Q Sol aux steam dumped, "

    for i in indices.dropFirst() {
      rows[i] +=
      String(format: "%G, ", pr_meth_plant_op[i])
      + String(format: "%G, ", pr_EY_Meth_heatConsumption[i])
      + String(format: "%G, ", pr_el_boiler_op_for_EY_Meth_heat[i])
      + String(format: "%G, ", pr_EY_Meth_el_cons[i])
      + String(format: "%G, ", PV_electrical_input_to_heater[i])
      + String(format: "%G, ", TES_thermal_input_by_heater[i])
      + String(format: "%G, ", TES_thermal_input_by_CSP[i])
      + String(format: "%G, ", TES_total_thermal_input[i])
      + String(format: "%G, ", Q_solar_avail[i])
      + String(format: "%G, ", PV_elec_avail_after_eHeater[i])
      + String(format: "%G, ", TES_charging_aux_elec_cons[i])
      + String(format: "%G, ", SF_TES_charge_PV_aux_cons_not_covered_by_PV[i])
      + String(format: "%G, ", SF_TES_charge_PV_aux_cons_covered_by_PV[i])
      + String(format: "%G, ", PV_elec_avail_after_TES_charging[i])
      + String(format: "%G, ", Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i])
      + String(format: "%G, ", Steam_extraction_matching_max_net_elec_request[i])
      + String(format: "%G, ", min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i])
      + String(format: "%G, ", steam_extraction_matching_min_op_case[i])
      + String(format: "%G, ", pr_PB_eff_excl_extraction_at_min_EY_pr_Meth[i])
      + String(format: "%G, ", pr_PB_heat_input_based_on_avail_heat[i])
      + String(format: "%G, ", pr_PB_eff_excl_extraction_at_discharge_load[i])
      + String(format: "%G, ", pr_TES_discharging_aux_elec_cons[i])
      + String(format: "%G, ", pr_Ey_op_by_PB[i])
      + String(format: "%G, ", Check_calc_PB_heat_input_based_on_EY_op[i])
      + String(format: "%G, ", pr_heat_request_for_aux_consumers_by_PB[i])
      + String(format: "%G, ", TES_storage_level[i])
      + String(format: "%G, ", PB_op_mode[i])
      + String(format: "%G, ", PB_startup_heatConsumption_effective[i])
      + String(format: "%G, ", TES_discharge_effective[i])
      + String(format: "%G, ", TES_discharging_aux_elec_cons[i])
      + String(format: "%G, ", extracted_steam[i])
      + String(format: "%G, ", Heat_avail_for_elec_generation[i])
      + String(format: "%G, ", gross_elec_from_PB[i])
      + String(format: "%G, ", PB_aux_cons[i])
      + String(format: "%G, ", PB_aux_cons_not_covered_by_PB[i])
      + String(format: "%G, ", aux_cons_covered_by_PB[i])
      + String(format: "%G, ", Net_elec_from_PB[i])
      + String(format: "%G, ", total_net_elec_avail[i])
      + String(format: "%G, ", aux_cons_not_covered[i])
      + String(format: "%G, ", TES_disch_Cons_covered[i])
      + String(format: "%G, ", aux_steam_provided_by_PB_SF[i])
      + String(format: "%G, ", avail_total_net_elec[i])
      + String(format: "%G, ", pr_min_meth_heatConsumption[i])
      + String(format: "%G, ", pr_meth_heatConsumption_not_covered_by_PB_SF[i])
      + String(format: "%G, ", pr_meth_heatConsumption_covered_by_PB_SF[i])
      + String(format: "%G, ", pr_min_meth_elec_cons[i])
      + String(format: "%G, ", aux_cons_not_covered_by_PB_SF_incl[i])
      + String(format: "%G, ", pr_meth_elec_cons_covered_by_PB_SF[i])
      + String(format: "%G, ", pr_meth_heatConsumption_not_covered_by_aux_boiler[i])
      + String(format: "%G, ", pr_meth_heatConsumption_covered_by_aux_boiler[i])
      + String(format: "%G, ", aux_boiler_cap_avail_after_pr_meth_cons[i])
      + String(format: "%G, ", grid_cap_avail_after_pr_meth[i])
      + String(format: "%G, ", aux_steam_avail_after_pr_meth_cons[i])
      + String(format: "%G, ", total_net_elec_avail_after_pr_meth_cons[i])
      + String(format: "%G, ", total_steam_avail_for_EY_after_pr_meth_cons[i])
      + String(format: "%G, ", gross_operating_point_of_EY[i])
      + String(format: "%G, ", EY_plant_start[i])
      + String(format: "%G, ", EY_aux_elec_cons[i])
      + String(format: "%G, ", Net_elec_to_EY[i])
      + String(format: "%G, ", aux_elec_cons_not_covered[i])
      + String(format: "%G, ", EY_aux_elec_cons_covered[i])
      + String(format: "%G, ", elec_avail_after_EY_elec_cons[i])
      + String(format: "%G, ", EY_aux_heatConsumption[i])
      + String(format: "%G, ", EY_aux_heatConsumption_not_covered_by_PB_SF[i])
      + String(format: "%G, ", EY_aux_heatConsumption_covered_by_PB_SF[i])
      + String(format: "%G, ", PB_SF_aux_heat_avail_after_EY[i])
      + String(format: "%G, ", elec_used_to_cover_EY_aux_heat[i])
      + String(format: "%G, ", aux_electr_not_covered_by_plant[i])
      + String(format: "%G, ", elec_to_cover_EY_aux_heatConsumption_covered_by_plant[i])
      + String(format: "%G, ", aux_boiler_cap_avail_after_EY[i])
      + String(format: "%G, ", grid_cap_avail_after_EY[i])
      + String(format: "%G, ", elec_avail_after_total_EY[i])
      + String(format: "%G, ", Amount_of_H2_produced_MTPH[i])
      + String(format: "%G, ", H2_dumping_MTPH[i])
      + String(format: "%G, ", meth_plant_start[i])
      + String(format: "%G, ", meth_produced_MTPH[i])
      + String(format: "%G, ", meth_plant_aux_elec_cons[i])
      + String(format: "%G, ", aux_elec_not_covered_by_plant[i])
      + String(format: "%G, ", meth_plant_aux_elec_covered_by_plant[i])
      + String(format: "%G, ", elec_avail_after_meth_plant_aux_elec[i])
      + String(format: "%G, ", meth_plant_heatConsumption[i])
      + String(format: "%G, ", meth_plant_heatConsumption_not_covered_by_heat_from_PB_SF[i])
      + String(format: "%G, ", meth_plant_heatConsumption_covered_by_heat_from_PB_SF[i])
      + String(format: "%G, ", PB_SF_aux_heat_avail_after_met[i])
      + String(format: "%G, ", elec_needed_for_not_yet_covered_meth_plant_aux_heat[i])
      + String(format: "%G, ", aux_elec_not_covered_by_plant2[i])
      + String(format: "%G, ", elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i])
      + String(format: "%G, ", elec_avail_after_meth_plant_heatConsumption[i])
      + String(format: "%G, ", total_elec_used_to_produce_aux_steam[i])
      + String(format: "%G, ", aux_steam_missing_due_to_aux_boiler_cap_limit[i])
      + String(format: "%G, ", total_aux_elec_demand[i])
      + String(format: "%G, ", total_aux_elec_demand_covered[i])
      + String(format: "%G, ", Bat_charging[i])
      + String(format: "%G, ", Bat_storage_level_MWh[i])
      + String(format: "%G, ", Bat_discharging[i])
      + String(format: "%G, ", elec_from_grid[i])
      + String(format: "%G, ", aux_elec_missing_due_to_grid_limit[i])
      + String(format: "%G, ", elec_to_grid[i])
      + String(format: "%G, ", elec_dumped_due_to_grid_limit[i])
      + String(format: "%G, ", Q_Sol_aux_steam_dumped[i])      
    }
    #endif
    //PV_elec_avail_after_eHeater_sum = PV_elec_avail_after_eHeater.total
    //PV_electrical_input_to_heater_sum = PV_electrical_input_to_heater.total

    Heat_to_aux_directly_from_CSP_sum = Heat_to_aux_directly_from_CSP.total
    Heat_to_aux_from_PB_sum = Heat_to_aux_from_PB.total
    Total_SF_heat_dumped_sum = Total_SF_heat_dumped.total

    Q_solar_before_dumping_sum = Q_solar_before_dumping.total
    TES_total_thermal_input_sum = TES_total_thermal_input.total
    Q_solar_avail_sum = Q_solar_avail.total
    TES_thermal_input_by_CSP_sum = TES_thermal_input_by_CSP.total
    Q_Sol_aux_steam_dumped_sum = Q_Sol_aux_steam_dumped.total
    gross_elec_from_PB_sum = gross_elec_from_PB.total
    aux_steam_provided_by_PB_SF_sum = aux_steam_provided_by_PB_SF.total
    elec_from_grid_sum = elec_from_grid.total
    elec_to_grid_sum = elec_to_grid.total
    net_elec_above_max_consumers_sum = net_elec_above_max_consumers.total
    meth_produced_MTPH_sum = meth_produced_MTPH.total
    meth_plant_heatConsumption_covered_by_heat_from_PB_SF_sum = meth_plant_heatConsumption_covered_by_heat_from_PB_SF.total
    EY_aux_heatConsumption_covered_by_PB_SF_sum = EY_aux_heatConsumption_covered_by_PB_SF.total
    Produced_thermal_energy_sum = meth_plant_heatConsumption_covered_by_heat_from_PB_SF_sum + EY_aux_heatConsumption_covered_by_PB_SF_sum
    avail_total_net_elec_sum = avail_total_net_elec.total
    EY_aux_heatConsumption_sum = EY_aux_heatConsumption.total
    meth_plant_heatConsumption_sum = meth_plant_heatConsumption.total
    H2_to_meth_production_effective_MTPH_sum = H2_to_meth_production_effective_MTPH.total
    PB_startup_heatConsumption_effective_count = PB_startup_heatConsumption_effective.nonZeroCount
    TES_discharge_effective_count = TES_discharge_effective.nonZeroCount
    EY_plant_start_count = EY_plant_start.nonZeroCount
    meth_plant_start_count = meth_plant_start.nonZeroCount
    gross_operating_point_of_EY_count = gross_operating_point_of_EY.nonZeroCount
    H2_to_meth_production_effective_MTPH_count = H2_to_meth_production_effective_MTPH.nonZeroCount
    
    aux_elec_missing_due_to_grid_limit_sum = aux_elec_missing_due_to_grid_limit.total

    // if grid_max_import == 1.0 {
    //   grid_max_import = aux_elec_missing_due_to_grid_limit.max()!
    //   print(grid_max_import)
    // }
    pr_meth_plant_op = indices.map { i in meth_produced_MTPH[i] / Meth.nominal_hourly_prod_cap }

    // let avg = [
    //   average(Q_solar_before_dumping[1...]),
    //   average(PV_MV_power_at_transformer_outlet[1...]),
    //   average(PV_electrical_input_to_heater[1...]),
    //   average(TES_thermal_input_by_CSP[1...]),
    //   average(TES_storage_level[1...]),
    //   average(TES_discharge_effective[1...]),
    //   average(extracted_steam[1...]),
    //   average(Net_elec_from_PB[1...]),
    //   average(gross_operating_point_of_EY[1...]),
    //   average(EY_aux_heatConsumption[1...]),
    //   average(Amount_of_H2_produced_MTPH[1...]),
    //   average(H2_storage_level_MT[1...]),
    //   average(H2_dumping_MTPH[1...]),
    //   average(meth_produced_MTPH[1...]),
    //   average(meth_plant_aux_elec_cons[1...]),
    //   average(meth_plant_heatConsumption[1...]),
    //   average(elec_from_grid[1...]),
    //   average(elec_to_grid[1...])
    // ]
    
    // return avg
  }

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
  var TES_Thermal_capacity = 0.0
  var TES_salt_mass = 0.0
  var PB_Ratio_Heat_input_vs_output = 0.0
}

struct Parameter: Codable {
  var ranges: [ClosedRange<Double>]

  init(
    CSP_Loop_Nr: ClosedRange<Double>,
    PV_DC_Cap: ClosedRange<Double>,
    PV_AC_Cap: ClosedRange<Double>,
    Heater_cap: ClosedRange<Double>,
    TES_Full_Load_Hours: ClosedRange<Double>,
    EY_Nominal_elec_input: ClosedRange<Double>,
    PB_Nominal_gross_cap: ClosedRange<Double>,
    BESS_cap: ClosedRange<Double>,
    H2_storage_cap: ClosedRange<Double>,
    Meth_nominal_hourly_prod_cap: ClosedRange<Double>,
    El_boiler_cap: ClosedRange<Double>,
    grid_max_export: ClosedRange<Double>
  ) {
    self.ranges = [
      CSP_Loop_Nr,
      PV_DC_Cap,
      PV_AC_Cap,
      Heater_cap,
      TES_Full_Load_Hours,
      EY_Nominal_elec_input,
      PB_Nominal_gross_cap,
      BESS_cap,
      H2_storage_cap,
      Meth_nominal_hourly_prod_cap,
      El_boiler_cap,
      grid_max_export
    ]
  }

  subscript(i: Int) -> ClosedRange<Double> {
    get { ranges[i] } 
    set { ranges[i] = newValue }
  }

  mutating func bisect(_ values: [Double])  {
    ranges = zip(ranges, values).map { range, half in
      let mid = range.normalized(value: half)
      var lowerBound = max(0, mid - 0.25)
      let upperBound = min(1, lowerBound + 0.5)
      lowerBound = upperBound - 0.5
      return range.denormalized(value: lowerBound)...range.denormalized(value: upperBound)
    }
  } 

  func denormalized(values: [Double]) -> [Double] {
    zip(ranges, values).map { range, value in range.normalized(value: value) }
  }

  func normalized(values: [Double]) -> [Double] {
    zip(ranges, values).map { range, value in range.denormalized(value: value) }
  }

  func steps(count: Int) -> [[Double]] {
    ranges.map { range in
      stride(from: 0, to: 1, by: 1 / Double(count)).map(range.denormalized(value:))
    } 
  }

  func randomValues(count: Int) -> [[Double]] {
    ranges.map { range in (1...count).map { _ in Double.random(in: range) } }
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

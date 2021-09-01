import BlackBoxModel
import Foundation
import Helpers
import PhysicalQuantities
import xlsxwriter

struct SunOl {

  var PV_DC_Cap = 818.0
  var PV_AC_Cap = 613.0
  var Heater_cap = 239.0
  var EY_Nominal_elec_input = 280.0
  var PB_Nominal_Gross_cap = 250.0
  var BESS_cap = 100.0
  var Meth_nominal_hourly_prod_cap = 14.8
  var CSP_Loop_Nr = 113.0
  var CSP_aux_elec_perc = 0.01
  var Ratio_CSP_vs_Heater = 1.315007
  var El_boiler_eff = 0.99
  var El_boiler_cap = 100.0
  var TES_Full_Load_Hours = 14.0
  var TES_Aux_elec_perc = 0.01
  var TES_dead_mass_ratio = 0.1
  var Grid_max_import = 70.0
  var Grid_max_export = 70.0
  var BESS_max_Charging_cap = 50.0
  var H2_storage_cap = 100.0
  var PB_Ratio_Heat_input_vs_output = 0.0
  var PV_elec_avail_after_eHeater_sum: Double = 0
  var PV_electrical_input_to_heater_sum: Double = 0
  var Q_solar_before_dumping_sum: Double = 0
  var TES_total_thermal_input_sum: Double = 0
  var Q_solar_avail_sum: Double = 0
  var Gross_elec_from_PB_sum: Double = 0
  var Aux_steam_provided_by_PB_SF_sum: Double = 0
  var Elec_from_grid_sum: Double = 0
  var H2_to_meth_production_effective_MTPH_sum: Double = 0
  var Q_Sol_aux_steam_dumped_sum: Double = 0
  var extracted_steam_sum: Double = 0
  var meth_produced_MTPH_sum: Double = 0
  var avail_total_net_elec_sum: Double = 0
  var Amount_of_H2_produced_MTPH: [Double] = []
  var TES_Thermal_capacity = 0.0
  var TES_salt_mass = 0.0

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
    var nominal_Gross_cap = 250.0
    var nominal_Gross_eff = 0.4713

    var Ratio_Heat_input_vs_output = 0.6176

    var aux_cons_perc = 0.05
    var max_heat_input = 569.855
    var min_heat_input = 91.4943
    var min_el_cap_perc = 0.125
    var minimum_Gross_cap = 31.25
    var cold_start_energyperc = 2.0
    var warm_start_energyperc = 0.4
    var hot_start_energyperc = 0.05
    var warm_start_duration = 6.0
    var cold_start_duration = 48.0
    var th = Polynomial([-1.52794811, 4.61474612, -5.27135243, 2.81011828, 0.37443614].reversed())
    var el = Polynomial([-1.29372858006, 3.79919335925, -4.21508179486, 2.20137842450, 0.50823859118].reversed())

    lazy var nominal_heat_input = nominal_Gross_cap / nominal_Gross_eff
    lazy var cold_start_heat_req = nominal_heat_input * cold_start_energyperc
    lazy var warm_start_heat_req = nominal_heat_input * warm_start_energyperc
    lazy var hot_start_heat_req = nominal_heat_input * hot_start_energyperc
    mutating func proportion(nominal_Gross_cap: Double, EY: Electrolysis, nominal_heat_cons: Double) {
      let gross_cap = [  // A29-A33
        ref_gross_cap.nominal, ((((ref_gross_cap.min + ref_gross_cap.nominal) / 2) + ref_gross_cap.nominal) / 2),
        ((ref_gross_cap.min + ref_gross_cap.nominal) / 2), ref_gross_cap.low, ref_gross_cap.min,
      ]
      let load_perc = gross_cap.map { $0 / ref_gross_cap.nominal }  // B

      let heat_input = load_perc.map { $0 * nominal_Gross_cap }  // D

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
        min(EY.heat_input, EY.heat_input * $0 * nominal_Gross_cap * (1.0 - aux_cons_perc) / (EY.net_elec_input + EY.aux_elec_input))
          + nominal_heat_cons
      }  // F
      th = Polynomial(x: thermal_load_perc, y: eff_factor)
      el = Polynomial(x: load_perc, y: eff_factor)
      Ratio_Heat_input_vs_output = factor * (no_extraction[0] / ref_aux_heat_prod.nominal) / (gross[0] / steam_extraction[0])
    }
  }

  struct Electrolysis {
    private(set) var ElectrEnergy_per_tH2 = 55.0, min_cap_rate = 0.1, net_elec_input = 180.0, aux_elec_input = 2.7, heat_input = 40.0
    lazy var gross_elec_input = net_elec_input + aux_elec_input
    lazy var min_elec_input = gross_elec_input * min_cap_rate
    mutating func proportion(net_elec_input: Double) {
      let ratio = net_elec_input / self.net_elec_input
      self.net_elec_input = net_elec_input
      aux_elec_input *= ratio
      heat_input *= ratio
    }
  }

  struct MethanolPlant {
    private(set) var H2_cons = 20000.0, prod_cap = 100_000.0, min_cap_perc = 0.5, nominal_hourly_prod_cap = 14.8

    lazy var nominal_heat_cons = nominal_hourly_prod_cap / Ref_meth_hourly_prod_cap * 10.0
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
  var TES_elec_elec_perc = 0.01
  var Q_Sol_MW_thLoop: [Double] = [0]
  var Reference_PV_plant_power_at_inverter_inlet_DC: [Double] = [0]
  var Reference_PV_MV_power_at_transformer_outlet: [Double] = [0]

  #if DEBUGA
  var results: Results
  #endif
  init(dataFile: DataFile) {
    #if DEBUGA
    self.results = .init()
    #endif

    for data in dataFile.data {
      Q_Sol_MW_thLoop.append(Double(data[0]))
      Reference_PV_plant_power_at_inverter_inlet_DC.append(Double(data[1]))
      Reference_PV_MV_power_at_transformer_outlet.append(Double(data[2]))
    }
  }
  @discardableResult mutating func callAsFunction(pr_meth_plant_op: [Double]) -> [Double] {
    var Heater = Heater()
    Heater.cap = Heater_cap

    var PV = PV()
    PV.AC_Cap = PV_AC_Cap
    PV.DC_Cap = PV_DC_Cap

    var BESS = Battery()
    BESS.charging_cap = BESS_max_Charging_cap
    BESS.cap = BESS_cap

    var Meth = MethanolPlant()
    Meth.proportion(nominal_hourly_prod_cap: Meth_nominal_hourly_prod_cap)

    var EY = Electrolysis()
    EY.proportion(net_elec_input: EY_Nominal_elec_input)

    var PB = PowerBlock()
    PB.proportion(nominal_Gross_cap: PB_Nominal_Gross_cap, EY: EY, nominal_heat_cons: Meth.nominal_heat_cons)
    PB_Ratio_Heat_input_vs_output = PB.Ratio_Heat_input_vs_output
    TES_Thermal_capacity = TES_Full_Load_Hours * PB.nominal_heat_input
    TES_salt_mass = TES_Thermal_capacity * 1000.0 * 3600.0 / (846.9867739 - 451.6806344) / 1000.0 * (1.0 + TES_dead_mass_ratio)

    let PB_heat_input_at_min_aux =
      (EY.min_elec_input + Meth.min_cap_perc * Meth.nominal_aux_electr_cons) / (1 - PB.aux_cons_perc)
      / (PB.nominal_Gross_eff
        * PB.el((EY.min_elec_input + Meth.min_cap_perc * Meth.nominal_aux_electr_cons) / (1 - PB.aux_cons_perc) / PB.nominal_Gross_cap))
    let PB_eff_at_min_Op =
      max(PB.minimum_Gross_cap, (EY.min_elec_input + Meth.min_cap_perc * Meth.nominal_aux_electr_cons) / (1 - PB.aux_cons_perc))
      / max(PB.min_heat_input, PB_heat_input_at_min_aux)
    let TES_Thermal_cap = TES_Full_Load_Hours * PB.nominal_heat_input
    let maximum = Reference_PV_MV_power_at_transformer_outlet.max() ?? 0
    let Inverter_power_fraction = Reference_PV_MV_power_at_transformer_outlet.map { max(0, $0 / maximum) }
    let indices = Reference_PV_MV_power_at_transformer_outlet.indices
    let Q_solar_before_dumping = Q_Sol_MW_thLoop.map { $0 * CSP_Loop_Nr }
    let Inverter_eff = indices.map {
      return iff(
        Reference_PV_MV_power_at_transformer_outlet[$0] < maximum,
        max(Reference_PV_MV_power_at_transformer_outlet[$0], 0) / Reference_PV_plant_power_at_inverter_inlet_DC[$0], 0)
    }
    let inverter = zip(Inverter_power_fraction, Inverter_eff).filter { $0.0 > 0 && $0.0 < 1 }.sorted(by: { $0.0 < $1.0 })
    let chunks = inverter.chunked { Int($0.0 * 100) == Int($1.0 * 100) }
    let eff1 = chunks.map { bin in bin.reduce(0.0) { $0 + $1.1 } / Double(bin.count) }
    let eff2 = zip(stride(from: 0.01, through: 1, by: 0.01), eff1).map { PV.AC_Cap * $0.0 / $0.1 / PV.DC_Cap }
    let LL = Polynomial(x: Array(eff2[...20]), y: Array(eff1[...20]), degree: 6)
    let ML = Polynomial(x: Array(eff2[8...22]), y: Array(eff1[8...22]), degree: 3)
    let HL = Polynomial(x: Array(eff2[20...]), y: Array(eff1[20...]), degree: 4)

    let E_PV_Total_Scaled_DC =  // J
      Reference_PV_plant_power_at_inverter_inlet_DC.map { $0 * PV.DC_Cap / PV.Ref_DC_cap }
    // var chunked = E_PV_Total_Scaled_DC.chunked { !($0 == 0 && $1 > 0) }
    // let s = chunked.removeFirst()
    // chunked[chunked.endIndex - 1].append(contentsOf: s)
    // let sumOfDay = chunked.map(sum)
    // let dayNight = chunked.map { ($0.count, $0.endIndex - $0.firstIndex(of: 0)!) }

    let PV_MV_power_at_transformer_outlet: [Double] = indices.map {  // K
      let load = E_PV_Total_Scaled_DC[$0] / PV.DC_Cap
      if load > 0.2 {
        return E_PV_Total_Scaled_DC[$0] * HL(load)
      } else if load > 0.1 {
        return E_PV_Total_Scaled_DC[$0] * ML(load)
      } else if load > 0 {
        return E_PV_Total_Scaled_DC[$0] * LL(load)
      } else {
        return Reference_PV_MV_power_at_transformer_outlet[$0] / PV.Ref_AC_cap * PV.AC_Cap
      }
    }

    let Aux_elec_for_CSP_SF_PV_Plant: [Double] = indices.map {  // L
      Q_solar_before_dumping[$0] * CSP_aux_elec_perc + max(0, -PV_MV_power_at_transformer_outlet[$0])
    }
    #if DEBUGA
    /*   print("", "N", "D", "I", "J", "K", "L", separator: "\t    ")
     write(
     pr_meth_plant_op, Q_Sol_MW_thLoop, Q_solar_before_dumping, E_PV_Total_Scaled_DC, PV_MV_power_at_transformer_outlet, Aux_elec_for_CSP_SF_PV_Plant,
     maxLength: 99)*/
    #endif
    #if DEBUGA
    results.compare(Q_solar_before_dumping, with: "I")
    results.compare(PV_MV_power_at_transformer_outlet, with: "K")
    results.compare(Aux_elec_for_CSP_SF_PV_Plant, with: "L")
    #endif
    let zeroes = Array(repeating: 0.0, count: indices.count)
    var pr_EY_Meth_heat_cons = zeroes  // O
    var pr_el_boiler_op_for_EY_Meth_heat = zeroes  // P
    var pr_EY_Meth_el_cons = zeroes  // Q

    for i in indices.dropFirst() {
      pr_EY_Meth_heat_cons[i] = max(
        0.0,
        min(
          iff(Q_solar_before_dumping[i] >= Meth.nominal_heat_cons * pr_meth_plant_op[i], Q_solar_before_dumping[i], 0),
          max(
            0,
            min(
              PV_MV_power_at_transformer_outlet[i] - Aux_elec_for_CSP_SF_PV_Plant[i] - Meth.nominal_aux_electr_cons * pr_meth_plant_op[i],
              EY.gross_elec_input)) / EY.gross_elec_input * EY.heat_input + Meth.nominal_heat_cons * pr_meth_plant_op[i],
          EY.heat_input
            + iff(
              PV_MV_power_at_transformer_outlet[i] - Aux_elec_for_CSP_SF_PV_Plant[i] >= Meth.nominal_aux_electr_cons * pr_meth_plant_op[i],
              Meth.nominal_heat_cons * pr_meth_plant_op[i], 0)))
      let w =
        (PV_MV_power_at_transformer_outlet[i] + pr_EY_Meth_heat_cons[i] / El_boiler_eff - Aux_elec_for_CSP_SF_PV_Plant[i]
          - (Meth.nominal_heat_cons / El_boiler_eff + Meth.nominal_aux_electr_cons) * pr_meth_plant_op[i])
        / (EY.gross_elec_input + EY.heat_input / El_boiler_eff) * EY.heat_input + Meth.nominal_heat_cons * pr_meth_plant_op[i]
        - pr_EY_Meth_heat_cons[i]
      pr_el_boiler_op_for_EY_Meth_heat[i] = max(
        0,
        min(
          El_boiler_eff * El_boiler_cap, max(0, EY.heat_input + Meth.nominal_heat_cons * pr_meth_plant_op[i] - pr_EY_Meth_heat_cons[i]),
          max(0, iff(PV_MV_power_at_transformer_outlet[i] > 0, w, 0)), EY.heat_input + Meth.nominal_heat_cons * pr_meth_plant_op[i]))
      pr_EY_Meth_el_cons[i] = max(  // Q
        0,
        min(
          iff(
            PV_MV_power_at_transformer_outlet[i] - Aux_elec_for_CSP_SF_PV_Plant[i] - pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_eff
              >= Meth.nominal_aux_electr_cons * pr_meth_plant_op[i],
            PV_MV_power_at_transformer_outlet[i] - Aux_elec_for_CSP_SF_PV_Plant[i] - pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_eff, 0),
          max(0, min(Q_solar_before_dumping[i] + pr_el_boiler_op_for_EY_Meth_heat[i] - Meth.nominal_heat_cons * pr_meth_plant_op[i], EY.heat_input))
            / EY.heat_input * EY.gross_elec_input
            + iff(
              Q_solar_before_dumping[i] + pr_el_boiler_op_for_EY_Meth_heat[i] >= Meth.nominal_heat_cons * pr_meth_plant_op[i],
              Meth.nominal_aux_electr_cons * pr_meth_plant_op[i], 0), EY.gross_elec_input + Meth.nominal_aux_electr_cons * pr_meth_plant_op[i]))
    }
    #if DEBUGA
    results.compare(pr_EY_Meth_heat_cons, with: "O")
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
    var SF_TES_chrg_PV_aux_cons_not_covered_by_PV = zeroes  // Y
    var SF_TES_chrg_PV_aux_cons_covered_by_PV = zeroes  // Z
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
    var PB_startup_heat_cons_calculated = zeroes  // AO
    var PB_startup_heat_cons_effective = zeroes  // AP
    var TES_discharge_effective = zeroes  // AQ
    var TES_discharging_aux_elec_cons = zeroes  // AR

    for i in indices.dropFirst() {
      TES_storage_level[i] = iff(  // AM
        TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - TES_discharge_effective[i - 1] - PB_startup_heat_cons_effective[i - 1] < 0.01, 0,
        TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - TES_discharge_effective[i - 1] - PB_startup_heat_cons_effective[i - 1])
      PV_electrical_input_to_heater[i] = max(  // R
        0,
        min(
          Heater.cap, (Q_solar_before_dumping[i] - pr_EY_Meth_heat_cons[i]) * Ratio_CSP_vs_Heater / Heater.eff,
          (PV_MV_power_at_transformer_outlet[i] - Aux_elec_for_CSP_SF_PV_Plant[i] - pr_EY_Meth_el_cons[i])
            * (1 - TES_Aux_elec_perc * Heater.eff * (1 + 1 / Ratio_CSP_vs_Heater)),
          (TES_Thermal_cap - TES_storage_level[i]) / (1 + 1 / Ratio_CSP_vs_Heater) / Heater.eff))
      TES_thermal_input_by_heater[i] = PV_electrical_input_to_heater[i] * Heater.eff  // S
      TES_thermal_input_by_CSP[i] = TES_thermal_input_by_heater[i] / Ratio_CSP_vs_Heater  // T
      TES_total_thermal_input[i] = TES_thermal_input_by_CSP[i] + TES_thermal_input_by_heater[i]
      Q_solar_avail[i] = Q_solar_before_dumping[i] - TES_thermal_input_by_CSP[i]
      PV_elec_avail_after_eHeater[i] = max(0, PV_MV_power_at_transformer_outlet[i] - PV_electrical_input_to_heater[i])
      TES_charging_aux_elec_cons[i] = TES_total_thermal_input[i] * TES_Aux_elec_perc + Aux_elec_for_CSP_SF_PV_Plant[i]
      SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i] = max(0, TES_charging_aux_elec_cons[i] - PV_elec_avail_after_eHeater[i])
      SF_TES_chrg_PV_aux_cons_covered_by_PV[i] = TES_charging_aux_elec_cons[i] - SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
      PV_elec_avail_after_TES_charging[i] = max(0, PV_elec_avail_after_eHeater[i] - SF_TES_chrg_PV_aux_cons_covered_by_PV[i])
      Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] =  // AB
        max(
          0,
          min(
            EY.gross_elec_input + Meth.nominal_aux_electr_cons * pr_meth_plant_op[i] + SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
              + pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_eff - PV_elec_avail_after_TES_charging[i],
            PB.nominal_Gross_cap * (1 - PB.aux_cons_perc)))
      // Output sum
      Steam_extraction_matching_max_net_elec_request[i] =  // AC
        iff(
          pr_EY_Meth_el_cons[i] == 0 && Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] > 0,
          pr_meth_plant_op[i] * Meth.nominal_heat_cons
            + (Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] - SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i] - pr_meth_plant_op[i]
              * Meth.nominal_aux_electr_cons) / EY.gross_elec_input * EY.heat_input,
          max(
            0,
            (Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] - SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]) / EY.gross_elec_input
              * EY.heat_input))
      let heat = (EY.min_elec_input + pr_meth_plant_op[i] * Meth.nominal_aux_electr_cons + TES_charging_aux_elec_cons[i]) / (1 - PB.aux_cons_perc)
      min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i] =  // AD
        heat / (PB.nominal_Gross_eff * (PB.el(heat / PB.nominal_Gross_cap))) * (1 + TES_Aux_elec_perc / PB_eff_at_min_Op)
      steam_extraction_matching_min_op_case[i] =  // AE
        iff(pr_EY_Meth_el_cons[i] == 0, pr_meth_plant_op[i] * Meth.nominal_heat_cons + EY.min_cap_rate * EY.heat_input, 0)
      pr_PB_eff_excl_extraction_at_min_EY_pr_Meth[i] =  // AF
        PB.nominal_Gross_eff * PB.th(min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i] / PB.nominal_heat_input)
      let AA = PV_elec_avail_after_TES_charging
      let AB = Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op
      let Q = pr_EY_Meth_el_cons
      let K = PV_MV_power_at_transformer_outlet
      let N = pr_meth_plant_op
      let U = TES_total_thermal_input
      let Y = SF_TES_chrg_PV_aux_cons_not_covered_by_PV
      let AM = TES_storage_level
      let AO = PB_startup_heat_cons_calculated
      let AD = min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions
      let AE = steam_extraction_matching_min_op_case
      let AF = pr_PB_eff_excl_extraction_at_min_EY_pr_Meth
      // AG
      pr_PB_heat_input_based_on_avail_heat[i] = iff(
        (AB[i] >= PB.minimum_Gross_cap * (1 - PB.aux_cons_perc) && AB[i - 1] < PB.minimum_Gross_cap * (1 - PB.aux_cons_perc) && Q[i] > 0),
        iff(
          AM[i - 1] + U[i - 1] - AO[i - 1] < PB.min_op_hours * (AD[i] + PB.Ratio_Heat_input_vs_output * AE[i]), 0,
          min(
            PB.max_heat_input,
            max(
              (AM[i - 1] + U[i - 1] - AO[i - 1]) / countiff(K[i...].prefix(16), { $0 < EY.min_elec_input }),
              AD[i] + PB.Ratio_Heat_input_vs_output * AE[i]))),
        iff(
          (Q[i - 1] > 0 && Q[i] == 0 && AB[i] >= PB.minimum_Gross_cap * (1 - PB.aux_cons_perc)),
          iff(
            AM[i - 1] + U[i - 1] - AO[i - 1] - pr_PB_heat_input_based_on_avail_heat[i - 1]
              < (PB.min_op_hours - 1) * (AD[i] + PB.Ratio_Heat_input_vs_output * AE[i]), 0,
            min(
              PB.max_heat_input,
              max(
                (AM[i - 1] + U[i - 1] - AO[i - 1] - pr_PB_heat_input_based_on_avail_heat[i - 1])
                  / countiff(K[i...].prefix(16), { $0 < EY.min_elec_input }), AD[i] + PB.Ratio_Heat_input_vs_output * AE[i]))),
          iff(
            (AA[i] > EY.gross_elec_input + Meth.nominal_aux_electr_cons * N[i] - PB.minimum_Gross_cap * (1 - PB.aux_cons_perc) || AM[i - 1] == 0
              || AB[i] == 0), 0,
            pr_PB_heat_input_based_on_avail_heat[i - 1]
              + ((pr_PB_heat_input_based_on_avail_heat[i - 1] > 0)
                ? ((Y[i] - Y[i - 1]) / AF[i]
                  + (Meth.nominal_heat_cons * PB.Ratio_Heat_input_vs_output + Meth.nominal_aux_electr_cons / AF[i]) * (-N[i - 1] + N[i])) : 0))))
      pr_PB_eff_excl_extraction_at_discharge_load[i] = iff(  // AH
        pr_PB_heat_input_based_on_avail_heat[i] == 0, 0,
        PB.th(
          (pr_PB_heat_input_based_on_avail_heat[i] - PB.Ratio_Heat_input_vs_output * steam_extraction_matching_min_op_case[i]
            / (min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i] + steam_extraction_matching_min_op_case[i])
            * pr_PB_heat_input_based_on_avail_heat[i]) / PB.nominal_heat_input) * PB.nominal_Gross_eff)
      pr_TES_discharging_aux_elec_cons[i] = pr_PB_heat_input_based_on_avail_heat[i] * TES_Aux_elec_perc
      pr_Ey_op_by_PB[i] = iff(  // AJ
        pr_PB_heat_input_based_on_avail_heat[i] == 0, 0,
        (pr_PB_heat_input_based_on_avail_heat[i]
          - iff(pr_EY_Meth_el_cons[i] == 0, PB.Ratio_Heat_input_vs_output * Meth.nominal_heat_cons * pr_meth_plant_op[i], 0)
          - ((pr_TES_discharging_aux_elec_cons[i] + SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
            + iff(pr_EY_Meth_el_cons[i] == 0, Meth.nominal_aux_electr_cons * pr_meth_plant_op[i], 0)) / (1 - PB.aux_cons_perc)
            / pr_PB_eff_excl_extraction_at_discharge_load[i]))
          / (PB.Ratio_Heat_input_vs_output * EY.heat_input / EY.gross_elec_input + 1 / (1 - PB.aux_cons_perc)
            / pr_PB_eff_excl_extraction_at_discharge_load[i]))
      Check_calc_PB_heat_input_based_on_EY_op[i] = iff(  // AK
        pr_Ey_op_by_PB[i] == 0 || pr_Ey_op_by_PB[i] < EY.min_elec_input, 0,
        (SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i] + pr_TES_discharging_aux_elec_cons[i] + pr_Ey_op_by_PB[i]
          + iff(pr_EY_Meth_el_cons[i] > 0, 0, Meth.nominal_aux_electr_cons * pr_meth_plant_op[i])) / (1 - PB.aux_cons_perc)
          / PB.el(
            ((SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i] + pr_TES_discharging_aux_elec_cons[i] + pr_Ey_op_by_PB[i]
              + iff(pr_EY_Meth_el_cons[i] > 0, 0, Meth.nominal_aux_electr_cons * pr_meth_plant_op[i])) / (1 - PB.aux_cons_perc) / PB.nominal_Gross_cap)
          ) / PB.nominal_Gross_eff
          + (pr_Ey_op_by_PB[i] / EY.gross_elec_input * EY.heat_input + iff(pr_EY_Meth_el_cons[i] > 0, 0, Meth.nominal_heat_cons * pr_meth_plant_op[i]))
          * PB.Ratio_Heat_input_vs_output)
      pr_heat_request_for_aux_consumers_by_PB[i] = max(  // AL
        0,
        iff(
          pr_Ey_op_by_PB[i] == 0 || Check_calc_PB_heat_input_based_on_EY_op[i] == 0, 0,
          pr_Ey_op_by_PB[i] / (EY.gross_elec_input) * EY.heat_input + iff(pr_EY_Meth_el_cons[i] > 0, 0, pr_meth_plant_op[i] * Meth.nominal_heat_cons))
      )
      /*
       TES_storage_level[i] = iff(  // AM
       TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - TES_discharge_effective[i - 1] - PB.startup_heat_cons_effective[i - 1] < 0.01, 0,
       TES_storage_level[i - 1] + TES_total_thermal_input[i - 1] - TES_discharge_effective[i - 1] - PB.startup_heat_cons_effective[i - 1])
       */
      PB_op_mode[i] = iff(  // AN
        Check_calc_PB_heat_input_based_on_EY_op[i - 1] == 0 && Check_calc_PB_heat_input_based_on_EY_op[i] > 0
          && TES_storage_level[i] > Check_calc_PB_heat_input_based_on_EY_op[i], -1,
        iff(
          Check_calc_PB_heat_input_based_on_EY_op[i - 1] > 0 && Check_calc_PB_heat_input_based_on_EY_op[i] > 0, 0,
          iff(
            Check_calc_PB_heat_input_based_on_EY_op[i - 1] > 0 && Check_calc_PB_heat_input_based_on_EY_op[i] == 0 && PB_op_mode[i - 1] == 0, 1,
            PB_op_mode[i - 1] + 1)))
      PB_startup_heat_cons_calculated[i] = iff(
        PB_op_mode[i] < 1, 0,
        iff(
          PB_op_mode[i] <= PB.warm_start_duration, PB.hot_start_heat_req,
          iff(PB_op_mode[i] <= PB.cold_start_duration, PB.warm_start_heat_req, PB.cold_start_heat_req)))
      PB_startup_heat_cons_effective[i] = iff(
        PB_op_mode[i] == -1,
        iff(
          PB_op_mode[i - 1] <= PB.warm_start_duration, PB.hot_start_heat_req,
          iff(PB_op_mode[i - 1] <= PB.cold_start_duration, PB.warm_start_heat_req, PB.cold_start_heat_req)), 0)
      TES_discharge_effective[i] = iff(
        min(
          Check_calc_PB_heat_input_based_on_EY_op[i] + pr_heat_request_for_aux_consumers_by_PB[i] * PB.Ratio_Heat_input_vs_output,
          TES_storage_level[i] + TES_total_thermal_input[i], PB.max_heat_input,
          iff(TES_storage_level[i] == 0, 0, Check_calc_PB_heat_input_based_on_EY_op[i])) < PB.min_heat_input + PB.Ratio_Heat_input_vs_output
          * (pr_meth_plant_op[i] * Meth.nominal_heat_cons),
        iff(
          TES_discharge_effective[i - 1] > 0 || PV_elec_avail_after_TES_charging[i] == 0
            || PV_elec_avail_after_TES_charging[i] > EY.net_elec_input - PB.min_el_cap_perc * PB.nominal_Gross_cap,
          min(
            TES_storage_level[i],
            Check_calc_PB_heat_input_based_on_EY_op[i] + pr_heat_request_for_aux_consumers_by_PB[i] * PB.Ratio_Heat_input_vs_output), 0),
        min(
          Check_calc_PB_heat_input_based_on_EY_op[i] + pr_heat_request_for_aux_consumers_by_PB[i] * PB.Ratio_Heat_input_vs_output,
          TES_storage_level[i] + TES_total_thermal_input[i], PB.max_heat_input,
          iff(TES_storage_level[i] == 0, 0, Check_calc_PB_heat_input_based_on_EY_op[i])))
      TES_discharging_aux_elec_cons[i] = TES_discharge_effective[i] * TES_Aux_elec_perc
    }
    #if DEBUGA
    results.compare(PV_electrical_input_to_heater, with: "R")
    results.compare(TES_thermal_input_by_heater, with: "S")
    results.compare(TES_thermal_input_by_CSP, with: "T")
    results.compare(TES_total_thermal_input, with: "U")
    results.compare(Q_solar_avail, with: "V")
    results.compare(PV_elec_avail_after_eHeater, with: "W")
    results.compare(TES_charging_aux_elec_cons, with: "X")
    results.compare(SF_TES_chrg_PV_aux_cons_not_covered_by_PV, with: "Y")
    results.compare(SF_TES_chrg_PV_aux_cons_covered_by_PV, with: "Z")
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
    results.compare(PB_startup_heat_cons_effective, with: "AP")
    results.compare(TES_discharge_effective, with: "AQ")
    results.compare(TES_discharging_aux_elec_cons, with: "AR")
    #endif
    /*  print(
     "", "O", "P", "Q",  //"R", "S", "T", "U", "V", "W", "X", "Y", "Z", "AA", "AB", "AC",
     "AD", "AE", "AF",  //"AN", "AO", "AP", "AG"
     separator: "\t   ")
     write(
     pr_EY_Meth_heat_cons,  // O
     pr_el_boiler_op_for_EY_Meth_heat,  // P
     pr_EY_Meth_el_cons,  // Q
     //   PV_electrical_input_to_heater,  // R
     //   TES_thermal_input_by_heater,  // S
     //    TES_thermal_input_by_CSP,  // T
     //    TES_total_thermal_input,  // U
     //    Q_solar_avail,  // V
     //    PV_elec_avail_after_eHeater,  // W
     //   TES_charging_aux_elec_cons,  // X
     //    SF_TES_chrg_PV_aux_cons_not_covered_by_PV,  // Y
     //    SF_TES_chrg_PV_aux_cons_covered_by_PV,  // Z
     //    PV_elec_avail_after_TES_charging,  // AA
     //    Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op,  // AB
     //    Steam_extraction_matching_max_net_elec_request,  // AC
     min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions,  // AD
     steam_extraction_matching_min_op_case,  // AE
     pr_PB_eff_excl_extraction_at_min_EY_pr_Meth,  // AF
     //  PB_op_mode,  // AN
     //   PB.startup_heat_cons_calculated, // AO
     //   PB.startup_heat_cons_effective_MWth,  // AP
     // pr_PB_heat_input_based_on_avail_heat,  // AG
     maxLength: 99)*/
    var extracted_steam = zeroes  // AS
    var Heat_avail_for_elec_generation = zeroes  // AT
    var Gross_elec_from_PB = zeroes  // AU
    var PB_aux_cons = zeroes  // AV
    var PB_aux_cons_not_covered_by_PB = zeroes  // AW
    var Aux_cons_covered_by_PB = zeroes  // AX
    var Net_elec_from_PB = zeroes  // AY
    var Total_net_elec_avail = zeroes  // AZ
    var Aux_cons_not_covered = zeroes  // BA
    var TES_disch_Cons_covered = zeroes  // BB
    var Aux_steam_provided_by_PB_SF = zeroes  // BC

    for i in indices.dropFirst() {
      extracted_steam[i] =  // AS
        max(
          0,
          iff(
            Check_calc_PB_heat_input_based_on_EY_op[i] > 0 && TES_discharge_effective[i] > 0,
            iff(pr_EY_Meth_el_cons[i] > 0, 0, Meth.nominal_heat_cons * pr_meth_plant_op[i])
              + (pr_Ey_op_by_PB[i] + TES_discharge_effective[i] - Check_calc_PB_heat_input_based_on_EY_op[i]) / EY.gross_elec_input * EY.heat_input, 0
          ))
      Heat_avail_for_elec_generation[i] =  // AT
        max(0, TES_discharge_effective[i] - extracted_steam[i] * PB.Ratio_Heat_input_vs_output)
      Gross_elec_from_PB[i] =  // AU
        min(
          PB.nominal_Gross_cap,
          Heat_avail_for_elec_generation[i] * (PB.th(Heat_avail_for_elec_generation[i] / PB.nominal_heat_input) * PB.nominal_Gross_eff))
      PB_aux_cons[i] = Gross_elec_from_PB[i] * PB.aux_cons_perc
      PB_aux_cons_not_covered_by_PB[i] = max(0, PB_aux_cons[i] - Gross_elec_from_PB[i])
      Aux_cons_covered_by_PB[i] = PB_aux_cons[i] - PB_aux_cons_not_covered_by_PB[i]
      Net_elec_from_PB[i] = Gross_elec_from_PB[i] - Aux_cons_covered_by_PB[i]
      Total_net_elec_avail[i] = max(0, PV_elec_avail_after_TES_charging[i] + Net_elec_from_PB[i])
      Aux_cons_not_covered[i] = max(
        0,
        SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i] + TES_discharging_aux_elec_cons[i] + PB_aux_cons_not_covered_by_PB[i] - Total_net_elec_avail[i])
      TES_disch_Cons_covered[i] = min(
        SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i] + TES_discharging_aux_elec_cons[i] + PB_aux_cons_not_covered_by_PB[i], Total_net_elec_avail[i])
      Aux_steam_provided_by_PB_SF[i] = extracted_steam[i] + Q_solar_avail[i]
    }
    var avail_total_net_elec = zeroes  // BD
    var pr_min_meth_heat_cons = zeroes  // BE
    var pr_meth_heat_cons_not_covered_by_PB_SF = zeroes  // BF
    var pr_meth_heat_cons_covered_by_PB_SF = zeroes  // BG
    var pr_min_meth_elec_cons = zeroes  // BH
    var aux_cons_not_covered_by_PB_SF_incl = zeroes  // BI not used
    var pr_meth_elec_cons_covered_by_PB_SF = zeroes  // BJ
    var pr_meth_heat_cons_not_covered_by_aux_boiler = zeroes
    var pr_meth_heat_cons_covered_by_aux_boiler = zeroes
    var aux_boiler_cap_avail_after_pr_meth_cons = zeroes
    var Grid_cap_avail_after_pr_meth = zeroes
    var aux_steam_avail_after_pr_meth_cons = zeroes
    var total_net_elec_avail_after_pr_meth_cons = zeroes
    var Total_steam_avail_for_EY_after_pr_meth_cons = zeroes  //BQ

    for i in indices.dropFirst() {
      avail_total_net_elec[i] = max(0, -TES_disch_Cons_covered[i] + Total_net_elec_avail[i])
      pr_min_meth_heat_cons[i] = Meth.nominal_heat_cons * pr_meth_plant_op[i]
      pr_meth_heat_cons_not_covered_by_PB_SF[i] = max(0, pr_min_meth_heat_cons[i] - Aux_steam_provided_by_PB_SF[i])
      pr_meth_heat_cons_covered_by_PB_SF[i] = pr_min_meth_heat_cons[i] - pr_meth_heat_cons_not_covered_by_PB_SF[i]
      pr_min_meth_elec_cons[i] = Meth.nominal_aux_electr_cons * pr_meth_plant_op[i]
      aux_cons_not_covered_by_PB_SF_incl[i] = max(0, pr_min_meth_elec_cons[i] + Aux_cons_not_covered[i] - avail_total_net_elec[i])
      pr_meth_elec_cons_covered_by_PB_SF[i] = min(pr_min_meth_elec_cons[i] + Aux_cons_not_covered[i], avail_total_net_elec[i])
      pr_meth_heat_cons_not_covered_by_aux_boiler[i] = max(
        0,
        min(
          pr_meth_heat_cons_not_covered_by_PB_SF[i] - El_boiler_cap * El_boiler_eff,
          (avail_total_net_elec[i] + Grid_max_import - pr_meth_elec_cons_covered_by_PB_SF[i] - pr_meth_heat_cons_not_covered_by_PB_SF[i]
            / El_boiler_eff) * El_boiler_eff))
      pr_meth_heat_cons_covered_by_aux_boiler[i] = pr_meth_heat_cons_not_covered_by_PB_SF[i] - pr_meth_heat_cons_not_covered_by_aux_boiler[i]
      aux_boiler_cap_avail_after_pr_meth_cons[i] = max(
        0,
        min(
          El_boiler_cap * El_boiler_eff - pr_meth_heat_cons_covered_by_aux_boiler[i],
          (avail_total_net_elec[i] + Grid_max_import - pr_meth_elec_cons_covered_by_PB_SF[i] - pr_meth_heat_cons_covered_by_aux_boiler[i]
            / El_boiler_eff) * El_boiler_eff))
      Grid_cap_avail_after_pr_meth[i] =
        Grid_max_import
        - max(0, -(avail_total_net_elec[i] - pr_meth_elec_cons_covered_by_PB_SF[i] - pr_meth_heat_cons_covered_by_aux_boiler[i] / El_boiler_eff))
      aux_steam_avail_after_pr_meth_cons[i] = Aux_steam_provided_by_PB_SF[i] - pr_meth_heat_cons_covered_by_PB_SF[i]
      total_net_elec_avail_after_pr_meth_cons[i] = max(
        0, avail_total_net_elec[i] - pr_meth_elec_cons_covered_by_PB_SF[i] - pr_meth_heat_cons_covered_by_aux_boiler[i] / El_boiler_eff)
      let avail = min(
        total_net_elec_avail_after_pr_meth_cons[i] / (EY.gross_elec_input + EY.heat_input / El_boiler_eff) * EY.heat_input,
        aux_boiler_cap_avail_after_pr_meth_cons[i] + aux_steam_avail_after_pr_meth_cons[i],
        (Grid_cap_avail_after_pr_meth[i] + total_net_elec_avail_after_pr_meth_cons[i]) * El_boiler_eff + aux_steam_avail_after_pr_meth_cons[i])
      Total_steam_avail_for_EY_after_pr_meth_cons[i] = iff(
        aux_steam_avail_after_pr_meth_cons[i] < EY.heat_input * EY.min_cap_rate, iff(avail < EY.heat_input * EY.min_cap_rate, 0, avail),
        aux_steam_avail_after_pr_meth_cons[i])
    }
    var Gross_operating_point_of_EY = zeroes  // BR
    var EY_plant_start = zeroes  // BS
    var EY_aux_elec_cons = zeroes  // BT
    var Net_elec_to_EY = zeroes  // BU
    var aux_elec_cons_not_covered = zeroes  // BV
    var EY_aux_elec_cons_covered = zeroes  // BW
    var Elec_avail_after_EY_elec_cons = zeroes  // BX
    var EY_aux_heat_cons = zeroes  // BY
    var EY_aux_heat_cons_not_covered_by_PB_SF = zeroes  // BZ
    var EY_aux_heat_cons_covered_by_PB_SF = zeroes  // CA
    var PB_SF_aux_heat_avail_after_EY = zeroes  // CB
    var Elec_used_to_cover_EY_aux_heat = zeroes  // CC
    var aux_electr_not_covered_by_plant = zeroes  // CD

    for i in indices.dropFirst() {
      Gross_operating_point_of_EY[i] = max(
        0,
        min(
          EY.gross_elec_input, Total_steam_avail_for_EY_after_pr_meth_cons[i] / EY.heat_input * EY.gross_elec_input,
          total_net_elec_avail_after_pr_meth_cons[i]
            - max(0, (Total_steam_avail_for_EY_after_pr_meth_cons[i] - aux_steam_avail_after_pr_meth_cons[i]) / El_boiler_eff)))
      EY_plant_start[i] = iff(Gross_operating_point_of_EY[i - 1] == 0 && Gross_operating_point_of_EY[i] > 0, 1, 0)
      EY_aux_elec_cons[i] = Gross_operating_point_of_EY[i] / EY.gross_elec_input * EY.aux_elec_input
      Net_elec_to_EY[i] = Gross_operating_point_of_EY[i] - EY_aux_elec_cons[i]
      aux_elec_cons_not_covered[i] = max(0, Gross_operating_point_of_EY[i] + Aux_cons_not_covered[i] - avail_total_net_elec[i])
      EY_aux_elec_cons_covered[i] = min(Aux_cons_not_covered[i] + EY_aux_elec_cons[i], avail_total_net_elec[i] - Net_elec_to_EY[i])
      Elec_avail_after_EY_elec_cons[i] = max(0, avail_total_net_elec[i] - EY_aux_elec_cons_covered[i] - Net_elec_to_EY[i])
      EY_aux_heat_cons[i] = EY.heat_input * Net_elec_to_EY[i] / EY.net_elec_input
      EY_aux_heat_cons_not_covered_by_PB_SF[i] = max(0, EY_aux_heat_cons[i] - Aux_steam_provided_by_PB_SF[i])
      EY_aux_heat_cons_covered_by_PB_SF[i] = EY_aux_heat_cons[i] - EY_aux_heat_cons_not_covered_by_PB_SF[i]
      PB_SF_aux_heat_avail_after_EY[i] = Aux_steam_provided_by_PB_SF[i] - EY_aux_heat_cons_covered_by_PB_SF[i]
      Elec_used_to_cover_EY_aux_heat[i] = EY_aux_heat_cons_not_covered_by_PB_SF[i] / El_boiler_eff
      aux_electr_not_covered_by_plant[i] = max(0, Elec_used_to_cover_EY_aux_heat[i] + aux_elec_cons_not_covered[i] - Elec_avail_after_EY_elec_cons[i])
    }
    var Elec_to_cover_EY_aux_heat_cons_covered_by_plant = zeroes  // CE
    var aux_boiler_cap_avail_after_EY = zeroes  // CF
    var Grid_cap_avail_after_EY = zeroes  // CG
    var Elec_avail_after_total_EY = zeroes  // CH
    Amount_of_H2_produced_MTPH = zeroes
    for i in indices.dropFirst() {
      Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i] = min(  // CE
        Elec_used_to_cover_EY_aux_heat[i] + aux_elec_cons_not_covered[i], Elec_avail_after_EY_elec_cons[i])
      aux_boiler_cap_avail_after_EY[i] = max(  // CF
        0,
        min(
          El_boiler_cap * El_boiler_eff - EY_aux_heat_cons_not_covered_by_PB_SF[i],
          (Elec_avail_after_EY_elec_cons[i] + Grid_max_import - Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i]) * El_boiler_eff))
      Grid_cap_avail_after_EY[i] =  // CG
        Grid_max_import - max(0, -(Elec_avail_after_EY_elec_cons[i] - Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i]))
      Elec_avail_after_total_EY[i] =  // CH
        Elec_avail_after_EY_elec_cons[i] - Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i]
      Amount_of_H2_produced_MTPH[i] = Net_elec_to_EY[i] / EY.ElectrEnergy_per_tH2  // CI
    }
    #if DEBUGA
    /*  print(
     "", "AH", "AI", "AJ", "AK", "AL", "AM", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ", "BA", "BB", "BC", "BD", "BE", "BF",
     "BG", "BH", "BI", separator: "\t   ")
     write(
     pr_PB_eff_excl_extraction_at_discharge_load,  // AH
     pr_TES_discharging_aux_elec_cons,  // AI
     pr_Ey_op_by_PB,  // AJ
     Check_calc_PB_heat_input_based_on_EY_op,  // AK
     pr_heat_request_for_aux_consumers_by_PB,  // AL
     TES_storage_level,  // AM
     PB.startup_heat_cons_effective,  // AP
     TES_discharge_effective,  // AQ
     TES_discharging_aux_elec_cons,  // AR
     Extracted_steam,  // AS
     Heat_avail_for_elec_generation,  // AT
     Gross_elec_from_PB,  // AU
     PB.aux_cons,  // AV
     PB.aux_cons_not_covered_by_PB,  // AW
     Aux_cons_covered_by_PB,  // AX
     Net_elec_from_PB,  // AY
     Total_net_elec_avail,  // AZ
     Aux_cons_not_covered,  // BA
     TES_disch_Cons_covered,  // BB
     Aux_steam_provided_by_PB_SF,  // BC
     avail_total_net_elec,  // BD
     pr_min_meth_heat_cons,  // BE
     pr_meth_heat_cons_not_covered_by_PB_SF,  // BF
     pr_meth_heat_cons_covered_by_PB_SF,  // BG
     pr_min_meth_elec_cons,  // BH
     aux_cons_not_covered_by_PB_SF_incl,  // BI
     maxLength: 99)*/
    results.compare(extracted_steam, with: "AS")
    results.compare(Heat_avail_for_elec_generation, with: "AT")
    results.compare(Gross_elec_from_PB, with: "AU")
    results.compare(PB_aux_cons, with: "AV")
    results.compare(PB_aux_cons_not_covered_by_PB, with: "AW")
    results.compare(Aux_cons_covered_by_PB, with: "AX")
    results.compare(Net_elec_from_PB, with: "AY")
    results.compare(Total_net_elec_avail, with: "AZ")
    results.compare(Aux_cons_not_covered, with: "BA")
    results.compare(TES_disch_Cons_covered, with: "BB")
    results.compare(Aux_steam_provided_by_PB_SF, with: "BC")
    results.compare(avail_total_net_elec, with: "BD")
    results.compare(pr_min_meth_heat_cons, with: "BE")
    results.compare(pr_meth_heat_cons_not_covered_by_PB_SF, with: "BF")
    results.compare(pr_meth_heat_cons_covered_by_PB_SF, with: "BG")
    results.compare(pr_min_meth_elec_cons, with: "BH")
    results.compare(aux_cons_not_covered_by_PB_SF_incl, with: "BI")
    /*  print(
     "", "BJ", "BK", "BL", "BM", "BN", "BO", "BP", "BQ", "BR", "BS", "BT", "BU", "BV", "BW", "BX", "BY", "BZ", "CA", "CB", "CC", "CD", "CE", "CF",
     "CG", "CH", "CI", separator: "\t   ")
     write(
     pr_meth_elec_cons_covered_by_PB_SF,  // BJ
     pr_meth_heat_cons_not_covered_by_aux_boiler,  // BK
     pr_meth_heat_cons_covered_by_aux_boiler,  // BL
     aux_boiler_cap_avail_after_pr_meth_cons,  // BM
     Grid_cap_avail_after_pr_meth,  // BN
     aux_steam_avail_after_pr_meth_cons,  // BO
     total_net_elec_avail_after_pr_meth_cons,  // BP
     Total_steam_avail_for_EY_after_pr_meth_cons,  // BQ
     Gross_operating_point_of_EY,  // BR
     EY_plant_start,  // BS
     EY_aux_elec_cons,  // BT
     Net_elec_to_EY,  // BU
     aux_elec_cons_not_covered,  // BV
     EY_aux_elec_cons_covered,  // BW
     Elec_avail_after_EY_elec_cons,  //BX
     EY_aux_heat_cons,  // BY
     EY_aux_heat_cons_not_covered_by_PB_SF,  // BZ
     EY_aux_heat_cons_covered_by_PB_SF,  // CA
     PB.SF_aux_heat_avail_after_EY,  // CB
     Elec_used_to_cover_EY_aux_heat,  // CC
     aux_electr_not_covered_by_plant,  // CD
     Elec_to_cover_EY_aux_heat_cons_covered_by_plant,  // CE
     aux_boiler_cap_avail_after_EY,  // CF
     Grid_cap_avail_after_EY,  // CG
     Elec_avail_after_total_EY,  // CH
     Amount_of_H2_produced_MTPH,  // CI
     maxLength: 99)*/
    results.compare(pr_meth_elec_cons_covered_by_PB_SF, with: "BJ")
    results.compare(pr_meth_heat_cons_not_covered_by_aux_boiler, with: "BK")
    results.compare(pr_meth_heat_cons_covered_by_aux_boiler, with: "BL")
    results.compare(aux_boiler_cap_avail_after_pr_meth_cons, with: "BM")
    results.compare(Grid_cap_avail_after_pr_meth, with: "BN")
    results.compare(aux_steam_avail_after_pr_meth_cons, with: "BO")
    results.compare(total_net_elec_avail_after_pr_meth_cons, with: "BP")
    results.compare(Total_steam_avail_for_EY_after_pr_meth_cons, with: "BQ")
    results.compare(Gross_operating_point_of_EY, with: "BR")
    results.compare(EY_plant_start, with: "BS")
    results.compare(EY_aux_elec_cons, with: "BT")
    results.compare(Net_elec_to_EY, with: "BU")
    results.compare(aux_elec_cons_not_covered, with: "BV")
    results.compare(EY_aux_elec_cons_covered, with: "BW")
    results.compare(Elec_avail_after_EY_elec_cons, with: "BX")
    results.compare(EY_aux_heat_cons, with: "BY")
    results.compare(EY_aux_heat_cons_not_covered_by_PB_SF, with: "BZ")
    results.compare(EY_aux_heat_cons_covered_by_PB_SF, with: "CA")
    results.compare(PB_SF_aux_heat_avail_after_EY, with: "CB")
    results.compare(Elec_used_to_cover_EY_aux_heat, with: "CC")
    results.compare(aux_electr_not_covered_by_plant, with: "CD")
    results.compare(Elec_to_cover_EY_aux_heat_cons_covered_by_plant, with: "CE")
    results.compare(aux_boiler_cap_avail_after_EY, with: "CF")
    results.compare(Grid_cap_avail_after_EY, with: "CG")
    results.compare(Elec_avail_after_total_EY, with: "CH")
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
            (Elec_avail_after_total_EY[i] + PB_SF_aux_heat_avail_after_EY[i] / El_boiler_eff + Grid_cap_avail_after_EY[i]
              - aux_electr_not_covered_by_plant[i]) / (Meth.nominal_aux_electr_cons + Meth.nominal_heat_cons / El_boiler_eff) * Meth.max_H2_Cons,
            (aux_boiler_cap_avail_after_EY[i] + PB_SF_aux_heat_avail_after_EY[i]) / Meth.nominal_heat_cons * Meth.max_H2_Cons,
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
    #if DEBUGA
    /* print("", "CJ", "CK", "CL", separator: "\t   ")
     write(H2_storage_level_MT, H2_to_meth_production_calculated_MTPH, H2_to_meth_production_effective_MTPH, maxLength: 99)*/
    results.compare(H2_storage_level_MT, with: "CJ")
    results.compare(H2_to_meth_production_calculated_MTPH, with: "CK")
    results.compare(H2_to_meth_production_effective_MTPH, with: "CL")
    #endif
    var H2_dumping_MTPH = zeroes  // CM
    var meth_plant_start = zeroes  // CN
    var meth_produced_MTPH = zeroes  // CO
    var meth_plant_aux_elec_cons = zeroes  // CP
    var Aux_elec_not_covered_by_plant = zeroes  // CQ
    var meth_plant_aux_elec_covered_by_plant = zeroes  // CR
    var Elec_avail_after_meth_plant_aux_elec = zeroes  // CS
    var meth_plant_heat_cons = zeroes  // CT
    var meth_plant_heat_cons_not_covered_by_heat_from_PB_SF = zeroes  // CU
    var meth_plant_heat_cons_covered_by_heat_from_PB_SF = zeroes  // CV
    var PB_SF_aux_heat_avail_after_met = zeroes  // CW
    var Elec_needed_for_not_yet_covered_meth_plant_aux_heat = zeroes  // CX
    var Aux_elec_not_covered_by_plant2 = zeroes  // CY
    var Elec_to_cover_addtl_meth_aux_heat_cov_by_plant = zeroes  // CZ
    var Elec_avail_after_meth_plant_heat_cons = zeroes  // DA
    var Total_elec_used_to_produce_aux_steam = zeroes  // DB
    var Aux_steam_missing_due_to_aux_boiler_cap_limit = zeroes  // DC
    var Total_aux_elec_demand = zeroes  // DD
    var Total_aux_elec_demand_covered = zeroes  // DE

    for i in indices.dropFirst() {  // CM -- DM
      H2_dumping_MTPH[i] =  // CM
        max(H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i] - H2_to_meth_production_effective_MTPH[i] - H2_storage_cap, 0)
      meth_plant_start[i] =  // CN
        iff(H2_to_meth_production_effective_MTPH[i - 1] == 0 && H2_to_meth_production_effective_MTPH[i] > 0, 1, 0)
      meth_produced_MTPH[i] =  // CO
        H2_to_meth_production_effective_MTPH[i] / Meth.H2_cons * Meth.prod_cap
      meth_plant_aux_elec_cons[i] =  // CP
        meth_produced_MTPH[i] / Meth.nominal_hourly_prod_cap * Meth.nominal_aux_electr_cons
      Aux_elec_not_covered_by_plant[i] =  // CQ
        max(0, meth_plant_aux_elec_cons[i] + aux_electr_not_covered_by_plant[i] - Elec_avail_after_total_EY[i])
      meth_plant_aux_elec_covered_by_plant[i] =  // CR
        min(meth_plant_aux_elec_cons[i] + aux_electr_not_covered_by_plant[i], Elec_avail_after_total_EY[i])
      Elec_avail_after_meth_plant_aux_elec[i] =  // CS
        Elec_avail_after_total_EY[i] - meth_plant_aux_elec_covered_by_plant[i]
      meth_plant_heat_cons[i] =  // CT
        meth_produced_MTPH[i] / Meth.nominal_hourly_prod_cap * Meth.nominal_heat_cons
      meth_plant_heat_cons_not_covered_by_heat_from_PB_SF[i] =  // CU
        max(0, meth_plant_heat_cons[i] - PB_SF_aux_heat_avail_after_EY[i])
      meth_plant_heat_cons_covered_by_heat_from_PB_SF[i] =  // CV
        min(meth_plant_heat_cons[i], PB_SF_aux_heat_avail_after_EY[i])
      PB_SF_aux_heat_avail_after_met[i] =  // CW
        PB_SF_aux_heat_avail_after_EY[i] - meth_plant_heat_cons_covered_by_heat_from_PB_SF[i]
      Elec_needed_for_not_yet_covered_meth_plant_aux_heat[i] =  // CX
        meth_plant_heat_cons_not_covered_by_heat_from_PB_SF[i] / El_boiler_eff
      Aux_elec_not_covered_by_plant2[i] =  // CY
        max(0, Elec_needed_for_not_yet_covered_meth_plant_aux_heat[i] + Aux_elec_not_covered_by_plant[i] - Elec_avail_after_meth_plant_aux_elec[i])
      Elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i] =  // CZ
        min(Elec_needed_for_not_yet_covered_meth_plant_aux_heat[i] + Aux_elec_not_covered_by_plant[i], Elec_avail_after_meth_plant_aux_elec[i])
      Elec_avail_after_meth_plant_heat_cons[i] =  // DA
        Elec_avail_after_meth_plant_aux_elec[i] - Elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i]
      Total_elec_used_to_produce_aux_steam[i] =  // DB
        Elec_used_to_cover_EY_aux_heat[i] + Elec_needed_for_not_yet_covered_meth_plant_aux_heat[i]
      Aux_steam_missing_due_to_aux_boiler_cap_limit[i] =  // DC
        max(0, Total_elec_used_to_produce_aux_steam[i] - El_boiler_cap) * El_boiler_eff
      Total_aux_elec_demand[i] =  // DD
        Elec_needed_for_not_yet_covered_meth_plant_aux_heat[i] + meth_plant_aux_elec_cons[i] + Elec_used_to_cover_EY_aux_heat[i] + EY_aux_elec_cons[i]
        + PB_aux_cons[i] + TES_discharging_aux_elec_cons[i] + TES_charging_aux_elec_cons[i]
      Total_aux_elec_demand_covered[i] =  // DE
        Elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i] + meth_plant_aux_elec_covered_by_plant[i]
        + Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i] + EY_aux_elec_cons_covered[i] + Aux_cons_covered_by_PB[i] + TES_disch_Cons_covered[i]
        + SF_TES_chrg_PV_aux_cons_covered_by_PV[i]
    }
    #if DEBUGA
    results.compare(H2_dumping_MTPH, with: "CM")
    results.compare(meth_plant_start, with: "CN")
    results.compare(meth_produced_MTPH, with: "CO")
    results.compare(meth_plant_aux_elec_cons, with: "CP")
    results.compare(Aux_elec_not_covered_by_plant, with: "CQ")
    results.compare(meth_plant_aux_elec_covered_by_plant, with: "CR")
    results.compare(Elec_avail_after_meth_plant_aux_elec, with: "CS")
    results.compare(meth_plant_heat_cons, with: "CT")
    results.compare(meth_plant_heat_cons_not_covered_by_heat_from_PB_SF, with: "CU")
    results.compare(meth_plant_heat_cons_covered_by_heat_from_PB_SF, with: "CV")
    results.compare(PB_SF_aux_heat_avail_after_met, with: "CW")
    results.compare(Elec_needed_for_not_yet_covered_meth_plant_aux_heat, with: "CX")
    results.compare(Aux_elec_not_covered_by_plant2, with: "CY")
    results.compare(Elec_to_cover_addtl_meth_aux_heat_cov_by_plant, with: "CZ")
    results.compare(Elec_avail_after_meth_plant_heat_cons, with: "DA")
    results.compare(Total_elec_used_to_produce_aux_steam, with: "DB")
    results.compare(Aux_steam_missing_due_to_aux_boiler_cap_limit, with: "DC")
    results.compare(Total_aux_elec_demand, with: "DD")
    results.compare(Total_aux_elec_demand_covered, with: "DE")
    #endif
    var Bat_charging = zeroes  // DF
    var Bat_storage_level_MWh = zeroes  // DG
    var Bat_discharging = zeroes  // DH

    for i in indices.dropFirst() {
      Bat_storage_level_MWh[i] =  // DG
        max(0, min(BESS.cap, Bat_storage_level_MWh[i - 1] + Bat_charging[i - 1] * BESS.charging_eff - Bat_discharging[i - 1]))
      Bat_charging[i] =  // DF
        max(0, min((BESS.cap - Bat_storage_level_MWh[i]) / BESS.charging_eff, Elec_avail_after_meth_plant_heat_cons[i], BESS_max_Charging_cap))
      Bat_discharging[i] =  // DH
        max(0, min(Bat_storage_level_MWh[i], Aux_elec_not_covered_by_plant2[i], BESS_max_Charging_cap * BESS.charging_eff))
    }
    var Elec_from_grid = zeroes  // DI
    var Aux_elec_missing_due_to_grid_limit = zeroes  // DJ
    var Elec_to_grid = zeroes  // DK
    var elec_dumped_due_to_grid_limit = zeroes  // DL
    var Q_Sol_aux_steam_dumped = zeroes  // DM

    for i in indices.dropFirst() {
      Elec_from_grid[i] =  // DI
        max(
          0, min(Aux_elec_not_covered_by_plant2[i] + Bat_charging[i] - Elec_avail_after_meth_plant_heat_cons[i] - Bat_discharging[i], Grid_max_import)
        )
      Aux_elec_missing_due_to_grid_limit[i] =  // DJ
        max(0, Aux_elec_not_covered_by_plant2[i] + Bat_charging[i] - Elec_avail_after_meth_plant_heat_cons[i] - Bat_discharging[i] - Grid_max_import)
      Elec_to_grid[i] =  // DK
        max(
          0,
          min(-(Aux_elec_not_covered_by_plant2[i] + Bat_charging[i] - Elec_avail_after_meth_plant_heat_cons[i] - Bat_discharging[i]), Grid_max_export)
        )
      elec_dumped_due_to_grid_limit[i] =  // DL
        max(
          0, -(Aux_elec_not_covered_by_plant[i] + Bat_charging[i] - Elec_avail_after_meth_plant_heat_cons[i] - Bat_discharging[i]) - Grid_max_export)
      Q_Sol_aux_steam_dumped[i] =  // DM
        max(0, PB_SF_aux_heat_avail_after_met[i])
    }
    #if DEBUGA
    /* print(
     "", "CM", "CN", "CO", "CP", "CQ", "CR", "CS", "CT", "CU", "CV", "CW", "CX", "CY", "CZ", "DA", "DB", "DC", "DD", "DE", "DF", "DG", "DH", "DI",
     "DJ", "DK", "DL", "DM", separator: "\t   ")
     write(
     H2_dumping_MTPH,  // CM
     meth_plant_start,  // CN
     meth_produced_MTPH,  // CO
     meth_plant_aux_elec_cons,  // CP
     Aux_elec_not_covered_by_plant,  // CQ
     meth_plant_aux_elec_covered_by_plant,  // CR
     Elec_avail_after_meth_plant_aux_elec,  // CS
     meth_plant_heat_cons,  // CT
     meth_plant_heat_cons_not_covered_by_heat_from_PB_SF,  // CU
     meth_plant_heat_cons_covered_by_heat_from_PB_SF,  // CV
     PB.SF_aux_heat_avail_after_met,  // CW
     Elec_needed_for_not_yet_covered_meth_plant_aux_heat,  // CX
     Aux_elec_not_covered_by_plant2,  //CY
     Elec_to_cover_addtl_meth_aux_heat_cov_by_plant,  // CZ
     Elec_avail_after_meth_plant_heat_cons,  // DA
     Total_elec_used_to_produce_aux_steam,  // DB
     Aux_steam_missing_due_to_aux_boiler_cap_limit,  // DC
     Total_aux_elec_demand,  // DD
     Total_aux_elec_demand_covered,  // DE
     Bat_charging,  // DF
     Bat_storage_level_MWh,  // DG
     Bat_discharging,  // DH
     Elec_from_grid,  // DI
     Aux_elec_missing_due_to_grid_limit,  // DJ
     Elec_to_grid,  // DK
     elec_dumped_due_to_grid_limit,  // DL
     Q_Sol_aux_steam_dumped,  // DM
     maxLength: 99)*/
    results.compare(Bat_charging, with: "DF")
    results.compare(Bat_storage_level_MWh, with: "DG")
    results.compare(Bat_discharging, with: "DH")
    results.compare(Elec_from_grid, with: "DI")
    results.compare(Aux_elec_missing_due_to_grid_limit, with: "DJ")
    results.compare(Elec_to_grid, with: "DK")
    results.compare(elec_dumped_due_to_grid_limit, with: "DL")
    results.compare(Q_Sol_aux_steam_dumped, with: "DM")
    #endif

    PV_elec_avail_after_eHeater_sum = PV_elec_avail_after_eHeater.sum
    PV_electrical_input_to_heater_sum = PV_electrical_input_to_heater.sum
    Q_solar_before_dumping_sum = Q_solar_before_dumping.sum
    TES_total_thermal_input_sum = TES_total_thermal_input.sum
    Q_solar_avail_sum = Q_solar_avail.sum
    Q_Sol_aux_steam_dumped_sum = Q_Sol_aux_steam_dumped.sum
    extracted_steam_sum = extracted_steam.sum
    Gross_elec_from_PB_sum = Gross_elec_from_PB.sum
    Aux_steam_provided_by_PB_SF_sum = Aux_steam_provided_by_PB_SF.sum
    Elec_from_grid_sum = Elec_from_grid.sum
    meth_produced_MTPH_sum = meth_produced_MTPH.sum
    avail_total_net_elec_sum = avail_total_net_elec.sum
    H2_to_meth_production_effective_MTPH_sum = H2_to_meth_production_effective_MTPH.sum
    return indices.map { i in meth_produced_MTPH[i] / Meth.nominal_hourly_prod_cap }
  }
}

struct Parameter {
  var CSP_Loop_Nr: Double
  var PV_DC_Cap: Double
  var PV_AC_Cap: Double
  var Heater_cap: Double
  var TES_Full_Load_Hours: Double
  var EY_Nominal_elec_input: Double
  var PB_Nominal_Gross_cap: Double
  var BESS_cap: Double
  var H2_storage_cap: Double
  var Meth_nominal_hourly_prod_cap: Double
  var El_boiler_cap: Double
  var Grid_max_export: Double
}

func main() {
  let url = URL(fileURLWithPath: "/workspaces/SPC/input.txt")
  guard let dataFile = DataFile(url) else { return }
  for _ in 1...10 {
    // let H2_storage_cap = concurrentSeek(goal: Double.infinity, 50...150, tolerance: 1) {
    var calc = SunOl(dataFile: dataFile)
    // calc.H2_storage_cap = $0  // 100.0
    calc(pr_meth_plant_op: calc(pr_meth_plant_op: calc(pr_meth_plant_op: Array(repeating: 0.5, count: 8760))))

    let C = SpecificCost().invest(config: calc)
    let BO3 = calc.H2_to_meth_production_effective_MTPH_sum
    let BV3 = 0.0
    let BW3 = 0.0
    let CA3 = 0.0
    let CB3 = 0.0
    let CC3 = calc.meth_produced_MTPH_sum
    let P3 = 25.0
    let P4 = 0.07
    let P5 = P4 * (1 + P4) ** P3 / ((1 + P4) ** P3 - 1)
    let P7 = 2 * 0.091
    let P8 = 0.33 * 0.091
    let CL = (P5 * C.2 + C.4 + BV3 * P7 * 1000 - BW3 * P8 * 1000) / (BO3)
    let CP = (P5 * C.3 + C.4 + BV3 * P7 * 1000 - BW3 * P8 * 1000) / CC3
    let CS = (P5 * C.0 + C.4) / CA3
    let CU = (P5 * C.1) / CB3
  }

  // costs.0
  // calc.avail_total_net_elec_sum
  // calc.meth_produced_MTPH_sum
  // calc.PV_elec_avail_after_eHeater_sum
  // return calc.H2_to_meth_production_effective_MTPH_sum
  // }
  /*
  let CSP_Loop_Nr = concurrentSeek(goal: Double.infinity, 50...150, tolerance: 1) {
    var calc = SunOl(dataFile: dataFile)
    calc.CSP_Loop_Nr = $0  // 113
    calc(pr_meth_plant_op: calc(pr_meth_plant_op: calc(pr_meth_plant_op: Array(repeating: 0.5, count: 8760))))
    return calc.H2_to_meth_production_effective_MTPH_sum
  }

  let _ = concurrentSeek(goal: Double.infinity, 50...150, tolerance: 1) {
    var calc = SunOl(dataFile: dataFile)
    calc.CSP_Loop_Nr = 113
    calc.PV_DC_Cap = 818
    calc.PV_AC_Cap = 613
    calc.Heater_cap = 239
    calc.TES_Full_Load_Hours = 13
    calc.EY_Nominal_elec_input = 280
    calc.PB_Nominal_Gross_cap = 250
    calc.BESS_cap = 100.0
    calc.H2_storage_cap = $0  // 100.0
    calc.Meth_nominal_hourly_prod_cap = 14.8
    calc.El_boiler_cap = 100
    calc.Grid_max_export = 70
    calc(pr_meth_plant_op: calc(pr_meth_plant_op: calc(pr_meth_plant_op: Array(repeating: 0.5, count: 8760))))
    SpecificCost().invest(config: calc)

    return calc.H2_to_meth_production_effective_MTPH_sum
  }
  */
}

let now = Date()
main()
print(-now.timeIntervalSinceNow)

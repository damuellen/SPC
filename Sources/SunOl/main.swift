import BlackBoxModel
import Foundation
import PhysicalQuantities

class SunOl {
  var CSP_Loop_Nr = 113.0
  var PV_AC_Cap = 613.0
  var PV_DC_Cap = 818.0
  var Ref_PV_AC_capacity = 510.0
  var Ref_PV_DC_capacity = 683.4
  var Ref_meth_H2_consumption = 20000.0
  var Ref_meth_prod_capacity = 100_000.0
  var CSP_aux_elec_percentage = 0.01
  var Ratio_CSP_vs_Heater = 1.32
  var Heater_efficiency = 0.96
  var EY_Nominal_gross_elec_input = 284.2
  var EY_Nominal_elec_input = 280.0
  var EY_min_cap_rate = 0.1
  var El_boiler_efficiency = 0.99
  var El_boiler_capacity = 100.0
  var Heater_cap = 239.0
  var Meth_min_cap_perc = 0.5
  var TES_Full_Load_Hours = 14.0
  var TES_Aux_elec_percentage = 0.01
  var Grid_max_import = 70.0
  var Grid_max_export = 70.0
  var BESS_Capacity = 100.0
  var BESS_Charging_Efficiency = 0.7
  var BESS_max_Charging_capacity = 50.0
  var H2_storage_cap = 100.0
  var PB_min_op_hours = 5.0
  var PB_Nominal_Gross_Capacity = 250.0
  var PB_Nominal_Gross_eff = 0.4713
  var PB_Ratio_Heat_input_vs_output = 0.62

  var PB_nominal_heat_input: Double {
    PB_Nominal_Gross_Capacity / PB_Nominal_Gross_eff
  }

  var PB_aux_cons_perc = 0.05
  var PB_max_heat_input = 570.0
  var PB_min_heat_input = 91.0
  var PB_hot_start_heat_req = 0.0
  var PB_warm_start_heat_req = 212.0
  var PB_cold_start_heat_req = 1061.0
  var PB_warm_start_duration = 6.0
  var PB_cold_start_duration = 48.0
  var PB_min_el_cap_perc = 0.125
  var PB_minimum_Gross_Capacity = 31.3
  var PB_heat_input_at_min_aux = 102.0

  var PB_eff_at_min_Op: Double {
    max(
      PB_minimum_Gross_Capacity,
      (EY_min_elec_input + Meth_min_cap_perc * Meth_nominal_aux_electr_cons)
        / (1 - PB_aux_cons_perc))
      / max(PB_min_heat_input, PB_heat_input_at_min_aux)
  }

  var EY_ElectrEnergy_per_tH2 = 0.0

  var EY_min_elec_input: Double {
    (EY_Nominal_aux_elec_input + EY_Nominal_elec_input) * EY_min_cap_rate
  }

  var Ref_EY_capacity = 180.0

  var EY_Nominal_aux_elec_input: Double {
    EY_Nominal_elec_input / Ref_EY_capacity * 2.7
  }

  var EY_nominal_heat_input: Double {
    40 * EY_Nominal_elec_input / Ref_EY_capacity
  }

  var Meth_max_H2_Cons: Double {
    Meth_nominal_hourly_prod_cap / Ref_meth_prod_capacity
      * Ref_meth_H2_consumption
  }

  var Meth_min_H2_Cons: Double {
    Meth_min_cap_perc * Meth_nominal_hourly_prod_cap / Ref_meth_prod_capacity
      * Ref_meth_H2_consumption
  }

  var Ref_meth_hourly_prod_capacity: Double {
    Ref_meth_prod_capacity * 334 * 24
  }

  var Meth_nominal_aux_electr_cons: Double {
    Meth_nominal_hourly_prod_cap / Ref_meth_hourly_prod_capacity * 10.0  // G79
  }

  var Meth_nominal_heat_cons = 12.0
  var Meth_nominal_hourly_prod_cap = 14.8

  var Ref_Inv_eff_approx_handover = 0.14
  var TES_elec_elec_percentage = 0.01

  var TES_Thermal_capacity: Double {
    TES_Full_Load_Hours * PB_nominal_heat_input
  }

  let HL_C = Array([0.22, -0.36, 0.21, 1.00].reversed())
  let LL_C = Array(
    [-2.93E+07, 1.87E+07, -4.83E+06, 6.48E+05, -47182, 1730, -21, 1].reversed()
  )
  let th_C = Array([-1.53, 4.61, -5.27, 2.81, 0.37].reversed())
  let el_C = Array([-1.29, 3.80, -4.22, 2.20, 0.51].reversed())

  var Q_Sol_MW_thLoop: [Double] = [0]
  var Reference_PV_plant_power_at_inverter_inlet_DC: [Double] = [0]
  var Reference_PV_MV_power_at_transformer_outlet: [Double] = [0]

  init() {
    let url = URL(fileURLWithPath: "/workspaces/SPC/input.txt")

    guard let dataFile = DataFile(url) else { return }

    for data in dataFile.data {
      Q_Sol_MW_thLoop.append(Double(data[0]))
      Reference_PV_plant_power_at_inverter_inlet_DC.append(Double(data[1]))
      Reference_PV_MV_power_at_transformer_outlet.append(Double(data[2]))
    }
  }

  func callAsFunction() {
    let maximum = Reference_PV_MV_power_at_transformer_outlet.max() ?? 0
    let Inverter_power_fraction =
      Reference_PV_MV_power_at_transformer_outlet.map { max(0, $0 / maximum) }
    let indices = Reference_PV_MV_power_at_transformer_outlet.indices

    let Q_solar_before_dumping = Q_Sol_MW_thLoop.map { $0 * CSP_Loop_Nr }
    //  Q_solar_before_dumping.show(100)

    let Inverter_efficiency = indices.map {
      return iff(
        Reference_PV_MV_power_at_transformer_outlet[$0] < maximum,
        max(Reference_PV_MV_power_at_transformer_outlet[$0], 0)
          / Reference_PV_plant_power_at_inverter_inlet_DC[$0], 0)
    }

    let E_PV_Total_Scaled_DC =  // J
      Reference_PV_plant_power_at_inverter_inlet_DC.map {
        $0 * PV_DC_Cap / Ref_PV_DC_capacity
      }

    let PV_MV_power_at_transformer_outlet: [Double] = indices.map {  // K
      let r = (E_PV_Total_Scaled_DC[$0] / PV_DC_Cap)
      return min(
        PV_AC_Cap,
        iff(
          E_PV_Total_Scaled_DC[$0] / PV_DC_Cap > Ref_Inv_eff_approx_handover,
          E_PV_Total_Scaled_DC[$0]
            * (r ** 3 * HL_C[3] + r ** 2 * HL_C[2] + r ** 1 * HL_C[1] + HL_C[0]),
          iff(
            r > 0,
            E_PV_Total_Scaled_DC[$0]
              * (r ** 7 * LL_C[7] + r ** 6 * LL_C[6] + r ** 5 * LL_C[5] + r
                ** 4 * LL_C[4] + r ** 3 * LL_C[3] + r ** 2 * LL_C[2] + r ** 1
                * LL_C[1] + LL_C[0]),
            Reference_PV_MV_power_at_transformer_outlet[$0]
              / Ref_PV_AC_capacity * PV_AC_Cap)))
    }

    let Aux_elec_for_CSP_SF_and_PV_Plant: [Double] = indices.map {  // L
      (i: Int) -> Double in
      Q_solar_before_dumping[i] * CSP_aux_elec_percentage
        + max(0, -PV_MV_power_at_transformer_outlet[i])
    }

    let pr_met_plant_operation = Array(  // N
      repeating: Meth_min_cap_perc, count: indices.count)
    let zeroes = Array(repeating: 0.0, count: indices.count)

    var pr_EY_Meth_heat_consumption = zeroes
    var pr_el_boiler_op_for_EY_Meth_heat = zeroes  // P
    var pr_EY_Meth_el_consumption = zeroes  // Q
    var PV_electrical_input_to_heater = zeroes  // R
    var TES_thermal_input_by_heater = zeroes  // S
    var TES_thermal_input_by_CSP = zeroes  // T
    var TES_total_thermal_input = zeroes  // U
    var Q_solar_avail = zeroes  // V
    var PV_elec_avail_after_eHeater = zeroes  // W
    var TES_charging_aux_elec_consumption = zeroes  // X
    var SF_TES_chrg_PV_aux_cons_not_covered_by_PV = zeroes  // Y
    var SF_TES_chrg_PV_aux_cons_covered_by_PV = zeroes  // Z
    var PV_elec_avail_after_TES_charging = zeroes  // AA
    var Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op = zeroes  // AB
    var Steam_extraction_matching_max_net_elec_request = zeroes  // AC
    var min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions = zeroes
    var steam_extraction_matching_min_op_case = zeroes  // AE
    var pr_PB_efficiency_excl_extraction_at_min_EY_and_pr_Meth = zeroes  // AF
    var PB_operation_mode = zeroes  // AN
    var PB_startup_heat_consumption_calculated = zeroes
    var PB_startup_heat_consumption_effective_MWth = zeroes  // AP
    var pr_PB_heat_input_based_on_avail_heat = zeroes  // AG
    var pr_PB_efficiency_excl_extraction_at_discharge_load = zeroes  // AH
    var pr_TES_discharging_aux_elec_consumption = zeroes  // AI
    var pr_Ey_op_by_PB = zeroes  // AJ
    var Check_calc_PB_heat_input_based_on_EY_operation = zeroes  // AK
    var pr_heat_request_for_aux_consumers_by_PB = zeroes  // AL
    var TES_storage_level = zeroes  // AM
    var PB_startup_heat_consumption_effective = zeroes
    var TES_discharge_effective = zeroes
    var TES_discharging_aux_elec_consumption = zeroes
    var Extracted_steam = zeroes
    var Heat_avail_for_elec_generation = zeroes
    var Gross_elec_from_PB = zeroes
    var PB_aux_consumption = zeroes
    var Pb_aux_consumption_not_covered_by_PB = zeroes
    var Aux_consumption_covered_by_PB = zeroes
    var Net_elec_from_PB = zeroes
    var Total_net_elec_avail = zeroes
    var Aux_cons_not_covered = zeroes
    var TES_disch_Cons_covered = zeroes
    var Aux_steam_provided_by_PB_and_SF = zeroes
    var avail_total_net_elec = zeroes
    var pr_min_meth_heat_consumption = zeroes
    var pr_meth_heat_consumption_not_covered_by_PB_SF = zeroes
    var pr_meth_heat_consumption_covered_by_PB_SF = zeroes
    var pr_min_meth_elec_consumption = zeroes
    var aux_cons_not_covered_by_PB_SF_incl = zeroes
    var pr_meth_elec_cons_covered_by_PB_SF = zeroes
    var pr_meth_heat_consumption_not_covered_by_aux_boiler = zeroes
    var pr_meth_heat_consumption_covered_by_aux_boiler = zeroes
    var aux_boiler_capacity_avail_after_pr_meth_cons = zeroes
    var Grid_capacity_avail_after_pr_meth = zeroes
    var aux_steam_avail_after_pr_meth_cons = zeroes
    var total_net_elec_avail_after_pr_meth_cons = zeroes
    var Total_steam_avail_for_EY_after_pr_meth_cons = zeroes
    var Gross_operating_point_of_EY = zeroes
    var EY_plant_start = zeroes
    var EY_aux_elec_cons = zeroes
    var Net_elec_to_EY = zeroes
    var aux_elec_cons_not_covered = zeroes
    var EY_aux_elec_cons_covered = zeroes
    var Elec_avail_after_EY_elec_cons = zeroes
    var EY_aux_heat_cons = zeroes
    var EY_aux_heat_cons_not_covered_by_PB_and_SF = zeroes
    var EY_aux_heat_cons_covered_by_PB_and_SF = zeroes
    var PB_and_SF_aux_heat_avail_after_EY = zeroes
    var Elec_used_to_cover_EY_aux_heat = zeroes
    var aux_electr_not_covered_by_plant = zeroes
    var Elec_to_cover_EY_aux_heat_cons_covered_by_plant = zeroes
    var aux_boiler_capacity_avail_after_EY = zeroes
    var Grid_capacity_avail_after_EY = zeroes
    var Elec_avail_after_total_EY = zeroes
    var Amount_of_H2_produced_MTPH = zeroes

    for i in indices.dropFirst() {
      let c1 =
        Q_solar_before_dumping[i] >= Meth_nominal_heat_cons
          * pr_met_plant_operation[i] ? Q_solar_before_dumping[i] : 0
      let c2 =
        PV_MV_power_at_transformer_outlet[i]
          - Aux_elec_for_CSP_SF_and_PV_Plant[i] >= Meth_nominal_aux_electr_cons
          * pr_met_plant_operation[i]
        ? Meth_nominal_heat_cons * pr_met_plant_operation[i] : 0
      let m1 = min(
        PV_MV_power_at_transformer_outlet[i]
          - Aux_elec_for_CSP_SF_and_PV_Plant[i] - Meth_nominal_aux_electr_cons
          * pr_met_plant_operation[i], EY_Nominal_gross_elec_input)
      pr_EY_Meth_heat_consumption[i] = max(
        0.0,
        min(
          c1,
          max(
            0,
            m1 / EY_Nominal_gross_elec_input * EY_nominal_heat_input
              + Meth_nominal_heat_cons * pr_met_plant_operation[i],
            EY_nominal_heat_input + c2)))

      pr_el_boiler_op_for_EY_Meth_heat[i] = max(
        0,
        min(
          El_boiler_efficiency * El_boiler_capacity,
          max(
            0,
            EY_nominal_heat_input + Meth_nominal_heat_cons
              * pr_met_plant_operation[i] - pr_EY_Meth_heat_consumption[i]),
          max(
            0,
            iff(
              PV_MV_power_at_transformer_outlet[i] > 0,
              (PV_MV_power_at_transformer_outlet[i]
                + pr_EY_Meth_heat_consumption[i] / El_boiler_efficiency
                - Aux_elec_for_CSP_SF_and_PV_Plant[i]
                - (Meth_nominal_heat_cons / El_boiler_efficiency
                  + Meth_nominal_aux_electr_cons) * pr_met_plant_operation[i])
                / (EY_Nominal_gross_elec_input + EY_nominal_heat_input
                  / El_boiler_efficiency) * EY_nominal_heat_input
                + Meth_nominal_heat_cons * pr_met_plant_operation[i]
                - pr_EY_Meth_heat_consumption[i], 0)),
          EY_nominal_heat_input + Meth_nominal_heat_cons
            * pr_met_plant_operation[i]))

      pr_EY_Meth_el_consumption[i] = max(
        0,
        min(
          iff(
            PV_MV_power_at_transformer_outlet[i]
              - Aux_elec_for_CSP_SF_and_PV_Plant[i]
              - pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_efficiency
              >= Meth_nominal_aux_electr_cons * pr_met_plant_operation[i],
            PV_MV_power_at_transformer_outlet[i]
              - Aux_elec_for_CSP_SF_and_PV_Plant[i]
              - pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_efficiency, 0),
          max(
            0,
            min(
              Q_solar_before_dumping[i] + pr_el_boiler_op_for_EY_Meth_heat[i]
                - Meth_nominal_heat_cons * pr_met_plant_operation[i],
              EY_nominal_heat_input)) / EY_nominal_heat_input
            * (EY_Nominal_gross_elec_input)
            + iff(
              Q_solar_before_dumping[i] + pr_el_boiler_op_for_EY_Meth_heat[i]
                >= Meth_nominal_heat_cons * pr_met_plant_operation[i],
              Meth_nominal_aux_electr_cons * pr_met_plant_operation[i], 0),
          EY_Nominal_gross_elec_input + Meth_nominal_aux_electr_cons
            * pr_met_plant_operation[i]))

      PV_electrical_input_to_heater[i] = max(
        0,
        min(
          Heater_cap,
          (Q_solar_before_dumping[i] - pr_EY_Meth_heat_consumption[i])
            * Ratio_CSP_vs_Heater / Heater_efficiency,
          (PV_MV_power_at_transformer_outlet[i]
            - Aux_elec_for_CSP_SF_and_PV_Plant[i]
            - pr_EY_Meth_el_consumption[i])
            * (1 - TES_Aux_elec_percentage * Heater_efficiency
              * (1 + 1 / Ratio_CSP_vs_Heater)),
          (TES_Thermal_capacity - TES_storage_level[i])
            / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_efficiency))

      TES_thermal_input_by_heater[i] =
        PV_electrical_input_to_heater[i] * Heater_efficiency  // S
      TES_thermal_input_by_CSP[i] =
        TES_thermal_input_by_heater[i] / Ratio_CSP_vs_Heater  // T
      TES_total_thermal_input[i] =
        TES_thermal_input_by_CSP[i] + TES_thermal_input_by_heater[i]

      Q_solar_avail[i] =
        Q_solar_before_dumping[i] - TES_thermal_input_by_CSP[i]

      PV_elec_avail_after_eHeater[i] = max(
        0,
        PV_MV_power_at_transformer_outlet[i] - PV_electrical_input_to_heater[i]
      )

      TES_charging_aux_elec_consumption[i] =
        TES_total_thermal_input[i] * TES_Aux_elec_percentage
        + Aux_elec_for_CSP_SF_and_PV_Plant[i]

      SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i] = max(
        0,
        TES_charging_aux_elec_consumption[i] - PV_elec_avail_after_eHeater[i])

      SF_TES_chrg_PV_aux_cons_covered_by_PV[i] =
        TES_charging_aux_elec_consumption[i]
        - SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]

      PV_elec_avail_after_TES_charging[i] = max(
        0,
        PV_elec_avail_after_eHeater[i]
          - SF_TES_chrg_PV_aux_cons_covered_by_PV[i])

      Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] = max(
        0,
        min(
          EY_Nominal_gross_elec_input + Meth_nominal_aux_electr_cons
            * pr_met_plant_operation[i]
            + SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
            + pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_efficiency
            - PV_elec_avail_after_TES_charging[i],
          PB_Nominal_Gross_Capacity * (1 - PB_aux_cons_perc)))

      /// Output sum
      Steam_extraction_matching_max_net_elec_request[i] = iff(
        pr_EY_Meth_el_consumption[i] == 0
          && Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i]
            > 0,
        pr_met_plant_operation[i] * Meth_nominal_heat_cons
          + (Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i]
            - SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
            - pr_met_plant_operation[i] * Meth_nominal_aux_electr_cons)
            / EY_Nominal_gross_elec_input * EY_nominal_heat_input,
        max(
          0,
          (Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i]
            - SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i])
            / EY_Nominal_gross_elec_input * EY_nominal_heat_input))

      let x1 =
        EY_min_elec_input + pr_met_plant_operation[i]
        * Meth_nominal_aux_electr_cons + TES_charging_aux_elec_consumption[i]

      min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i] =
        x1 / (1 - PB_aux_cons_perc)
        / (PB_Nominal_Gross_eff
          * (el_C[4]
            * (x1 / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 4
            + el_C[3]
            * (x1 / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 3
            + el_C[2]
            * (x1 / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 2
            + el_C[1]
            * (x1 / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 1
            + el_C[0]))
        * (1 + TES_Aux_elec_percentage / PB_eff_at_min_Op)

      steam_extraction_matching_min_op_case[i] = iff(
        pr_EY_Meth_el_consumption[i] == 0,
        pr_met_plant_operation[i] * Meth_nominal_heat_cons + EY_min_cap_rate
          * EY_nominal_heat_input, 0)

      let r1 =
        min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i]
        / PB_nominal_heat_input

      pr_PB_efficiency_excl_extraction_at_min_EY_and_pr_Meth[i] =
        PB_Nominal_Gross_eff
        * (th_C[4] * r1 ** 4 + th_C[3] * r1 ** 3 + th_C[2] * r1 ** 2 + th_C[1]
          * r1 ** 1 + th_C[0])

      PB_operation_mode[i] = iff(
        Check_calc_PB_heat_input_based_on_EY_operation[i] == 0
          && Check_calc_PB_heat_input_based_on_EY_operation[i] > 0
          && TES_storage_level[i]
            > Check_calc_PB_heat_input_based_on_EY_operation[i],
        -1,
        iff(
          Check_calc_PB_heat_input_based_on_EY_operation[i] > 0
            && Check_calc_PB_heat_input_based_on_EY_operation[i] > 0, 0,
          iff(
            Check_calc_PB_heat_input_based_on_EY_operation[i] > 0
              && Check_calc_PB_heat_input_based_on_EY_operation[i] == 0
              && PB_operation_mode[i - 1] == 0, 1, PB_operation_mode[i - 1] + 1
          )))

      PB_startup_heat_consumption_calculated[i] = iff(
        PB_operation_mode[i] < 1, 0,
        iff(
          PB_operation_mode[i] <= PB_warm_start_duration,
          PB_hot_start_heat_req,
          iff(
            PB_operation_mode[i] <= PB_cold_start_duration,
            PB_warm_start_heat_req, PB_cold_start_heat_req)))

      PB_startup_heat_consumption_effective_MWth[i] = iff(
        PB_operation_mode[i] == -1,
        iff(
          PB_operation_mode[i] <= PB_warm_start_duration,
          PB_hot_start_heat_req,
          iff(
            PB_operation_mode[i] <= PB_cold_start_duration,
            PB_warm_start_heat_req, PB_cold_start_heat_req)), 0)

      let AA = PV_elec_avail_after_TES_charging
      let AB = Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op
      let Q = pr_EY_Meth_el_consumption
      let K = PV_MV_power_at_transformer_outlet
      let N = pr_met_plant_operation
      let U = TES_total_thermal_input
      let Y = SF_TES_chrg_PV_aux_cons_not_covered_by_PV
      let AM = TES_storage_level
      let AG = pr_PB_heat_input_based_on_avail_heat
      let AO = PB_startup_heat_consumption_calculated
      let AD = min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions
      let AE = steam_extraction_matching_min_op_case
      let AF = pr_PB_efficiency_excl_extraction_at_min_EY_and_pr_Meth
      // AH
      pr_PB_heat_input_based_on_avail_heat[i] = iff(
        (AB[i] >= PB_minimum_Gross_Capacity * (1 - PB_aux_cons_perc)
          && AB[i - 1] < PB_minimum_Gross_Capacity * (1 - PB_aux_cons_perc)
          && Q[i] > 0),
        iff(
          AM[i - 1] + U[i - 1] - AO[i - 1] < PB_min_op_hours
            * (AD[i] + PB_Ratio_Heat_input_vs_output * AE[i]), 0,
          min(
            PB_max_heat_input,
            max(
              (AM[i - 1] + U[i - 1] - AO[i - 1])
                / countiff(K[i...].prefix(16), { $0 < EY_min_elec_input }),
              AD[i] + PB_Ratio_Heat_input_vs_output * AE[i]))),

        iff(
          (Q[i - 1] > 0 && Q[i] == 0
            && AB[i] >= PB_minimum_Gross_Capacity * (1 - PB_aux_cons_perc)),
          iff(
            AM[i - 1] + U[i - 1] - AO[i - 1] - AG[i - 1]
              < (PB_min_op_hours - 1)
                * (AD[i] + PB_Ratio_Heat_input_vs_output * AE[i]),
            0,
            min(
              PB_max_heat_input,
              max(
                (AM[i - 1] + U[i - 1] - AO[i - 1] - AG[i - 1])
                  / countiff(K[i...].prefix(16), { $0 < EY_min_elec_input }),
                AD[i] + PB_Ratio_Heat_input_vs_output * AE[i]))),
          iff(
            (AA[i] > EY_Nominal_gross_elec_input + Meth_nominal_aux_electr_cons
              * N[i] - PB_minimum_Gross_Capacity * (1 - PB_aux_cons_perc)
              || AM[i - 1] == 0 || AB[i] == 0), 0,
            AG[i - 1]
              + ((AG[i - 1] > 0)
                ? ((Y[i] - Y[i - 1]) / AF[i]
                  + (Meth_nominal_heat_cons * PB_Ratio_Heat_input_vs_output
                    + Meth_nominal_aux_electr_cons / AF[i])
                    * (-N[i - 1] + N[i]))
                : 0))))

      let factor =
        ((pr_PB_heat_input_based_on_avail_heat[i]
          - PB_Ratio_Heat_input_vs_output
          * steam_extraction_matching_min_op_case[i]
          / (min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i]
            + steam_extraction_matching_min_op_case[i])
          * pr_PB_heat_input_based_on_avail_heat[i]) / PB_nominal_heat_input)

      pr_PB_efficiency_excl_extraction_at_discharge_load[i] = iff(
        pr_PB_heat_input_based_on_avail_heat[i] == 0, 0,
        (th_C[4] * factor ** 4 + th_C[3] * factor ** 3 + th_C[2] * factor ** 2
          + th_C[1] * factor ** 1 + th_C[0]) * PB_Nominal_Gross_eff)

      pr_TES_discharging_aux_elec_consumption[i] =
        pr_PB_heat_input_based_on_avail_heat[i] * TES_Aux_elec_percentage

      pr_Ey_op_by_PB[i] = iff(
        pr_PB_heat_input_based_on_avail_heat[i] == 0, 0,
        (pr_PB_heat_input_based_on_avail_heat[i]
          - iff(
            pr_EY_Meth_el_consumption[i] == 0,
            PB_Ratio_Heat_input_vs_output * Meth_nominal_heat_cons
              * pr_met_plant_operation[i], 0)
          - ((pr_TES_discharging_aux_elec_consumption[i]
            + SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
            + iff(
              pr_EY_Meth_el_consumption[i] == 0,
              Meth_nominal_aux_electr_cons * pr_met_plant_operation[i], 0))
            / (1 - PB_aux_cons_perc)
            / pr_PB_efficiency_excl_extraction_at_discharge_load[i]))
          / (PB_Ratio_Heat_input_vs_output * EY_nominal_heat_input
            / EY_Nominal_gross_elec_input + 1 / (1 - PB_aux_cons_perc)
            / pr_PB_efficiency_excl_extraction_at_discharge_load[i]))

      Check_calc_PB_heat_input_based_on_EY_operation[i] = iff(
        pr_Ey_op_by_PB[i] == 0 || pr_Ey_op_by_PB[i] < EY_min_elec_input, 0,
        (SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
          + pr_TES_discharging_aux_elec_consumption[i] + pr_Ey_op_by_PB[i]
          + iff(
            pr_EY_Meth_el_consumption[i] > 0, 0,
            Meth_nominal_aux_electr_cons * pr_met_plant_operation[i]))
          / (1 - PB_aux_cons_perc)
          / (el_C[4]
            * ((SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
              + pr_TES_discharging_aux_elec_consumption[i] + pr_Ey_op_by_PB[i]
              + iff(
                pr_EY_Meth_el_consumption[i] > 0, 0,
                Meth_nominal_aux_electr_cons * pr_met_plant_operation[i]))
              / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 4
            + el_C[3]
            * ((SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
              + pr_TES_discharging_aux_elec_consumption[i] + pr_Ey_op_by_PB[i]
              + iff(
                pr_EY_Meth_el_consumption[i] > 0, 0,
                Meth_nominal_aux_electr_cons * pr_met_plant_operation[i]))
              / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 3
            + el_C[2]
            * ((SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
              + pr_TES_discharging_aux_elec_consumption[i] + pr_Ey_op_by_PB[i]
              + iff(
                pr_EY_Meth_el_consumption[i] > 0, 0,
                Meth_nominal_aux_electr_cons * pr_met_plant_operation[i]))
              / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 2
            + el_C[1]
            * ((SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
              + pr_TES_discharging_aux_elec_consumption[i] + pr_Ey_op_by_PB[i]
              + iff(
                pr_EY_Meth_el_consumption[i] > 0, 0,
                Meth_nominal_aux_electr_cons * pr_met_plant_operation[i]))
              / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 1
            + el_C[0]) / PB_Nominal_Gross_eff
          + (pr_Ey_op_by_PB[i] / EY_Nominal_gross_elec_input
            * EY_nominal_heat_input
            + iff(
              pr_EY_Meth_el_consumption[i] > 0, 0,
              Meth_nominal_heat_cons * pr_met_plant_operation[i]))
          * PB_Ratio_Heat_input_vs_output)

      pr_heat_request_for_aux_consumers_by_PB[i] = max(
        0,
        iff(
          pr_Ey_op_by_PB[i] == 0
            || Check_calc_PB_heat_input_based_on_EY_operation[i] == 0, 0,
          pr_Ey_op_by_PB[i] / (EY_Nominal_gross_elec_input)
            * EY_nominal_heat_input
            + iff(
              pr_EY_Meth_el_consumption[i] > 0, 0,
              pr_met_plant_operation[i] * Meth_nominal_heat_cons)))

      TES_storage_level[i] = iff(
        TES_storage_level[i - 1] + TES_total_thermal_input[i - 1]
          - TES_discharge_effective[i]
          - PB_startup_heat_consumption_effective[i] < 0.01, 0,
        TES_storage_level[i - 1] + TES_total_thermal_input[i - 1]
          - TES_discharge_effective[i]
          - PB_startup_heat_consumption_effective[i])

      PB_startup_heat_consumption_effective[i] = iff(
        PB_operation_mode[i] == -1,
        iff(
          PB_operation_mode[i] <= PB_warm_start_duration,
          PB_hot_start_heat_req,
          iff(
            PB_operation_mode[i] <= PB_cold_start_duration,
            PB_warm_start_heat_req, PB_cold_start_heat_req)), 0)

      TES_discharge_effective[i] = iff(
        min(
          Check_calc_PB_heat_input_based_on_EY_operation[i]
            + pr_heat_request_for_aux_consumers_by_PB[i]
            * PB_Ratio_Heat_input_vs_output,
          TES_storage_level[i] + TES_total_thermal_input[i], PB_max_heat_input,
          iff(
            TES_storage_level[i] == 0, 0,
            Check_calc_PB_heat_input_based_on_EY_operation[i]))
          < PB_min_heat_input + PB_Ratio_Heat_input_vs_output
          * (pr_met_plant_operation[i] * Meth_nominal_heat_cons),
        iff(
          TES_discharge_effective[i - 1] > 0
            || PV_elec_avail_after_TES_charging[i] == 0
            || PV_elec_avail_after_TES_charging[i] > EY_Nominal_elec_input
              - PB_min_el_cap_perc * PB_Nominal_Gross_Capacity,
          min(
            TES_storage_level[i],
            Check_calc_PB_heat_input_based_on_EY_operation[i]
              + pr_heat_request_for_aux_consumers_by_PB[i]
              * PB_Ratio_Heat_input_vs_output), 0),
        min(
          Check_calc_PB_heat_input_based_on_EY_operation[i]
            + pr_heat_request_for_aux_consumers_by_PB[i]
            * PB_Ratio_Heat_input_vs_output,
          TES_storage_level[i] + TES_total_thermal_input[i], PB_max_heat_input,
          iff(
            TES_storage_level[i] == 0, 0,
            Check_calc_PB_heat_input_based_on_EY_operation[i])))

      TES_discharging_aux_elec_consumption[i] =
        TES_discharge_effective[i] * TES_Aux_elec_percentage

      Extracted_steam[i] = max(
        0,
        iff(
          Check_calc_PB_heat_input_based_on_EY_operation[i] > 0
            && TES_discharge_effective[i] > 0,
          iff(
            pr_EY_Meth_el_consumption[i] > 0, 0,
            Meth_nominal_heat_cons * pr_met_plant_operation[i])
            + (pr_Ey_op_by_PB[i] + TES_discharge_effective[i]
              - Check_calc_PB_heat_input_based_on_EY_operation[i])
              / EY_Nominal_gross_elec_input * EY_nominal_heat_input,
          0))

      Heat_avail_for_elec_generation[i] = max(
        0,
        TES_discharge_effective[i] - Extracted_steam[i]
          * PB_Ratio_Heat_input_vs_output)

      let th = Heat_avail_for_elec_generation[i] / PB_nominal_heat_input
      Gross_elec_from_PB[i] = min(
        PB_Nominal_Gross_Capacity,
        Heat_avail_for_elec_generation[i]
          * ((th_C[4] * th ** 4 + th_C[3] * th ** 3 + th_C[2] * th ** 2
            + th_C[1] * th ** 1 + th_C[0]) * PB_Nominal_Gross_eff))

      PB_aux_consumption[i] = Gross_elec_from_PB[i] * PB_aux_cons_perc

      Pb_aux_consumption_not_covered_by_PB[i] = max(
        0, PB_aux_consumption[i] - Gross_elec_from_PB[i])

      Aux_consumption_covered_by_PB[i] =
        PB_aux_consumption[i] - Pb_aux_consumption_not_covered_by_PB[i]

      Net_elec_from_PB[i] =
        Gross_elec_from_PB[i] - Aux_consumption_covered_by_PB[i]

      Total_net_elec_avail[i] = max(
        0, PV_elec_avail_after_TES_charging[i] + Net_elec_from_PB[i])

      Aux_cons_not_covered[i] = max(
        0,
        SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
          + TES_discharging_aux_elec_consumption[i]
          + Pb_aux_consumption_not_covered_by_PB[i] - Total_net_elec_avail[i])

      TES_disch_Cons_covered[i] = min(
        SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
          + TES_discharging_aux_elec_consumption[i]
          + Pb_aux_consumption_not_covered_by_PB[i], Total_net_elec_avail[i])

      Aux_steam_provided_by_PB_and_SF[i] =
        Extracted_steam[i] + Q_solar_avail[i]

      avail_total_net_elec[i] = max(
        0, -TES_disch_Cons_covered[i] + Total_net_elec_avail[i])

      pr_min_meth_heat_consumption[i] =
        Meth_nominal_heat_cons * pr_met_plant_operation[i]

      pr_meth_heat_consumption_not_covered_by_PB_SF[i] = max(
        0, pr_min_meth_heat_consumption[i] - Aux_steam_provided_by_PB_and_SF[i]
      )

      pr_meth_heat_consumption_covered_by_PB_SF[i] =
        pr_min_meth_heat_consumption[i]
        - pr_meth_heat_consumption_not_covered_by_PB_SF[i]

      pr_min_meth_elec_consumption[i] =
        Meth_nominal_aux_electr_cons * pr_met_plant_operation[i]

      aux_cons_not_covered_by_PB_SF_incl[i] = max(
        0,
        pr_min_meth_elec_consumption[i] + Aux_cons_not_covered[i]
          - avail_total_net_elec[i])

      pr_meth_elec_cons_covered_by_PB_SF[i] = min(
        pr_min_meth_elec_consumption[i] + Aux_cons_not_covered[i],
        avail_total_net_elec[i])

      pr_meth_heat_consumption_not_covered_by_aux_boiler[i] = max(
        0,
        min(
          pr_meth_heat_consumption_not_covered_by_PB_SF[i] - El_boiler_capacity
            * El_boiler_efficiency,
          (avail_total_net_elec[i] + Grid_max_import
            - pr_meth_elec_cons_covered_by_PB_SF[i]
            - pr_meth_heat_consumption_not_covered_by_PB_SF[i]
            / El_boiler_efficiency) * El_boiler_efficiency))

      pr_meth_heat_consumption_covered_by_aux_boiler[i] =
        pr_meth_heat_consumption_not_covered_by_PB_SF[i]
        - pr_meth_heat_consumption_not_covered_by_aux_boiler[i]

      aux_boiler_capacity_avail_after_pr_meth_cons[i] = max(
        0,
        min(
          El_boiler_capacity * El_boiler_efficiency
            - pr_meth_heat_consumption_covered_by_aux_boiler[i],
          (avail_total_net_elec[i] + Grid_max_import
            - pr_meth_elec_cons_covered_by_PB_SF[i]
            - pr_meth_heat_consumption_covered_by_aux_boiler[i]
            / El_boiler_efficiency) * El_boiler_efficiency))

      Grid_capacity_avail_after_pr_meth[i] =
        Grid_max_import
        - max(
          0,
          -(avail_total_net_elec[i] - pr_meth_elec_cons_covered_by_PB_SF[i]
            - pr_meth_heat_consumption_covered_by_aux_boiler[i]
            / El_boiler_efficiency))

      aux_steam_avail_after_pr_meth_cons[i] =
        Aux_steam_provided_by_PB_and_SF[i]
        - pr_meth_heat_consumption_covered_by_PB_SF[i]

      total_net_elec_avail_after_pr_meth_cons[i] = max(
        0,
        avail_total_net_elec[i] - pr_meth_elec_cons_covered_by_PB_SF[i]
          - pr_meth_heat_consumption_covered_by_aux_boiler[i]
          / El_boiler_efficiency)

      Total_steam_avail_for_EY_after_pr_meth_cons[i] = iff(
        aux_steam_avail_after_pr_meth_cons[i] < EY_nominal_heat_input
          * EY_min_cap_rate,
        iff(
          min(
            total_net_elec_avail_after_pr_meth_cons[i]
              / (EY_Nominal_gross_elec_input + EY_nominal_heat_input
                / El_boiler_efficiency) * EY_nominal_heat_input,
            aux_boiler_capacity_avail_after_pr_meth_cons[i]
              + aux_steam_avail_after_pr_meth_cons[i],
            (Grid_capacity_avail_after_pr_meth[i]
              + total_net_elec_avail_after_pr_meth_cons[i])
              * El_boiler_efficiency + aux_steam_avail_after_pr_meth_cons[i])
            < EY_nominal_heat_input * EY_min_cap_rate, 0,
          min(
            total_net_elec_avail_after_pr_meth_cons[i]
              / (EY_Nominal_gross_elec_input + EY_nominal_heat_input
                / El_boiler_efficiency) * EY_nominal_heat_input,
            aux_boiler_capacity_avail_after_pr_meth_cons[i]
              + aux_steam_avail_after_pr_meth_cons[i],
            (Grid_capacity_avail_after_pr_meth[i]
              + total_net_elec_avail_after_pr_meth_cons[i])
              * El_boiler_efficiency + aux_steam_avail_after_pr_meth_cons[i])),
        aux_steam_avail_after_pr_meth_cons[i])

      Gross_operating_point_of_EY[i] = max(
        0,
        min(
          EY_Nominal_gross_elec_input,
          Total_steam_avail_for_EY_after_pr_meth_cons[i]
            / EY_nominal_heat_input * EY_Nominal_gross_elec_input,
          total_net_elec_avail_after_pr_meth_cons[i]
            - max(
              0,
              (Total_steam_avail_for_EY_after_pr_meth_cons[i]
                - aux_steam_avail_after_pr_meth_cons[i]) / El_boiler_efficiency
            )))

      // Output
      EY_plant_start[i] = iff(
        Gross_operating_point_of_EY[i] == 0
          && Gross_operating_point_of_EY[i] > 0, 1, 0)

      EY_aux_elec_cons[i] =
        Gross_operating_point_of_EY[i] / EY_Nominal_gross_elec_input
        * EY_Nominal_aux_elec_input

      Net_elec_to_EY[i] = Gross_operating_point_of_EY[i] - EY_aux_elec_cons[i]

      aux_elec_cons_not_covered[i] = max(
        0,
        Gross_operating_point_of_EY[i] + Aux_cons_not_covered[i]
          - avail_total_net_elec[i])

      EY_aux_elec_cons_covered[i] = min(
        Aux_cons_not_covered[i] + EY_aux_elec_cons[i],
        avail_total_net_elec[i] - Net_elec_to_EY[i])

      Elec_avail_after_EY_elec_cons[i] = max(
        0,
        avail_total_net_elec[i] - EY_aux_elec_cons_covered[i]
          - Net_elec_to_EY[i])

      EY_aux_heat_cons[i] =
        EY_nominal_heat_input * Net_elec_to_EY[i] / EY_Nominal_elec_input

      EY_aux_heat_cons_not_covered_by_PB_and_SF[i] = max(
        0, EY_aux_heat_cons[i] - Aux_steam_provided_by_PB_and_SF[i])

      EY_aux_heat_cons_covered_by_PB_and_SF[i] =
        EY_aux_heat_cons[i] - EY_aux_heat_cons_not_covered_by_PB_and_SF[i]

      PB_and_SF_aux_heat_avail_after_EY[i] =
        Aux_steam_provided_by_PB_and_SF[i]
        - EY_aux_heat_cons_covered_by_PB_and_SF[i]

      Elec_used_to_cover_EY_aux_heat[i] =
        EY_aux_heat_cons_not_covered_by_PB_and_SF[i] / El_boiler_efficiency

      aux_electr_not_covered_by_plant[i] = max(
        0,
        Elec_used_to_cover_EY_aux_heat[i] + aux_elec_cons_not_covered[i]
          - Elec_avail_after_EY_elec_cons[i])

      Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i] = min(
        Elec_used_to_cover_EY_aux_heat[i] + aux_elec_cons_not_covered[i],
        Elec_avail_after_EY_elec_cons[i])

      // Output
      aux_boiler_capacity_avail_after_EY[i] = max(
        0,
        min(
          El_boiler_capacity * El_boiler_efficiency
            - EY_aux_heat_cons_not_covered_by_PB_and_SF[i],
          (Elec_avail_after_EY_elec_cons[i] + Grid_max_import
            - Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i])
            * El_boiler_efficiency))

      Grid_capacity_avail_after_EY[i] =
        Grid_max_import
        - max(
          0,
          -(Elec_avail_after_EY_elec_cons[i]
            - Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i]))

      Elec_avail_after_total_EY[i] =
        Elec_avail_after_EY_elec_cons[i]
        - Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i]

      Amount_of_H2_produced_MTPH[i] =
        Net_elec_to_EY[i] / EY_ElectrEnergy_per_tH2  // CI
    }
    let COUNT = 39

    var H2_storage_level_MT = zeroes
    var H2_to_met_production_calculated_MTPH = zeroes
    var H2_to_met_production_effective_MTPH = zeroes

    for i in indices.dropFirst() {
      H2_storage_level_MT[i] = min(  // CJ
        H2_storage_level_MT[i - 1] + Amount_of_H2_produced_MTPH[i - 1]
          - H2_to_met_production_effective_MTPH[i - 1], H2_storage_cap)

      let count = countiff(
        Amount_of_H2_produced_MTPH[i...].prefix(17), { $0 < Meth_min_H2_Cons })

      H2_to_met_production_calculated_MTPH[i] =  // CK
        iff(
          Amount_of_H2_produced_MTPH[i - 1] >= Meth_min_H2_Cons
            && Amount_of_H2_produced_MTPH[i] < Meth_min_H2_Cons,
          max(
            Meth_min_H2_Cons,
            min(
              (Amount_of_H2_produced_MTPH[i] + H2_storage_level_MT[i]) / count,
              H2_storage_level_MT[i] + sum(
                Amount_of_H2_produced_MTPH[i...].prefix(COUNT)) / Double(COUNT)
            )),
          iff(
            Amount_of_H2_produced_MTPH[i] >= Meth_min_H2_Cons, 0.0,
            H2_to_met_production_calculated_MTPH[i - 1]))

      let c = countiff(
        Amount_of_H2_produced_MTPH[i...].prefix(16), { $0 < Meth_min_H2_Cons })
      let avg: Double
      if c > 0 {
        avg = (H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i]) / c
      } else {
        avg = average(Amount_of_H2_produced_MTPH[i...].prefix(16))
      }
      // FIXME
      H2_to_met_production_effective_MTPH[i] =  // CL
        max(
          0,
          min(
            (Elec_avail_after_total_EY[i]
              + PB_and_SF_aux_heat_avail_after_EY[i] / El_boiler_efficiency
              + Grid_capacity_avail_after_EY[i]
              - aux_electr_not_covered_by_plant[i])
              / (Meth_nominal_aux_electr_cons + Meth_nominal_heat_cons
                / El_boiler_efficiency) * Meth_max_H2_Cons,
            (aux_boiler_capacity_avail_after_EY[i]
              + PB_and_SF_aux_heat_avail_after_EY[i]) / Meth_nominal_heat_cons
              * Meth_max_H2_Cons,
            iff(
              H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i]
                < Meth_min_H2_Cons, 0,
              H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i]),
            Meth_max_H2_Cons,
            max(
              H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i]
                - H2_storage_cap, Meth_min_H2_Cons,
              H2_to_met_production_calculated_MTPH[i],
              iff(
                H2_to_met_production_calculated_MTPH[i] > 0, 0,
                min(
                  (H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i])
                    / countiff(
                      Amount_of_H2_produced_MTPH[i...].prefix(2), { $0 == 0 })
                    * Meth_min_H2_Cons,
                  iff(
                    H2_storage_level_MT[i] < 10 * Meth_min_H2_Cons,
                    average(Amount_of_H2_produced_MTPH[i...].prefix(2)),
                    Meth_max_H2_Cons), avg)))))

    }

    var H2_dumping_MTPH = zeroes
    var met_plant_start = zeroes
    var met_produced_MTPH = zeroes
    var met_plant_aux_elec_cons = zeroes
    var Aux_elec_not_covered_by_plant = zeroes
    var met_plant_aux_elec_covered_by_plant = zeroes
    var Elec_avail_after_met_plant_aux_elec = zeroes
    var met_plant_heat_cons = zeroes
    var met_plant_heat_cons_not_covered_by_heat_from_PB_and_SF = zeroes
    var met_plant_heat_cons_covered_by_heat_from_PB_and_SF = zeroes
    var PB_and_SF_aux_heat_avail_after_met = zeroes
    var Elec_needed_for_not_yet_covered_met_plant_aux_heat = zeroes
    var Aux_elec_not_covered_by_plant2 = zeroes
    var Elec_to_cover_addtl_meth_aux_heat_cov_by_plant = zeroes
    var Elec_avail_after_met_plant_heat_cons = zeroes
    var Total_elec_used_to_produce_aux_steam = zeroes
    var Aux_steam_missing_due_to_aux_boiler_capacity_limit = zeroes
    var Total_aux_elec_demand = zeroes
    var Total_aux_elec_demand_covered = zeroes
    var Bat_charging = zeroes
    var Bat_storage_level_MWh = zeroes
    var Bat_discharging = zeroes
    var Elec_from_grid = zeroes
    var Aux_elec_missing_due_to_grid_limit = zeroes
    var Elec_to_grid = zeroes
    var elec_dumped_due_to_grid_limit = zeroes
    var Q_Sol_and_aux_steam_dumped = zeroes

    for i in indices.dropFirst() {

      H2_dumping_MTPH[i] =  // CM
        max(
          H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i]
            - H2_to_met_production_effective_MTPH[i] - H2_storage_cap, 0)

      met_plant_start[i] =  // CN
        iff(
          H2_to_met_production_effective_MTPH[i] == 0
            && H2_to_met_production_effective_MTPH[i] > 0, 1, 0)

      met_produced_MTPH[i] =  // CO
        H2_to_met_production_effective_MTPH[i] / Ref_meth_H2_consumption
        * Ref_meth_prod_capacity

      met_plant_aux_elec_cons[i] =  // CP
        met_produced_MTPH[i] / Meth_nominal_hourly_prod_cap
        * Meth_nominal_aux_electr_cons

      Aux_elec_not_covered_by_plant[i] =  // CQ
        max(
          0,
          met_plant_aux_elec_cons[i] + aux_electr_not_covered_by_plant[i]
            - Elec_avail_after_total_EY[i])

      met_plant_aux_elec_covered_by_plant[i] =  // CR
        min(
          met_plant_aux_elec_cons[i] + aux_electr_not_covered_by_plant[i],
          Elec_avail_after_total_EY[i])

      Elec_avail_after_met_plant_aux_elec[i] =  // CS
        Elec_avail_after_total_EY[i] - met_plant_aux_elec_covered_by_plant[i]

      met_plant_heat_cons[i] =  // CT
        met_produced_MTPH[i] / Meth_nominal_hourly_prod_cap
        * Meth_nominal_heat_cons

      met_plant_heat_cons_not_covered_by_heat_from_PB_and_SF[i] =  // CU
        max(0, met_plant_heat_cons[i] - PB_and_SF_aux_heat_avail_after_EY[i])

      met_plant_heat_cons_covered_by_heat_from_PB_and_SF[i] =  // CV
        min(met_plant_heat_cons[i], PB_and_SF_aux_heat_avail_after_EY[i])

      PB_and_SF_aux_heat_avail_after_met[i] =  // CW
        PB_and_SF_aux_heat_avail_after_EY[i]
        - met_plant_heat_cons_covered_by_heat_from_PB_and_SF[i]

      Elec_needed_for_not_yet_covered_met_plant_aux_heat[i] =  // CX
        met_plant_heat_cons_not_covered_by_heat_from_PB_and_SF[i]
        / El_boiler_efficiency

      Aux_elec_not_covered_by_plant2[i] =  // CY
        max(
          0,
          Elec_needed_for_not_yet_covered_met_plant_aux_heat[i]
            + aux_electr_not_covered_by_plant[i]
            - Elec_avail_after_met_plant_aux_elec[i])

      Elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i] =  // CZ
        min(
          Elec_needed_for_not_yet_covered_met_plant_aux_heat[i]
            + Aux_elec_not_covered_by_plant[i],
          Elec_avail_after_met_plant_aux_elec[i])

      Elec_avail_after_met_plant_heat_cons[i] =  // DA
        Elec_avail_after_met_plant_aux_elec[i]
        - Elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i]

      Total_elec_used_to_produce_aux_steam[i] =  // DB
        Elec_used_to_cover_EY_aux_heat[i]
        + Elec_needed_for_not_yet_covered_met_plant_aux_heat[i]

      Aux_steam_missing_due_to_aux_boiler_capacity_limit[i] =  // DC
        max(0, Total_elec_used_to_produce_aux_steam[i] - El_boiler_capacity)
        * El_boiler_efficiency

      Total_aux_elec_demand[i] =  // DD
        Elec_needed_for_not_yet_covered_met_plant_aux_heat[i]
        + met_plant_aux_elec_cons[i] + Elec_used_to_cover_EY_aux_heat[i]
        + EY_aux_elec_cons[i] + PB_aux_consumption[i]
        + TES_discharging_aux_elec_consumption[i]
        + TES_charging_aux_elec_consumption[i]

      Total_aux_elec_demand_covered[i] =  // DE
        Elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i]
        + met_plant_aux_elec_covered_by_plant[i]
        + Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i]
        + EY_aux_elec_cons_covered[i] + Aux_consumption_covered_by_PB[i]
        + TES_disch_Cons_covered[i] + SF_TES_chrg_PV_aux_cons_covered_by_PV[i]

      Bat_charging[i] =  // DF
        max(
          0,
          min(
            (BESS_Capacity - Bat_storage_level_MWh[i])
              / BESS_Charging_Efficiency,
            Elec_avail_after_met_plant_heat_cons[i], BESS_max_Charging_capacity
          ))

      Bat_storage_level_MWh[i] =  // DG
        max(
          0,
          min(
            BESS_Capacity,
            Bat_storage_level_MWh[i - 1] + Bat_charging[i]
              * BESS_Charging_Efficiency - Bat_discharging[i]))

      Bat_discharging[i] =  // DH
        max(
          0,
          min(
            Bat_storage_level_MWh[i], Aux_elec_not_covered_by_plant[i],
            BESS_max_Charging_capacity * BESS_Charging_Efficiency))

      Elec_from_grid[i] =  // D
        max(
          0,
          min(
            Aux_elec_not_covered_by_plant[i] + Bat_charging[i]
              - Elec_avail_after_met_plant_heat_cons[i] - Bat_discharging[i],
            Grid_max_import))

      Aux_elec_missing_due_to_grid_limit[i] =  // DJ
        max(
          0,
          Aux_elec_not_covered_by_plant[i] + Bat_charging[i]
            - Elec_avail_after_met_plant_heat_cons[i] - Bat_discharging[i]
            - Grid_max_import)

      Elec_to_grid[i] =  // DK
        max(
          0,
          min(
            -(Aux_elec_not_covered_by_plant[i] + Bat_charging[i]
              - Elec_avail_after_met_plant_heat_cons[i] - Bat_discharging[i]),
            Grid_max_export))

      elec_dumped_due_to_grid_limit[i] =  // DL
        max(
          0,
          -(Aux_elec_not_covered_by_plant[i] + Bat_charging[i]
            - Elec_avail_after_met_plant_heat_cons[i] - Bat_discharging[i])
            - Grid_max_export)

      Q_Sol_and_aux_steam_dumped[i] =  // DM
        max(0, PB_and_SF_aux_heat_avail_after_met[i])
    }
    print(Q_solar_before_dumping.sum)
    print(PV_electrical_input_to_heater.sum)
    print(Q_Sol_and_aux_steam_dumped.sum)
    print(TES_thermal_input_by_CSP.sum)
  }
}

func main() {
  let calc = SunOl()
  /*
  calc.CSP_Loop_Nr = 115
  calc.PV_DC_Cap = 800
  calc.PV_AC_Cap = 600
  calc.Heater_cap = 220
  calc.TES_Full_Load_Hours = 13
  calc.EY_Nominal_elec_input = 180
  calc.PB_Nominal_Gross_Capacity = 100
  calc.BESS_Capacity = 40
  calc.H2_storage_cap = 40
  calc.Meth_nominal_hourly_prod_cap = 12
  calc.El_boiler_capacity = 60
  calc.Grid_max_export = 70
  */
  calc()

}

main()

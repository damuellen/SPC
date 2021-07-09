import BlackBoxModel
import Foundation
import PhysicalQuantities

class SunOl {
  let CSP_Loop_Nr = 113.0
  let PV_AC_Cap = 613.0
  let PV_DC_Cap = 818.0
  let Ref_PV_AC_capacity = 510.0
  let Ref_PV_DC_capacity = 683.4
  let Ref_meth_H2_consumption = 20000.0
  let Ref_meth_prod_capacity = 100_000.0
  let CSP_aux_elec_percentage = 0.0
  let Ratio_CSP_vs_Heater = 0.0
  let Heater_efficiency = 0.96
  let Meaux_elecnominal_heat_cons = 0.0
  let H2_storage_cap = 100.0
  let PB_min_op_hours = 0.0
  let PB_Nominal_Gross_Capacity = 250.0
  let PB_eff_at_min_Op = 0.0
  let PB_Ratio_Heat_input_vs_output = 0.0
  let PB_nominal_heat_input = 0.0
  let PB_Nominal_Gross_eff = 0.4713
  let PB_elec_cons_perc = 0.0
  let PB_aux_cons_perc = 0.0
  let PB_max_heat_input = 0.0
  let PB_min_heat_input = 0.0
  let PB_hot_start_heat_req = 0.0
  let PB_warm_start_heat_req = 0.0
  let PB_cold_start_heat_req = 0.0
  let PB_warm_start_duration = 0.0
  let PB_cold_start_duration = 0.0
  let PB_min_el_cap_perc = 0.0
  let PB_minimum_Gross_Capacity = 0.0
  let EY_ElectrEnergy_per_tH2 = 0.0
  let EY_min_elec_input = 0.0
  let EY_Nominal_aux_elec_input = 0.0
  let EY_Nominal_gross_elec_input = 0.0
  let EY_Nominal_elec_input = 0.0
  let EY_min_cap_rate = 0.0
  let EY_nominal_heat_input: Double = 0.0
  let El_boiler_efficiency = 0.0
  let El_boiler_capacity = 0.0
  let Heater_cap = 0.0
  let Ref_meaux_elecH2_consumption = 0.0
  let Meth_min_cap_perc = 0.5
  let Meth_max_H2_Cons = 0.0
  let Meth_min_H2_Cons = 0.0
  let Meth_nominal_aux_electr_cons = 0.0
  let Meth_nominal_heat_cons = 0.0
  let Meth_nominal_hourly_prod_cap = 14.8
  let Meaux_elecmin_cap_perc = 0.0
  let Meaux_elecnominal_elec_electr_cons = 0.0
  let Ref_Inv_eff_approx_handover = 0.0
  let TES_elec_elec_percentage = 0.0
  let Ref_Inv_eff_appRef_Inv_eff_approx_handoverrox_handover = 0.0
  let TES_Thermal_capacity = 0.0
  let TES_Aux_elec_percentage = 0.0
  let Grid_max_import = 70.0
  let Grid_max_export = 70.0
  let BESS_Capacity = 100.0
  let BESS_Charging_Efficiency = 0.7
  let BESS_max_Charging_capacity = 50.0

  let HL_C = Array([0.22, -0.36, 0.21, 1.00].reversed())
  let LL_C = Array(
    [-2.93E+07, 1.87E+07, -4.83E+06, 6.48E+05, -47182, 1730, -21, 1].reversed()
  )
  let th_C = Array([-1.53, 4.61, -5.27, 2.81, 0.37].reversed())
  let el_C = Array([-1.29, 3.80, -4.22, 2.20, 0.51].reversed())

  var Q_Sol_MW_thLoop = [Double]()
  var Reference_PV_plant_power_at_inverter_inlet_DC = [Double]()
  var Reference_PV_MV_power_at_transformer_outlet = [Double]()

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
    Q_solar_before_dumping.show(100)

    let Inverter_efficiency = indices.map {
      return iff(
        Reference_PV_MV_power_at_transformer_outlet[$0] < maximum,
        max(Reference_PV_MV_power_at_transformer_outlet[$0], 0)
          / Reference_PV_plant_power_at_inverter_inlet_DC[$0], 0)
    }

    let E_PV_Total_Scaled_DC = // J
      Reference_PV_plant_power_at_inverter_inlet_DC.map {
        $0 * PV_DC_Cap / Ref_PV_DC_capacity
      }

    let PV_MV_power_at_transformer_outlet: [Double] = indices.map { // K
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

    let pr_met_plant_operation = Array( // N
      repeating: Meth_min_cap_perc, count: indices.count)
    var pr_EY_Meth_heat_consumption = Array(
      repeating: 0.0, count: indices.count)

    for i in indices {
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
    }
    let pr_el_boiler_op_for_EY_Meth_heat: [Double] = indices.map {
      (i: Int) -> Double in  // P
      max(
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
    }

    let pr_EY_Meth_el_consumption: [Double] = indices.map {
      (i: Int) -> Double in  // Q
      return max(
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
    }

    let PV_electrical_input_to_heater: [Double] = indices.map { (i: Int) -> Double in  // R
      return max(
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
    }

    let TES_thermal_input_by_heater: [Double] =
      PV_electrical_input_to_heater.product(Heater_efficiency)  // S
    let TES_thermal_input_by_CSP: [Double] =
      TES_thermal_input_by_heater.quotient(Ratio_CSP_vs_Heater)  // T
    let TES_total_thermal_input = indices.map { (i: Int) -> Double in  // U
      TES_thermal_input_by_CSP[i] + TES_thermal_input_by_heater[i]
    }
    let Q_solar_avail: [Double] = indices.map { (i: Int) -> Double in  // V
      Q_solar_before_dumping[i] - TES_thermal_input_by_CSP[i]
    }
    let PV_elec_avail_after_eHeater: [Double] = indices.map { // W
      (i: Int) -> Double in
      max(
        0,
        PV_MV_power_at_transformer_outlet[i] - PV_electrical_input_to_heater[i]
      )
    }
    let TES_charging_aux_elec_consumption: [Double] = indices.map { // X
      (i: Int) -> Double in
      TES_total_thermal_input[i] * TES_Aux_elec_percentage
        + Aux_elec_for_CSP_SF_and_PV_Plant[i]
    }
    let SF_TES_chrg_PV_aux_cons_not_covered_by_PV: [Double] = indices.map { // Y
      (i: Int) -> Double in
      max(
        0,
        TES_charging_aux_elec_consumption[i] - PV_elec_avail_after_eHeater[i])
    }
    let SF_TES_chrg_PV_aux_cons_covered_by_PV: [Double] = indices.map { // Z
      (i: Int) -> Double in
      TES_charging_aux_elec_consumption[i]
        - SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
    }
    let PV_elec_avail_after_TES_charging: [Double] = indices.map { // AA
      (i: Int) -> Double in
      max(
        0,
        PV_elec_avail_after_eHeater[i]
          - SF_TES_chrg_PV_aux_cons_covered_by_PV[i])
    }
    let Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op: // AB
      [Double] = indices.map { (i: Int) -> Double in
        max(
          0,
          min(
            EY_Nominal_gross_elec_input + Meth_nominal_aux_electr_cons
              * pr_met_plant_operation[i]
              + SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
              + pr_el_boiler_op_for_EY_Meth_heat[i] / El_boiler_efficiency
              - PV_elec_avail_after_TES_charging[i],
            PB_Nominal_Gross_Capacity * (1 - PB_aux_cons_perc)))
      }
    /// Output sum
    let Steam_extraction_matching_max_net_elec_request: [Double] = indices.map // AC
    { (i: Int) -> Double in
      iff(
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
    }
    /* let min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions = indices.map { (i: Int) -> Double in // AD
      let x = EY_min_elec_input + pr_met_plant_operation[i] * Meth_nominal_aux_electr_cons + TES_charging_aux_elec_consumption[i]
      return x
        / (1 - PB_aux_cons_perc) / (PB_Nominal_Gross_eff * (el_C[4] * x
        / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 4 + el_C[3] * x
        / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 3 + el_C[2] * x
                                                                                                                                                                                                                            / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 2 + el_C[1] * ((EY_min_elec_input + pr_met_plant_operation[i] * Meth_nominal_aux_electr_cons + TES_charging_aux_elec_consumption[i])
        //FIXME                                                                                                                                                                                                                                                                                              / (1 - PB_aux_cons_perc) / PB_Nominal_Gross_Capacity) ** 1 + el_C[0])) * (1 + TES_Aux_elec_percentage / PB_eff_at_min_Op)
    }*/
    let min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions = [
      Double
    ]()
    let steam_extraction_matching_min_op_case = indices.map { // AE
      (i: Int) -> Double in
      iff(
        pr_EY_Meth_el_consumption[i] == 0,
        pr_met_plant_operation[i] * Meth_nominal_heat_cons + EY_min_cap_rate
          * EY_nominal_heat_input, 0)
    }
    let pr_PB_efficiency_excl_extraction_at_min_EY_and_pr_Meth = // AF
      min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions.map {
        $0 / PB_nominal_heat_input
      }
      .map { r in
        PB_Nominal_Gross_eff
          * (th_C[4] * r ** 4 + th_C[3] * r ** 3 + th_C[2] * r ** 2 + th_C[1]
            * r ** 1 + th_C[0])
      }

    var prev_PB_operation_mode = 0.0
    let PB_operation_mode = indices.map { (i: Int) -> Double in // AN
      /// moved
      prev_PB_operation_mode = iff(
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
              && prev_PB_operation_mode == 0, 1, prev_PB_operation_mode + 1)))
      return prev_PB_operation_mode
    }/*
    let PB_startup_heat_consumption_calculated = indices.map {
      (i: Int) -> Double in
      return iff(
        PB_operation_mode[i] < 1, 0,
        iff(
          PB_operation_mode[i] <= PB_warm_start_duration,
          PB_hot_start_heat_req,
          iff(
            PB_operation_mode[i] <= PB_cold_start_duration,
            PB_warm_start_heat_req, PB_cold_start_heat_req)), 0.0)
    }*/


    let PB_startup_heat_consumption_calculated = [
      Double
    ]()

    let PB_startup_heat_consumption_effective_MWth = indices.map { (i: Int) -> Double in // AP
      iff(PB_operation_mode[i] == -1,
      iff(PB_operation_mode[i] <= PB_warm_start_duration,
      PB_hot_start_heat_req,
      iff(PB_operation_mode[i] <= PB_cold_start_duration,
      PB_warm_start_heat_req,
      PB_cold_start_heat_req)),
      0)
    }

    let U3 = 0.0
    let Y3 = 0.0
    let Q3 = 0.0
    let N3 = 0.0
    let pr_PB_heat_input_based_on_avail_heat = [
      Double
    ]() /*
  let pr_PB_heat_input_based_on_avail_heat = indices.map { (i: Int) -> Double in // AG
    iff(
      (Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i]
        >= PB_minimum_Gross_Capacity * (1 - PB_aux_cons_perc))
        && (Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i] < PB_minimum_Gross_Capacity * (1 - PB_aux_cons_perc))
        && (pr_EY_Meth_el_consumption[i] > 0),
      iff(
        TES_storage_level[i] + U3 - PB_startup_heat_consumption_calculated[i]
          < PB_min_op_hours
          * (min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i]
            + PB_Ratio_Heat_input_vs_output * steam_extraction_matching_min_op_case[i]),
        0,
        min(
          PB_max_heat_input,
          max(
            (TES_storage_level[i] + U3
              - PB_startup_heat_consumption_calculated[i])
              / countiff(
                [PV_MV_power_at_transformer_outlet], { $0 < EY_min_elec_input }),
            min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i]
              + PB_Ratio_Heat_input_vs_output * [i]))),
      iff(
        Q3 > 0 && pr_EY_Meth_el_consumption[i] == 0
          && Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i]
            >= PB_minimum_Gross_Capacity * (1 - PB_aux_cons_perc),
        iff(
          TES_storage_level[i] + U3 - PB_startup_heat_consumption_calculated[i]
            - pr_PB_heat_input_based_on_avail_heat[i]
            < (PB_min_op_hours - 1)
              * (min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i] + PB_Ratio_Heat_input_vs_output
                * steam_extraction_matching_min_op_case[i]),
          0,
          min(
            PB_max_heat_input,
            max(
              (TES_storage_level[i] + U3
                - PB_startup_heat_consumption_calculated[i]
                - pr_PB_heat_input_based_on_avail_heat[i])
                / countiff(
                  [PV_MV_power_at_transformer_outlet], { $0 < EY_min_elec_input }
                ),
              min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i]
                + PB_Ratio_Heat_input_vs_output
                * steam_extraction_matching_min_op_case[i]))),
        iff(
          PV_elec_avail_after_TES_charging[i] > EY_Nominal_gross_elec_input
            + Meth_nominal_aux_electr_cons * pr_met_plant_operation[i]
            - PB_minimum_Gross_Capacity * (1 - PB_aux_cons_perc)
            || TES_storage_level[i] == 0
            || Max_net_elec_request_from_EY_Meth_aux_to_PB_after_pr_PV_EY_op[i]
              == 0,
          0,
          pr_PB_heat_input_based_on_avail_heat
            + iff(
              pr_PB_heat_input_based_on_avail_heat > 0,
              (SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i] - Y3)
                / pr_PB_efficiency_excl_extraction_at_min_EY_and_pr_Meth[i]
                + (Meth_nominal_heat_cons * PB_Ratio_Heat_input_vs_output
                  + Meth_nominal_aux_electr_cons
                  / pr_PB_efficiency_excl_extraction_at_min_EY_and_pr_Meth[i]
                  * (-N3 + pr_met_plant_operation[i]),
              0))))
  }*/
    let factor = indices.map { (i: Int) -> Double in
      ((pr_PB_heat_input_based_on_avail_heat[i] - PB_Ratio_Heat_input_vs_output
        * steam_extraction_matching_min_op_case[i]
        / (min_PB_heat_request_from_EY_Meth_aux_to_PB_without_extractions[i]
          + steam_extraction_matching_min_op_case[i])
        * pr_PB_heat_input_based_on_avail_heat[i]) / PB_nominal_heat_input)
    }
    let pr_PB_efficiency_excl_extraction_at_discharge_load = indices.map { // AH
      (i: Int) -> Double in
      iff(
        pr_PB_heat_input_based_on_avail_heat[i] == 0, 0,
        (th_C[4] * factor[i] ** 4 + th_C[3] * factor[i] ** 3 + th_C[2]
          * factor[i] ** 2 + th_C[1] * factor[i] ** 1 + th_C[0])
          * PB_Nominal_Gross_eff)
    }
    let pr_TES_discharging_aux_elec_consumption = // AI
      pr_PB_heat_input_based_on_avail_heat.map { $0 * TES_Aux_elec_percentage }

    let pr_Ey_op_by_PB: [Double] = indices.map { (i: Int) -> Double in // AJ
      iff(
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
    }
    let Check_calc_PB_heat_input_based_on_EY_operation: [Double] = indices.map // AK
    { (i: Int) -> Double in
      iff(
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
    }
    let pr_heat_request_for_aux_consumers_by_PB: [Double] = indices.map { // AL
      (i: Int) -> Double in
      max(
        0,
        iff(
          pr_Ey_op_by_PB[i] == 0
            || Check_calc_PB_heat_input_based_on_EY_operation[i] == 0, 0,
          pr_Ey_op_by_PB[i] / (EY_Nominal_gross_elec_input)
            * EY_nominal_heat_input
            + iff(
              pr_EY_Meth_el_consumption[i] > 0, 0,
              pr_met_plant_operation[i] * Meth_nominal_heat_cons)))
    }

    var prev_TES_storage_level = 0.0
    let TES_storage_level: [Double] = indices.map { (i: Int) -> Double in // AM
      prev_TES_storage_level = iff(
        prev_TES_storage_level + TES_total_thermal_input[i - 1]
          - TES_discharge_effective[i] - PB_startup_heat_consumption_effective[i]
          < 0.01, 0,
        prev_TES_storage_level + TES_total_thermal_input[i - 1]
          - TES_discharge_effective[i] - PB_startup_heat_consumption_effective[i])
      return prev_TES_storage_level
    }

    let PB_startup_heat_consumption_effective = indices.map { // AO
      (i: Int) -> Double in
      iff(
        PB_operation_mode[i] == -1,
        iff(
          PB_operation_mode[i] <= PB_warm_start_duration,
          PB_hot_start_heat_req,
          iff(
            PB_operation_mode[i] <= PB_cold_start_duration,
            PB_warm_start_heat_req, PB_cold_start_heat_req)), 0)
    }

    var prev_TES_discharge_effective = 0.0
    let TES_discharge_effective = indices.map { // AQ
      (i: Array<Double>.Index) -> Double in
      prev_TES_discharge_effective = iff(
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
          prev_TES_discharge_effective > 0
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
      return prev_TES_discharge_effective
    }

    let TES_discharging_aux_elec_consumption = TES_discharge_effective.product( // AR
      TES_Aux_elec_percentage)

    let Extracted_steam: [Double] = indices.map { (i: Int) -> Double in // AS
      max(
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
    }

    let Heat_avail_for_elec_generation: [Double] = indices.map { // AT
      (i: Int) -> Double in
      max(
        0,
        TES_discharge_effective[i] - Extracted_steam[i]
          * PB_Ratio_Heat_input_vs_output)
    }

    let Gross_elec_from_PB: [Double] = indices.map { (i: Int) -> Double in // AU
      let th = Heat_avail_for_elec_generation[i] / PB_nominal_heat_input
      return min(
        PB_Nominal_Gross_Capacity,
        Heat_avail_for_elec_generation[i]
          * ((th_C[4] * th ** 4 + th_C[3] * th ** 3 + th_C[2] * th ** 2
            + th_C[1] * th ** 1 + th_C[0]) * PB_Nominal_Gross_eff))
    }

    let PB_aux_consumption: [Double] = Gross_elec_from_PB.map { // AV
      $0 * PB_aux_cons_perc
    }

    let Pb_aux_consumption_not_covered_by_PB: [Double] = indices.map { // AW
      (i: Int) -> Double in
      max(0, PB_aux_consumption[i] - Gross_elec_from_PB[i])
    }

    let Aux_consumption_covered_by_PB: [Double] = indices.map { // AX
      (i: Int) -> Double in
      PB_aux_consumption[i] - Pb_aux_consumption_not_covered_by_PB[i]
    }

    let Net_elec_from_PB: [Double] = indices.map { (i: Int) -> Double in // AY
      Gross_elec_from_PB[i] - Aux_consumption_covered_by_PB[i]
    }

    let Total_net_elec_avail: [Double] = indices.map { (i: Int) -> Double in // AZ
      max(0, PV_elec_avail_after_TES_charging[i] + Net_elec_from_PB[i])
    }

    let Aux_cons_not_covered: [Double] = indices.map { (i: Int) -> Double in // BA
      max(
        0,
        SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
          + TES_discharging_aux_elec_consumption[i]
          + Pb_aux_consumption_not_covered_by_PB[i] - Total_net_elec_avail[i])
    }

    let TES_disch_Cons_covered: [Double] = indices.map { (i: Int) -> Double in // BB
      min(
        SF_TES_chrg_PV_aux_cons_not_covered_by_PV[i]
          + TES_discharging_aux_elec_consumption[i]
          + Pb_aux_consumption_not_covered_by_PB[i], Total_net_elec_avail[i])
    }
    let Aux_steam_provided_by_PB_and_SF: [Double] = indices.map { // BC
      (i: Int) -> Double in Extracted_steam[i] + Q_solar_avail[i]
    }

    let avail_total_net_elec: [Double] = indices.map { (i: Int) -> Double in // BD
      max(0, -TES_disch_Cons_covered[i] + Total_net_elec_avail[i])
    }

    let pr_min_meth_heat_consumption: [Double] = indices.map { // BE
      (i: Int) -> Double in Meth_nominal_heat_cons * pr_met_plant_operation[i]
    }

    let pr_meth_heat_consumption_not_covered_by_PB_SF: [Double] = indices.map { // BF
      (i: Int) -> Double in
      max(
        0, pr_min_meth_heat_consumption[i] - Aux_steam_provided_by_PB_and_SF[i]
      )
    }
    let pr_meth_heat_consumption_covered_by_PB_SF: [Double] = indices.map { // BG
      (i: Int) -> Double in
      pr_min_meth_heat_consumption[i]
        - pr_meth_heat_consumption_not_covered_by_PB_SF[i]
    }
    let pr_min_meth_elec_consumption: [Double] = indices.map { // BH
      (i: Int) -> Double in
      Meth_nominal_aux_electr_cons * pr_met_plant_operation[i]
    }
    let aux_cons_not_covered_by_PB_SF_incl: [Double] = indices.map { // BI
      (i: Int) -> Double in
      max(
        0,
        pr_min_meth_elec_consumption[i] + Aux_cons_not_covered[i]
          - avail_total_net_elec[i])
    }
    let pr_meth_elec_cons_covered_by_PB_SF: [Double] = indices.map { // BJ
      (i: Int) -> Double in
      min(
        pr_min_meth_elec_consumption[i] + Aux_cons_not_covered[i],
        avail_total_net_elec[i])
    }
    let pr_meth_heat_consumption_not_covered_by_aux_boiler: [Double] = // BK
      indices.map { (i: Int) -> Double in
        max(
          0,
          min(
            pr_meth_heat_consumption_not_covered_by_PB_SF[i]
              - El_boiler_capacity * El_boiler_efficiency,
            (avail_total_net_elec[i] + Grid_max_import
              - pr_meth_elec_cons_covered_by_PB_SF[i]
              - pr_meth_heat_consumption_not_covered_by_PB_SF[i]
              / El_boiler_efficiency) * El_boiler_efficiency))
      }
    let pr_meth_heat_consumption_covered_by_aux_boiler: [Double] = indices.map // BL
    { (i: Int) -> Double in
      pr_meth_heat_consumption_not_covered_by_PB_SF[i]
        - pr_meth_heat_consumption_not_covered_by_aux_boiler[i]
    }
    let aux_boiler_capacity_avail_after_pr_meth_cons: [Double] = indices.map { // BM
      (i: Int) -> Double in
      max(
        0,
        min(
          El_boiler_capacity * El_boiler_efficiency
            - pr_meth_heat_consumption_covered_by_aux_boiler[i],
          (avail_total_net_elec[i] + Grid_max_import
            - pr_meth_elec_cons_covered_by_PB_SF[i]
            - pr_meth_heat_consumption_covered_by_aux_boiler[i]
            / El_boiler_efficiency) * El_boiler_efficiency))
    }
    let Grid_capacity_avail_after_pr_meth: [Double] = indices.map { // BN
      (i: Int) -> Double in
      Grid_max_import
        - max(
          0,
          -(avail_total_net_elec[i] - pr_meth_elec_cons_covered_by_PB_SF[i]
            - pr_meth_heat_consumption_covered_by_aux_boiler[i]
            / El_boiler_efficiency))
    }
    let aux_steam_avail_after_pr_meth_cons: [Double] = indices.map { // BO
      (i: Int) -> Double in
      Aux_steam_provided_by_PB_and_SF[i]
        - pr_meth_heat_consumption_covered_by_PB_SF[i]
    }
    let total_net_elec_avail_after_pr_meth_cons: [Double] = indices.map { // BP
      (i: Int) -> Double in
      max(
        0,
        avail_total_net_elec[i] - pr_meth_elec_cons_covered_by_PB_SF[i]
          - pr_meth_heat_consumption_covered_by_aux_boiler[i]
          / El_boiler_efficiency)
    }
    let Total_steam_avail_for_EY_after_pr_meth_cons = indices.map { // BQ
      (i: Int) -> Double in
      iff(
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
    }

    let Gross_operating_point_of_EY: [Double] = indices.map { // BR
      (i: Int) -> Double in
      max(
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
    }
    // Output
    let EY_plant_start: [Double] = indices.map { (i: Int) -> Double in // BS
      iff(
        Gross_operating_point_of_EY[i] == 0
          && Gross_operating_point_of_EY[i] > 0, 1, 0)
    }

    let EY_aux_elec_cons: [Double] = indices.map { (i: Int) -> Double in // BT
      Gross_operating_point_of_EY[i] / EY_Nominal_gross_elec_input
        * EY_Nominal_aux_elec_input
    }

    let Net_elec_to_EY: [Double] = indices.map { (i: Int) -> Double in // BU
      Gross_operating_point_of_EY[i] - EY_aux_elec_cons[i]
    }
    let aux_elec_cons_not_covered: [Double] = indices.map { // BV
      (i: Int) -> Double in
      max(
        0,
        Gross_operating_point_of_EY[i] + Aux_cons_not_covered[i]
          - avail_total_net_elec[i])
    }
    let EY_aux_elec_cons_covered: [Double] = indices.map { // BW
      (i: Int) -> Double in
      min(
        Aux_cons_not_covered[i] + EY_aux_elec_cons[i],
        avail_total_net_elec[i] - Net_elec_to_EY[i])
    }
    let Elec_avail_after_EY_elec_cons: [Double] = indices.map { // BX
      (i: Int) -> Double in
      max(
        0,
        avail_total_net_elec[i] - EY_aux_elec_cons_covered[i]
          - Net_elec_to_EY[i])
    }
    let EY_aux_heat_cons: [Double] = indices.map { (i: Int) -> Double in // BY
      EY_nominal_heat_input * Net_elec_to_EY[i] / EY_Nominal_elec_input
    }
    let EY_aux_heat_cons_not_covered_by_PB_and_SF: [Double] = indices.map { // BZ
      (i: Int) -> Double in
      max(0, EY_aux_heat_cons[i] - Aux_steam_provided_by_PB_and_SF[i])
    }
    let EY_aux_heat_cons_covered_by_PB_and_SF: [Double] = indices.map { // CA
      (i: Int) -> Double in
      EY_aux_heat_cons[i] - EY_aux_heat_cons_not_covered_by_PB_and_SF[i]
    }
    let PB_and_SF_aux_heat_avail_after_EY: [Double] = indices.map { // CB
      (i: Int) -> Double in
      Aux_steam_provided_by_PB_and_SF[i]
        - EY_aux_heat_cons_covered_by_PB_and_SF[i]
    }
    let Elec_used_to_cover_EY_aux_heat: [Double] = indices.map { // CC
      (i: Int) -> Double in
      EY_aux_heat_cons_not_covered_by_PB_and_SF[i] / El_boiler_efficiency
    }
    let aux_electr_not_covered_by_plant: [Double] = indices.map { // CD
      (i: Int) -> Double in
      max(
        0,
        Elec_used_to_cover_EY_aux_heat[i] + aux_elec_cons_not_covered[i]
          - Elec_avail_after_EY_elec_cons[i])
    }
    let Elec_to_cover_EY_aux_heat_cons_covered_by_plant: [Double] = indices.map // CE
    { (i: Int) -> Double in
      min(
        Elec_used_to_cover_EY_aux_heat[i] + aux_elec_cons_not_covered[i],
        Elec_avail_after_EY_elec_cons[i])
    }
    // Output
    let aux_boiler_capacity_avail_after_EY: [Double] = indices.map { // CF
      (i: Int) -> Double in
      max(
        0,
        min(
          El_boiler_capacity * El_boiler_efficiency
            - EY_aux_heat_cons_not_covered_by_PB_and_SF[i],
          (Elec_avail_after_EY_elec_cons[i] + Grid_max_import
            - Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i])
            * El_boiler_efficiency))
    }
    
    let Grid_capacity_avail_after_EY: [Double] = indices.map { // CG
      (i: Int) -> Double in
      Grid_max_import
        - max(
          0,
          -(Elec_avail_after_EY_elec_cons[i]
            - Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i]))
    }
    let Elec_avail_after_total_EY: [Double] = indices.map { // CK
      (i: Int) -> Double in
      Elec_avail_after_EY_elec_cons[i]
        - Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i]
    }

    let Amount_of_H2_produced_MTPH: [Double] = indices.map { // CI
      (i: Int) -> Double in Net_elec_to_EY[i] / EY_ElectrEnergy_per_tH2
    }

    let prev_H2_storage_level_MT = 0.0
    let H2_storage_level_MT: [Double] = indices.map { (i: Int) -> Double in // CJ
      min(
        prev_H2_storage_level_MT + Amount_of_H2_produced_MTPH[i]
          - H2_to_met_production_effective_MTPH[i], H2_storage_cap)
    }
    let COUNT = 39

    var prev_H2_to_met_production_calculated_MTPH = 0.0
    let H2_to_met_production_calculated_MTPH: [Double] = indices.map { // CK
      (i: Int) -> Double in
      guard i > 0 else { return 0 }

      let count = countiff(Amount_of_H2_produced_MTPH[i...].prefix(17), { $0 < Meth_min_H2_Cons })

      prev_H2_to_met_production_calculated_MTPH =
      iff(Amount_of_H2_produced_MTPH[i-1] >= Meth_min_H2_Cons && Amount_of_H2_produced_MTPH[i] < Meth_min_H2_Cons,
        max(Meth_min_H2_Cons,
          min(
            (Amount_of_H2_produced_MTPH[i] + H2_storage_level_MT[i]) / count,
            H2_storage_level_MT[i] + sum(Amount_of_H2_produced_MTPH[i...].prefix(COUNT)) / Double(COUNT))
        ),
        iff(Amount_of_H2_produced_MTPH[i] >= Meth_min_H2_Cons, 0.0, prev_H2_to_met_production_calculated_MTPH)
      )
      return prev_H2_to_met_production_calculated_MTPH
    }
    let H2_to_met_production_effective_MTPH = [
      Double
    ]() /*
  let H2_to_met_production_effective_MTPH: [Double] = indices.map { (i: Int) -> Double in // CL
    max(
      0,
      min(
        (Elec_avail_after_total_EY[i] + PB_and_SF_aux_heat_avail_after_EY[i]
          / El_boiler_efficiency + Grid_capacity_avail_after_EY[i]
          - aux_electr_not_covered_by_plant)
          / (Meth_nominal_aux_electr_cons + Meth_nominal_heat_cons
            / El_boiler_efficiency) * Meth_max_H2_Cons,
        (aux_boiler_capacity_avail_after_EY
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
              (
                (H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i])
                  / countiff(Amount_of_H2_produced_MTPH[i...].prefix(16), { $0 == 0 })
                  * Meth_min_H2_Cons,
                iff(
                  H2_storage_level_MT[i] < 10 * Meth_min_H2_Cons,
                  average(Amount_of_H2_produced_MTPH[i...].prefix(16)), Meth_max_H2_Cons)
              ),
              ((H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH) / (
                countiff(
                  Amount_of_H2_produced_MTPH[i...].prefix(16), { $0 < Meth_min_H2_Cons }),
                average(Amount_of_H2_produced_MTPH[i...].prefix(16))
              )))))))
  }
  */
    let H2_dumping_MTPH: [Double] = indices.map { (i: Int) -> Double in // CM
      max(
        H2_storage_level_MT[i] + Amount_of_H2_produced_MTPH[i]
          - H2_to_met_production_effective_MTPH[i] - H2_storage_cap, 0)
    }

    let met_plant_start: [Double] = indices.map { (i: Int) -> Double in // CN
      iff(
        H2_to_met_production_effective_MTPH[i] == 0
          && H2_to_met_production_effective_MTPH[i] > 0, 1, 0)
    }

    let met_produced_MTPH: [Double] = H2_to_met_production_effective_MTPH.map { // CO
      $0 / Ref_meth_H2_consumption * Ref_meth_prod_capacity
    }

    let met_plant_aux_elec_cons: [Double] = met_produced_MTPH.map { // CP
      $0 / Meth_nominal_hourly_prod_cap * Meth_nominal_aux_electr_cons
    }

    let Aux_elec_not_covered_by_plant: [Double] = indices.map { // CQ
      (i: Int) -> Double in
      max(
        0,
        met_plant_aux_elec_cons[i] + aux_electr_not_covered_by_plant[i]
          - Elec_avail_after_total_EY[i])
    }

    let met_plant_aux_elec_covered_by_plant: [Double] = indices.map { // CR
      (i: Int) -> Double in
      min(
        met_plant_aux_elec_cons[i] + aux_electr_not_covered_by_plant[i],
        Elec_avail_after_total_EY[i])
    }

    let Elec_avail_after_met_plant_aux_elec: [Double] = indices.map { // CS
      (i: Int) -> Double in
      Elec_avail_after_total_EY[i] - met_plant_aux_elec_covered_by_plant[i]
    }

    let met_plant_heat_cons: [Double] = met_produced_MTPH.map { // CT
      $0 / Meth_nominal_hourly_prod_cap * Meth_nominal_heat_cons
    }

    let met_plant_heat_cons_not_covered_by_heat_from_PB_and_SF = indices.map { // CU
      (i: Int) -> Double in
      max(0, met_plant_heat_cons[i] - PB_and_SF_aux_heat_avail_after_EY[i])
    }

    let met_plant_heat_cons_covered_by_heat_from_PB_and_SF = indices.map { // CV
      (i: Int) -> Double in
      min(met_plant_heat_cons[i], PB_and_SF_aux_heat_avail_after_EY[i])
    }

    let PB_and_SF_aux_heat_avail_after_met: [Double] = indices.map { // CW
      (i: Int) -> Double in
      PB_and_SF_aux_heat_avail_after_EY[i]
        - met_plant_heat_cons_covered_by_heat_from_PB_and_SF[i]
    }

    let Elec_needed_for_not_yet_covered_met_plant_aux_heat = // CX
      met_plant_heat_cons_not_covered_by_heat_from_PB_and_SF.quotient(El_boiler_efficiency)

    let Aux_elec_not_covered_by_plant2: [Double] = indices.map { // CY
      (i: Int) -> Double in
      max(
        0,
        Elec_needed_for_not_yet_covered_met_plant_aux_heat[i] + aux_electr_not_covered_by_plant[i]
          - Elec_avail_after_met_plant_aux_elec[i])
    }

/*
    var prev_Aux_elec_not_covered_by_plant = 0.0
    let Aux_elec_not_covered_by_plant2: [Double] = indices.map { // CY
      (i: Int) -> Double in
      prev_Aux_elec_not_covered_by_plant = max(
        0,
        Elec_needed_for_not_yet_covered_met_plant_aux_heat[i]
          + prev_Aux_elec_not_covered_by_plant
          - Elec_avail_after_met_plant_aux_elec[i])
      return prev_Aux_elec_not_covered_by_plant
    }
*/
    let Elec_to_cover_addtl_meth_aux_heat_cov_by_plant: [Double] = indices.map  // CZ
    { (i: Int) -> Double in
      min(
        Elec_needed_for_not_yet_covered_met_plant_aux_heat[i]
          + Aux_elec_not_covered_by_plant[i],
        Elec_avail_after_met_plant_aux_elec[i])
    }

    let Elec_avail_after_met_plant_heat_cons: [Double] = indices.map { // DA
      (i: Int) -> Double in
      Elec_avail_after_met_plant_aux_elec[i]
        - Elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i]
    }
    let Total_elec_used_to_produce_aux_steam: [Double] = indices.map { // DB
      (i: Int) -> Double in
      Elec_used_to_cover_EY_aux_heat[i]
        + Elec_needed_for_not_yet_covered_met_plant_aux_heat[i]
    }

    let Aux_steam_missing_due_to_aux_boiler_capacity_limit: [Double] = // DC
      indices.map { (i: Int) -> Double in
        max(0, Total_elec_used_to_produce_aux_steam[i] - El_boiler_capacity)
          * El_boiler_efficiency
      }

    let Total_aux_elec_demand: [Double] = indices.map { (i: Int) -> Double in // DD
      Elec_needed_for_not_yet_covered_met_plant_aux_heat[i]
        + met_plant_aux_elec_cons[i] + Elec_used_to_cover_EY_aux_heat[i]
        + EY_aux_elec_cons[i] + PB_aux_consumption[i]
        + TES_discharging_aux_elec_consumption[i]
        + TES_charging_aux_elec_consumption[i]
    }

    let Total_aux_elec_demand_covered: [Double] = indices.map { // DE
      (i: Int) -> Double in
      Elec_to_cover_addtl_meth_aux_heat_cov_by_plant[i]
        + met_plant_aux_elec_covered_by_plant[i]
        + Elec_to_cover_EY_aux_heat_cons_covered_by_plant[i]
        + EY_aux_elec_cons_covered[i] + Aux_consumption_covered_by_PB[i]
        + TES_disch_Cons_covered[i] + SF_TES_chrg_PV_aux_cons_covered_by_PV[i]
    }

    let Bat_charging: [Double] = indices.map { (i: Int) -> Double in // DF
      max(
        0,
        min(
          (BESS_Capacity - Bat_storage_level_MWh[i])
            / BESS_Charging_Efficiency,
          Elec_avail_after_met_plant_heat_cons[i], BESS_max_Charging_capacity))
    }

    var prev_Bat_storage_level_MWh = 0.0
    let Bat_storage_level_MWh: [Double] = indices.map { (i: Int) -> Double in //DG
      prev_Bat_storage_level_MWh = max(
        0,
        min(
          BESS_Capacity,
          prev_Bat_storage_level_MWh + Bat_charging[i]
            * BESS_Charging_Efficiency - Bat_discharging[i]))
      return prev_Bat_storage_level_MWh
    }

    let Bat_discharging: [Double] = indices.map { (i: Int) -> Double in // DH
      max(
        0,
        min(
          Bat_storage_level_MWh[i], Aux_elec_not_covered_by_plant[i],
          BESS_max_Charging_capacity * BESS_Charging_Efficiency))
    }

    let Elec_from_grid: [Double] = indices.map { (i: Int) -> Double in // D
      max(
        0,
        min(
          Aux_elec_not_covered_by_plant[i] + Bat_charging[i]
            - Elec_avail_after_met_plant_heat_cons[i] - Bat_discharging[i],
          Grid_max_import))
    }

    let Aux_elec_missing_due_to_grid_limit: [Double] = indices.map { // DJ
      (i: Int) -> Double in
      max(
        0,
        Aux_elec_not_covered_by_plant[i] + Bat_charging[i]
          - Elec_avail_after_met_plant_heat_cons[i] - Bat_discharging[i]
          - Grid_max_import)
    }

    let Elec_to_grid: [Double] = indices.map { (i: Int) -> Double in // DK
      max(
        0,
        min(
          -(Aux_elec_not_covered_by_plant[i] + Bat_charging[i]
            - Elec_avail_after_met_plant_heat_cons[i] - Bat_discharging[i]),
          Grid_max_export))
    }

    let elec_dumped_due_to_grid_limit: [Double] = indices.map { // DL
      (i: Int) -> Double in
      max(
        0,
        -(Aux_elec_not_covered_by_plant[i] + Bat_charging[i]
          - Elec_avail_after_met_plant_heat_cons[i] - Bat_discharging[i])
          - Grid_max_export)
    }

    let Q_Sol_and_aux_steam_dumped: [Double] = indices.map { // DM
      (i: Int) -> Double in max(0, PB_and_SF_aux_heat_avail_after_met[i])
    }
  }
}

func main() {
  let calc = SunOl()
  calc()
}

main()

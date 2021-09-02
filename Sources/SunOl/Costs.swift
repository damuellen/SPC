struct SpecificCost {

  let Solar_field = (basis: 38.0, c1: 1_581_220.0, exp: 0.8, f: 0.71, coeff: 18_000_000.0, range: 19.0...130.0)
  let Assembly_hall_1_line = (c1: 12_000_000.0, c2: 3_300_000.0, range: 19.0...60.0)
  let Assembly_hall_2_lines = (c1: 12_000_000.0, c2: 5_940_000.0, range: 61.0...130.0)
  let PV_DC_part = (basis: 605.0, coeff: 465.124)
  let PV_AC_part = (basis: 490.0, exp: 0.7, coeff: 64_150.0, range: 267...778)
  let Heater_system = (basis: 200.0, c1: 4_000_000.0, exp: 0.4, c2: 211_729.0, factor: 0.9, coeff: 3_500_000.0, range: 200.0...400.0)
  let Thermal_energy_storage = (basis: 26920.0, c1: 2_000_000.0, exp: 0.75, c2: 1908.888181, factor: 0.55, coeff: 26_000_000.0)
  let Electrolysis_coeff = 840.000
  let Hydrogen_storage = (basis: 60.0, coeff: 936_000.0)
  let Methanol_plant_coeff = 5_865_366.0
  let Power_Block = (basis: 50.0, c1: 84_370_000.0, coeff: 466_229.0, range: 50.0...200.0)
  let Battery_energy_storage = (basis: 50.0, c1: 5_317_746.0, coeff: 319_065.0)
  let Electrical_boiler_capacity = (basis: 3.27, exp: 0.7, coeff: 262_862.0)
  let Substation_capacity = (basis: 135.0, exp: 0.7, coeff: 17_778.0)

  func invest(config: SunOl) -> (LCH2: Double, LCoM: Double, LCoE: Double, LCoTh: Double) {
    let auxLoops =
      ((Double(config.Q_solar_avail_sum) - Double(config.Q_Sol_aux_steam_dumped_sum)) 
      + (Double(config.extracted_steam_sum) * config.PB_Ratio_Heat_input_vs_output))
      / Double(config.Q_solar_before_dumping_sum) * config.CSP_Loop_Nr

    let Assembly_hall = iff(
      config.CSP_Loop_Nr <= Solar_field.range.upperBound, Assembly_hall_1_line.c1 + Assembly_hall_1_line.c2,
      Assembly_hall_2_lines.c1 + Assembly_hall_2_lines.c2)

    let CSP_SF_cost_dedicated_to_ICPH =
      Solar_field.coeff * ((config.CSP_Loop_Nr - auxLoops) / Solar_field.basis) ** Solar_field.exp + Solar_field.c1 * Solar_field.f
      * (config.CSP_Loop_Nr - auxLoops)
    let CSP_SF_cost_dedicated_to_aux_heat =
      Solar_field.coeff * (auxLoops / Solar_field.basis) ** Solar_field.f + Solar_field.c1 * Solar_field.f * auxLoops
    let PV_DC_Cost = config.PV_DC_Cap * PV_DC_part.coeff + 0.0
    let PV_AC_Cost = (config.PV_AC_Cap / PV_AC_part.basis) ** PV_AC_part.exp * PV_AC_part.basis * PV_AC_part.coeff + 0.0

    let Heater_Cost =
      Heater_system.exp + Heater_system.coeff * (config.Heater_cap / Heater_system.basis) ** Heater_system.exp + config.Heater_cap
      * Heater_system.factor * Heater_system.c2

    let TES_Storage_cost =
      Thermal_energy_storage.c1 + Thermal_energy_storage.coeff * (config.TES_salt_mass / Thermal_energy_storage.basis) ** Thermal_energy_storage.exp
      + config.TES_salt_mass * Thermal_energy_storage.c2 * Thermal_energy_storage.factor

    let Electrolysis_Cost = config.EY_Nominal_elec_input * Electrolysis_coeff + 0.0
    let PB_Cost = Power_Block.c1 + (config.PB_Nominal_Gross_cap - Power_Block.basis) * Power_Block.coeff
    let Battery_storage_cost = config.BESS_cap * Battery_energy_storage.coeff + Battery_energy_storage.c1
    let Hydrogen_Storage_cost = config.H2_storage_cap * Hydrogen_storage.coeff + 0.0
    let Methanol_plant_cost = config.Meth_nominal_hourly_prod_cap * Methanol_plant_coeff + 0.0

    let Electrical_boiler_cost =
      Electrical_boiler_capacity.coeff * Electrical_boiler_capacity.basis * (config.El_boiler_cap / Electrical_boiler_capacity.basis)
      ** Electrical_boiler_capacity.exp

    let Substation_cost =
      Substation_capacity.coeff * Substation_capacity.basis * (config.Grid_max_export / Substation_capacity.basis) ** Substation_capacity.exp

    let CSP_O_M_Cost = (11.3333 / 3 * 1 / 3 * 1000 * 1000) + (0.00606061 / 3 * 1 / 3 * 1000 * 1000) * config.CSP_Loop_Nr
    let PV_O_M_Cost = (11.3333 * 1000 * 1000) + 0 * config.PV_DC_Cap
    let PB_O_M_Cost = (11.3333 / 3 * 2 / 3 * 1000 * 1000) + (0.00606061 / 3 * 2 / 3 * 1000 * 1000) * config.PB_Nominal_Gross_cap

    let CAPEX_ICPH_assembly_hall_csp_sf_dedicated_to_ICPH_PC_DC_PV_AC_Heaters_TES_PB_Substation =
      Assembly_hall + CSP_SF_cost_dedicated_to_ICPH + PV_DC_Cost + PV_AC_Cost + Heater_Cost + TES_Storage_cost + PB_Cost + Substation_cost

    let CAPEX_aux_thermal_energy_csp_sf_cost_dedicated_to_aux_heat = CSP_SF_cost_dedicated_to_aux_heat

    let CAPEX_Hydrogen_ICPH_half_of_loops_dedicated_to_aux_heat_electrolysis_half_of_electrical_boiler_cost =
      Assembly_hall + CSP_SF_cost_dedicated_to_ICPH + (CSP_SF_cost_dedicated_to_aux_heat / 2) + PV_DC_Cost + PV_AC_Cost + Heater_Cost
      + TES_Storage_cost + PB_Cost + (Electrical_boiler_cost / 2) + Substation_cost + Electrolysis_Cost

    let Total_CAPEX =
      Assembly_hall + CSP_SF_cost_dedicated_to_ICPH + CSP_SF_cost_dedicated_to_aux_heat + PV_DC_Cost + PV_AC_Cost + Heater_Cost + TES_Storage_cost
      + Electrolysis_Cost + PB_Cost + Battery_storage_cost + Hydrogen_Storage_cost + Methanol_plant_cost + Electrical_boiler_cost + Substation_cost
    let Total_OPEX = CSP_O_M_Cost + PV_O_M_Cost + PB_O_M_Cost

    let Y = 25.0
    let R = 0.07
    let FCR = R * (1 + R) ** Y / ((1 + R) ** Y - 1)
    let BUY = 2 * 0.091
    let SELL = 0.33 * 0.091

    let LCH2 =
      (FCR * CAPEX_Hydrogen_ICPH_half_of_loops_dedicated_to_aux_heat_electrolysis_half_of_electrical_boiler_cost + Total_OPEX
        + Double(config.Elec_from_grid_sum) * BUY * 1000 - Double(config.Elec_to_grid_sum) * SELL * 1000) / Double(config.H2_to_meth_production_effective_MTPH_sum)
        
    let LCoM =
      (FCR * Total_CAPEX + Total_OPEX + Double(config.Elec_from_grid_sum) * BUY * 1000 - Double(config.Elec_to_grid_sum) * SELL * 1000)
      / Double(config.meth_produced_MTPH_sum)

    let LCoE =
      (FCR * CAPEX_ICPH_assembly_hall_csp_sf_dedicated_to_ICPH_PC_DC_PV_AC_Heaters_TES_PB_Substation + Total_OPEX) / Double(config.avail_total_net_elec_sum)

    let LCoTh =
      (FCR * CAPEX_aux_thermal_energy_csp_sf_cost_dedicated_to_aux_heat) / Double(config.EY_aux_heat_cons_covered_by_PB_SF_sum)
      + Double(config.meth_plant_heat_cons_covered_by_heat_from_PB_SF_sum)

    return (LCH2, LCoM, LCoE, LCoTh)
  }
}

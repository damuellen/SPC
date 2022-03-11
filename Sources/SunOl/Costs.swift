import Helpers

public struct Costs {
  // static let AdditionalCostPerLoop = 762533.1364

  static let Plant_life = 25.0
  static let Rate_of_return = 0.07
  static let FCR = Rate_of_return * (1 + Rate_of_return) ** Plant_life / ((1 + Rate_of_return) ** Plant_life - 1)
  static let Elec_buy = 2 * 0.091
  static let Elec_sell = 0.33 * 0.091

  public init(_ model: TunOl)
   {
     let FX_USD = 0.82
     let Hydrogen_density = 5.783
     let CO2_density = 945.0
     let RawMeth_density = 782.0
 
     let Solar_field = (basis: 38.0, c1: 1_581_220.0, exp: 0.8, f: 0.71, coeff: 18_000_000.0, range: 19.0...130.0)
     let Assembly_hall = (c4: -0.037401977, c3: 23.83076428, c2: -5296.963373, c1: 518074.8094, c0: 185180.2005, range: 1.0...270.0)
     let PV_DC_part = (basis: 605.0, coeff: 465_124.0)
     let PV_AC_part = (basis: 490.0, exp: 0.7, coeff: 64_150.0, range: 267...778)
     let Heater_system = (basis: 200.0, c1: 4_000_000.0, exp: 0.4, c2: 211728.735839637, factor: 0.9, coeff: 3_500_000.0, range: 200.0...400.0)
     let Thermal_energy_storage = (basis: 26920.0, c1: 2_000_000.0, exp: 0.75, c2: 1908.888181, factor: 0.55, coeff: 26_000_000.0)
     let Power_Block = (basis: 50.0, c1: 84_370_000.0, coeff: 466_229.0, range: 50.0...200.0)
     let Electrolysis_coeff = 700_000.0 * 1.2
     let Hydrogen_storage = (basis: 24E-2 * Hydrogen_density, exp: 0.9, coeff: 780_000 * 1.2)
     let CCU_plant = (basis: 20.6, exp: 0.7, coeff: 15_000_000.0 / FX_USD)
     let CO2_storage = (basis: 24E-2 * CO2_density, exp: 0.9, coeff: 780_000.0)
     let MethSynt_plant = (basis: 19.5, exp: 0.7, coeff: 60_000_000.0 / FX_USD * 0.4)
     let RawMeth_storage = (basis: 24E-2 * RawMeth_density, exp: 0.9, coeff: 694146.8625 / FX_USD)
     let MethDist_plant = (basis: 12.5, exp: 0.7, coeff: 60_000_000.0 / FX_USD * 0.6)
     let Battery_energy_storage = (basis: 50.0, c1: 5_317_746.0, coeff: 319_065.0)
     let Electrical_boiler = (basis: 3.27, exp: 0.7, coeff: 494000 * 1.45 * 1.2)
     let Substation = (basis: 135.0, exp: 0.7, coeff: 2_400_000.0)

    // let factor = min(Heat_to_aux_directly_from_CSP_sum + Heat_to_aux_from_PB_sum * model.PB_Ratio_Heat_input_vs_output,
    //  Q_solar_before_dumping_sum - Total_SF_heat_dumped_sum - TES_thermal_input_by_CSP_sum)

    // var auxLoops = model.CSP_loop_nr_ud > 0 ?
    //  min(model.CSP_loop_nr_ud, Double(model.CSP_loop_nr_ud * factor / Q_solar_before_dumping_sum)) : 0
    // if (auxLoops <= 0 || factor <= 0) {
    //   auxLoops = 0
    // }
    let Assembly_hall_cost = model.CSP_loop_nr_ud > 0 ? Assembly_hall.c4 * Double(model.CSP_loop_nr_ud) ** 4 + Assembly_hall.c3 * Double(model.CSP_loop_nr_ud) ** 3
      + Assembly_hall.c2 * Double(model.CSP_loop_nr_ud) ** 2 + Assembly_hall.c1 * Double(model.CSP_loop_nr_ud) ** 1 + Assembly_hall.c0 : 0
    // let CSP_SF_cost_dedicated_to_ICPH =
    //   Solar_field.coeff * ((model.CSP_loop_nr_ud - auxLoops) / Solar_field.basis) ** Solar_field.exp + Solar_field.c1 * Solar_field.f
    //   * (model.CSP_loop_nr_ud - auxLoops)

    // var aux_Heat_ratio = Double(meth_plant_heatConsumption_sum / (meth_plant_heatConsumption_sum + EY_aux_heatConsumption_sum))
    // if aux_Heat_ratio.isNaN { aux_Heat_ratio = 0 }
    // let CSP_SF_cost_dedicated_to_Hydrogen = Solar_field.coeff * ((model.CSP_loop_nr_ud - auxLoops * aux_Heat_ratio) / Solar_field.basis) ** Solar_field.exp + Solar_field.c1 * Solar_field.f
    //   * (model.CSP_loop_nr_ud - auxLoops * aux_Heat_ratio)
    
    let CSP_SF_cost_dedicated_to_Methanol = Solar_field.coeff * (model.CSP_loop_nr_ud / Solar_field.basis) ** Solar_field.exp + Solar_field.c1 * Solar_field.f
      * model.CSP_loop_nr_ud
    // let CSP_SF_cost_dedicated_to_aux_heat = AdditionalCostPerLoop * auxLoops

    let PV_DC_cost = model.PV_DC_cap_ud * PV_DC_part.coeff + 0.0
    let PV_AC_cost = (model.PV_AC_cap_ud / PV_AC_part.basis) ** PV_AC_part.exp * PV_AC_part.basis * PV_AC_part.coeff + 0.0

    let Heater_cost = model.Heater_cap_ud > 0 ?
      (Heater_system.c1 + Heater_system.coeff * (model.Heater_cap_ud / Heater_system.basis) ** Heater_system.exp + model.Heater_cap_ud
      * Heater_system.factor * Heater_system.c2) : 0

    var TES_storage_cost =
      Thermal_energy_storage.c1 + Thermal_energy_storage.coeff * (model.TES_salt_mass / Thermal_energy_storage.basis) ** Thermal_energy_storage.exp
      + model.TES_salt_mass * Thermal_energy_storage.c2 * Thermal_energy_storage.factor
    if TES_storage_cost.isNaN { TES_storage_cost = 0 }
    
    let PB_cost = model.PB_nom_gross_cap_ud > 0 ? (Power_Block.c1 + (model.PB_nom_gross_cap_ud - Power_Block.basis) * Power_Block.coeff) : 0

    let Electrolysis_cost = model.EY_var_net_nom_cons_ud * Electrolysis_coeff + 0.0

    let Hydrogen_storage_cost = Hydrogen_storage.coeff * ((model.Hydrogen_storage_cap_ud / Hydrogen_storage.basis) ** Hydrogen_storage.exp) + 0.0

    let CCU_plant_cost = CCU_plant.coeff * (model.CCU_C_O_2_nom_prod_ud / CCU_plant.basis) ** CCU_plant.exp + 0.0

    let CO2_storage_cost = CO2_storage.coeff * (model.C_O_2_storage_cap_ud / CO2_storage.basis) ** CO2_storage.exp + 0.0

    let MethSynt_plant_cost = MethSynt_plant.coeff * ((model.MethSynt_RawMeth_nom_prod_ud / MethSynt_plant.basis) ** MethSynt_plant.exp) + 0.0

    let RawMeth_storage_cost = RawMeth_storage.coeff * ((model.RawMeth_storage_cap_ud / RawMeth_storage.basis) ** RawMeth_storage.exp) + 0.0

    let MethDist_plant_cost = MethDist_plant.coeff * ((model.MethDist_Meth_nom_prod_ud / MethDist_plant.basis) ** MethDist_plant.exp) + 0.0

    let Battery_storage_cost = model.BESS_cap_ud * Battery_energy_storage.coeff + (model.BESS_cap_ud > 0 ? Battery_energy_storage.c1 : 0)

    let Electrical_boiler_cost = model.El_boiler_cap_ud > 0 ?
      (Electrical_boiler.coeff * (model.El_boiler_cap_ud / Electrical_boiler.basis) ** Electrical_boiler.exp) : 0

    // let Substation_cost_ICPH =
      // Substation_capacity.coeff * Substation_capacity.basis * ((model.Heater_cap_ud + model.EY_var_net_nom_cons_ud  + model.EY_aux_elec_input + model.Meth_nominal_aux_electr_cons) / Substation_capacity.basis) ** Substation_capacity.exp

    let Substation_cost =
      Substation.coeff * (max(model.Grid_export_max_ud, model.Grid_import_max_ud) / Substation.basis) ** Substation.exp

    let CSP_O_M_Cost = (11.3333 / 3 * 1 / 3 * 1000 * 1000) + (0.00606061 / 3 * 1 / 3 * 1000 * 1000) * model.CSP_loop_nr_ud
    let PV_O_M_Cost = (11.3333 * 1000 * 1000) + (0.00606061 / 100 * 1000 * 1000) * model.PV_DC_cap_ud
    let PB_O_M_Cost = (11.3333 / 3 * 2 / 3 * 1000 * 1000) + (0.00606061 / 3 * 2 / 3 * 1000 * 1000) * model.PB_nom_gross_cap_ud

    // let CAPEX_ICPH_assembly_hall_csp_sf_dedicated_to_ICPH_PC_DC_PV_AC_Heaters_TES_PB_Substation =
      // Assembly_hall + CSP_SF_cost_dedicated_to_ICPH + PV_DC_Cost + PV_AC_Cost + Heater_Cost + TES_Storage_cost + PB_Cost + Substation_cost_ICPH

    // let CAPEX_aux_thermal_energy_csp_sf_cost_dedicated_to_aux_heat = CSP_SF_cost_dedicated_to_aux_heat

    // let CAPEX_Hydrogen_ICPH_half_of_loops_dedicated_to_aux_heat_electrolysis_half_of_electrical_boiler_cost =
    //  Assembly_hall + CSP_SF_cost_dedicated_to_Hydrogen + PV_DC_Cost + PV_AC_Cost + Heater_Cost
    //  + TES_Storage_cost + PB_Cost + (Electrical_boiler_cost * aux_Heat_ratio) + Substation_cost + Electrolysis_Cost

    self.Total_CAPEX =
      Assembly_hall_cost + CSP_SF_cost_dedicated_to_Methanol + PV_DC_cost + PV_AC_cost + Heater_cost + TES_storage_cost + PB_cost + Electrolysis_cost + Hydrogen_storage_cost
      + CCU_plant_cost + CO2_storage_cost + MethSynt_plant_cost + RawMeth_storage_cost + MethDist_plant_cost + Battery_storage_cost + Electrical_boiler_cost + Substation_cost

    self.Total_OPEX = CSP_O_M_Cost + PV_O_M_Cost + PB_O_M_Cost
  }
  
  var Total_CAPEX: Double
  var Total_OPEX: Double

  public func LCOM(meth_produced_MTPH: Double, elec_from_grid: Double, elec_to_grid: Double) -> Double {
    let lcom = ((Costs.FCR * Total_CAPEX + Total_OPEX) / 365 + elec_from_grid * Costs.Elec_buy * 1000 - elec_to_grid * Costs.Elec_sell * 1000) / meth_produced_MTPH
    return lcom
  }
}


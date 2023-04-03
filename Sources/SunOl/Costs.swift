import Helpers

public struct Costs {
  // static let AdditionalCostPerLoop = 762533.1364

  static let Plant_life: Double = 25.0
  static let Rate_of_return: Double = 0.03 * 0.7 + 0.13 * 0.3
  static let FCR: Double = Rate_of_return * (1 + Rate_of_return) ** Plant_life / ((1 + Rate_of_return) ** Plant_life - 1)
  static let Elec_buy: Double = 2 * 0.098
  static let Elec_sell: Double = 0.33 * 0.098

  public init(_ model: TunOl) {
    let FX_USD = 1 / 0.92 // 0.82
    let Hydrogen_density = 5.783
    //  let CO2_density = 945.0
    //  let RawMeth_density = 782.0

    let Solar_field = (basis: 38.0, c1: 15000000.0, c2: 2353102.66816456, exp: 0.85, factor: 0.72, coeff: 25000000.0, range: 19.0...130.0)
    let Assembly_hall = (c1: 87819.8346218374, c0: 4149722.41758168)
    let PV_DC_part = (basis: 0, coeff: 802184.207438602)
    let PV_AC_part = (basis: 0, coeff: 134233.234759846)
    let Heater_system = (basis: 200.0, c1: 7000000.0, exp: 0.45, c2: 309140.303724601, factor: 0.9, coeff: 3600000.0, range: 200.0...400.0)
    let Thermal_energy_storage = (basis: 26920.0, c1: 114793692.328915, c2: 4029.33117346384, factor: 0.95)
    let Power_Block = (basis: 50.0, c1: 55_000_000.0, exp: 0.735, coeff: 41_000_000.0)
    let Electrolysis_coeff = 700000 * 1.2 * 0 + (0.87 + 1.15) * 1_000_000 / FX_USD * (model.EY_Ref_var_net_nom_cons + model.EY_Ref_var_nom_cons) / model.EY_Ref_var_net_nom_cons
    let Hydrogen_storage = (basis: 24E-2 * Hydrogen_density, exp: 0.9, coeff: 780_000 * 1.2 * 0)
    let CCU_plant = (basis: 22.890276, exp: 0.7, coeff: 18_292_682.9268293 * 0)
    let CO2_storage = (basis: 226.8, exp: 0.9, coeff: 780_000.0 * 0)
    let MethSynt_plant = (basis: 19.0665095748076, exp: 0.7, coeff: 29_268_292.6829268 * 0)
    let RawMeth_storage = (basis: 1.87680000000000E+02, exp: 0.9, coeff: (694146.8625 / FX_USD) * 0)
    let MethDist_plant = (exp: 0, coeff: 0.36*1000000*(model.EY_Ref_var_net_nom_cons+model.EY_Ref_var_nom_cons)/model.MethDist_Ref_meth_hour_prod / FX_USD)
    let Battery_energy_storage = (basis: 0.0, coeff: 501579.333846229)
    let Electrical_boiler = (basis: 3.27, exp: 0.7, coeff: 494000 * 1.45 * 1.2)
    let Substation = (basis: 135.0, exp: 0.7, coeff: 2.4E+06)
    
    if model.CSP_loop_nr_ud.isZero {
      self.Assembly_hall_cost = 0
      self.CSP_SF_cost_dedicated_to_Methanol = 0
    } else { 
      self.Assembly_hall_cost = Assembly_hall.c1 * Double(model.CSP_loop_nr_ud.rounded(.up)) + Assembly_hall.c0
      self.CSP_SF_cost_dedicated_to_Methanol = Solar_field.c1 + Solar_field.coeff * (model.CSP_loop_nr_ud.rounded(.up) / Solar_field.basis) ** Solar_field.exp + Solar_field.c2 * Solar_field.factor
      * model.CSP_loop_nr_ud.rounded(.up)
    }
    // let CSP_SF_cost_dedicated_to_aux_heat = AdditionalCostPerLoop * auxLoops

    self.PV_DC_cost = model.PV_DC_cap_ud * PV_DC_part.coeff
    self.PV_AC_cost = model.PV_AC_cap_ud * PV_AC_part.coeff

    self.Heater_cost =
      model.Heater_cap_ud > Double.zero
      ? (Heater_system.c1 + Heater_system.coeff * (model.Heater_cap_ud / Heater_system.basis) ** Heater_system.exp + model.Heater_cap_ud * Heater_system.factor * Heater_system.c2)
      : Double.zero

    self.TES_storage_cost = Thermal_energy_storage.c1 + (model.TES_salt_mass - Thermal_energy_storage.basis) * Thermal_energy_storage.c2 * Thermal_energy_storage.factor
    if model.TES_salt_mass.isZero { TES_storage_cost = 0 }
    self.PB_cost = model.PB_nom_gross_cap_ud > Double.zero 
      ? Power_Block.c1 + Power_Block.coeff * (model.PB_nom_gross_cap_ud / Power_Block.basis) ** Power_Block.exp
      : Double.zero

    self.Electrolysis_cost = model.EY_var_net_nom_cons_ud * Electrolysis_coeff

    self.Hydrogen_storage_cost = Hydrogen_storage.coeff * ((model.Hydrogen_storage_cap_ud / Hydrogen_storage.basis) ** Hydrogen_storage.exp)

    self.CCU_plant_cost = CCU_plant.coeff * (model.CCU_CO2_nom_prod_ud / CCU_plant.basis) ** CCU_plant.exp

    self.CO2_storage_cost = CO2_storage.coeff * (model.CO2_storage_cap_ud / CO2_storage.basis) ** CO2_storage.exp
    self.MethSynt_plant_cost = MethSynt_plant.coeff * ((model.MethSynt_RawMeth_nom_prod_ud / MethSynt_plant.basis) ** MethSynt_plant.exp)

    self.RawMeth_storage_cost = RawMeth_storage.coeff * ((model.RawMeth_storage_cap_ud / RawMeth_storage.basis) ** RawMeth_storage.exp)

    self.MethDist_plant_cost = MethDist_plant.coeff * model.MethDist_Meth_nom_prod_ud

    self.Battery_storage_cost = model.BESS_cap_ud * Battery_energy_storage.coeff

    self.Electrical_boiler_cost = model.El_boiler_cap_ud > Double.zero ? (Electrical_boiler.coeff * (model.El_boiler_cap_ud / Electrical_boiler.basis) ** Electrical_boiler.exp) : Double.zero

    // let Substation_cost_ICPH =
    // Substation_capacity.coeff * Substation_capacity.basis * ((model.Heater_cap_ud + model.EY_var_net_nom_cons_ud  + model.EY_aux_elec_input + model.Meth_nominal_aux_electr_cons) / Substation_capacity.basis) ** Substation_capacity.exp

    self.Substation_cost =
      max(model.Grid_export_max_ud, model.Grid_import_max_ud) > Double.zero
      ? Substation.coeff * (max(model.Grid_export_max_ud, model.Grid_import_max_ud) / Substation.basis) ** Substation.exp : Double.zero

    let CSP_O_M_Cost = model.CSP_loop_nr_ud > 0 ? (11.3333 / 3.0 * 1.0 / 3.0 * 1000.0 * 1000) + (0.00606061 / 3.0 * 1.0 / 3.0 * 1000.0 * 1000.0) * model.CSP_loop_nr_ud : Double.zero
    // let PV_O_M_Cost = (11.3333 * 1000.0 * 1000) + (0.00606061 / 100.0 * 1000.0 * 1000.0) * model.PV_DC_cap_ud
    let PV_O_M_Cost = (18.01 * 1000 + model.PV_DC_cap_ud * -0.008375 * 1000) * model.PV_DC_cap_ud
    let PB_O_M_Cost = model.PB_nom_gross_cap_ud > 0 ?  (11.3333 / 3.0 * 2.0 / 3.0 * 1000.0 * 1000.0) + (0.00606061 / 3 * 2.0 / 3.0 * 1000.0 * 1000.0) * model.PB_nom_gross_cap_ud: Double.zero
    let OM_Cost_EY_Methsynt = (MethDist_plant_cost + Electrolysis_cost) * 0.035
    self.CO2_Cost = 200.0 / model.MethDist_Ref_meth_hour_prod * model.MethSynt_Ref_rawmeth_hour_prod / model.MethSynt_Ref_rawmeth_hour_prod * model.MethSynt_Ref_CO2_hour_cons
    let BESS_OM_Cost = model.BESS_cap_ud > 0 ? model.BESS_cap_ud * 501579.333846229 / 25 : 0
    // let CAPEX_ICPH_assembly_hall_csp_sf_dedicated_to_ICPH_PC_DC_PV_AC_Heaters_TES_PB_Substation =
    // Assembly_hall + CSP_SF_cost_dedicated_to_ICPH + PV_DC_Cost + PV_AC_Cost + Heater_Cost + TES_Storage_cost + PB_Cost + Substation_cost_ICPH

    // let CAPEX_aux_thermal_energy_csp_sf_cost_dedicated_to_aux_heat = CSP_SF_cost_dedicated_to_aux_heat
    // let CAPEX_Hydrogen_ICPH_half_of_loops_dedicated_to_aux_heat_electrolysis_half_of_electrical_boiler_cost =
    //  Assembly_hall + CSP_SF_cost_dedicated_to_Hydrogen + PV_DC_Cost + PV_AC_Cost + Heater_Cost
    //  + TES_Storage_cost + PB_Cost + (Electrical_boiler_cost * aux_Heat_ratio) + Substation_cost + Electrolysis_Cost
    self.Total_CAPEX =
      Assembly_hall_cost + CSP_SF_cost_dedicated_to_Methanol + PV_DC_cost + PV_AC_cost + Heater_cost + TES_storage_cost + PB_cost + Electrolysis_cost + Hydrogen_storage_cost
      + CCU_plant_cost + CO2_storage_cost + MethSynt_plant_cost + RawMeth_storage_cost + MethDist_plant_cost + Battery_storage_cost + Electrical_boiler_cost + Substation_cost

    self.Total_OPEX = CSP_O_M_Cost + PV_O_M_Cost + PB_O_M_Cost + OM_Cost_EY_Methsynt + BESS_OM_Cost
  }
  var Total_CAPEX: Double
  var Total_OPEX: Double
  var CO2_Cost: Double
  var Assembly_hall_cost: Double
  var CSP_SF_cost_dedicated_to_Methanol: Double
  var PV_DC_cost: Double
  var PV_AC_cost: Double
  var Heater_cost: Double
  var TES_storage_cost: Double
  var PB_cost: Double
  var Electrolysis_cost: Double
  var Hydrogen_storage_cost: Double
  var CCU_plant_cost: Double
  var CO2_storage_cost: Double
  var MethSynt_plant_cost: Double
  var RawMeth_storage_cost: Double
  var MethDist_plant_cost: Double
  var Battery_storage_cost: Double
  var Electrical_boiler_cost: Double
  var Substation_cost: Double

  public func LCOM(meth_produced_MTPH: Double, elec_from_grid: Double, elec_to_grid: Double) -> Double {
    let Overhead_cost_on_Methanol = 1.0
    let Overhead_cost = 50.0
    let lcom =
      ((((Costs.FCR * Total_CAPEX + Total_OPEX) + (elec_from_grid * Costs.Elec_buy * 1000.0) - (elec_to_grid * Costs.Elec_sell * 1000.0)) / meth_produced_MTPH) + CO2_Cost + Overhead_cost)
      * Overhead_cost_on_Methanol
    return lcom
  }
}

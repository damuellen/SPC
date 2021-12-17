import Utilities
/*
struct SunOl2 {

  let A_CCU_max_perc: Double
  let A_CCU_Min_perc: Double
  let A_CO2_max_cons: Double
  let A_CO2_min_cons: Double
  let A_equiv_harmonious_max_perc: Double
  let A_equiv_harmonious_min_perc: Double
  let A_EY_max_perc: Double
  let A_EY_Min_perc: Double
  let A_H2_max_cons: Double
  let A_H2_min_cons: Double
  let A_MethDist_max_perc: Double
  let A_MethDist_Min_perc: Double
  let A_MethSynt_max_perc: Double
  let A_MethSynt_Min_perc: Double
  let A_overall_fix_stby_cons: Double
  let A_overall_heat_fix_stby_cons: Double
  let A_overall_var_heat_max_cons: Double
  let A_overall_var_heat_min_cons: Double
  let A_overall_var_max_cons: Double
  let A_overall_var_min_cons: Double
  let A_RawMeth_max_cons: Double
  let A_RawMeth_min_cons: Double
  let B_CCU_max_perc: Double
  let B_CCU_Min_perc: Double
  let B_CO2_max_cons: Double
  let B_CO2_min_cons: Double
  let B_equiv_harmonious_max_perc: Double
  let B_equiv_harmonious_min_perc: Double
  let B_EY_max_perc: Double
  let B_EY_Min_perc: Double
  let B_H2_max_cons: Double
  let B_H2_min_cons: Double
  let B_MethDist_max_perc: Double
  let B_MethDist_Min_perc: Double
  let B_MethSynt_max_perc: Double
  let B_MethSynt_Min_perc: Double
  let B_overall_fix_stby_cons: Double
  let B_overall_heat_fix_stby_cons: Double
  let B_overall_var_heat_max_cons: Double
  let B_overall_var_heat_min_cons: Double
  let B_overall_var_max_cons: Double
  let B_overall_var_min_cons: Double
  let B_RawMeth_max_cons: Double
  let B_RawMeth_min_cons: Double
  let BESS_cap_ud: Double
  let BESS_chrg_eff: Double
  let BESS_chrg_max_cons: Double
  let BESS_chrg_max_ratio: Double
  let C_CCU_max_perc: Double
  let C_CCU_Min_perc: Double
  let C_CO2_max_cons: Double
  let C_CO2_min_cons: Double
  let C_equiv_harmonious_max_perc: Double
  let C_equiv_harmonious_min_perc: Double
  let C_EY_max_perc: Double
  let C_EY_min_perc: Double
  let C_H2_max_cons: Double
  let C_H2_min_cons: Double
  let C_MethDist_max_perc: Double
  let C_MethDist_min_perc: Double
  let C_MethSynt_max_perc: Double
  let C_MethSynt_min_perc: Double
  let C_overall_fix_stby_cons: Double
  let C_overall_heat_fix_stby_cons: Double
  let C_overall_var_heat_max_cons: Double
  let C_overall_var_heat_min_cons: Double
  let C_overall_var_max_cons: Double
  let C_overall_var_min_cons: Double
  let C_RawMeth_max_cons: Double
  let C_RawMeth_min_cons: Double
  let CCU_cap_min_perc: Double
  let CCU_CO2_min_prod: Double
  let CCU_CO2_nom_prod_ud: Double
  let CCU_fix_cons: Double
  let CCU_fix_heat_cons: Double
  let CCU_harmonious_max_perc: Double
  let CCU_harmonious_min_perc: Double
  let CCU_harmonious_perc_at_PB_min: Double
  let CCU_harmonious_perc_at_PB_nom: Double
  let CCU_heat_stby_cons: Double
  let CCU_heat_stup_cons: Double
  let CCU_stby_cons: Double
  let CCU_stup_cons: Double
  let CCU_var_heat_nom_cons: Double
  let CCU_var_nom_cons: Double
  let CD_CCU_max_perc: Double
  let CD_CCU_min_perc: Double
  let CD_CO2_max_cons: Double
  let CD_CO2_min_cons: Double
  let CD_equiv_harmonious_max_perc: Double
  let CD_equiv_harmonious_min_perc: Double
  let CD_EY_max_perc: Double
  let CD_EY_min_perc: Double
  let CD_H2_max_cons: Double
  let CD_H2_min_cons: Double
  let CD_MethDist_max_perc: Double
  let CD_MethDist_min_perc: Double
  let CD_MethSynt_max_perc: Double
  let CD_MethSynt_min_perc: Double
  let CD_overall_var_heat_max_cons: Double
  let CD_overall_var_heat_min_cons: Double
  let CD_overall_var_max_cons: Double
  let CD_overall_var_min_cons: Double
  let CD_RawMeth_max_cons: Double
  let CD_RawMeth_min_cons: Double
  let CO2_storage_cap_ud: Double
  let CSP_Cold_HTF_T: Double
  let CSP_Hot_HTF_T: Double
  let CSP_loop_nr_ud: Double
  let CSP_night_aux_cons_per_loop: Double
  let CSP_nonsolar_aux_cons: Double
  let CSP_SF_Max_th_Power: Double
  let CSP_var_aux_nom_perc: Double
  let D_CCU_max_perc: Double
  let D_CCU_min_perc: Double
  let D_CO2_max_cons: Double
  let D_CO2_min_cons: Double
  let D_equiv_harmonious_max_perc: Double
  let D_equiv_harmonious_min_perc: Double
  let D_EY_max_perc: Double
  let D_EY_min_perc: Double
  let D_H2_max_cons: Double
  let D_H2_min_cons: Double
  let D_MethDist_max_perc: Double
  let D_MethDist_min_perc: Double
  let D_MethSynt_max_perc: Double
  let D_MethSynt_min_perc: Double
  let D_overall_fix_stby_cons: Double
  let D_overall_heat_fix_stby_cons: Double
  let D_overall_var_heat_max_cons: Double
  let D_overall_var_heat_min_cons: Double
  let D_overall_var_max_cons: Double
  let D_overall_var_min_cons: Double
  let D_RawMeth_max_cons: Double
  let D_RawMeth_min_cons: Double
  let Density_CO2: Double
  let Density_H2: Double
  let El_boiler_cap_ud: Double
  let El_boiler_eff: Double
  let EY_aux_heat_input_at_min_PB: Double
  let EY_cap_min_perc: Double
  let EY_fix_cons: Double
  let EY_H2_min_prod: Double
  let EY_H2_nom_prod: Double
  let EY_harmonious_max_perc: Double
  let EY_harmonious_min_perc: Double
  let EY_harmonious_perc_at_PB_min: Double
  let EY_harmonious_perc_at_PB_nom: Double
  let EY_heat_fix_cons: Double
  let EY_heat_stby_cons: Double
  let EY_heat_stup_cons: Double
  let EY_stby_cons: Double
  let EY_stup_cons: Double
  let EY_var_aux_min_cons: Double
  let EY_var_aux_nom_cons: Double
  let EY_var_gross_nom_cons: Double
  let EY_var_heat_nom_cons: Double
  let EY_var_net_nom_cons_ud: Double
  let Grid_export_max_ud: Double
  let Grid_import_max_ud: Double
  let H2_storage_cap_ud: Double
  let Heater_cap_ud: Double
  let Heater_eff: Double
  let Heater_outlet_T: Double
  let MethDist_cap_min_perc: Double
  let MethDist_fix_cons: Double
  let MethDist_H2O_min_prod: Double
  let MethDist_H2O_nom_prod: Double
  let MethDist_harmonious_max_perc: Double
  let MethDist_harmonious_min_perc: Double
  let MethDist_harmonious_perc_at_PB_min: Double
  let MethDist_harmonious_perc_at_PB_nom: Double
  let MethDist_heat_fix_cons: Double
  let MethDist_heat_stby_cons: Double
  let MethDist_heat_stup_cons: Double
  let MethDist_Meth_min_prod: Double
  let MethDist_Meth_nom_prod_ud: Double
  let MethDist_RawMeth_min_cons: Double
  let MethDist_RawMeth_nom_cons: Double
  let MethDist_stby_cons: Double
  let MethDist_stup_cons: Double
  let MethDist_var_heat_nom_cons: Double
  let MethDist_var_nom_cons: Double
  let MethSynt_annual_op_days: Double
  let MethSynt_annual_op_hours: Double
  let MethSynt_annual_outage_days: Double
  let MethSynt_cap_min_perc: Double
  let MethSynt_CO2_min_cons: Double
  let MethSynt_CO2_nom_cons: Double
  let MethSynt_fix_cons: Double
  let MethSynt_H2_min_cons: Double
  let MethSynt_H2_nom_cons: Double
  let MethSynt_harmonious_max_perc: Double
  let MethSynt_harmonious_min_perc: Double
  let MethSynt_harmonious_perc_at_PB_min: Double
  let MethSynt_harmonious_perc_at_PB_nom: Double
  let MethSynt_heat_fix_prod: Double
  let MethSynt_heat_stby_cons: Double
  let MethSynt_RawMeth_min_prod: Double
  let MethSynt_RawMeth_nom_prod_ud: Double
  let MethSynt_stby_cons: Double
  let MethSynt_stup_duration: Double
  let MethSynt_var_heat_nom_prod: Double
  let MethSynt_var_nom_cons: Double
  let Overall_fix_cons: Double
  let Overall_harmonious_max_perc: Double
  let Overall_harmonious_min_perc: Double
  let Overall_harmonious_perc_at_PB_min: Double
  let Overall_harmonious_perc_at_PB_nom: Double
  let Overall_harmonious_var_cons_at_PB_min: Double
  let Overall_harmonious_var_cons_at_PB_nom: Double
  let Overall_harmonious_var_heat_cons_at_PB_min: Double
  let Overall_harmonious_var_heat_cons_at_PB_nom: Double
  let Overall_harmonious_var_heat_max_cons: Double
  let Overall_harmonious_var_heat_min_cons: Double
  let Overall_harmonious_var_max_cons: Double
  let Overall_harmonious_var_min_cons: Double
  let Overall_heat_fix_cons: Double
  let PB_cold_start_duration: Double
  let PB_cold_start_energyperc: Double
  let PB_cold_start_heat_req: Double
  let PB_eff_at_max_harmonious: Double
  let PB_eff_at_min_harmonious: Double
  let PB_el_cap_min_perc: Double
  let PB_fix_aux_el: Double
  let PB_fix_aux_elec_cons_perc_of_ref: Double
  
  let PB_g2n_var_aux_el: Polynomial

  let PB_gross_cap_at_max_harmonious: Double
  let PB_gross_cap_at_min_harmonious: Double
  let PB_gross_min_cap: Double
  let PB_gross_min_eff: Double
  let PB_heat_input_at_max_harmonious: Double
  let PB_heat_input_at_min_harmonious: Double
  let PB_heat_min_input: Double
  let PB_hot_start_energyperc: Double
  let PB_hot_start_heat_req: Double

  let PB_n2g_var_aux_el: Polynomial

  let PB_net_cap_at_max_harmonious: Double
  let PB_net_cap_at_min_harmonious: Double
  let PB_net_min_cap: Double
  let PB_nom_gross_cap_ud: Double
  let PB_nom_gross_eff: Double
  let PB_nom_heat_cons: Double
  let PB_nom_net_cap: Double
  let PB_nom_var_aux_cons: Double
  let PB_nom_var_aux_cons_perc_gross: Double
  let PB_nom_var_aux_cons_perc_net: Double
  let PB_op_hours_min_nr: Double
  let PB_Ratio_Heat_input_vs_output: Double
  let PB_stby_aux_cons: Double
  let PB_stby_fix_aux_cons_perc: Double
  let PB_stby_var_aux_cons_perc: Double
  let PB_stup_aux_cons: Double
  let PB_stup_fix_aux_elec_cons_perc: Double
  let PB_stup_var_aux_elec_cons_perc: Double
  let PB_var_aux_cons_C0: Double
  let PB_var_aux_cons_C1: Double
  let PB_var_aux_cons_C2: Double
  let PB_var_aux_cons_C3: Double
  let PB_var_heat_max_cons: Double
  let PB_warm_start_duration: Double
  let PB_warm_start_energyperc: Double
  let PB_warm_start_heat_req: Double
  let PV_AC_cap_ud: Double
  let PV_DC_cap_ud: Double
  let Ratio_CSP_vs_Heater: Double
  let RawMeth_storage_cap_ud: Double
  let Ref_CCU_CO2_hourly_prod: Double
  let Ref_CCU_fix_cons: Double
  let Ref_CCU_heat_fix_cons: Double
  let Ref_CCU_heat_stby_cons: Double
  let Ref_CCU_heat_stup_cons: Double
  let Ref_CCU_stby_cons: Double
  let Ref_CCU_stup_cons: Double
  let Ref_CCU_var_heat_nom_cons: Double
  let Ref_CCU_var_nom_cons: Double
  let Ref_EY_fix_cons: Double
  let Ref_EY_H2_hourly_nom_prod: Double
  let Ref_EY_heat_fix_cons: Double
  let Ref_EY_heat_stby_cons: Double
  let Ref_EY_heat_stup_cons: Double
  let Ref_EY_stby_cons: Double
  let Ref_EY_stup_cons: Double
  let Ref_EY_var_heat_nom_cons: Double
  let Ref_EY_var_net_nom_cons: Double
  let Ref_EY_var_nom_cons: Double
  let Ref_Inv_eff_approx_handover: Double
  let Ref_MethDist_fix_cons: Double
  let Ref_MethDist_heat_fix_cons: Double
  let Ref_MethDist_heat_stby_cons: Double
  let Ref_MethDist_heat_stup_cons: Double
  let Ref_MethDist_meth_annual_prod: Double
  let Ref_MethDist_meth_hourly_prod: Double
  let Ref_MethDist_rawmeth_hourly_cons: Double
  let Ref_MethDist_stby_cons: Double
  let Ref_MethDist_stup_cons: Double
  let Ref_MethDist_var_heat_nom_cons: Double
  let Ref_MethDist_var_nom_cons: Double
  let Ref_MethDist_water_annual_prod: Double
  let Ref_MethDist_water_hourly_prod: Double
  let Ref_MethSynt_CO2_annual_cons: Double
  let Ref_MethSynt_CO2_hourly_cons: Double
  let Ref_MethSynt_fix_cons: Double
  let Ref_MethSynt_H2_annual_cons: Double
  let Ref_MethSynt_H2_hourly_cons: Double
  let Ref_MethSynt_heat_fix_prod: Double
  let Ref_MethSynt_heat_stby_cons: Double
  let Ref_MethSynt_heat_stup_cons: Double
  let Ref_MethSynt_rawmeth_hourly_prod: Double
  let Ref_MethSynt_stby_cons: Double
  let Ref_MethSynt_stup_cons: Double
  let Ref_MethSynt_var_heat_nom_prod: Double
  let Ref_MethSynt_var_nom_cons: Double
  let Ref_PB_25p_aux_heat_prod: Double
  let Ref_PB_25p_gross_cap: Double
  let Ref_PB_25p_gross_cap_max_aux_heat: Double
  let Ref_PB_25p_gross_eff: Double
  let Ref_PB_25p_gross_eff_excl_aux_heat_cons: Double
  let Ref_PB_25p_gross_eff_excl_max_aux_heat_cons: Double
  let Ref_PB_25p_gross_eff_max_aux_heat: Double
  let Ref_PB_25p_heat_cons: Double
  let Ref_PB_25p_heat_cons_excl_aux_heat: Double
  let Ref_PB_25p_heat_cons_excl_max_aux_heat: Double
  let Ref_PB_25p_heat_cons_max_aux_heat: Double
  let Ref_PB_25p_max_aux_heat_prod: Double
  let Ref_PB_30p_aux_heat_prod: Double
  let Ref_PB_30p_gross_cap: Double
  let Ref_PB_30p_gross_eff: Double
  let Ref_PB_30p_gross_eff_excl_aux_heat_cons: Double
  let Ref_PB_30p_heat_cons: Double
  let Ref_PB_30p_heat_cons_excl_aux_heat: Double
  let Ref_PB_nom_aux_heat_prod: Double
  let Ref_PB_nom_gross_cap: Double
  let Ref_PB_nom_gross_eff: Double
  let Ref_PB_nom_gross_eff_excl_aux_heat_cons: Double
  let Ref_PB_nom_heat_cons: Double
  let Ref_PB_nom_heat_cons_excl_aux_heat: Double
  let Ref_PV_AC_cap: Double
  let Ref_PV_DC_cap: Double
  let SF_heat_exch_approach_temp: Double
  let TES_aux_cons_perc: Double
  let TES_cold_tank_T: Double
  let TES_dead_mass_ratio: Double
  let TES_full_load_hours_ud: Double
  let TES_salt_mass: Double
  let TES_thermal_cap: Double

  init() {

    // self._ = 3.39311445520421E-02

    self.PB_g2n_var_aux_el = Polynomial([6.75146424176523E-01, -6.52496244217653E-02, 1.02805131768711E-01, 2.94370132015919E-01].reversed())

    self.PB_n2g_var_aux_el = Polynomial([0.73236331417144, -0.16064263609163, 0.13719418738314, 0.29095457369943].reversed())

    // self._ = 6.43407043308906E-03

    // self.fix_aux_el = Polynomial([3.30241955243857E-01, -4.95362932865787E-01, 2.93145114445988E-01, 8.71975863175942E-01].reversed())

    // self._ = 4.62509835126915E-03
    // self._ = 5.26407043308906E-03

    // self.fix_stby_el = Polynomial([2.11142058373717E-01, -3.16713087560573E-01, 2.14558232294004E-01, 8.91012796892852E-01].reversed())

    // self._ = 1.27891539980364E-02
    // self._ = 5.98157043308906E-03

    // self.fix_stup_el = Polynomial([1.85815193367649E-01, -2.78722790051474E-01, 1.98852401739667E-01, 8.94055194944158E-01].reversed())
    self.A_CCU_max_perc = 0.0
    self.A_CCU_Min_perc = 0.0
    self.A_CO2_max_cons = -A_CCU_max_perc * CCU_CO2_nom_prod_ud + A_MethSynt_max_perc * MethSynt_CO2_nom_cons
    self.A_CO2_min_cons = -A_CCU_Min_perc * CCU_CO2_nom_prod_ud + A_MethSynt_Min_perc * MethSynt_CO2_nom_cons
    self.A_equiv_harmonious_max_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * A_MethDist_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * A_MethSynt_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * A_CCU_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * A_EY_max_perc, 0)
    )
    self.A_equiv_harmonious_min_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * A_MethDist_Min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * A_MethSynt_Min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * A_CCU_Min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * A_EY_Min_perc, 0)
    )
    self.A_EY_max_perc = 0.0
    self.A_EY_Min_perc = 0.0
    self.A_H2_max_cons = -A_EY_max_perc * EY_H2_nom_prod + A_MethSynt_max_perc * MethSynt_H2_nom_cons
    self.A_H2_min_cons = -A_EY_Min_perc * EY_H2_nom_prod + A_MethSynt_Min_perc * MethSynt_H2_nom_cons
    self.A_MethDist_max_perc = MethDist_harmonious_max_perc
    self.A_MethDist_Min_perc = MethDist_cap_min_perc
    self.A_MethSynt_max_perc = 0.0
    self.A_MethSynt_Min_perc = 0.0
    self.A_overall_fix_stby_cons =
      iff(A_MethDist_Min_perc > 0, MethDist_fix_cons, MethDist_stby_cons) + iff(A_MethSynt_Min_perc > 0, MethSynt_fix_cons, MethSynt_stby_cons) + iff(A_CCU_Min_perc > 0, CCU_fix_cons, CCU_stby_cons)
      + iff(A_EY_Min_perc > 0, EY_fix_cons, EY_stby_cons)
    self.A_overall_heat_fix_stby_cons =
      iff(A_MethDist_max_perc > 0, MethDist_heat_fix_cons, MethDist_heat_stby_cons) + iff(A_MethSynt_max_perc > 0, -MethSynt_heat_fix_prod, MethSynt_heat_stby_cons)
      + iff(A_CCU_max_perc > 0, CCU_fix_heat_cons, CCU_heat_stby_cons) + iff(A_EY_max_perc > 0, EY_heat_fix_cons, EY_heat_stby_cons)
    self.A_overall_var_heat_max_cons = EY_var_heat_nom_cons * A_EY_max_perc + MethDist_var_heat_nom_cons * A_MethDist_max_perc - MethSynt_var_heat_nom_prod * A_MethSynt_max_perc + CCU_var_heat_nom_cons * A_CCU_max_perc
    self.A_overall_var_heat_min_cons = EY_var_heat_nom_cons * A_EY_Min_perc + MethDist_var_heat_nom_cons * A_MethDist_Min_perc - MethSynt_var_heat_nom_prod * A_MethSynt_Min_perc + CCU_var_heat_nom_cons * A_CCU_Min_perc
    self.A_overall_var_max_cons =
      A_EY_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + A_MethSynt_max_perc * MethSynt_var_nom_cons + A_MethDist_max_perc * MethDist_var_nom_cons + A_CCU_max_perc * CCU_var_nom_cons
    self.A_overall_var_min_cons =
      A_EY_Min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + A_MethSynt_Min_perc * MethSynt_var_nom_cons + A_MethDist_Min_perc * MethDist_var_nom_cons + A_CCU_Min_perc * CCU_var_nom_cons
    self.A_RawMeth_max_cons = -A_MethSynt_max_perc * MethSynt_RawMeth_nom_prod_ud + A_MethDist_max_perc * MethDist_RawMeth_nom_cons
    self.A_RawMeth_min_cons = -A_MethSynt_Min_perc * MethSynt_RawMeth_nom_prod_ud + A_MethDist_Min_perc * MethDist_RawMeth_nom_cons
    self.B_CCU_max_perc = 0
    self.B_CCU_Min_perc = 0
    self.B_CO2_max_cons = -B_CCU_max_perc * CCU_CO2_nom_prod_ud + B_MethSynt_max_perc * MethSynt_CO2_nom_cons
    self.B_CO2_min_cons = -B_CCU_Min_perc * CCU_CO2_nom_prod_ud + B_MethSynt_Min_perc * MethSynt_CO2_nom_cons
    self.B_equiv_harmonious_max_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * B_MethDist_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * B_MethSynt_max_perc, 0),
      0
    )
    self.B_equiv_harmonious_min_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * B_MethDist_Min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * B_MethSynt_Min_perc, 0),
      0
    )
    self.B_EY_max_perc = 0.0
    self.B_EY_Min_perc = 0.0
    self.B_H2_max_cons = -B_EY_max_perc * EY_H2_nom_prod + B_MethSynt_max_perc * MethSynt_H2_nom_cons
    self.B_H2_min_cons = -B_EY_Min_perc * EY_H2_nom_prod + B_MethSynt_Min_perc * MethSynt_H2_nom_cons
    self.B_MethDist_max_perc = min(1, MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    self.B_MethDist_Min_perc = max(MethDist_cap_min_perc, MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons, 0)
    self.B_MethSynt_max_perc = min(1, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud)
    self.B_MethSynt_Min_perc = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, 0)
    self.B_overall_fix_stby_cons =
      iff(B_MethDist_Min_perc > 0, MethDist_fix_cons, MethDist_stby_cons) + iff(B_MethSynt_Min_perc > 0, MethSynt_fix_cons, MethSynt_stby_cons) + iff(B_CCU_Min_perc > 0, CCU_fix_cons, CCU_stby_cons)
      + iff(B_EY_Min_perc > 0, EY_fix_cons, EY_stby_cons)
    self.B_overall_heat_fix_stby_cons =
      iff(B_MethDist_max_perc > 0, MethDist_heat_fix_cons, MethDist_heat_stby_cons) + iff(B_MethSynt_max_perc > 0, -MethSynt_heat_fix_prod, MethSynt_heat_stby_cons)
      + iff(B_CCU_max_perc > 0, CCU_fix_heat_cons, CCU_heat_stby_cons) + iff(B_EY_max_perc > 0, EY_heat_fix_cons, EY_heat_stby_cons)
    self.B_overall_var_heat_max_cons = EY_var_heat_nom_cons * B_EY_max_perc + MethDist_var_heat_nom_cons * B_MethDist_max_perc - MethSynt_var_heat_nom_prod * B_MethSynt_max_perc + CCU_var_heat_nom_cons * B_CCU_max_perc
    self.B_overall_var_heat_min_cons = EY_var_heat_nom_cons * B_EY_Min_perc + MethDist_var_heat_nom_cons * B_MethDist_Min_perc - MethSynt_var_heat_nom_prod * B_MethSynt_Min_perc + CCU_var_heat_nom_cons * B_CCU_Min_perc
    self.B_overall_var_max_cons =
      B_EY_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + B_MethSynt_max_perc * MethSynt_var_nom_cons + B_MethDist_max_perc * MethDist_var_nom_cons + B_CCU_max_perc * CCU_var_nom_cons
    self.B_overall_var_min_cons =
      B_EY_Min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + B_MethSynt_Min_perc * MethSynt_var_nom_cons + B_MethDist_Min_perc * MethDist_var_nom_cons + B_CCU_Min_perc * CCU_var_nom_cons
    self.B_RawMeth_max_cons = -B_MethSynt_max_perc * MethSynt_RawMeth_nom_prod_ud + B_MethDist_max_perc * MethDist_RawMeth_nom_cons
    self.B_RawMeth_min_cons = -B_MethSynt_Min_perc * MethSynt_RawMeth_nom_prod_ud + B_MethDist_Min_perc * MethDist_RawMeth_nom_cons
    self.BESS_cap_ud = 130.0
    self.BESS_chrg_eff = 0.7
    self.BESS_chrg_max_cons = BESS_cap_ud * BESS_chrg_max_ratio
    self.BESS_chrg_max_ratio = 0.5
    self.C_CCU_max_perc = min(1, MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud)
    self.C_CCU_Min_perc = max(
      CCU_cap_min_perc,
      MethSynt_CO2_min_cons / CCU_CO2_nom_prod_ud,
      MethSynt_cap_min_perc * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud
    )
    self.C_CO2_max_cons = -C_CCU_max_perc * CCU_CO2_nom_prod_ud + C_MethSynt_max_perc * MethSynt_CO2_nom_cons
    self.C_CO2_min_cons = -C_CCU_Min_perc * CCU_CO2_nom_prod_ud + C_MethSynt_min_perc * MethSynt_CO2_nom_cons
    self.C_equiv_harmonious_max_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * C_MethDist_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * C_MethSynt_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * C_CCU_max_perc, 0),
      0
    )
    self.C_equiv_harmonious_min_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * C_MethDist_min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * C_MethSynt_min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * C_CCU_Min_perc, 0),
      0
    )
    self.C_EY_max_perc = 0.0
    self.C_EY_min_perc = 0.0
    self.C_H2_max_cons = -C_EY_max_perc * EY_H2_nom_prod + C_MethSynt_max_perc * MethSynt_H2_nom_cons
    self.C_H2_min_cons = -C_EY_min_perc * EY_H2_nom_prod + C_MethSynt_min_perc * MethSynt_H2_nom_cons
    self.C_MethDist_max_perc = min(1, MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons, CCU_CO2_nom_prod_ud / MethSynt_CO2_nom_cons * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    self.C_MethDist_min_perc = max(
      MethDist_cap_min_perc,
      MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons,
      MethSynt_cap_min_perc * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, CCU_CO2_min_prod / MethSynt_CO2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons
    )
    self.C_MethSynt_max_perc = min(1, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud, CCU_CO2_nom_prod_ud / MethSynt_CO2_nom_cons)
    self.C_MethSynt_min_perc = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, CCU_CO2_min_prod / MethSynt_CO2_nom_cons)
    self.C_overall_fix_stby_cons =
      iff(C_MethDist_min_perc > 0, MethDist_fix_cons, MethDist_stby_cons) + iff(C_MethSynt_min_perc > 0, MethSynt_fix_cons, MethSynt_stby_cons) + iff(C_CCU_Min_perc > 0, CCU_fix_cons, CCU_stby_cons)
      + iff(C_EY_min_perc > 0.0, EY_fix_cons, EY_stby_cons)
    self.C_overall_heat_fix_stby_cons =
      iff(C_MethDist_max_perc > 0, MethDist_heat_fix_cons, MethDist_heat_stby_cons) + iff(C_MethSynt_max_perc > 0, -MethSynt_heat_fix_prod, MethSynt_heat_stby_cons)
      + iff(C_CCU_max_perc > 0, CCU_fix_heat_cons, CCU_heat_stby_cons) + iff(C_EY_max_perc > 0, EY_heat_fix_cons, EY_heat_stby_cons)
    self.C_overall_var_heat_max_cons = EY_var_heat_nom_cons * C_EY_max_perc + MethDist_var_heat_nom_cons * C_MethDist_max_perc - MethSynt_var_heat_nom_prod * C_MethSynt_max_perc + CCU_var_heat_nom_cons * C_CCU_max_perc
    self.C_overall_var_heat_min_cons = EY_var_heat_nom_cons * C_EY_min_perc + MethDist_var_heat_nom_cons * C_MethDist_min_perc - MethSynt_var_heat_nom_prod * C_MethSynt_min_perc + CCU_var_heat_nom_cons * C_CCU_Min_perc
    self.C_overall_var_max_cons =
      C_EY_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + C_MethSynt_max_perc * MethSynt_var_nom_cons + C_MethDist_max_perc * MethDist_var_nom_cons + C_CCU_max_perc * CCU_var_nom_cons
    self.C_overall_var_min_cons =
      C_EY_min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + C_MethSynt_min_perc * MethSynt_var_nom_cons + C_MethDist_min_perc * MethDist_var_nom_cons + C_CCU_Min_perc * CCU_var_nom_cons
    self.C_RawMeth_max_cons = -C_MethSynt_max_perc * MethSynt_RawMeth_nom_prod_ud + C_MethDist_max_perc * MethDist_RawMeth_nom_cons
    self.C_RawMeth_min_cons = -C_MethSynt_min_perc * MethSynt_RawMeth_nom_prod_ud + C_MethDist_min_perc * MethDist_RawMeth_nom_cons
    self.CCU_cap_min_perc = 0.5
    self.CCU_CO2_min_prod = CCU_CO2_nom_prod_ud * CCU_cap_min_perc
    self.CCU_CO2_nom_prod_ud = 30.0
    self.CCU_fix_cons = CCU_CO2_nom_prod_ud / Ref_CCU_CO2_hourly_prod * Ref_CCU_fix_cons
    self.CCU_fix_heat_cons = CCU_CO2_nom_prod_ud / Ref_CCU_CO2_hourly_prod * Ref_CCU_heat_fix_cons
    self.CCU_harmonious_max_perc = min(
      1,
      MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud,
      EY_H2_nom_prod / MethSynt_H2_nom_cons * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud,
      MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud
    )
    self.CCU_harmonious_min_perc = max(
      CCU_cap_min_perc,
      MethSynt_CO2_min_cons / CCU_CO2_nom_prod_ud,
      max(MethSynt_cap_min_perc, EY_H2_min_prod / MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud
    )
    self.CCU_harmonious_perc_at_PB_min = CCU_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_min
    self.CCU_harmonious_perc_at_PB_nom = iff(
      PB_nom_net_cap / Overall_harmonious_var_max_cons * CCU_harmonious_max_perc < CCU_harmonious_min_perc,
      0,
      PB_nom_net_cap / Overall_harmonious_var_max_cons * CCU_harmonious_max_perc
    )
    self.CCU_heat_stby_cons = CCU_CO2_nom_prod_ud / Ref_CCU_CO2_hourly_prod * Ref_CCU_heat_stby_cons
    self.CCU_heat_stup_cons = CCU_CO2_nom_prod_ud / Ref_CCU_CO2_hourly_prod * Ref_CCU_heat_stup_cons
    self.CCU_stby_cons = CCU_CO2_nom_prod_ud / Ref_CCU_CO2_hourly_prod * Ref_CCU_stby_cons
    self.CCU_stup_cons = CCU_CO2_nom_prod_ud / Ref_CCU_CO2_hourly_prod * Ref_CCU_stup_cons
    self.CCU_var_heat_nom_cons = CCU_CO2_nom_prod_ud / Ref_CCU_CO2_hourly_prod * Ref_CCU_var_heat_nom_cons
    self.CCU_var_nom_cons = CCU_CO2_nom_prod_ud / Ref_CCU_CO2_hourly_prod * Ref_CCU_var_nom_cons
    self.CD_CCU_max_perc = max(
      CCU_cap_min_perc,
      MethSynt_CO2_min_cons / CCU_CO2_nom_prod_ud,
      max(MethSynt_cap_min_perc, EY_H2_min_prod / MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud
    )
    self.CD_CCU_min_perc = max(
      CCU_cap_min_perc,
      MethSynt_CO2_min_cons / CCU_CO2_nom_prod_ud,
      max(MethSynt_cap_min_perc, EY_H2_min_prod / MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod_ud
    )
    self.CD_CO2_max_cons = -CD_CCU_max_perc * CCU_CO2_nom_prod_ud + CD_MethSynt_max_perc * MethSynt_CO2_nom_cons
    self.CD_CO2_min_cons = -CD_CCU_min_perc * CCU_CO2_nom_prod_ud + CD_MethSynt_min_perc * MethSynt_CO2_nom_cons
    self.CD_equiv_harmonious_max_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * CD_MethDist_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * CD_MethSynt_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * CD_CCU_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * CD_EY_max_perc, 0),
      0
    )
    self.CD_equiv_harmonious_min_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * CD_MethDist_min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * CD_MethSynt_min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * CD_CCU_min_perc, 0),
      0
    )
    self.CD_EY_max_perc = max(
      EY_cap_min_perc,
      MethSynt_H2_min_cons / EY_H2_nom_prod,
      max(MethSynt_cap_min_perc, CCU_CO2_min_prod / MethSynt_CO2_nom_cons) * MethSynt_H2_nom_cons / EY_H2_nom_prod,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_H2_nom_cons / EY_H2_nom_prod
    )
    self.CD_EY_min_perc = EY_cap_min_perc
    self.CD_H2_max_cons = -CD_EY_max_perc * EY_H2_nom_prod + CD_MethSynt_max_perc * MethSynt_H2_nom_cons
    self.CD_H2_min_cons = -CD_EY_min_perc * EY_H2_nom_prod + CD_MethSynt_min_perc * MethSynt_H2_nom_cons
    self.CD_MethDist_max_perc = max(
      MethDist_cap_min_perc,
      MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, EY_H2_min_prod / MethSynt_H2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, CCU_CO2_min_prod / MethSynt_CO2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons
    )
    self.CD_MethDist_min_perc = max(
      MethDist_cap_min_perc,
      MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, EY_H2_min_prod / MethSynt_H2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, CCU_CO2_min_prod / MethSynt_CO2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons
    )
    self.CD_MethSynt_max_perc = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, EY_H2_min_prod / MethSynt_H2_nom_cons, CCU_CO2_min_prod / MethSynt_CO2_nom_cons)
    self.CD_MethSynt_min_perc = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, EY_H2_min_prod / MethSynt_H2_nom_cons, CCU_CO2_min_prod / MethSynt_CO2_nom_cons)
    self.CD_overall_var_heat_max_cons =
      EY_var_heat_nom_cons * CD_EY_max_perc + MethDist_var_heat_nom_cons * CD_MethDist_max_perc - MethSynt_var_heat_nom_prod * CD_MethSynt_max_perc + CCU_var_heat_nom_cons * CD_CCU_max_perc
    self.CD_overall_var_heat_min_cons =
      EY_var_heat_nom_cons * CD_EY_min_perc + MethDist_var_heat_nom_cons * CD_MethDist_min_perc - MethSynt_var_heat_nom_prod * CD_MethSynt_min_perc + CCU_var_heat_nom_cons * CD_CCU_min_perc
    self.CD_overall_var_max_cons =
      CD_EY_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + CD_MethSynt_max_perc * MethSynt_var_nom_cons + CD_MethDist_max_perc * MethDist_var_nom_cons + CD_CCU_max_perc * CCU_var_nom_cons
    self.CD_overall_var_min_cons =
      CD_EY_min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + CD_MethSynt_min_perc * MethSynt_var_nom_cons + CD_MethDist_min_perc * MethDist_var_nom_cons + CD_CCU_min_perc * CCU_var_nom_cons
    self.CD_RawMeth_max_cons = -CD_MethSynt_max_perc * MethSynt_RawMeth_nom_prod_ud + CD_MethDist_max_perc * MethDist_RawMeth_nom_cons
    self.CD_RawMeth_min_cons = -CD_MethSynt_min_perc * MethSynt_RawMeth_nom_prod_ud + CD_MethDist_min_perc * MethDist_RawMeth_nom_cons
    self.CO2_storage_cap_ud = H2_storage_cap_ud / Density_H2 * Density_CO2 / 4
    self.CSP_Cold_HTF_T = TES_cold_tank_T + SF_heat_exch_approach_temp
    self.CSP_Hot_HTF_T = 425.0
    self.CSP_loop_nr_ud = 130.0
    self.CSP_night_aux_cons_per_loop = 3.0000000000000001E-3
    self.CSP_nonsolar_aux_cons = CSP_night_aux_cons_per_loop * CSP_loop_nr_ud
    self.CSP_SF_Max_th_Power = Heater_cap_ud * Heater_eff / Ratio_CSP_vs_Heater + EY_var_heat_nom_cons + MethDist_var_heat_nom_cons
    self.CSP_var_aux_nom_perc = 0.01
    self.D_CCU_max_perc = CCU_harmonious_max_perc
    self.D_CCU_min_perc = CCU_harmonious_min_perc
    self.D_CO2_max_cons = D_CCU_max_perc * CCU_CO2_nom_prod_ud - D_MethSynt_max_perc * MethSynt_CO2_nom_cons
    self.D_CO2_min_cons = -D_CCU_min_perc * CCU_CO2_nom_prod_ud + D_MethSynt_min_perc * MethSynt_CO2_nom_cons
    self.D_equiv_harmonious_max_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * D_MethDist_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * D_MethSynt_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * D_CCU_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * D_EY_max_perc, 0),
      0
    )
    self.D_equiv_harmonious_min_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * D_MethDist_min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * D_MethSynt_min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * D_CCU_min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * D_EY_min_perc, 0),
      0
    )
    self.D_EY_max_perc = EY_harmonious_max_perc
    self.D_EY_min_perc = EY_harmonious_min_perc
    self.D_H2_max_cons = D_EY_max_perc * EY_H2_nom_prod - D_MethSynt_max_perc * MethSynt_H2_nom_cons
    self.D_H2_min_cons = -D_EY_min_perc * EY_H2_nom_prod + D_MethSynt_min_perc * MethSynt_H2_nom_cons
    self.D_MethDist_max_perc = MethDist_harmonious_max_perc
    self.D_MethDist_min_perc = MethDist_harmonious_min_perc
    self.D_MethSynt_max_perc = MethSynt_harmonious_max_perc
    self.D_MethSynt_min_perc = MethSynt_harmonious_min_perc
    self.D_overall_fix_stby_cons =
      iff(D_MethDist_min_perc > 0, MethDist_fix_cons, MethDist_stby_cons) + iff(D_MethSynt_min_perc > 0, MethSynt_fix_cons, MethSynt_stby_cons) + iff(D_CCU_min_perc > 0, CCU_fix_cons, CCU_stby_cons)
      + iff(D_EY_min_perc > 0, EY_fix_cons, EY_stby_cons)
    self.D_overall_heat_fix_stby_cons =
      iff(D_MethDist_max_perc > 0, MethDist_heat_fix_cons, MethDist_heat_stby_cons) + iff(D_MethSynt_max_perc > 0, -MethSynt_heat_fix_prod, MethSynt_heat_stby_cons)
      + iff(D_CCU_max_perc > 0, CCU_fix_heat_cons, CCU_heat_stby_cons) + iff(D_EY_max_perc > 0, EY_heat_fix_cons, EY_heat_stby_cons)
    self.D_overall_var_heat_max_cons = EY_var_heat_nom_cons * D_EY_max_perc + MethDist_var_heat_nom_cons * D_MethDist_max_perc - MethSynt_var_heat_nom_prod * D_MethSynt_max_perc + CCU_var_heat_nom_cons * D_CCU_max_perc
    self.D_overall_var_heat_min_cons = EY_var_heat_nom_cons * D_EY_min_perc + MethDist_var_heat_nom_cons * D_MethDist_min_perc - MethSynt_var_heat_nom_prod * D_MethSynt_min_perc + CCU_var_heat_nom_cons * D_CCU_min_perc
    self.D_overall_var_max_cons =
      D_EY_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + D_MethSynt_max_perc * MethSynt_var_nom_cons + D_MethDist_max_perc * MethDist_var_nom_cons + D_CCU_max_perc * CCU_var_nom_cons
    self.D_overall_var_min_cons =
      D_EY_min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + D_MethSynt_min_perc * MethSynt_var_nom_cons + D_MethDist_min_perc * MethDist_var_nom_cons + D_CCU_min_perc * CCU_var_nom_cons
    self.D_RawMeth_max_cons = D_MethSynt_max_perc * MethSynt_RawMeth_nom_prod_ud - D_MethDist_max_perc * MethDist_RawMeth_nom_cons
    self.D_RawMeth_min_cons = -D_MethSynt_min_perc * MethSynt_RawMeth_nom_prod_ud + D_MethDist_min_perc * MethDist_RawMeth_nom_cons
    self.Density_CO2 = 1.9766999999999999
    self.Density_H2 = 8.9899999999999994E-2
    self.El_boiler_cap_ud = 100.0
    self.El_boiler_eff = 0.99

    self.EY_aux_heat_input_at_min_PB =
      max(EY_var_aux_min_cons, (PB_net_min_cap - MethSynt_var_nom_cons * MethSynt_cap_min_perc - MethSynt_fix_cons - MethDist_var_nom_cons * MethDist_cap_min_perc - MethDist_fix_cons)) / EY_var_gross_nom_cons
      * EY_var_heat_nom_cons
    self.EY_cap_min_perc = 0.1
    self.EY_fix_cons = EY_var_net_nom_cons_ud / Ref_EY_var_net_nom_cons * Ref_EY_fix_cons
    self.EY_H2_min_prod = EY_H2_nom_prod * EY_cap_min_perc
    self.EY_H2_nom_prod = Ref_EY_H2_hourly_nom_prod / Ref_EY_var_net_nom_cons * EY_var_net_nom_cons_ud
    self.EY_harmonious_max_perc = min(
      1,
      MethSynt_H2_nom_cons / EY_H2_nom_prod,
      CCU_CO2_nom_prod_ud / MethSynt_CO2_nom_cons * MethSynt_H2_nom_cons / EY_H2_nom_prod,
      MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud * MethSynt_H2_nom_cons / EY_H2_nom_prod
    )
    self.EY_harmonious_min_perc = max(
      EY_cap_min_perc,
      MethSynt_H2_min_cons / EY_H2_nom_prod,
      max(MethSynt_cap_min_perc, CCU_CO2_min_prod / MethSynt_CO2_nom_cons) * MethSynt_H2_nom_cons / EY_H2_nom_prod,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_H2_nom_cons / EY_H2_nom_prod
    )
    self.EY_harmonious_perc_at_PB_min = EY_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_min
    self.EY_harmonious_perc_at_PB_nom = iff(PB_nom_net_cap / Overall_harmonious_var_max_cons * EY_harmonious_max_perc < EY_harmonious_min_perc, 0, PB_nom_net_cap / Overall_harmonious_var_max_cons * EY_harmonious_max_perc)
    self.EY_heat_fix_cons = EY_var_net_nom_cons_ud / Ref_EY_var_net_nom_cons * Ref_EY_heat_fix_cons
    self.EY_heat_stby_cons = EY_var_net_nom_cons_ud / Ref_EY_var_net_nom_cons * Ref_EY_heat_stby_cons
    self.EY_heat_stup_cons = EY_var_net_nom_cons_ud / Ref_EY_var_net_nom_cons * Ref_EY_heat_stup_cons
    self.EY_stby_cons = EY_var_net_nom_cons_ud / Ref_EY_var_net_nom_cons * Ref_EY_stby_cons
    self.EY_stup_cons = EY_var_net_nom_cons_ud / Ref_EY_var_net_nom_cons * Ref_EY_stup_cons
    self.EY_var_aux_min_cons = (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) * EY_cap_min_perc
    self.EY_var_aux_nom_cons = EY_var_net_nom_cons_ud / Ref_EY_var_net_nom_cons * Ref_EY_var_nom_cons
    self.EY_var_gross_nom_cons = EY_var_net_nom_cons_ud + EY_var_aux_nom_cons
    self.EY_var_heat_nom_cons = Ref_EY_var_heat_nom_cons * EY_var_net_nom_cons_ud / Ref_EY_var_net_nom_cons
    self.EY_var_net_nom_cons_ud = 310.0
    // self.fix_aux_el_C0 = 0.87197586317594244
    // self.fix_aux_el_C1 = 0.29314511444598762
    // self.fix_aux_el_C2 = -0.49536293286578681
    // self.fix_aux_el_C3 = 0.33024195524385674
    // self.fix_stby_el_C0 = 0.8910127968928524
    // self.fix_stby_el_C1 = 0.21455823229400395
    // self.fix_stby_el_C2 = -0.31671308756057304
    // self.fix_stby_el_C3 = 0.21114205837371655
    // self.fix_stup_el_C0 = 0.89405519494415775
    // self.fix_stup_el_C1 = 0.19885240173966706
    // self.fix_stup_el_C2 = -0.27872279005147399
    // self.fix_stup_el_C3 = 0.18581519336764935
    self.Grid_export_max_ud = 50.0
    self.Grid_import_max_ud = 50.0
    self.H2_storage_cap_ud = 50.0
    self.Heater_cap_ud = 300.0
    self.Heater_eff = 0.96
    self.Heater_outlet_T = 565.0

    self.MethDist_cap_min_perc = 0.5
    self.MethDist_fix_cons = MethDist_Meth_nom_prod_ud / Ref_MethDist_meth_hourly_prod * Ref_MethDist_fix_cons
    self.MethDist_H2O_min_prod = MethDist_H2O_nom_prod * MethDist_cap_min_perc
    self.MethDist_H2O_nom_prod = MethDist_Meth_nom_prod_ud / Ref_MethDist_meth_hourly_prod * Ref_MethDist_water_hourly_prod
    self.MethDist_harmonious_max_perc = min(
      1,
      MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      EY_H2_nom_prod / MethSynt_H2_nom_cons * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      CCU_CO2_nom_prod_ud / MethSynt_CO2_nom_cons * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons
    )
    self.MethDist_harmonious_min_perc = max(
      MethDist_cap_min_perc,
      MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, EY_H2_min_prod / MethSynt_H2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, CCU_CO2_min_prod / MethSynt_CO2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons
    )
    self.MethDist_harmonious_perc_at_PB_min = MethDist_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_min
    self.MethDist_harmonious_perc_at_PB_nom = iff(
      PB_nom_net_cap / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc < MethDist_harmonious_min_perc,
      0,
      PB_nom_net_cap / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc
    )
    self.MethDist_heat_fix_cons = MethDist_Meth_nom_prod_ud / Ref_MethDist_meth_hourly_prod * Ref_MethDist_heat_fix_cons
    self.MethDist_heat_stby_cons = MethDist_Meth_nom_prod_ud / Ref_MethDist_meth_hourly_prod * Ref_MethDist_heat_stby_cons
    self.MethDist_heat_stup_cons = MethDist_Meth_nom_prod_ud / Ref_MethDist_meth_hourly_prod * Ref_MethDist_heat_stup_cons
    self.MethDist_Meth_min_prod = MethDist_cap_min_perc * MethDist_Meth_nom_prod_ud
    self.MethDist_Meth_nom_prod_ud = 20.0
    self.MethDist_RawMeth_min_cons = MethDist_RawMeth_nom_cons * MethDist_cap_min_perc
    self.MethDist_RawMeth_nom_cons = MethDist_Meth_nom_prod_ud / Ref_MethDist_meth_hourly_prod * Ref_MethDist_rawmeth_hourly_cons
    self.MethDist_stby_cons = MethDist_Meth_nom_prod_ud / Ref_MethDist_meth_hourly_prod * Ref_MethDist_stby_cons
    self.MethDist_stup_cons = MethDist_Meth_nom_prod_ud / Ref_MethDist_meth_hourly_prod * Ref_MethDist_stup_cons
    self.MethDist_var_heat_nom_cons = MethDist_Meth_nom_prod_ud / Ref_MethDist_meth_hourly_prod * Ref_MethDist_var_heat_nom_cons
    self.MethDist_var_nom_cons = MethDist_Meth_nom_prod_ud / Ref_MethDist_meth_hourly_prod * Ref_MethDist_var_nom_cons
    self.MethSynt_annual_op_days = 365.25 - MethSynt_annual_outage_days
    self.MethSynt_annual_op_hours = MethSynt_annual_op_days * 24.0
    self.MethSynt_annual_outage_days = 32.0
    self.MethSynt_cap_min_perc = 0.1
    self.MethSynt_CO2_min_cons = MethSynt_CO2_nom_cons * MethSynt_cap_min_perc
    self.MethSynt_CO2_nom_cons = MethSynt_RawMeth_nom_prod_ud / Ref_MethSynt_rawmeth_hourly_prod * Ref_MethSynt_CO2_hourly_cons
    self.MethSynt_fix_cons = MethSynt_RawMeth_nom_prod_ud / Ref_MethSynt_rawmeth_hourly_prod * Ref_MethSynt_fix_cons
    self.MethSynt_H2_min_cons = MethSynt_H2_nom_cons * MethSynt_cap_min_perc
    self.MethSynt_H2_nom_cons = MethSynt_RawMeth_nom_prod_ud / Ref_MethSynt_rawmeth_hourly_prod * Ref_MethSynt_H2_hourly_cons
    self.MethSynt_harmonious_max_perc = min(1, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud, EY_H2_nom_prod / MethSynt_H2_nom_cons, CCU_CO2_nom_prod_ud / MethSynt_CO2_nom_cons)
    self.MethSynt_harmonious_min_perc = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, EY_H2_min_prod / MethSynt_H2_nom_cons, CCU_CO2_min_prod / MethSynt_CO2_nom_cons)
    self.MethSynt_harmonious_perc_at_PB_min = MethSynt_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_min
    self.MethSynt_harmonious_perc_at_PB_nom = iff(
      PB_nom_net_cap / Overall_harmonious_var_max_cons * MethSynt_harmonious_max_perc < MethSynt_harmonious_min_perc,
      0,
      PB_nom_net_cap / Overall_harmonious_var_max_cons * MethSynt_harmonious_max_perc
    )
    self.MethSynt_heat_fix_prod = MethSynt_RawMeth_nom_prod_ud / Ref_MethSynt_rawmeth_hourly_prod * Ref_MethSynt_heat_fix_prod
    self.MethSynt_heat_stby_cons = MethSynt_RawMeth_nom_prod_ud / Ref_MethSynt_rawmeth_hourly_prod * Ref_MethSynt_heat_stby_cons
    self.MethSynt_RawMeth_min_prod = MethSynt_RawMeth_nom_prod_ud * MethSynt_cap_min_perc
    self.MethSynt_RawMeth_nom_prod_ud = 50.0
    self.MethSynt_stby_cons = MethSynt_RawMeth_nom_prod_ud / Ref_MethSynt_rawmeth_hourly_prod * Ref_MethSynt_stby_cons
    self.MethSynt_stup_duration = 15.0
    self.MethSynt_var_heat_nom_prod = MethSynt_RawMeth_nom_prod_ud / Ref_MethSynt_rawmeth_hourly_prod * Ref_MethSynt_var_heat_nom_prod
    self.MethSynt_var_nom_cons = MethSynt_RawMeth_nom_prod_ud / Ref_MethSynt_rawmeth_hourly_prod * Ref_MethSynt_var_nom_cons
    self.Overall_fix_cons = EY_fix_cons + MethSynt_fix_cons + MethDist_fix_cons + CCU_fix_cons
    self.Overall_harmonious_max_perc = 1.0
    self.Overall_harmonious_min_perc = Overall_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_min_cons
    self.Overall_harmonious_perc_at_PB_min = Overall_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_min
    self.Overall_harmonious_perc_at_PB_nom = Overall_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_nom
    self.Overall_harmonious_var_cons_at_PB_min = max(PB_net_min_cap, Overall_harmonious_var_min_cons)
    self.Overall_harmonious_var_cons_at_PB_nom = min(PB_nom_net_cap, Overall_harmonious_var_max_cons)
    self.Overall_harmonious_var_heat_cons_at_PB_min = Overall_harmonious_var_cons_at_PB_min / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons
    self.Overall_harmonious_var_heat_cons_at_PB_nom = Overall_harmonious_var_heat_max_cons / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_nom
    self.Overall_harmonious_var_heat_max_cons =
      EY_harmonious_max_perc * EY_var_heat_nom_cons + MethDist_harmonious_max_perc * MethDist_var_heat_nom_cons - MethSynt_harmonious_max_perc * MethSynt_var_heat_nom_prod + CCU_harmonious_max_perc * CCU_var_heat_nom_cons
    self.Overall_harmonious_var_heat_min_cons =
      EY_var_heat_nom_cons * EY_harmonious_min_perc + MethDist_var_heat_nom_cons * MethDist_harmonious_min_perc - MethSynt_var_heat_nom_prod * MethSynt_harmonious_min_perc + CCU_var_heat_nom_cons * CCU_harmonious_min_perc
    self.Overall_harmonious_var_max_cons =
      EY_harmonious_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + MethSynt_harmonious_max_perc * MethSynt_var_nom_cons + MethDist_harmonious_max_perc * MethDist_var_nom_cons + CCU_harmonious_max_perc
      * CCU_var_nom_cons
    self.Overall_harmonious_var_min_cons =
      EY_harmonious_min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + MethSynt_harmonious_min_perc * MethSynt_var_nom_cons + MethDist_harmonious_min_perc * MethDist_var_nom_cons + CCU_harmonious_min_perc
      * CCU_var_nom_cons
    self.Overall_heat_fix_cons = EY_heat_fix_cons + MethSynt_heat_fix_prod - MethDist_heat_fix_cons + CCU_fix_heat_cons
    self.PB_cold_start_duration = 48.0
    self.PB_cold_start_energyperc = 2.0
    self.PB_cold_start_heat_req = PB_nom_heat_cons * PB_cold_start_energyperc
    self.PB_eff_at_max_harmonious = ifFinite(
      iff(
        PB_gross_cap_at_max_harmonious = PB_nom_gross_cap_ud,
        PB_nom_gross_eff,
        PB_nom_gross_eff
          * el(PB_gross_cap_at_max_harmonious / PB_nom_gross_cap_ud)
      ),
      0
    )
    self.PB_eff_at_min_harmonious = ifFinite(
      PB_nom_gross_eff
        * el(max(PB_gross_min_cap, PB_gross_cap_at_min_harmonious) / PB_nom_gross_cap_ud),
      0
    )
    self.PB_el_cap_min_perc = Ref_PB_25p_gross_cap_max_aux_heat / Ref_PB_nom_gross_cap
    self.PB_fix_aux_el =
      Ref_PB_nom_gross_cap * PB_fix_aux_elec_cons_perc_of_ref
      * fix_aux_el_C3(PB_nom_gross_cap_ud / Ref_PB_nom_gross_cap)
    self.PB_fix_aux_elec_cons_perc_of_ref = 6.4340704330890603E-3
    // self.PB_g2n_var_aux_el_C0 = PB_var_aux_cons_C0
    // self.PB_g2n_var_aux_el_C1 = PB_var_aux_cons_C1
    // self.PB_g2n_var_aux_el_C2 = PB_var_aux_cons_C2
    // self.PB_g2n_var_aux_el_C3 = PB_var_aux_cons_C3
    self.PB_gross_cap_at_max_harmonious =
      PB_fix_aux_el + PB_net_cap_at_max_harmonious + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
      * (PB_n2g_var_aux_el_C3 * (PB_net_cap_at_max_harmonious / PB_nom_net_cap) ** 3 + PB_n2g_var_aux_el_C2 * (PB_net_cap_at_max_harmonious / PB_nom_net_cap) ** 2 + PB_n2g_var_aux_el_C1
        * (PB_net_cap_at_max_harmonious / PB_nom_net_cap) ** 1 + PB_n2g_var_aux_el_C0)
    self.PB_gross_cap_at_min_harmonious =
      PB_net_cap_at_min_harmonious + PB_fix_aux_el + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
      * PB_n2g_var_aux_el(PB_net_cap_at_min_harmonious / PB_nom_net_cap)
    self.PB_gross_min_cap = PB_nom_gross_cap_ud * PB_el_cap_min_perc
    self.PB_gross_min_eff = PB_gross_min_cap / PB_heat_min_input
    self.PB_heat_input_at_max_harmonious = ifFinite(PB_gross_cap_at_max_harmonious / PB_eff_at_max_harmonious, 0)
    self.PB_heat_input_at_min_harmonious = ifFinite(PB_gross_cap_at_min_harmonious / PB_eff_at_min_harmonious, 0)
    self.PB_heat_min_input = ifFinite(
      PB_gross_min_cap / (PB_nom_gross_eff * el(PB_el_cap_min_perc)),
      0
    )
    self.PB_hot_start_energyperc = 0.05
    self.PB_hot_start_heat_req = PB_nom_heat_cons * PB_hot_start_energyperc
    // self.PB_n2g_var_aux_el_C0 = PB_calcO49
    // self.PB_n2g_var_aux_el_C1 = PB_calcN49
    // self.PB_n2g_var_aux_el_C2 = PB_calcM49
    // self.PB_n2g_var_aux_el_C3 = PB_calcL49
    self.PB_net_cap_at_max_harmonious = min(PB_nom_net_cap, max(PB_net_min_cap, Overall_harmonious_var_max_cons + Overall_fix_cons))
    self.PB_net_cap_at_min_harmonious = min(PB_nom_net_cap, max(PB_net_min_cap, Overall_harmonious_var_min_cons + Overall_fix_cons))
    self.PB_net_min_cap =
      PB_gross_min_cap - PB_fix_aux_el - PB_nom_var_aux_cons
      * (PB_g2n_var_aux_el_C3 * (PB_gross_min_cap / PB_nom_gross_cap_ud) ** 3 + PB_g2n_var_aux_el_C2 * (PB_gross_min_cap / PB_nom_gross_cap_ud) ** 2 + PB_g2n_var_aux_el_C1 * (PB_gross_min_cap / PB_nom_gross_cap_ud) ** 1
        + PB_g2n_var_aux_el_C0 * (PB_gross_min_cap / PB_nom_gross_cap_ud) ** 0)
    self.PB_nom_gross_cap_ud = 150.0
    self.PB_nom_gross_eff = PB_calcI16
    self.PB_nom_heat_cons = ifFinite(PB_nom_gross_cap_ud / PB_nom_gross_eff, 0)
    self.PB_nom_net_cap = PB_nom_gross_cap_ud - PB_nom_var_aux_cons - PB_fix_aux_el
    self.PB_nom_var_aux_cons = PB_nom_gross_cap_ud * PB_nom_var_aux_cons_perc_gross
    self.PB_nom_var_aux_cons_perc_gross = 3.3931144552042103E-2
    self.PB_nom_var_aux_cons_perc_net = PB_calcI18
    self.PB_op_hours_min_nr = 5
    self.PB_Ratio_Heat_input_vs_output = PB_calcI14
    self.PB_stby_aux_cons =
      PB_nom_gross_cap_ud * PB_stby_var_aux_cons_perc + Ref_PB_nom_gross_cap * PB_stby_fix_aux_cons_perc
      * fix_stby_el(PB_nom_gross_cap_ud / Ref_PB_nom_gross_cap)
    self.PB_stby_fix_aux_cons_perc = 5.2640704330890603E-3
    self.PB_stby_var_aux_cons_perc = 4.6250983512691503E-3
    self.PB_stup_aux_cons =
      PB_nom_gross_cap_ud * PB_stup_var_aux_elec_cons_perc + Ref_PB_nom_gross_cap * PB_stup_fix_aux_elec_cons_perc
      * fix_stup_el(PB_nom_gross_cap_ud / Ref_PB_nom_gross_cap)
    self.PB_stup_fix_aux_elec_cons_perc = 5.9815704330890597E-3
    self.PB_stup_var_aux_elec_cons_perc = 1.2789153998036399E-2
    self.PB_var_aux_cons_C0 = 0.29437013201591916
    self.PB_var_aux_cons_C1 = 0.10280513176871063
    self.PB_var_aux_cons_C2 = -6.5249624421765337E-2
    self.PB_var_aux_cons_C3 = 0.67514642417652304
    self.PB_var_heat_max_cons = PB_calcI17
    self.PB_warm_start_duration = 6.0
    self.PB_warm_start_energyperc = 0.4
    self.PB_warm_start_heat_req = PB_nom_heat_cons * PB_warm_start_energyperc
    self.PV_AC_cap_ud = 800.0
    self.PV_DC_cap_ud = 1116.0
    self.Ratio_CSP_vs_Heater =
      (_xll.h(SS, Heater_outlet_T) - _xll.h(SS, CSP_Hot_HTF_T - SF_heat_exch_approach_temp)) / (_xll.h(SS, CSP_Hot_HTF_T - SF_heat_exch_approach_temp) - _xll.h(SS, CSP_Cold_HTF_T - SF_heat_exch_approach_temp))
    self.RawMeth_storage_cap_ud = 300.0
    self.Ref_CCU_CO2_hourly_prod = 22.0
    self.Ref_CCU_fix_cons = 0.0
    self.Ref_CCU_heat_fix_cons = 0.0
    self.Ref_CCU_heat_stby_cons = 0.0
    self.Ref_CCU_heat_stup_cons = 0.0
    self.Ref_CCU_stby_cons = 0.0
    self.Ref_CCU_stup_cons = 0.0
    self.Ref_CCU_var_heat_nom_cons = 22.0
    self.Ref_CCU_var_nom_cons = 2.0
    self.Ref_EY_fix_cons = 0.0
    self.Ref_EY_H2_hourly_nom_prod = Ref_EY_var_net_nom_cons / 55
    self.Ref_EY_heat_fix_cons = 0.0
    self.Ref_EY_heat_stby_cons = 0.0
    self.Ref_EY_heat_stup_cons = 0.0
    self.Ref_EY_stby_cons = 0.0
    self.Ref_EY_stup_cons = 0.0
    self.Ref_EY_var_heat_nom_cons = 40.0
    self.Ref_EY_var_net_nom_cons = 180.0
    self.Ref_EY_var_nom_cons = 2.7
    self.Ref_Inv_eff_approx_handover = Inv_EffC22
    self.Ref_MethDist_fix_cons = 0
    self.Ref_MethDist_heat_fix_cons = 0.0
    self.Ref_MethDist_heat_stby_cons = 1.7
    self.Ref_MethDist_heat_stup_cons = 1.7
    self.Ref_MethDist_meth_annual_prod = 100000
    self.Ref_MethDist_meth_hourly_prod = Ref_MethDist_meth_annual_prod / MethSynt_annual_op_hours
    self.Ref_MethDist_rawmeth_hourly_cons = Ref_MethSynt_rawmeth_hourly_prod
    self.Ref_MethDist_stby_cons = 0.0
    self.Ref_MethDist_stup_cons = 0.0
    self.Ref_MethDist_var_heat_nom_cons = 17.53
    self.Ref_MethDist_var_nom_cons = 1.1000000000000001
    self.Ref_MethDist_water_annual_prod = 56227.0
    self.Ref_MethDist_water_hourly_prod = Ref_MethDist_water_annual_prod / MethSynt_annual_op_hours
    self.Ref_MethSynt_CO2_annual_cons = 137372.0
    self.Ref_MethSynt_CO2_hourly_cons = Ref_MethSynt_CO2_annual_cons / MethSynt_annual_op_hours
    self.Ref_MethSynt_fix_cons = 0.0
    self.Ref_MethSynt_H2_annual_cons = 18894.0
    self.Ref_MethSynt_H2_hourly_cons = Ref_MethSynt_H2_annual_cons / MethSynt_annual_op_hours
    self.Ref_MethSynt_heat_fix_prod = 0.0
    self.Ref_MethSynt_heat_stby_cons = 1.0
    self.Ref_MethSynt_heat_stup_cons = 1.0
    self.Ref_MethSynt_rawmeth_hourly_prod = Ref_MethSynt_CO2_hourly_cons + Ref_MethSynt_H2_hourly_cons
    self.Ref_MethSynt_stby_cons = 0.0
    self.Ref_MethSynt_stup_cons = 0.0
    self.Ref_MethSynt_var_heat_nom_prod = 5.4
    self.Ref_MethSynt_var_nom_cons = 1.4
    self.Ref_PB_25p_aux_heat_prod = (7.194 * 2775.4 - 5.414 * 167.6 - 1.78 * 649.6) / 1000
    self.Ref_PB_25p_gross_cap = 25.0
    self.Ref_PB_25p_gross_cap_max_aux_heat = 25
    self.Ref_PB_25p_gross_eff = Ref_PB_25p_gross_cap / Ref_PB_25p_heat_cons
    self.Ref_PB_25p_gross_eff_excl_aux_heat_cons = PB_calcE22
    self.Ref_PB_25p_gross_eff_excl_max_aux_heat_cons = PB_calcE24
    self.Ref_PB_25p_gross_eff_max_aux_heat = Ref_PB_25p_gross_cap_max_aux_heat / Ref_PB_25p_heat_cons_max_aux_heat
    self.Ref_PB_25p_heat_cons = 85.512
    self.Ref_PB_25p_heat_cons_excl_aux_heat = PB_calcE21
    self.Ref_PB_25p_heat_cons_excl_max_aux_heat = PB_calcE23
    self.Ref_PB_25p_heat_cons_max_aux_heat = 112.349
    self.Ref_PB_25p_max_aux_heat_prod = (23.333 * 2775.4 - 15.167 * 167.6 - 8.167 * 649.6) / 1000.0
    self.Ref_PB_30p_aux_heat_prod = (10.778 * 2775.4 - 8.278 * 167.6 - 2.5 * 649.6) / 1000.0
    self.Ref_PB_30p_gross_cap = 63.0
    self.Ref_PB_30p_gross_eff = Ref_PB_30p_gross_cap / Ref_PB_30p_heat_cons
    self.Ref_PB_30p_gross_eff_excl_aux_heat_cons = PB_calcE20
    self.Ref_PB_30p_heat_cons = 168.78700000000001
    self.Ref_PB_30p_heat_cons_excl_aux_heat = PB_calcE19
    self.Ref_PB_nom_aux_heat_prod = (23.333 * 2775.4 - 15.167 * 167.6 - 8.167 * 649.6) / 1000.0
    self.Ref_PB_nom_gross_cap = 200.0
    self.Ref_PB_nom_gross_eff = Ref_PB_nom_gross_cap / Ref_PB_nom_heat_cons
    self.Ref_PB_nom_gross_eff_excl_aux_heat_cons = PB_calcE18
    self.Ref_PB_nom_heat_cons = 463.48500000000001
    self.Ref_PB_nom_heat_cons_excl_aux_heat = PB_calcE17
    self.Ref_PV_AC_cap = max(Calculation_G5, G8764)
    self.Ref_PV_DC_cap = 683.4
    self.SF_heat_exch_approach_temp = 7.0
    self.TES_aux_cons_perc = 0.01
    self.TES_cold_tank_T = 304.55
    self.TES_dead_mass_ratio = 0.1
    self.TES_full_load_hours_ud = 14.0
    // self.TES_salt_mass = TES_thermal_cap * 1000.0 * 3600.0 / (_xll.h(SS, Heater_outlet_T) - _xll.h(SS, TES_cold_tank_T)) / 1000 * (1 + TES_dead_mass_ratio)
    self.TES_thermal_cap = TES_full_load_hours_ud * PB_nom_heat_cons
    // self.th_C0 = PB_calcU3
    // self.th_C1 = PB_calcT3
    // self.th_C2 = PB_calcS3
    // self.th_C3 = PB_calcR3
    // self.Th_C4 = PB_calcQ3

  }

}
*/
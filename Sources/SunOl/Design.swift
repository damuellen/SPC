import Utilities

struct TunOl {
  let A_CCU_max_perc: Double = 0
  let A_CCU_Min_perc: Double = 0
  let A_C_O_2_max_cons: Double
  let A_C_O_2_min_cons: Double
  let A_equiv_harmonious_max_perc: Double
  let A_equiv_harmonious_min_perc: Double
  let A_EY_max_perc: Double = 0
  let A_EY_Min_perc: Double = 0
  let A_Hydrogen_max_cons: Double
  let A_Hydrogen_min_cons: Double
  let A_MethDist_max_perc: Double
  let A_MethDist_Min_perc: Double
  let A_MethSynt_max_perc: Double = 0
  let A_MethSynt_Min_perc: Double = 0
  let A_overall_fix_stby_cons: Double
  let A_overall_heat_fix_stby_cons: Double
  let A_overall_heat_stup_cons: Double
  let A_overall_stup_cons: Double
  let A_overall_var_heat_max_cons: Double
  let A_overall_var_heat_min_cons: Double
  let A_overall_var_max_cons: Double
  let A_overall_var_min_cons: Double
  let A_RawMeth_max_cons: Double
  let A_RawMeth_min_cons: Double
  let B_CCU_max_perc: Double
  let B_CCU_Min_perc: Double
  let B_C_O_2_max_cons: Double
  let B_C_O_2_min_cons: Double
  let B_equiv_harmonious_max_perc: Double
  let B_equiv_harmonious_min_perc: Double
  let B_EY_max_perc: Double
  let B_EY_Min_perc: Double
  let B_Hydrogen_max_cons: Double
  let B_Hydrogen_min_cons: Double
  let B_MethDist_max_perc: Double
  let B_MethDist_Min_perc: Double
  let B_MethSynt_max_perc: Double
  let B_MethSynt_Min_perc: Double
  let B_overall_fix_stby_cons: Double
  let B_overall_heat_fix_stby_cons: Double
  let B_overall_heat_stup_cons: Double
  let B_overall_stup_cons: Double
  let B_overall_var_heat_max_cons: Double
  let B_overall_var_heat_min_cons: Double
  let B_overall_var_max_cons: Double
  let B_overall_var_min_cons: Double
  let B_RawMeth_max_cons: Double
  let B_RawMeth_min_cons: Double
  let BESS_chrg_eff: Double = 0.7
  let BESS_chrg_max_cons: Double
  let BESS_chrg_max_ratio: Double = 0.5
  let C_CCU_max_perc: Double
  let C_CCU_Min_perc: Double
  let C_C_O_2_max_cons: Double
  let C_C_O_2_min_cons: Double
  let C_equiv_harmonious_max_perc: Double
  let C_equiv_harmonious_min_perc: Double
  let C_EY_max_perc: Double
  let C_EY_min_perc: Double
  let C_Hydrogen_max_cons: Double
  let C_Hydrogen_min_cons: Double
  let C_MethDist_max_perc: Double
  let C_MethDist_min_perc: Double
  let C_MethSynt_max_perc: Double
  let C_MethSynt_min_perc: Double
  let C_overall_fix_stby_cons: Double
  let C_overall_heat_fix_stby_cons: Double
  let C_overall_heat_stup_cons: Double
  let C_overall_stup_cons: Double
  let C_overall_var_heat_max_cons: Double
  let C_overall_var_heat_min_cons: Double
  let C_overall_var_max_cons: Double
  let C_overall_var_min_cons: Double
  let C_RawMeth_max_cons: Double
  let C_RawMeth_min_cons: Double
  let CCU_cap_min_perc: Double = 0.5
  let CCU_C_O_2_min_prod: Double
  let CCU_fix_cons: Double
  let CCU_fix_heat_cons: Double
  let CCU_harmonious_max_perc: Double
  let CCU_harmonious_min_perc: Double
  let CCU_harmonious_perc_at_PB_min: Double
  let CCU_harmonious_perc_at_PB_nom: Double
  let CCU_heat_stby_cons: Double
  let CCU_heat_stup_cons: Double
  let CCU_Ref_C_O_2_hourly_prod: Double = 22
  let CCU_Ref_fix_cons: Double = 0
  let CCU_Ref_heat_fix_cons: Double = 0
  let CCU_Ref_heat_stby_cons: Double = 0
  let CCU_Ref_heat_stup_cons: Double = 1
  let CCU_Ref_stby_cons: Double = 0
  let CCU_Ref_stup_cons: Double = 1
  let CCU_Ref_var_heat_nom_cons: Double = 22
  let CCU_Ref_var_nom_cons: Double = 2
  let CCU_stby_cons: Double
  let CCU_stup_cons: Double
  let CCU_var_heat_nom_cons: Double
  let CCU_var_nom_cons: Double
  let CD_CCU_max_perc: Double
  let CD_CCU_min_perc: Double
  let CD_C_O_2_max_cons: Double
  let CD_C_O_2_min_cons: Double
  let CD_equiv_harmonious_max_perc: Double
  let CD_equiv_harmonious_min_perc: Double
  let CD_EY_max_perc: Double
  let CD_EY_min_perc: Double
  let CD_Hydrogen_max_cons: Double
  let CD_Hydrogen_min_cons: Double
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
  let CSP_Cold_HTF_T: Double
  let CSP_Hot_HTF_T: Double = 425
  let CSP_night_aux_cons_per_loop: Double = 3.0E-3
  let CSP_nonsolar_aux_cons: Double
  let CSP_SF_Max_th_Power: Double
  let CSP_var_aux_nom_perc: Double = 0.01
  let CCU_max_perc: [Double]
  let CCU_min_perc: [Double]
  let C_O_2_max_cons: [Double]
  let C_O_2_min_cons: [Double]
  let equiv_harmonious_max_perc: [Double]
  let equiv_harmonious_min_perc: [Double]
  let EY_max_perc: [Double]
  let EY_min_perc: [Double]
  let Hydrogen_max_cons: [Double]
  let Hydrogen_min_cons: [Double]
  let MethDist_max_perc: [Double]
  let MethDist_min_perc: [Double]
  let MethSynt_max_perc: [Double]
  let MethSynt_min_perc: [Double]
  let overall_fix_stby_cons: [Double]
  let overall_heat_fix_stby_cons: [Double]
  let overall_heat_stup_cons: [Double]
  let overall_stup_cons: [Double]
  let overall_var_heat_max_cons: [Double]
  let overall_var_heat_min_cons: [Double]
  let overall_var_max_cons: [Double]
  let overall_var_min_cons: [Double]
  let RawMeth_max_cons: [Double]
  let RawMeth_min_cons: [Double]
  let Density_C_O_2: Double = 945
  let Density_Hydrogen: Double = 5.783
  let El_boiler_eff: Double = 0.99
  let el_Coeff: [Double]
  let el_C0: Double
  let el_C1: Double
  let el_C2: Double
  let el_C3: Double
  let el_C4: Double
  let EY_aux_heat_input_at_min_PB: Double
  let EY_cap_min_perc: Double = 0.1
  let EY_fix_cons: Double
  let EY_Hydrogen_min_prod: Double
  let EY_Hydrogen_nom_prod: Double
  let EY_harmonious_max_perc: Double
  let EY_harmonious_min_perc: Double
  let EY_harmonious_perc_at_PB_min: Double
  let EY_harmonious_perc_at_PB_nom: Double
  let EY_heat_fix_cons: Double
  let EY_heat_stby_cons: Double
  let EY_heat_stup_cons: Double
  let EY_Ref_fix_cons: Double
  let EY_Ref_Hydrogen_hourly_nom_prod: Double
  let EY_Ref_heat_fix_cons: Double
  let EY_Ref_heat_stby_cons: Double
  let EY_Ref_heat_stup_cons: Double
  let EY_Ref_stby_cons: Double
  let EY_Ref_stup_cons: Double
  let EY_Ref_var_heat_nom_cons: Double
  let EY_Ref_var_net_nom_cons: Double
  let EY_Ref_var_nom_cons: Double
  let EY_stby_cons: Double
  let EY_stup_cons: Double
  let EY_var_aux_min_cons: Double
  let EY_var_aux_nom_cons: Double
  let EY_var_gross_nom_cons: Double
  let EY_var_heat_nom_cons: Double
  let fix_aux_el = [0.87197586317594244, 0.29314511444598762, -0.49536293286578681, 0.33024195524385674]
  let fix_stby_el = [0.8910127968928524, 0.21455823229400395, -0.31671308756057304, 0.21114205837371655]
  let fix_stup_el = [0.89405519494415775, 0.19885240173966706, -0.27872279005147399, 0.18581519336764935]
  let Heater_eff: Double = 0.96
  let Heater_outlet_T: Double = 565
  let HL_Coeff: [Double]
  let Inv_eff_Ref_approx_handover: Double
  let LL_Coeff: [Double]
  let MethDist_cap_min_perc: Double = 0.5
  let MethDist_fix_cons: Double
  let MethDist_HydrogenO_min_prod: Double
  let MethDist_HydrogenO_nom_prod: Double
  let MethDist_harmonious_max_perc: Double
  let MethDist_harmonious_min_perc: Double
  let MethDist_harmonious_perc_at_PB_min: Double
  let MethDist_harmonious_perc_at_PB_nom: Double
  let MethDist_heat_fix_cons: Double
  let MethDist_heat_stby_cons: Double
  let MethDist_heat_stup_cons: Double
  let MethDist_Meth_min_prod: Double
  let MethDist_RawMeth_min_cons: Double
  let MethDist_RawMeth_nom_cons: Double
  let MethDist_Ref_fix_cons: Double = 0
  let MethDist_Ref_heat_fix_cons: Double = 0
  let MethDist_Ref_heat_stby_cons: Double = 1.7
  let MethDist_Ref_heat_stup_cons: Double = 1.7
  let MethDist_Ref_meth_annual_prod: Double = 100000
  let MethDist_Ref_meth_hourly_prod: Double
  let MethDist_Ref_rawmeth_hourly_cons: Double
  let MethDist_Ref_stby_cons: Double = 0
  let MethDist_Ref_stup_cons: Double = 1
  let MethDist_Ref_var_heat_nom_cons: Double = 17.53
  let MethDist_Ref_var_nom_cons: Double = 1.1000000000000001
  let MethDist_Ref_water_annual_prod: Double = 56227
  let MethDist_Ref_water_hourly_prod: Double
  let MethDist_stby_cons: Double
  let MethDist_stup_cons: Double
  let MethDist_var_heat_nom_cons: Double
  let MethDist_var_nom_cons: Double
  let MethSynt_annual_op_days: Double
  let MethSynt_annual_op_hours: Double
  let MethSynt_annual_outage_days: Double = 32
  let MethSynt_cap_min_perc: Double = 0.1
  let MethSynt_C_O_2_min_cons: Double
  let MethSynt_C_O_2_nom_cons: Double
  let MethSynt_fix_cons: Double
  let MethSynt_Hydrogen_min_cons: Double
  let MethSynt_Hydrogen_nom_cons: Double
  let MethSynt_harmonious_max_perc: Double
  let MethSynt_harmonious_min_perc: Double
  let MethSynt_harmonious_perc_at_PB_min: Double
  let MethSynt_harmonious_perc_at_PB_nom: Double
  let MethSynt_heat_fix_prod: Double
  let MethSynt_heat_stby_cons: Double
  let MethSynt_heat_stup_cons: Double
  let MethSynt_RawMeth_min_prod: Double
  let MethSynt_Ref_C_O_2_annual_cons: Double = 137372
  let MethSynt_Ref_C_O_2_hourly_cons: Double
  let MethSynt_Ref_fix_cons: Double = 0
  let MethSynt_Ref_Hydrogen_annual_cons: Double = 18894
  let MethSynt_Ref_Hydrogen_hourly_cons: Double
  let MethSynt_Ref_heat_fix_prod: Double = 0
  let MethSynt_Ref_heat_stby_cons: Double = 1
  let MethSynt_Ref_heat_stup_cons: Double = 1
  let MethSynt_Ref_rawmeth_hourly_prod: Double
  let MethSynt_Ref_stby_cons: Double = 0
  let MethSynt_Ref_stup_cons: Double = 1
  let MethSynt_Ref_var_heat_nom_prod: Double = 5.4
  let MethSynt_Ref_var_nom_cons: Double = 1.4
  let MethSynt_stby_cons: Double
  let MethSynt_stup_cons: Double
  let MethSynt_stup_duration: Double = 15
  let MethSynt_var_heat_nom_prod: Double
  let MethSynt_var_nom_cons: Double
  let Overall_fix_cons: Double
  let Overall_harmonious_max_perc: Double = 1
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
  let PB_cold_start_duration: Double = 48
  let PB_cold_start_energyperc: Double = 2
  let PB_cold_start_heat_req: Double
  let PB_eff_at_max_harmonious: Double
  let PB_eff_at_min_harmonious: Double
  let PB_el_cap_min_perc: Double
  let PB_fix_aux_el: Double
  let PB_fix_aux_elec_cons_perc_of_ref: Double = 6.4340704330890603E-3
  let PB_g2n_var_aux_el_Coeff: [Double]
  let PB_gross_cap_at_max_harmonious: Double
  let PB_gross_cap_at_min_harmonious: Double
  let PB_gross_min_cap: Double
  let PB_gross_min_eff: Double
  let PB_heat_input_at_max_harmonious: Double
  let PB_heat_input_at_min_harmonious: Double
  let PB_heat_min_input: Double
  let PB_hot_start_energyperc: Double = 0.05
  let PB_hot_start_heat_req: Double
  let PB_n_g_var_aux_el_Coeff: [Double]
  let PB_n2g_var_aux_el_C0: Double
  let PB_n2g_var_aux_el_C1: Double
  let PB_n2g_var_aux_el_C2: Double
  let PB_n2g_var_aux_el_C3: Double
  let PB_net_cap_at_max_harmonious: Double
  let PB_net_cap_at_min_harmonious: Double
  let PB_net_min_cap: Double
  let PB_nom_gross_eff: Double
  let PB_nom_heat_cons: Double
  let PB_nom_net_cap: Double
  let PB_nom_var_aux_cons: Double
  let PB_nom_var_aux_cons_perc_gross: Double = 3.3931144552042103E-2
  let PB_nom_var_aux_cons_perc_net: Double
  let PB_op_hours_min_nr: Double = 5
  let PB_Ratio_Heat_input_vs_output: Double
  let PB_Ref_25p_aux_heat_prod: Double = (7.194 * 2775.4 - 5.414 * 167.6 - 1.78 * 649.6) / 1000
  let PB_Ref_25p_gross_cap: Double = 25
  let PB_Ref_25p_gross_cap_max_aux_heat: Double = 25
  let PB_Ref_25p_gross_eff: Double
  let PB_Ref_25p_gross_eff_excl_aux_heat_cons: Double
  let PB_Ref_25p_gross_eff_excl_max_aux_heat_cons: Double
  let PB_Ref_25p_gross_eff_max_aux_heat: Double
  let PB_Ref_25p_heat_cons: Double = 85.512
  let PB_Ref_25p_heat_cons_excl_aux_heat: Double
  let PB_Ref_25p_heat_cons_excl_max_aux_heat: Double
  let PB_Ref_25p_heat_cons_max_aux_heat: Double = 112.349
  let PB_Ref_25p_max_aux_heat_prod: Double = (23.333 * 2775.4 - 15.167 * 167.6 - 8.167 * 649.6) / 1000
  let PB_Ref_30p_aux_heat_prod: Double = (10.778 * 2775.4 - 8.278 * 167.6 - 2.5 * 649.6) / 1000
  let PB_Ref_30p_gross_cap: Double = 63
  let PB_Ref_30p_gross_eff: Double
  let PB_Ref_30p_gross_eff_excl_aux_heat_cons: Double
  let PB_Ref_30p_heat_cons: Double = 168.78700000000001
  let PB_Ref_30p_heat_cons_excl_aux_heat: Double
  let PB_Ref_nom_aux_heat_prod: Double = (23.333 * 2775.4 - 15.167 * 167.6 - 8.167 * 649.6) / 1000
  let PB_Ref_nom_gross_cap: Double = 200
  let PB_Ref_nom_gross_eff: Double
  let PB_Ref_nom_gross_eff_excl_aux_heat_cons: Double
  let PB_Ref_nom_heat_cons: Double = 463.48500000000001
  let PB_Ref_nom_heat_cons_excl_aux_heat: Double
  let PB_stby_aux_cons: Double
  let PB_stby_fix_aux_cons_perc: Double = 5.2640704330890603E-3
  let PB_stby_var_aux_cons_perc: Double = 4.6250983512691503E-3
  let PB_stup_aux_cons: Double
  let PB_stup_fix_aux_elec_cons_perc: Double = 5.9815704330890597E-3
  let PB_stup_var_aux_elec_cons_perc: Double = 1.2789153998036399E-2
  let PB_var_aux_cons = [0.29437013201591916, 0.10280513176871063, -6.5249624421765337E-2, 0.67514642417652304]
  let PB_var_heat_max_cons: Double
  let PB_warm_start_duration: Double = 6
  let PB_warm_start_energyperc: Double = 0.4
  let PB_warm_start_heat_req: Double
  let PV_Ref_AC_cap: Double
  let PV_Ref_DC_cap: Double = 683.4
  let Ratio_CSP_vs_Heater: Double
  let SF_heat_exch_approach_temp: Double = 7
  let TES_aux_cons_perc: Double = 0.01
  let TES_cold_tank_T: Double = 304.55
  let TES_dead_mass_ratio: Double = 0.1
  let TES_salt_mass: Double
  let TES_thermal_cap: Double
  let th_Coeff: [Double]
  let BESS_cap_ud: Double = 130
  let CCU_C_O_2_nom_prod_ud: Double = 35
  let C_O_2_storage_cap_ud: Double = 0
  let CSP_loop_nr_ud: Double = 130
  let El_boiler_cap_ud: Double = 100
  let EY_var_net_nom_cons_ud: Double = 400
  let Grid_export_max_ud: Double = 50
  let Grid_import_max_ud: Double = 50
  let Hydrogen_storage_cap_ud: Double = 60
  let Heater_cap_ud: Double = 300
  let MethDist_Meth_nom_prod_ud: Double = 20
  let MethSynt_RawMeth_nom_prod_ud: Double = 20
  let PB_nom_gross_cap_ud: Double = 150
  let PV_AC_cap_ud: Double = 80
  let PV_DC_cap_ud: Double = 1116
  let RawMeth_storage_cap_ud: Double = 300
  let TES_full_load_hours_ud: Double = 20
  let Grid_import_yes_no_BESS_strategy: Double = 0
  let Grid_import_yes_no_PB_strategy: Double = 0
/*
  init(
    BESS_cap_ud: Double = 130,
    CCU_C_O_2_nom_prod_ud: Double = 35,
    C_O_2_storage_cap_ud: Double,
    CSP_loop_nr_ud: Double = 130,
    El_boiler_cap_ud: Double = 100,
    EY_var_net_nom_cons_ud: Double = 400,
    Grid_export_max_ud: Double = 50,
    Grid_import_max_ud: Double = 50,
    Hydrogen_storage_cap_ud: Double = 60,
    Heater_cap_ud: Double = 300,
    MethDist_Meth_nom_prod_ud: Double = 20,
    MethSynt_RawMeth_nom_prod_ud: Double = 20,
    PB_nom_gross_cap_ud: Double = 150,
    PV_AC_cap_ud: Double = 800,
    PV_DC_cap_ud: Double = 1116,
    RawMeth_storage_cap_ud: Double = 300,
    TES_full_load_hours_ud: Double = 20
  ) {
    // self.A_CCU_max_perc = 0
    // self.A_CCU_Min_perc = 0
    let A_C_O_2_max_cons = -A_CCU_max_perc * CCU_C_O_2_nom_prod_ud + A_MethSynt_max_perc * MethSynt_C_O_2_nom_cons
    let A_C_O_2_min_cons = -A_CCU_Min_perc * CCU_C_O_2_nom_prod_ud + A_MethSynt_Min_perc * MethSynt_C_O_2_nom_cons
    let A_equiv_harmonious_max_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * A_MethDist_max_perc, 0), ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * A_MethSynt_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * A_CCU_max_perc, 0), ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * A_EY_max_perc, 0))
    let A_equiv_harmonious_min_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * A_MethDist_Min_perc, 0), ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * A_MethSynt_Min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * A_CCU_Min_perc, 0), ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * A_EY_Min_perc, 0))
    // self.A_EY_max_perc = 0
    // self.A_EY_Min_perc = 0
    let A_Hydrogen_max_cons = -A_EY_max_perc * EY_Hydrogen_nom_prod + A_MethSynt_max_perc * MethSynt_Hydrogen_nom_cons
    let A_Hydrogen_min_cons = -A_EY_Min_perc * EY_Hydrogen_nom_prod + A_MethSynt_Min_perc * MethSynt_Hydrogen_nom_cons
    let A_MethDist_max_perc = MethDist_harmonious_max_perc
    let A_MethDist_Min_perc = MethDist_cap_min_perc
    // self.A_MethSynt_max_perc = 0
    // self.A_MethSynt_Min_perc = 0
    let A_overall_fix_stby_cons = iff(A_MethDist_Min_perc > 0, MethDist_fix_cons, MethDist_stby_cons) + iff(A_MethSynt_Min_perc > 0, MethSynt_fix_cons, MethSynt_stby_cons) + iff(A_CCU_Min_perc > 0, CCU_fix_cons, CCU_stby_cons) + iff(A_EY_Min_perc > 0, EY_fix_cons, EY_stby_cons)
    let A_overall_heat_fix_stby_cons =
      iff(A_MethDist_max_perc > 0, MethDist_heat_fix_cons, MethDist_heat_stby_cons) + iff(A_MethSynt_max_perc > 0, -MethSynt_heat_fix_prod, MethSynt_heat_stby_cons) + iff(A_CCU_max_perc > 0, CCU_fix_heat_cons, CCU_heat_stby_cons)
      + iff(A_EY_max_perc > 0, EY_heat_fix_cons, EY_heat_stby_cons)
    let A_overall_heat_stup_cons = iff(A_MethDist_Min_perc > 0, 0, MethDist_heat_stup_cons) + iff(A_MethSynt_Min_perc > 0, 0, MethSynt_heat_stup_cons) + iff(A_CCU_Min_perc > 0, 0, CCU_heat_stup_cons) + iff(A_EY_Min_perc > 0, 0, EY_heat_stup_cons)
    let A_overall_stup_cons = iff(A_MethDist_Min_perc > 0, 0, MethDist_stup_cons) + iff(A_MethSynt_Min_perc > 0, 0, MethSynt_stup_cons) + iff(A_CCU_Min_perc > 0, 0, CCU_stup_cons) + iff(A_EY_Min_perc > 0, 0, EY_stup_cons)
    let A_overall_var_heat_max_cons = EY_var_heat_nom_cons * A_EY_max_perc + MethDist_var_heat_nom_cons * A_MethDist_max_perc - MethSynt_var_heat_nom_prod * A_MethSynt_max_perc + CCU_var_heat_nom_cons * A_CCU_max_perc
    let A_overall_var_heat_min_cons = EY_var_heat_nom_cons * A_EY_Min_perc + MethDist_var_heat_nom_cons * A_MethDist_Min_perc - MethSynt_var_heat_nom_prod * A_MethSynt_Min_perc + CCU_var_heat_nom_cons * A_CCU_Min_perc
    let A_overall_var_max_cons = A_EY_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + A_MethSynt_max_perc * MethSynt_var_nom_cons + A_MethDist_max_perc * MethDist_var_nom_cons + A_CCU_max_perc * CCU_var_nom_cons
    let A_overall_var_min_cons = A_EY_Min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + A_MethSynt_Min_perc * MethSynt_var_nom_cons + A_MethDist_Min_perc * MethDist_var_nom_cons + A_CCU_Min_perc * CCU_var_nom_cons
    let A_RawMeth_max_cons = -A_MethSynt_max_perc * MethSynt_RawMeth_nom_prod_ud + A_MethDist_max_perc * MethDist_RawMeth_nom_cons
    let A_RawMeth_min_cons = -A_MethSynt_Min_perc * MethSynt_RawMeth_nom_prod_ud + A_MethDist_Min_perc * MethDist_RawMeth_nom_cons
    let B_CCU_max_perc = 0
    let B_CCU_Min_perc = 0
    let B_C_O_2_max_cons = -B_CCU_max_perc * CCU_C_O_2_nom_prod_ud + B_MethSynt_max_perc * MethSynt_C_O_2_nom_cons
    let B_C_O_2_min_cons = -B_CCU_Min_perc * CCU_C_O_2_nom_prod_ud + B_MethSynt_Min_perc * MethSynt_C_O_2_nom_cons
    let B_equiv_harmonious_max_perc = max(ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * B_MethDist_max_perc, 0), ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * B_MethSynt_max_perc, 0), 0)
    let B_equiv_harmonious_min_perc = max(ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * B_MethDist_Min_perc, 0), ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * B_MethSynt_Min_perc, 0), 0)
    let B_EY_max_perc = 0
    let B_EY_Min_perc = 0
    let B_Hydrogen_max_cons = -B_EY_max_perc * EY_Hydrogen_nom_prod + B_MethSynt_max_perc * MethSynt_Hydrogen_nom_cons
    let B_Hydrogen_min_cons = -B_EY_Min_perc * EY_Hydrogen_nom_prod + B_MethSynt_Min_perc * MethSynt_Hydrogen_nom_cons
    let B_MethDist_max_perc = min(1, MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    let B_MethDist_Min_perc = max(MethDist_cap_min_perc, MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons, 0)
    let B_MethSynt_max_perc = min(1, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud)
    let B_MethSynt_Min_perc = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, 0)
    let B_overall_fix_stby_cons = iff(B_MethDist_Min_perc > 0, MethDist_fix_cons, MethDist_stby_cons) + iff(B_MethSynt_Min_perc > 0, MethSynt_fix_cons, MethSynt_stby_cons) + iff(B_CCU_Min_perc > 0, CCU_fix_cons, CCU_stby_cons) + iff(B_EY_Min_perc > 0, EY_fix_cons, EY_stby_cons)
    let B_overall_heat_fix_stby_cons =
      iff(B_MethDist_max_perc > 0, MethDist_heat_fix_cons, MethDist_heat_stby_cons) + iff(B_MethSynt_max_perc > 0, -MethSynt_heat_fix_prod, MethSynt_heat_stby_cons) + iff(B_CCU_max_perc > 0, CCU_fix_heat_cons, CCU_heat_stby_cons)
      + iff(B_EY_max_perc > 0, EY_heat_fix_cons, EY_heat_stby_cons)
    let B_overall_heat_stup_cons = iff(B_MethDist_Min_perc > 0, 0, MethDist_heat_stup_cons) + iff(B_MethSynt_Min_perc > 0, 0, MethSynt_heat_stup_cons) + iff(B_CCU_Min_perc > 0, 0, CCU_heat_stup_cons) + iff(B_EY_Min_perc > 0, 0, EY_heat_stup_cons)
    let B_overall_stup_cons = iff(B_MethDist_Min_perc > 0, 0, MethDist_stup_cons) + iff(B_MethSynt_Min_perc > 0, 0, MethSynt_stup_cons) + iff(B_CCU_Min_perc > 0, 0, CCU_stup_cons) + iff(B_EY_Min_perc > 0, 0, EY_stup_cons)
    let B_overall_var_heat_max_cons = EY_var_heat_nom_cons * B_EY_max_perc + MethDist_var_heat_nom_cons * B_MethDist_max_perc - MethSynt_var_heat_nom_prod * B_MethSynt_max_perc + CCU_var_heat_nom_cons * B_CCU_max_perc
    let B_overall_var_heat_min_cons = EY_var_heat_nom_cons * B_EY_Min_perc + MethDist_var_heat_nom_cons * B_MethDist_Min_perc - MethSynt_var_heat_nom_prod * B_MethSynt_Min_perc + CCU_var_heat_nom_cons * B_CCU_Min_perc
    let B_overall_var_max_cons = B_EY_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + B_MethSynt_max_perc * MethSynt_var_nom_cons + B_MethDist_max_perc * MethDist_var_nom_cons + B_CCU_max_perc * CCU_var_nom_cons
    let B_overall_var_min_cons = B_EY_Min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + B_MethSynt_Min_perc * MethSynt_var_nom_cons + B_MethDist_Min_perc * MethDist_var_nom_cons + B_CCU_Min_perc * CCU_var_nom_cons
    let B_RawMeth_max_cons = -B_MethSynt_max_perc * MethSynt_RawMeth_nom_prod_ud + B_MethDist_max_perc * MethDist_RawMeth_nom_cons
    let B_RawMeth_min_cons = -B_MethSynt_Min_perc * MethSynt_RawMeth_nom_prod_ud + B_MethDist_Min_perc * MethDist_RawMeth_nom_cons


    let BESS_chrg_max_cons = BESS_cap_ud * BESS_chrg_max_ratio

    let C_CCU_max_perc = min(1, MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud)
    let C_CCU_Min_perc = max(
      CCU_cap_min_perc, MethSynt_C_O_2_min_cons / CCU_C_O_2_nom_prod_ud, MethSynt_cap_min_perc * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud, max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud)
    let C_C_O_2_max_cons = -C_CCU_max_perc * CCU_C_O_2_nom_prod_ud + C_MethSynt_max_perc * MethSynt_C_O_2_nom_cons
    let C_C_O_2_min_cons = -C_CCU_Min_perc * CCU_C_O_2_nom_prod_ud + C_MethSynt_min_perc * MethSynt_C_O_2_nom_cons
    let C_equiv_harmonious_max_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * C_MethDist_max_perc, 0), ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * C_MethSynt_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * C_CCU_max_perc, 0), 0)
    let C_equiv_harmonious_min_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * C_MethDist_min_perc, 0), ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * C_MethSynt_min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * C_CCU_Min_perc, 0), 0)
    let C_EY_max_perc = 0
    let C_EY_min_perc = 0
    let C_Hydrogen_max_cons = -C_EY_max_perc * EY_Hydrogen_nom_prod + C_MethSynt_max_perc * MethSynt_Hydrogen_nom_cons
    let C_Hydrogen_min_cons = -C_EY_min_perc * EY_Hydrogen_nom_prod + C_MethSynt_min_perc * MethSynt_Hydrogen_nom_cons
    let C_MethDist_max_perc = min(1, MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons, CCU_C_O_2_nom_prod_ud / MethSynt_C_O_2_nom_cons * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    let C_MethDist_min_perc = max(
      MethDist_cap_min_perc, MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons, MethSynt_cap_min_perc * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    let C_MethSynt_max_perc = min(1, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud, CCU_C_O_2_nom_prod_ud / MethSynt_C_O_2_nom_cons)
    let C_MethSynt_min_perc = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons)
    let C_overall_fix_stby_cons = iff(C_MethDist_min_perc > 0, MethDist_fix_cons, MethDist_stby_cons) + iff(C_MethSynt_min_perc > 0, MethSynt_fix_cons, MethSynt_stby_cons) + iff(C_CCU_Min_perc > 0, CCU_fix_cons, CCU_stby_cons) + iff(C_EY_min_perc > 0, EY_fix_cons, EY_stby_cons)
    let C_overall_heat_fix_stby_cons =
      iff(C_MethDist_max_perc > 0, MethDist_heat_fix_cons, MethDist_heat_stby_cons) + iff(C_MethSynt_max_perc > 0, -MethSynt_heat_fix_prod, MethSynt_heat_stby_cons) + iff(C_CCU_max_perc > 0, CCU_fix_heat_cons, CCU_heat_stby_cons)
      + iff(C_EY_max_perc > 0, EY_heat_fix_cons, EY_heat_stby_cons)
    let C_overall_heat_stup_cons = iff(C_MethDist_min_perc > 0, 0, MethDist_heat_stup_cons) + iff(C_MethSynt_min_perc > 0, 0, MethSynt_heat_stup_cons) + iff(C_CCU_Min_perc > 0, 0, CCU_heat_stup_cons) + iff(C_EY_min_perc > 0, 0, EY_heat_stup_cons)
    let C_overall_stup_cons = iff(C_MethDist_min_perc > 0, 0, MethDist_stup_cons) + iff(C_MethSynt_min_perc > 0, 0, MethSynt_stup_cons) + iff(C_CCU_Min_perc > 0, 0, CCU_stup_cons) + iff(C_EY_min_perc > 0, 0, EY_stup_cons)
    let C_overall_var_heat_max_cons = EY_var_heat_nom_cons * C_EY_max_perc + MethDist_var_heat_nom_cons * C_MethDist_max_perc - MethSynt_var_heat_nom_prod * C_MethSynt_max_perc + CCU_var_heat_nom_cons * C_CCU_max_perc
    let C_overall_var_heat_min_cons = EY_var_heat_nom_cons * C_EY_min_perc + MethDist_var_heat_nom_cons * C_MethDist_min_perc - MethSynt_var_heat_nom_prod * C_MethSynt_min_perc + CCU_var_heat_nom_cons * C_CCU_Min_perc
    let C_overall_var_max_cons = C_EY_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + C_MethSynt_max_perc * MethSynt_var_nom_cons + C_MethDist_max_perc * MethDist_var_nom_cons + C_CCU_max_perc * CCU_var_nom_cons
    let C_overall_var_min_cons = C_EY_min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + C_MethSynt_min_perc * MethSynt_var_nom_cons + C_MethDist_min_perc * MethDist_var_nom_cons + C_CCU_Min_perc * CCU_var_nom_cons
    let C_RawMeth_max_cons = -C_MethSynt_max_perc * MethSynt_RawMeth_nom_prod_ud + C_MethDist_max_perc * MethDist_RawMeth_nom_cons
    let C_RawMeth_min_cons = -C_MethSynt_min_perc * MethSynt_RawMeth_nom_prod_ud + C_MethDist_min_perc * MethDist_RawMeth_nom_cons
    let CCU_cap_min_perc = 0.5
    let CCU_C_O_2_min_prod = CCU_C_O_2_nom_prod_ud * CCU_cap_min_perc
    let CCU_fix_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hourly_prod * CCU_Ref_fix_cons
    let CCU_fix_heat_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hourly_prod * CCU_Ref_heat_fix_cons
    let CCU_harmonious_max_perc = min(1, MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud, EY_Hydrogen_nom_prod / MethSynt_Hydrogen_nom_cons * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud)
    let CCU_harmonious_min_perc = max(
      CCU_cap_min_perc, MethSynt_C_O_2_min_cons / CCU_C_O_2_nom_prod_ud, max(MethSynt_cap_min_perc, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud)
    let CCU_harmonious_perc_at_PB_min = CCU_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_min
    let CCU_harmonious_perc_at_PB_nom = iff(PB_nom_net_cap / Overall_harmonious_var_max_cons * CCU_harmonious_max_perc < CCU_harmonious_min_perc, 0, PB_nom_net_cap / Overall_harmonious_var_max_cons * CCU_harmonious_max_perc)
    let CCU_heat_stby_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hourly_prod * CCU_Ref_heat_stby_cons
    let CCU_heat_stup_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hourly_prod * CCU_Ref_heat_stup_cons

    let CCU_stby_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hourly_prod * CCU_Ref_stby_cons
    let CCU_stup_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hourly_prod * CCU_Ref_stup_cons
    let CCU_var_heat_nom_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hourly_prod * CCU_Ref_var_heat_nom_cons
    let CCU_var_nom_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hourly_prod * CCU_Ref_var_nom_cons
    let CD_CCU_max_perc = max(
      CCU_cap_min_perc, MethSynt_C_O_2_min_cons / CCU_C_O_2_nom_prod_ud, max(MethSynt_cap_min_perc, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud)
    let CD_CCU_min_perc = max(
      CCU_cap_min_perc, MethSynt_C_O_2_min_cons / CCU_C_O_2_nom_prod_ud, max(MethSynt_cap_min_perc, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud)
    let CD_C_O_2_max_cons = -CD_CCU_max_perc * CCU_C_O_2_nom_prod_ud + CD_MethSynt_max_perc * MethSynt_C_O_2_nom_cons
    let CD_C_O_2_min_cons = -CD_CCU_min_perc * CCU_C_O_2_nom_prod_ud + CD_MethSynt_min_perc * MethSynt_C_O_2_nom_cons
    let CD_equiv_harmonious_max_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * CD_MethDist_max_perc, 0), ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * CD_MethSynt_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * CD_CCU_max_perc, 0), ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * CD_EY_max_perc, 0), 0)
    let CD_equiv_harmonious_min_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * CD_MethDist_min_perc, 0), ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * CD_MethSynt_min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * CD_CCU_min_perc, 0), 0)
    let CD_EY_max_perc = max(
      EY_cap_min_perc, MethSynt_Hydrogen_min_cons / EY_Hydrogen_nom_prod, max(MethSynt_cap_min_perc, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons) * MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod)
    let CD_EY_min_perc = EY_cap_min_perc
    let CD_Hydrogen_max_cons = -CD_EY_max_perc * EY_Hydrogen_nom_prod + CD_MethSynt_max_perc * MethSynt_Hydrogen_nom_cons
    let CD_Hydrogen_min_cons = -CD_EY_min_perc * EY_Hydrogen_nom_prod + CD_MethSynt_min_perc * MethSynt_Hydrogen_nom_cons
    let CD_MethDist_max_perc = max(
      MethDist_cap_min_perc, MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons, max(MethSynt_cap_min_perc, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    let CD_MethDist_min_perc = max(
      MethDist_cap_min_perc, MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons, max(MethSynt_cap_min_perc, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    let CD_MethSynt_max_perc = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons)
    let CD_MethSynt_min_perc = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons)
    let CD_overall_var_heat_max_cons = EY_var_heat_nom_cons * CD_EY_max_perc + MethDist_var_heat_nom_cons * CD_MethDist_max_perc - MethSynt_var_heat_nom_prod * CD_MethSynt_max_perc + CCU_var_heat_nom_cons * CD_CCU_max_perc
    let CD_overall_var_heat_min_cons = EY_var_heat_nom_cons * CD_EY_min_perc + MethDist_var_heat_nom_cons * CD_MethDist_min_perc - MethSynt_var_heat_nom_prod * CD_MethSynt_min_perc + CCU_var_heat_nom_cons * CD_CCU_min_perc
    let CD_overall_var_max_cons = CD_EY_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + CD_MethSynt_max_perc * MethSynt_var_nom_cons + CD_MethDist_max_perc * MethDist_var_nom_cons + CD_CCU_max_perc * CCU_var_nom_cons
    let CD_overall_var_min_cons = CD_EY_min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + CD_MethSynt_min_perc * MethSynt_var_nom_cons + CD_MethDist_min_perc * MethDist_var_nom_cons + CD_CCU_min_perc * CCU_var_nom_cons
    let CD_RawMeth_max_cons = -CD_MethSynt_max_perc * MethSynt_RawMeth_nom_prod_ud + CD_MethDist_max_perc * MethDist_RawMeth_nom_cons
    let CD_RawMeth_min_cons = -CD_MethSynt_min_perc * MethSynt_RawMeth_nom_prod_ud + CD_MethDist_min_perc * MethDist_RawMeth_nom_cons
    //self.C_O_2_storage_cap_ud = Hydrogen_storage_cap_ud / Density_Hydrogen * Density_C_O_2 / 2
    let CSP_Cold_HTF_T = TES_cold_tank_T + SF_heat_exch_approach_temp
    let CSP_nonsolar_aux_cons = CSP_night_aux_cons_per_loop * CSP_loop_nr_ud
    let CSP_SF_Max_th_Power = Heater_cap_ud * Heater_eff / Ratio_CSP_vs_Heater + EY_var_heat_nom_cons + MethDist_var_heat_nom_cons

    let D_CCU_max_perc = CCU_harmonious_max_perc
    let D_CCU_min_perc = CCU_harmonious_min_perc
    let D_C_O_2_max_cons = D_CCU_max_perc * CCU_C_O_2_nom_prod_ud - D_MethSynt_max_perc * MethSynt_C_O_2_nom_cons
    let D_C_O_2_min_cons = -D_CCU_min_perc * CCU_C_O_2_nom_prod_ud + D_MethSynt_min_perc * MethSynt_C_O_2_nom_cons
    let D_equiv_harmonious_max_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * D_MethDist_max_perc, 0), ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * D_MethSynt_max_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * D_CCU_max_perc, 0), ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * D_EY_max_perc, 0), 0)
    let D_equiv_harmonious_min_perc = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * D_MethDist_min_perc, 0), ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * D_MethSynt_min_perc, 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * D_CCU_min_perc, 0), ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * D_EY_min_perc, 0), 0)
    let D_EY_max_perc = EY_harmonious_max_perc
    let D_EY_min_perc = EY_harmonious_min_perc
    let D_Hydrogen_max_cons = D_EY_max_perc * EY_Hydrogen_nom_prod - D_MethSynt_max_perc * MethSynt_Hydrogen_nom_cons
    let D_Hydrogen_min_cons = -D_EY_min_perc * EY_Hydrogen_nom_prod + D_MethSynt_min_perc * MethSynt_Hydrogen_nom_cons
    let D_MethDist_max_perc = MethDist_harmonious_max_perc
    let D_MethDist_min_perc = MethDist_harmonious_min_perc
    let D_MethSynt_max_perc = MethSynt_harmonious_max_perc
    let D_MethSynt_min_perc = MethSynt_harmonious_min_perc
    let D_overall_fix_stby_cons = iff(D_MethDist_min_perc > 0, MethDist_fix_cons, MethDist_stby_cons) + iff(D_MethSynt_min_perc > 0, MethSynt_fix_cons, MethSynt_stby_cons) + iff(D_CCU_min_perc > 0, CCU_fix_cons, CCU_stby_cons) + iff(D_EY_min_perc > 0, EY_fix_cons, EY_stby_cons)
    let D_overall_heat_fix_stby_cons =
      iff(D_MethDist_max_perc > 0, MethDist_heat_fix_cons, MethDist_heat_stby_cons) + iff(D_MethSynt_max_perc > 0, -MethSynt_heat_fix_prod, MethSynt_heat_stby_cons) + iff(D_CCU_max_perc > 0, CCU_fix_heat_cons, CCU_heat_stby_cons)
      + iff(D_EY_max_perc > 0, EY_heat_fix_cons, EY_heat_stby_cons)
    let D_overall_heat_stup_cons = iff(D_MethDist_min_perc > 0, 0, MethDist_heat_stup_cons) + iff(D_MethSynt_min_perc > 0, 0, MethSynt_heat_stup_cons) + iff(D_CCU_min_perc > 0, 0, CCU_heat_stup_cons) + iff(D_EY_min_perc > 0, 0, EY_heat_stup_cons)
    let D_overall_stup_cons = iff(D_MethDist_min_perc > 0, 0, MethDist_stup_cons) + iff(D_MethSynt_min_perc > 0, 0, MethSynt_stup_cons) + iff(D_CCU_min_perc > 0, 0, CCU_stup_cons) + iff(D_EY_min_perc > 0, 0, EY_stup_cons)
    let D_overall_var_heat_max_cons = EY_var_heat_nom_cons * D_EY_max_perc + MethDist_var_heat_nom_cons * D_MethDist_max_perc - MethSynt_var_heat_nom_prod * D_MethSynt_max_perc + CCU_var_heat_nom_cons * D_CCU_max_perc
    let D_overall_var_heat_min_cons = EY_var_heat_nom_cons * D_EY_min_perc + MethDist_var_heat_nom_cons * D_MethDist_min_perc - MethSynt_var_heat_nom_prod * D_MethSynt_min_perc + CCU_var_heat_nom_cons * D_CCU_min_perc
    let D_overall_var_max_cons = D_EY_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + D_MethSynt_max_perc * MethSynt_var_nom_cons + D_MethDist_max_perc * MethDist_var_nom_cons + D_CCU_max_perc * CCU_var_nom_cons
    let D_overall_var_min_cons = D_EY_min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + D_MethSynt_min_perc * MethSynt_var_nom_cons + D_MethDist_min_perc * MethDist_var_nom_cons + D_CCU_min_perc * CCU_var_nom_cons
    let D_RawMeth_max_cons = D_MethSynt_max_perc * MethSynt_RawMeth_nom_prod_ud - D_MethDist_max_perc * MethDist_RawMeth_nom_cons
    let D_RawMeth_min_cons = -D_MethSynt_min_perc * MethSynt_RawMeth_nom_prod_ud + D_MethDist_min_perc * MethDist_RawMeth_nom_cons
    // self.el_C0 = PB_Eff!$U6
    // self.el_C1 = PB_Eff!$T6
    // self.el_C2 = PB_Eff!$S6
    // self.el_C3 = PB_Eff!$R6
    // self.el_C4 = PB_Eff!$Q6
    let EY_aux_heat_input_at_min_PB = max(EY_var_aux_min_cons, (PB_net_min_cap - MethSynt_var_nom_cons * MethSynt_cap_min_perc - MethSynt_fix_cons - MethDist_var_nom_cons * MethDist_cap_min_perc - MethDist_fix_cons)) / EY_var_gross_nom_cons * EY_var_heat_nom_cons
    let EY_fix_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_fix_cons
    let EY_Hydrogen_min_prod = EY_Hydrogen_nom_prod * EY_cap_min_perc
    let EY_Hydrogen_nom_prod = EY_Ref_Hydrogen_hourly_nom_prod / EY_Ref_var_net_nom_cons * EY_var_net_nom_cons_ud
    let EY_harmonious_max_perc = min(1, MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod, CCU_C_O_2_nom_prod_ud / MethSynt_C_O_2_nom_cons * MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud * MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod)
    let EY_harmonious_min_perc = max(
      EY_cap_min_perc, MethSynt_Hydrogen_min_cons / EY_Hydrogen_nom_prod, max(MethSynt_cap_min_perc, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons) * MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod)
    let EY_harmonious_perc_at_PB_min = EY_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_min
    let EY_harmonious_perc_at_PB_nom = iff(PB_nom_net_cap / Overall_harmonious_var_max_cons * EY_harmonious_max_perc < EY_harmonious_min_perc, 0, PB_nom_net_cap / Overall_harmonious_var_max_cons * EY_harmonious_max_perc)
    let EY_heat_fix_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_heat_fix_cons
    let EY_heat_stby_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_heat_stby_cons
    let EY_heat_stup_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_heat_stup_cons
    let EY_Ref_fix_cons = 0
    let EY_Ref_Hydrogen_hourly_nom_prod = EY_Ref_var_net_nom_cons / 55
    let EY_Ref_heat_fix_cons = 0
    let EY_Ref_heat_stby_cons = 0
    let EY_Ref_heat_stup_cons = 1
    let EY_Ref_stby_cons = 0
    let EY_Ref_stup_cons = 1
    let EY_Ref_var_heat_nom_cons = 40
    let EY_Ref_var_net_nom_cons = 180
    let EY_Ref_var_nom_cons = 2.7
    let EY_stby_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_stby_cons
    let EY_stup_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_stup_cons
    let EY_var_aux_min_cons = (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) * EY_cap_min_perc
    let EY_var_aux_nom_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_var_nom_cons
    let EY_var_gross_nom_cons = EY_var_net_nom_cons_ud + EY_var_aux_nom_cons
    let EY_var_heat_nom_cons = EY_Ref_var_heat_nom_cons * EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons

    // self.HL_C0 = Inv_Eff!$Q$25
    // self.HL_C1 = Inv_Eff!$P$25
    // self.HL_C2 = Inv_Eff!$O$25
    // self.HL_C3 = Inv_Eff!$N$25
    // self.Inv_eff_Ref_approx_handover = Inv_Eff!C22
    // self.LL_C0 = Inv_Eff!$Q$20
    // self.LL_C1 = Inv_Eff!$P$20
    // self.LL_C2 = Inv_Eff!$O$20
    // self.LL_C3 = Inv_Eff!$N$20
    // self.LL_C4 = Inv_Eff!$M$20
    // self.LL_C5 = Inv_Eff!$L$20
    // self.LL_C6 = Inv_Eff!$K$20
    // self.LL_C7 = Inv_Eff!$J$20
    let MethDist_fix_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hourly_prod * MethDist_Ref_fix_cons
    let MethDist_HydrogenO_min_prod = MethDist_HydrogenO_nom_prod * MethDist_cap_min_perc
    let MethDist_HydrogenO_nom_prod = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hourly_prod * MethDist_Ref_water_hourly_prod
    let MethDist_harmonious_max_perc = min(
      1, MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons, EY_Hydrogen_nom_prod / MethSynt_Hydrogen_nom_cons * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons, CCU_C_O_2_nom_prod_ud / MethSynt_C_O_2_nom_cons * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    let MethDist_harmonious_min_perc = max(
      MethDist_cap_min_perc, MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons, max(MethSynt_cap_min_perc, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    let MethDist_harmonious_perc_at_PB_min = MethDist_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_min
    let MethDist_harmonious_perc_at_PB_nom = iff(PB_nom_net_cap / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc < MethDist_harmonious_min_perc, 0, PB_nom_net_cap / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc)
    let MethDist_heat_fix_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hourly_prod * MethDist_Ref_heat_fix_cons
    let MethDist_heat_stby_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hourly_prod * MethDist_Ref_heat_stby_cons
    let MethDist_heat_stup_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hourly_prod * MethDist_Ref_heat_stup_cons
    let MethDist_Meth_min_prod = MethDist_cap_min_perc * MethDist_Meth_nom_prod_ud
    let MethDist_RawMeth_min_cons = MethDist_RawMeth_nom_cons * MethDist_cap_min_perc
    let MethDist_RawMeth_nom_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hourly_prod * MethDist_Ref_rawmeth_hourly_cons

    let MethDist_Ref_meth_hourly_prod = MethDist_Ref_meth_annual_prod / MethSynt_annual_op_hours
    let MethDist_Ref_rawmeth_hourly_cons = MethSynt_Ref_rawmeth_hourly_prod

    let MethDist_Ref_water_hourly_prod = MethDist_Ref_water_annual_prod / MethSynt_annual_op_hours
    let MethDist_stby_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hourly_prod * MethDist_Ref_stby_cons
    let MethDist_stup_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hourly_prod * MethDist_Ref_stup_cons
    let MethDist_var_heat_nom_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hourly_prod * MethDist_Ref_var_heat_nom_cons
    let MethDist_var_nom_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hourly_prod * MethDist_Ref_var_nom_cons
    let MethSynt_annual_op_days = 365.25 - MethSynt_annual_outage_days
    let MethSynt_annual_op_hours = MethSynt_annual_op_days * 24

    let MethSynt_C_O_2_min_cons = MethSynt_C_O_2_nom_cons * MethSynt_cap_min_perc
    let MethSynt_C_O_2_nom_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hourly_prod * MethSynt_Ref_C_O_2_hourly_cons
    let MethSynt_fix_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hourly_prod * MethSynt_Ref_fix_cons
    let MethSynt_Hydrogen_min_cons = MethSynt_Hydrogen_nom_cons * MethSynt_cap_min_perc
    let MethSynt_Hydrogen_nom_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hourly_prod * MethSynt_Ref_Hydrogen_hourly_cons
    let MethSynt_harmonious_max_perc = min(1, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud, EY_Hydrogen_nom_prod / MethSynt_Hydrogen_nom_cons, CCU_C_O_2_nom_prod_ud / MethSynt_C_O_2_nom_cons)
    let MethSynt_harmonious_min_perc = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons)
    let MethSynt_harmonious_perc_at_PB_min = MethSynt_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_min
    let MethSynt_harmonious_perc_at_PB_nom = iff(PB_nom_net_cap / Overall_harmonious_var_max_cons * MethSynt_harmonious_max_perc < MethSynt_harmonious_min_perc, 0, PB_nom_net_cap / Overall_harmonious_var_max_cons * MethSynt_harmonious_max_perc)
    let MethSynt_heat_fix_prod = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hourly_prod * MethSynt_Ref_heat_fix_prod
    let MethSynt_heat_stby_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hourly_prod * MethSynt_Ref_heat_stby_cons
    let MethSynt_heat_stup_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hourly_prod * MethSynt_Ref_heat_stup_cons
    let MethSynt_RawMeth_min_prod = MethSynt_RawMeth_nom_prod_ud * MethSynt_cap_min_perc

    let MethSynt_Ref_C_O_2_hourly_cons = MethSynt_Ref_C_O_2_annual_cons / MethSynt_annual_op_hours

    let MethSynt_Ref_Hydrogen_hourly_cons = MethSynt_Ref_Hydrogen_annual_cons / MethSynt_annual_op_hours

    let MethSynt_Ref_rawmeth_hourly_prod = MethSynt_Ref_C_O_2_hourly_cons + MethSynt_Ref_Hydrogen_hourly_cons


    let MethSynt_stby_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hourly_prod * MethSynt_Ref_stby_cons
    let MethSynt_stup_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hourly_prod * MethSynt_Ref_stup_cons

    let MethSynt_var_heat_nom_prod = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hourly_prod * MethSynt_Ref_var_heat_nom_prod
    let MethSynt_var_nom_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hourly_prod * MethSynt_Ref_var_nom_cons
    let Overall_fix_cons = EY_fix_cons + MethSynt_fix_cons + MethDist_fix_cons + CCU_fix_cons

    let Overall_harmonious_min_perc = Overall_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_min_cons
    let Overall_harmonious_perc_at_PB_min = Overall_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_min
    let Overall_harmonious_perc_at_PB_nom = Overall_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_nom
    let Overall_harmonious_var_cons_at_PB_min = max(PB_net_min_cap, Overall_harmonious_var_min_cons)
    let Overall_harmonious_var_cons_at_PB_nom = min(PB_nom_net_cap, Overall_harmonious_var_max_cons)
    let Overall_harmonious_var_heat_cons_at_PB_min = Overall_harmonious_var_cons_at_PB_min / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons
    let Overall_harmonious_var_heat_cons_at_PB_nom = Overall_harmonious_var_heat_max_cons / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_nom
    let Overall_harmonious_var_heat_max_cons = EY_harmonious_max_perc * EY_var_heat_nom_cons + MethDist_harmonious_max_perc * MethDist_var_heat_nom_cons - MethSynt_harmonious_max_perc * MethSynt_var_heat_nom_prod + CCU_harmonious_max_perc * CCU_var_heat_nom_cons
    let Overall_harmonious_var_heat_min_cons = EY_var_heat_nom_cons * EY_harmonious_min_perc + MethDist_var_heat_nom_cons * MethDist_harmonious_min_perc - MethSynt_var_heat_nom_prod * MethSynt_harmonious_min_perc + CCU_var_heat_nom_cons * CCU_harmonious_min_perc
    let Overall_harmonious_var_max_cons = EY_harmonious_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + MethSynt_harmonious_max_perc * MethSynt_var_nom_cons + MethDist_harmonious_max_perc * MethDist_var_nom_cons + CCU_harmonious_max_perc * CCU_var_nom_cons
    let Overall_harmonious_var_min_cons = EY_harmonious_min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + MethSynt_harmonious_min_perc * MethSynt_var_nom_cons + MethDist_harmonious_min_perc * MethDist_var_nom_cons + CCU_harmonious_min_perc * CCU_var_nom_cons
    let Overall_heat_fix_cons = EY_heat_fix_cons + MethSynt_heat_fix_prod - MethDist_heat_fix_cons + CCU_fix_heat_cons

    let PB_cold_start_heat_req = PB_nom_heat_cons * PB_cold_start_energyperc
    // self.PB_eff_at_max_harmonious = ifFinite(
    //  iff(
    //  PB_gross_cap_at_max_harmonious=PB_nom_gross_cap_ud,
    //  PB_nom_gross_eff,
    //  PB_nom_gross_eff*(el_C4*(PB_gross_cap_at_max_harmonious/PB_nom_gross_cap_ud)**4+el_C3*(PB_gross_cap_at_max_harmonious/PB_nom_gross_cap_ud)**3+el_C2*(PB_gross_cap_at_max_harmonious/PB_nom_gross_cap_ud)**2+el_C1*(PB_gross_cap_at_max_harmonious/PB_nom_gross_cap_ud)**1+el_C0)),
    //  0)
    let PB_eff_at_min_harmonious = ifFinite(
      PB_nom_gross_eff
        * (el_C4 * (max(PB_gross_min_cap, PB_gross_cap_at_min_harmonious) / PB_nom_gross_cap_ud) ** 4 + el_C3 * (max(PB_gross_min_cap, PB_gross_cap_at_min_harmonious) / PB_nom_gross_cap_ud) ** 3 + el_C2
          * (max(PB_gross_min_cap, PB_gross_cap_at_min_harmonious) / PB_nom_gross_cap_ud) ** 2 + el_C1 * (max(PB_gross_min_cap, PB_gross_cap_at_min_harmonious) / PB_nom_gross_cap_ud) ** 1 + el_C0),
      0)
    let PB_el_cap_min_perc = PB_Ref_25p_gross_cap_max_aux_heat / PB_Ref_nom_gross_cap
    let PB_fix_aux_el = PB_Ref_nom_gross_cap * PB_fix_aux_elec_cons_perc_of_ref * fix_aux_el(PB_nom_gross_cap_ud / PB_Ref_nom_gross_cap)
    // self.PB_g2n_var_aux_el_C0 = PB_var_aux_cons_C0
    // self.PB_g2n_var_aux_el_C1 = PB_var_aux_cons_C1
    // self.PB_g2n_var_aux_el_C2 = PB_var_aux_cons_C2
    // self.PB_g2n_var_aux_el_C3 = PB_var_aux_cons_C3
    let PB_gross_cap_at_max_harmonious =
      PB_fix_aux_el + PB_net_cap_at_max_harmonious + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
      * (PB_n2g_var_aux_el_C3 * (PB_net_cap_at_max_harmonious / PB_nom_net_cap) ** 3 + PB_n2g_var_aux_el_C2 * (PB_net_cap_at_max_harmonious / PB_nom_net_cap) ** 2 + PB_n2g_var_aux_el_C1 * (PB_net_cap_at_max_harmonious / PB_nom_net_cap) ** 1 + PB_n2g_var_aux_el_C0)
    let PB_gross_cap_at_min_harmonious =
      PB_net_cap_at_min_harmonious + PB_fix_aux_el + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
      * (PB_n2g_var_aux_el_C3 * (PB_net_cap_at_min_harmonious / PB_nom_net_cap) ** 3 + PB_n2g_var_aux_el_C2 * (PB_net_cap_at_min_harmonious / PB_nom_net_cap) ** 2 + PB_n2g_var_aux_el_C1 * (PB_net_cap_at_min_harmonious / PB_nom_net_cap) ** 1 + PB_n2g_var_aux_el_C0)
    let PB_gross_min_cap = PB_nom_gross_cap_ud * PB_el_cap_min_perc
    let PB_gross_min_eff = PB_gross_min_cap / PB_heat_min_input
    let PB_heat_input_at_max_harmonious = ifFinite(PB_gross_cap_at_max_harmonious / PB_eff_at_max_harmonious, 0)
    let PB_heat_input_at_min_harmonious = ifFinite(PB_gross_cap_at_min_harmonious / PB_eff_at_min_harmonious, 0)
    // self.PB_heat_min_input = ifFinite(
    //  PB_gross_min_cap/(PB_nom_gross_eff*(el_C4*PB_el_cap_min_perc**4 + el_C3*PB_el_cap_min_perc**3 +el_C2*PB_el_cap_min_perc**2 +el_C1*PB_el_cap_min_perc**1 +el_C0*PB_el_cap_min_perc**0)),
    //  0)
    let PB_hot_start_heat_req = PB_nom_heat_cons * PB_hot_start_energyperc
    // self.PB_n2g_var_aux_el_C0 = PB_Eff!O49
    // self.PB_n2g_var_aux_el_C1 = PB_Eff!N49
    // self.PB_n2g_var_aux_el_C2 = PB_Eff!M49
    // self.PB_n2g_var_aux_el_C3 = PB_Eff!L49
    let PB_net_cap_at_max_harmonious = min(PB_nom_net_cap, max(PB_net_min_cap, Overall_harmonious_var_max_cons + Overall_fix_cons))
    let PB_net_cap_at_min_harmonious = min(PB_nom_net_cap, max(PB_net_min_cap, Overall_harmonious_var_min_cons + Overall_fix_cons))
    let PB_net_min_cap = PB_gross_min_cap - PB_fix_aux_el - PB_nom_var_aux_cons * PB_g2n_var_aux_el(PB_gross_min_cap / PB_nom_gross_cap_ud)
    // self.PB_nom_gross_eff = PB_Eff!I16
    let PB_nom_heat_cons = ifFinite(PB_nom_gross_cap_ud / PB_nom_gross_eff, 0)
    let PB_nom_net_cap = PB_nom_gross_cap_ud - PB_nom_var_aux_cons - PB_fix_aux_el
    let PB_nom_var_aux_cons = PB_nom_gross_cap_ud * PB_nom_var_aux_cons_perc_gross
    let PB_nom_var_aux_cons_perc_gross = 3.3931144552042103E-2
    // self.PB_nom_var_aux_cons_perc_net = PB_Eff!I18
    // self.PB_Ratio_Heat_input_vs_output = PB_Eff!I14

    let PB_Ref_25p_gross_eff = PB_Ref_25p_gross_cap / PB_Ref_25p_heat_cons
    // self.PB_Ref_25p_gross_eff_excl_aux_heat_cons = PB_Eff!E22
    // self.PB_Ref_25p_gross_eff_excl_max_aux_heat_cons = PB_Eff!E24
    let PB_Ref_25p_gross_eff_max_aux_heat = PB_Ref_25p_gross_cap_max_aux_heat / PB_Ref_25p_heat_cons_max_aux_heat
    // self.PB_Ref_25p_heat_cons_excl_aux_heat = PB_Eff!E21
    // self.PB_Ref_25p_heat_cons_excl_max_aux_heat = PB_Eff!E23
    let PB_Ref_30p_gross_eff = PB_Ref_30p_gross_cap / PB_Ref_30p_heat_cons
    // self.PB_Ref_30p_gross_eff_excl_aux_heat_cons = PB_Eff!E20
    // self.PB_Ref_30p_heat_cons_excl_aux_heat = PB_Eff!E19
    let PB_Ref_nom_gross_eff = PB_Ref_nom_gross_cap / PB_Ref_nom_heat_cons
    // self.PB_Ref_nom_gross_eff_excl_aux_heat_cons = PB_Eff!E18
    // self.PB_Ref_nom_heat_cons_excl_aux_heat = PB_Eff!E17
    let PB_stby_aux_cons = PB_nom_gross_cap_ud * PB_stby_var_aux_cons_perc + PB_Ref_nom_gross_cap * PB_stby_fix_aux_cons_perc * (fix_stby_el(PB_nom_gross_cap_ud / PB_Ref_nom_gross_cap))

    let PB_stup_aux_cons = PB_nom_gross_cap_ud * PB_stup_var_aux_elec_cons_perc + PB_Ref_nom_gross_cap * PB_stup_fix_aux_elec_cons_perc * (fix_stup_el(PB_nom_gross_cap_ud / PB_Ref_nom_gross_cap))

    // self.PB_var_heat_max_cons = PB_Eff!I17

    let PB_warm_start_heat_req = PB_nom_heat_cons * PB_warm_start_energyperc
    // self.PV_Ref_AC_cap = max(Calculation!G5,G8764)
    // self.Ratio_CSP_vs_Heater = (_xll.h(SS,
    //  Heater_outlet_T)-_xll.h(SS,
    //  CSP_Hot_HTF_T-SF_heat_exch_approach_temp))/(_xll.h(SS,
    //  CSP_Hot_HTF_T-SF_heat_exch_approach_temp)-_xll.h(SS,
    //  CSP_Cold_HTF_T-SF_heat_exch_approach_temp))

    // self.TES_salt_mass = TES_thermal_cap*1000*3600/(_xll.h(SS,
    //  Heater_outlet_T)-_xll.h(SS,
    //  TES_cold_tank_T))/1000*(1+TES_dead_mass_ratio)
    let TES_thermal_cap = TES_full_load_hours_ud * PB_nom_heat_cons  // self.th_C0 = PB_Eff!$U3
    // self.th_C1 = PB_Eff!$T3
    // self.th_C2 = PB_Eff!$S3
    // self.th_C3 = PB_Eff!$R3
    // self.Th_C4 = PB_Eff!$Q3
  }
*/
}

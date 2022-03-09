import Libc
import Utilities

func h_SS(_ t: Double) -> Double { 0.000085999999711 * pow(t, 2) + 1.44300000008555 * t + 4.23842398826006 }

public struct TunOl {

  public static var Grid_import_yes_no_BESS_strategy: Double = 1
  public static var Grid_import_yes_no_PB_strategy: Double = 1

  public static var convergenceCurves = [[[Double]]](repeating: [[Double]](), count: 3)
  public static var Q_Sol_MW_thLoop = [Double]()
  public static var Reference_PV_plant_power_at_inverter_inlet_DC = [Double]()
  public static var Reference_PV_MV_power_at_transformer_outlet = [Double]()

  let BESS_chrg_eff: Double = 0.7
  let BESS_chrg_max_cons: Double
  let BESS_chrg_max_ratio: Double = 0.5
  let CCU_cap_min_perc: Double = 0.5

  let CCU_fix_cons: Double
  let CCU_fix_heat_cons: Double
  let CCU_harmonious_max_perc: Double
  let CCU_harmonious_min_perc: Double

  let CCU_var_heat_nom_cons: Double
  let CCU_var_nom_cons: Double

  let CCU_Ref_C_O_2_hour_prod: Double = 22
  let CCU_Ref_fix_cons: Double = 1
  let CCU_Ref_heat_fix_cons: Double = 1
  let CCU_Ref_heat_stby_cons: Double = 1
  let CCU_Ref_heat_stup_cons: Double = 1
  let CCU_Ref_stby_cons: Double = 1
  let CCU_Ref_stup_cons: Double = 1
  let CCU_Ref_var_heat_nom_cons: Double = 22
  let CCU_Ref_var_nom_cons: Double = 2

  let CSP_Cold_HTF_T: Double
  let CSP_Hot_HTF_T: Double = 425
  let CSP_night_aux_cons_per_loop: Double = 3.0E-3
  let CSP_nonsolar_aux_cons: Double
  let CSP_var_aux_nom_perc: Double = 0.01
  var CCU_max_perc = [Double](repeating: 0, count: 4)
  var CCU_min_perc = [Double](repeating: 0, count: 4)
  var C_O_2_max_cons = [Double](repeating: 0, count: 4)
  var C_O_2_min_cons = [Double](repeating: 0, count: 4)
  var equiv_harmonious_max_perc = [Double](repeating: 0, count: 4)
  var equiv_harmonious_min_perc = [Double](repeating: 0, count: 4)
  var EY_max_perc = [Double](repeating: 0, count: 4)
  var EY_min_perc = [Double](repeating: 0, count: 4)
  var Hydrogen_max_cons = [Double](repeating: 0, count: 4)
  var Hydrogen_min_cons = [Double](repeating: 0, count: 4)
  var MethDist_max_perc = [Double](repeating: 0, count: 4)
  var MethDist_min_perc = [Double](repeating: 0, count: 4)
  var MethSynt_max_perc = [Double](repeating: 0, count: 4)
  var MethSynt_min_perc = [Double](repeating: 0, count: 4)
  var overall_fix_stby_cons = [Double](repeating: 0, count: 4)
  var overall_heat_fix_stby_cons = [Double](repeating: 0, count: 4)
  var overall_heat_stup_cons = [Double](repeating: 0, count: 4)
  var overall_stup_cons = [Double](repeating: 0, count: 4)
  var overall_var_heat_max_cons = [Double](repeating: 0, count: 4)
  var overall_var_heat_min_cons = [Double](repeating: 0, count: 4)
  var overall_var_max_cons = [Double](repeating: 0, count: 4)
  var overall_var_min_cons = [Double](repeating: 0, count: 4)
  var RawMeth_max_cons = [Double](repeating: 0, count: 4)
  var RawMeth_min_cons = [Double](repeating: 0, count: 4)
  let Density_C_O_2: Double = 945
  let Density_Hydrogen: Double = 5.783
  let El_boiler_eff: Double = 0.99
  var el_Coeff: [Double] = []// [PB_Eff!$U6, PB_Eff!$T6, PB_Eff!$S6, PB_Eff!$R6, PB_Eff!$Q6]

  let EY_fix_cons: Double
  let EY_Hydrogen_nom_prod: Double

  let EY_harmonious_max_perc: Double
  let EY_harmonious_min_perc: Double
  let EY_harmonious_perc_at_PB_nom: Double
  let EY_heat_fix_cons: Double
  let EY_heat_stby_cons: Double
  let EY_heat_stup_cons: Double
  let EY_Ref_fix_cons: Double = 1

  let EY_var_aux_min_cons: Double
  let EY_var_gross_nom_cons: Double
  let EY_var_heat_nom_cons: Double

  let EY_cap_min_perc: Double = 0.1
  let EY_Ref_heat_fix_cons: Double = 1
  let EY_Ref_heat_stby_cons: Double = 1
  let EY_Ref_heat_stup_cons: Double = 1
  let EY_Ref_stby_cons: Double = 1
  let EY_Ref_stup_cons: Double = 1
  let EY_Ref_var_heat_nom_cons: Double = 40
  let EY_Ref_var_net_nom_cons: Double = 180
  let EY_Ref_var_nom_cons: Double = 2.7

  let fix_aux_el = [0.87197586317594244, 0.29314511444598762, -0.49536293286578681, 0.33024195524385674]
  let fix_stby_el = [0.8910127968928524, 0.21455823229400395, -0.31671308756057304, 0.21114205837371655]
  let fix_stup_el = [0.89405519494415775, 0.19885240173966706, -0.27872279005147399, 0.18581519336764935]
  let Heater_eff: Double = 0.96
  let Heater_outlet_T: Double = 565
  let HL_Coeff: [Double]
  let Inv_eff_Ref_approx_handover: Double = 0.13653  // Inv_Eff!C22
  let LL_Coeff: [Double]
  let MethDist_cap_min_perc: Double = 0.5

  let MethDist_fix_cons: Double
  let MethDist_HydrogenO_min_prod: Double

  let MethDist_harmonious_max_perc: Double
  let MethDist_harmonious_min_perc: Double

  let MethDist_harmonious_perc_at_PB_nom: Double
  let MethDist_RawMeth_nom_cons: Double
  let MethDist_Ref_meth_hour_prod: Double
  let MethDist_Ref_fix_cons: Double = 1
  let MethDist_Ref_heat_fix_cons: Double = 1
  let MethDist_Ref_heat_stby_cons: Double = 1.7
  let MethDist_Ref_heat_stup_cons: Double = 1.7
  let MethDist_Ref_meth_annual_prod: Double = 100000

  let MethDist_Ref_stby_cons: Double = 1
  let MethDist_Ref_stup_cons: Double = 1
  let MethDist_Ref_var_heat_nom_cons: Double = 17.53
  let MethDist_Ref_var_nom_cons: Double = 1.1000000000000001
  let MethDist_Ref_water_annual_prod: Double = 56227

  let MethSynt_annual_outage_days: Double = 32
  let MethSynt_cap_min_perc: Double = 0.1
  let MethSynt_C_O_2_min_cons: Double
  let MethSynt_C_O_2_nom_cons: Double
  let MethSynt_fix_cons: Double
  let MethSynt_Hydrogen_nom_cons: Double
  let MethSynt_harmonious_max_perc: Double
  let MethSynt_harmonious_min_perc: Double
  let MethSynt_heat_fix_prod: Double
  let MethSynt_Ref_C_O_2_hour_cons: Double
  let MethSynt_Ref_Hydrogen_hour_cons: Double
  let MethSynt_Ref_rawmeth_hour_prod: Double
  let MethSynt_var_heat_nom_prod: Double
  let MethSynt_var_nom_cons: Double
  let MethSynt_Ref_C_O_2_annual_cons: Double = 137372

  let MethSynt_Ref_fix_cons: Double = 1
  let MethSynt_Ref_Hydrogen_annual_cons: Double = 18894

  let MethSynt_Ref_heat_fix_prod: Double = 1
  let MethSynt_Ref_heat_stby_cons: Double = 1
  let MethSynt_Ref_heat_stup_cons: Double = 1

  let MethSynt_Ref_stby_cons: Double = 1
  let MethSynt_Ref_stup_cons: Double = 1
  let MethSynt_Ref_var_heat_nom_prod: Double = 5.4
  let MethSynt_Ref_var_nom_cons: Double = 1.4
  let MethSynt_stup_duration: Double = 15

  let Overall_harmonious_max_perc: Double = 1
  let Overall_fix_cons: Double
  let Overall_harmonious_min_perc: Double
  let Overall_harmonious_var_heat_cons_at_PB_nom: Double
  let Overall_harmonious_var_heat_max_cons: Double
  let Overall_harmonious_var_heat_min_cons: Double
  let Overall_harmonious_var_max_cons: Double
  let Overall_harmonious_var_min_cons: Double
  let Overall_heat_fix_cons: Double

  let PB_cold_start_duration: Double = 48
  let PB_cold_start_energyperc: Double = 2
  var PB_cold_start_heat_req: Double = 0
  let PB_fix_aux_el: Double
  let PB_fix_aux_elec_cons_perc_of_ref: Double = 6.4340704330890603E-3
  
  var PB_gross_min_cap: Double = 0
  var PB_gross_min_eff: Double = 0
  var PB_heat_min_input: Double = 0
  let PB_hot_start_energyperc: Double = 0.05
  var PB_hot_start_heat_req: Double = 0

  var PB_n_g_var_aux_el_Coeff: [Double] = [0]  // PB_Eff!O49 PB_Eff!N49 PB_Eff!M49 PB_Eff!L49

  let PB_net_min_cap: Double
  var PB_nom_gross_eff: Double = 0.4  // PB_Eff!I16
  var PB_nom_heat_cons: Double = 0
  let PB_nom_net_cap: Double
  let PB_nom_var_aux_cons: Double
  let PB_nom_var_aux_cons_perc_gross: Double = 3.3931144552042103E-2
  var PB_nom_var_aux_cons_perc_net: Double = 0  // PB_Eff!I18
  let PB_op_hours_min_nr: Double = 5
  var PB_Ratio_Heat_input_vs_output: Double = 0  // PB_Eff!I14

  let PB_Ref_25p_gross_cap: Double = 25
  let PB_Ref_25p_gross_cap_max_aux_heat: Double = 25

  let PB_Ref_25p_gross_eff_excl_aux_heat_cons: Double = 0  // PB_Eff!E22
  let PB_Ref_25p_gross_eff_excl_max_aux_heat_cons: Double = 0  // PB_Eff!E24

  let PB_Ref_25p_heat_cons: Double = 85.512
  // let PB_Ref_25p_heat_cons_excl_aux_heat: Double = 0  // PB_Eff!E21
  // let PB_Ref_25p_heat_cons_excl_max_aux_heat: Double = 0  // PB_Eff!E23

  let PB_Ref_25p_heat_cons_max_aux_heat: Double = 112.349

  let PB_Ref_30p_gross_cap: Double = 63

  // let PB_Ref_30p_gross_eff_excl_aux_heat_cons: Double = 0  // PB_Eff!E20

  let PB_Ref_30p_heat_cons: Double = 168.78700000000001
  // let PB_Ref_30p_heat_cons_excl_aux_heat: Double = 0  // PB_Eff!E19

  let PB_Ref_nom_gross_cap: Double = 200

  // let PB_Ref_nom_gross_eff_excl_aux_heat_cons: Double = 0  // PB_Eff!E18

  let PB_Ref_nom_heat_cons: Double = 463.48500000000001
  // let PB_Ref_nom_heat_cons_excl_aux_heat: Double = 0  // PB_Eff!E17
  let PB_stby_aux_cons: Double
  let PB_stby_fix_aux_cons_perc: Double = 5.2640704330890603E-3
  let PB_stby_var_aux_cons_perc: Double = 4.6250983512691503E-3
  let PB_stup_aux_cons: Double
  let PB_stup_fix_aux_elec_cons_perc: Double = 5.9815704330890597E-3
  let PB_stup_var_aux_elec_cons_perc: Double = 1.2789153998036399E-2
  let PB_var_aux_cons = [0.29437013201591916, 0.10280513176871063, -6.5249624421765337E-2, 0.67514642417652304]
  let PB_g2n_var_aux_el_Coeff: [Double] = [0.29437013201591916, 0.10280513176871063, -6.5249624421765337E-2, 0.67514642417652304]  // PB_var_aux_cons_C0
  var PB_var_heat_max_cons: Double = 0  // PB_Eff!I17

  let PB_warm_start_duration: Double = 6
  let PB_warm_start_energyperc: Double = 0.4
  var PB_warm_start_heat_req: Double = 0
  let PV_Ref_AC_cap: Double = 510  //max(Calculation!G5,G8764)
  let PV_Ref_DC_cap: Double = 683.4
  let Ratio_CSP_vs_Heater: Double
  let SF_heat_exch_approach_temp: Double = 7
  let TES_aux_cons_perc: Double = 0.01
  let TES_cold_tank_T: Double = 304.55
  let TES_dead_mass_ratio: Double = 0.1
  var TES_salt_mass: Double = 0
  var TES_thermal_cap: Double = 0

  var th_Coeff: [Double] = [0]  // PB_Eff!$U3 PB_Eff!$T3 PB_Eff!$S3 PB_Eff!$R3 PB_Eff!$Q3

  
  
  var CSP_loop_nr_ud: Double = 120
  var TES_full_load_hours_ud: Double = 20
  var PB_nom_gross_cap_ud: Double = 190
  var PV_AC_cap_ud: Double = 800
  var PV_DC_cap_ud: Double = 1116
  var EY_var_net_nom_cons_ud: Double = 450
  var Hydrogen_storage_cap_ud: Double = 60
  var Heater_cap_ud: Double = 300
  var CCU_C_O_2_nom_prod_ud: Double = 27
  var C_O_2_storage_cap_ud: Double = 5000
  var MethSynt_RawMeth_nom_prod_ud: Double = 50
  var RawMeth_storage_cap_ud: Double = 300
  var MethDist_Meth_nom_prod_ud: Double = 20
  var El_boiler_cap_ud: Double = 100
  var BESS_cap_ud: Double = 130
  var Grid_export_max_ud: Double = 50
  var Grid_import_max_ud: Double = 50
  var Grid_import_yes_no_BESS_strategy: Double = 1
  var Grid_import_yes_no_PB_strategy: Double = 1

  init(_ parameter: [Double]) {
    if !parameter.isEmpty {
      self.CSP_loop_nr_ud = parameter[0]
      self.TES_full_load_hours_ud = parameter[1]
      self.PB_nom_gross_cap_ud = parameter[2]
      self.PV_AC_cap_ud = parameter[3]
      self.PV_DC_cap_ud = parameter[4]
      self.EY_var_net_nom_cons_ud = parameter[5]
      self.Hydrogen_storage_cap_ud = parameter[6]
      self.Heater_cap_ud = parameter[7]
      self.CCU_C_O_2_nom_prod_ud = parameter[8]
      self.C_O_2_storage_cap_ud = parameter[9]
      self.MethSynt_RawMeth_nom_prod_ud = parameter[10]
      self.RawMeth_storage_cap_ud = parameter[11]
      self.MethDist_Meth_nom_prod_ud = parameter[12]
      self.El_boiler_cap_ud = parameter[13]
      self.BESS_cap_ud = parameter[14]
      self.Grid_export_max_ud = parameter[15]
      self.Grid_import_max_ud = parameter[16] 
    }

    let ac = self.PV_AC_cap_ud
    let dc = self.PV_DC_cap_ud
    self.Grid_import_yes_no_BESS_strategy = TunOl.Grid_import_yes_no_BESS_strategy
    self.Grid_import_yes_no_PB_strategy = TunOl.Grid_import_yes_no_PB_strategy

    let maximum = TunOl.Reference_PV_MV_power_at_transformer_outlet.max() ?? Double.zero
    let Inverter_power_fraction = TunOl.Reference_PV_MV_power_at_transformer_outlet.map { max(Double.zero, $0 / maximum) }
    let Inverter_eff = Inverter_power_fraction.indices.map {
      return iff(
        TunOl.Reference_PV_MV_power_at_transformer_outlet[$0] < maximum,
        max(TunOl.Reference_PV_MV_power_at_transformer_outlet[$0], Double.zero) / TunOl.Reference_PV_plant_power_at_inverter_inlet_DC[$0], Double.zero)
    }
    let inverter = zip(Inverter_power_fraction, Inverter_eff).filter { $0.0 > 0 && $0.0 < 1 }.sorted(by: { $0.0 < $1.0 })
    let chunks = inverter.chunked { Int($0.0 * 100) == Int($1.0 * 100) }
    let eff1 = chunks.map { bin in bin.reduce(0.0) { $0 + $1.1 } / Double(bin.count) }
    let eff2 = zip(stride(from: 0.01, through: 1, by: 0.01), eff1).map { ac * $0.0 / $0.1 / dc }
    self.LL_Coeff = Polynomial.fit(x: Array(eff2[..<20]), y: Array(eff1[..<20]), order: 7)!.coefficients
    self.HL_Coeff = Polynomial.fit(x: Array(eff2[15...]), y: Array(eff1[15...]), order: 3)!.coefficients

    let PB_grs_el_cap_min_perc = PB_Ref_25p_gross_cap_max_aux_heat / PB_Ref_nom_gross_cap
    self.CSP_Cold_HTF_T = TES_cold_tank_T + SF_heat_exch_approach_temp
    let EY_Ref_Hydrogen_hour_nom_prod = EY_Ref_var_net_nom_cons / 55
    let MethSynt_annual_op_days = 365.25 - MethSynt_annual_outage_days
    let MethSynt_annual_op_hours = MethSynt_annual_op_days * 24
    self.MethSynt_Ref_Hydrogen_hour_cons = MethSynt_Ref_Hydrogen_annual_cons / MethSynt_annual_op_hours
    self.MethSynt_Ref_C_O_2_hour_cons = MethSynt_Ref_C_O_2_annual_cons / MethSynt_annual_op_hours
    self.MethSynt_Ref_rawmeth_hour_prod = MethSynt_Ref_C_O_2_hour_cons + MethSynt_Ref_Hydrogen_hour_cons
    self.MethDist_Ref_meth_hour_prod = MethDist_Ref_meth_annual_prod / MethSynt_annual_op_hours
    let MethDist_Ref_water_hour_prod = MethDist_Ref_water_annual_prod / MethSynt_annual_op_hours
    let MethDist_Ref_rawmeth_hour_cons = MethSynt_Ref_rawmeth_hour_prod
    self.CSP_nonsolar_aux_cons = CSP_night_aux_cons_per_loop * CSP_loop_nr_ud
    self.BESS_chrg_max_cons = BESS_cap_ud * BESS_chrg_max_ratio
    self.EY_fix_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_fix_cons
    self.EY_heat_fix_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_heat_fix_cons
    let EY_var_aux_nom_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_var_nom_cons
    self.EY_var_heat_nom_cons = EY_Ref_var_heat_nom_cons * EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons
    self.EY_Hydrogen_nom_prod = EY_Ref_Hydrogen_hour_nom_prod / EY_Ref_var_net_nom_cons * EY_var_net_nom_cons_ud
    let EY_stby_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_stby_cons
    self.EY_heat_stby_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_heat_stby_cons
    let EY_stup_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_stup_cons
    self.EY_heat_stup_cons = EY_var_net_nom_cons_ud / EY_Ref_var_net_nom_cons * EY_Ref_heat_stup_cons
    let MethSynt_RawMeth_min_prod = MethSynt_RawMeth_nom_prod_ud * MethSynt_cap_min_perc
    let CCU_C_O_2_min_prod = CCU_C_O_2_nom_prod_ud * CCU_cap_min_perc
    self.CCU_fix_heat_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hour_prod * CCU_Ref_heat_fix_cons
    self.CCU_fix_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hour_prod * CCU_Ref_fix_cons
    let CCU_heat_fix_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hour_prod * CCU_Ref_heat_fix_cons
    self.CCU_var_nom_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hour_prod * CCU_Ref_var_nom_cons
    self.CCU_var_heat_nom_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hour_prod * CCU_Ref_var_heat_nom_cons
    let CCU_stby_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hour_prod * CCU_Ref_stby_cons
    let CCU_heat_stby_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hour_prod * CCU_Ref_heat_stby_cons
    let CCU_stup_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hour_prod * CCU_Ref_stup_cons
    let CCU_heat_stup_cons = CCU_C_O_2_nom_prod_ud / CCU_Ref_C_O_2_hour_prod * CCU_Ref_heat_stup_cons
    self.PB_fix_aux_el = iff(
      PB_nom_gross_cap_ud <= Double.zero, Double.zero,
      PB_Ref_nom_gross_cap * PB_fix_aux_elec_cons_perc_of_ref * POLY(PB_nom_gross_cap_ud / PB_Ref_nom_gross_cap, fix_aux_el))
    self.PB_nom_var_aux_cons = PB_nom_gross_cap_ud * PB_nom_var_aux_cons_perc_gross
    // let PB_g2n_var_aux_el_Coeff3 = PB_var_aux_cons_Coeff3
    // let PB_g2n_var_aux_el_Coeff2 = PB_var_aux_cons_Coeff2
    // let PB_g2n_var_aux_el_Coeff1 = PB_var_aux_cons_Coeff1
    // let PB_g2n_var_aux_el_Coeff0 = PB_var_aux_cons_Coeff0
    self.PB_stby_aux_cons = iff(
      PB_nom_gross_cap_ud <= Double.zero, Double.zero,
      PB_nom_gross_cap_ud * PB_stby_var_aux_cons_perc + PB_Ref_nom_gross_cap * PB_stby_fix_aux_cons_perc
        * POLY(PB_nom_gross_cap_ud / PB_Ref_nom_gross_cap, fix_stby_el))
    self.PB_stup_aux_cons = iff(
      PB_nom_gross_cap_ud <= Double.zero, Double.zero,
      PB_nom_gross_cap_ud * PB_stup_var_aux_elec_cons_perc + PB_Ref_nom_gross_cap * PB_stup_fix_aux_elec_cons_perc
        * POLY(PB_nom_gross_cap_ud / PB_Ref_nom_gross_cap, fix_stup_el))
    self.PB_gross_min_cap = PB_nom_gross_cap_ud * PB_grs_el_cap_min_perc
    self.Ratio_CSP_vs_Heater =
      (h_SS(Heater_outlet_T) - h_SS(CSP_Hot_HTF_T - SF_heat_exch_approach_temp))
      / (h_SS(CSP_Hot_HTF_T - SF_heat_exch_approach_temp) - h_SS(CSP_Cold_HTF_T - SF_heat_exch_approach_temp))
    self.EY_var_gross_nom_cons = EY_var_net_nom_cons_ud + EY_var_aux_nom_cons
    self.EY_var_aux_min_cons = (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) * EY_cap_min_perc
    let EY_Hydrogen_min_prod = EY_Hydrogen_nom_prod * EY_cap_min_perc
    self.MethSynt_Hydrogen_nom_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hour_prod * MethSynt_Ref_Hydrogen_hour_cons
    self.MethSynt_C_O_2_nom_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hour_prod * MethSynt_Ref_C_O_2_hour_cons
    self.MethSynt_fix_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hour_prod * MethSynt_Ref_fix_cons
    self.MethSynt_heat_fix_prod = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hour_prod * MethSynt_Ref_heat_fix_prod
    self.MethSynt_var_nom_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hour_prod * MethSynt_Ref_var_nom_cons
    self.MethSynt_var_heat_nom_prod = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hour_prod * MethSynt_Ref_var_heat_nom_prod
    let MethSynt_stby_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hour_prod * MethSynt_Ref_stby_cons
    let MethSynt_heat_stby_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hour_prod * MethSynt_Ref_heat_stby_cons
    let MethSynt_stup_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hour_prod * MethSynt_Ref_stup_cons
    let MethSynt_heat_stup_cons = MethSynt_RawMeth_nom_prod_ud / MethSynt_Ref_rawmeth_hour_prod * MethSynt_Ref_heat_stup_cons
    let MethDist_H2O_nom_prod = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hour_prod * MethDist_Ref_water_hour_prod
    self.MethDist_RawMeth_nom_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hour_prod * MethDist_Ref_rawmeth_hour_cons
    self.MethDist_fix_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hour_prod * MethDist_Ref_fix_cons
    let MethDist_heat_fix_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hour_prod * MethDist_Ref_heat_fix_cons
    let MethDist_var_nom_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hour_prod * MethDist_Ref_var_nom_cons
    let MethDist_var_heat_nom_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hour_prod * MethDist_Ref_var_heat_nom_cons
    let MethDist_stby_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hour_prod * MethDist_Ref_stby_cons
    let MethDist_heat_stby_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hour_prod * MethDist_Ref_heat_stby_cons
    let MethDist_stup_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hour_prod * MethDist_Ref_stup_cons
    let MethDist_heat_stup_cons = MethDist_Meth_nom_prod_ud / MethDist_Ref_meth_hour_prod * MethDist_Ref_heat_stup_cons
    self.Overall_fix_cons = EY_fix_cons + CCU_fix_cons + MethSynt_fix_cons + MethDist_fix_cons
    self.Overall_heat_fix_cons = EY_heat_fix_cons + CCU_heat_fix_cons - MethSynt_heat_fix_prod + MethDist_heat_fix_cons
    // let Overall_stup_cons = MethDist_stup_cons + MethSynt_stup_cons + CCU_stup_cons + EY_stup_cons
    // let Overall_heat_stup_cons =
    //   MethDist_heat_stup_cons + MethSynt_heat_stup_cons + CCU_heat_stup_cons + EY_heat_stup_cons
    // let Overall_stby_cons = MethDist_stby_cons + MethSynt_stby_cons + CCU_stby_cons + EY_stby_cons
    // let Overall_heat_stby_cons =
    //   MethDist_heat_stby_cons + MethSynt_heat_stby_cons + CCU_heat_stby_cons + EY_heat_stby_cons
    self.MethDist_harmonious_min_perc = max(
      MethDist_cap_min_perc, MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    let MethDist_RawMeth_min_cons = MethDist_RawMeth_nom_cons * MethDist_cap_min_perc
    self.MethSynt_harmonious_min_perc = max(
      MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons,
      CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons)
    self.MethSynt_C_O_2_min_cons = MethSynt_C_O_2_nom_cons * MethSynt_cap_min_perc
    self.CCU_harmonious_min_perc = max(
      CCU_cap_min_perc, MethSynt_C_O_2_min_cons / CCU_C_O_2_nom_prod_ud,
      max(MethSynt_cap_min_perc, EY_Hydrogen_min_prod / MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud)
    let MethSynt_Hydrogen_min_cons = MethSynt_Hydrogen_nom_cons * MethSynt_cap_min_perc // FIXME
    self.EY_harmonious_min_perc = max(
      EY_cap_min_perc, MethSynt_Hydrogen_min_cons / EY_Hydrogen_nom_prod,
      max(MethSynt_cap_min_perc, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons) * MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod)
    self.MethDist_harmonious_max_perc = min(
      1, MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      EY_Hydrogen_nom_prod / MethSynt_Hydrogen_nom_cons * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      CCU_C_O_2_nom_prod_ud / MethSynt_C_O_2_nom_cons * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    self.MethSynt_harmonious_max_perc = min(
      1, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud, EY_Hydrogen_nom_prod / MethSynt_Hydrogen_nom_cons,
      CCU_C_O_2_nom_prod_ud / MethSynt_C_O_2_nom_cons)
    self.CCU_harmonious_max_perc = min(
      1, MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud,
      EY_Hydrogen_nom_prod / MethSynt_Hydrogen_nom_cons * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud,
      MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud)
    self.EY_harmonious_max_perc = min(
      1, MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod,
      CCU_C_O_2_nom_prod_ud / MethSynt_C_O_2_nom_cons * MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod,
      MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud * MethSynt_Hydrogen_nom_cons / EY_Hydrogen_nom_prod)
    self.PB_nom_net_cap = PB_nom_gross_cap_ud - PB_nom_var_aux_cons - PB_fix_aux_el
    self.PB_net_min_cap = iff(
      PB_nom_gross_cap_ud <= Double.zero, Double.zero,
      PB_gross_min_cap - PB_fix_aux_el - PB_nom_var_aux_cons * POLY(PB_gross_min_cap / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff))
    self.MethDist_HydrogenO_min_prod = MethDist_H2O_nom_prod * MethDist_cap_min_perc

    self.Overall_harmonious_min_perc = Overall_harmonious_max_perc / MethDist_harmonious_max_perc * MethDist_harmonious_min_perc
    self.Overall_harmonious_var_min_cons =
      EY_harmonious_min_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + MethSynt_harmonious_min_perc * MethSynt_var_nom_cons
      + MethDist_harmonious_min_perc * MethDist_var_nom_cons + CCU_harmonious_min_perc * CCU_var_nom_cons
    self.Overall_harmonious_var_heat_min_cons =
      EY_var_heat_nom_cons * EY_harmonious_min_perc + MethDist_var_heat_nom_cons * MethDist_harmonious_min_perc - MethSynt_var_heat_nom_prod
      * MethSynt_harmonious_min_perc + CCU_var_heat_nom_cons * CCU_harmonious_min_perc
    self.Overall_harmonious_var_max_cons =
      EY_harmonious_max_perc * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + MethSynt_harmonious_max_perc * MethSynt_var_nom_cons
      + MethDist_harmonious_max_perc * MethDist_var_nom_cons + CCU_harmonious_max_perc * CCU_var_nom_cons
    self.Overall_harmonious_var_heat_max_cons =
      EY_harmonious_max_perc * EY_var_heat_nom_cons + MethDist_harmonious_max_perc * MethDist_var_heat_nom_cons - MethSynt_harmonious_max_perc
      * MethSynt_var_heat_nom_prod + CCU_harmonious_max_perc * CCU_var_heat_nom_cons
    self.MethDist_min_perc[0] = MethDist_cap_min_perc
    self.MethDist_max_perc[0] = 1
    self.MethDist_min_perc[1] = max(MethDist_cap_min_perc, MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons, Double.zero)
    self.MethSynt_min_perc[1] = max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, Double.zero)
    self.MethDist_max_perc[1] = min(1, MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    self.MethSynt_max_perc[1] = min(1, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud)
    self.MethDist_min_perc[2] = max(
      MethDist_cap_min_perc, MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons,
      MethSynt_cap_min_perc * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      max(MethSynt_cap_min_perc, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons) * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)

    self.MethSynt_min_perc[2] = max(
      MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud, CCU_C_O_2_min_prod / MethSynt_C_O_2_nom_cons)
    self.CCU_min_perc[2] = max(
      CCU_cap_min_perc, MethSynt_C_O_2_min_cons / CCU_C_O_2_nom_prod_ud, MethSynt_cap_min_perc * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud,
      max(MethSynt_cap_min_perc, MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod_ud) * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud)
    self.MethDist_max_perc[2] = min(
      1, MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons,
      CCU_C_O_2_nom_prod_ud / MethSynt_C_O_2_nom_cons * MethSynt_RawMeth_nom_prod_ud / MethDist_RawMeth_nom_cons)
    self.MethSynt_max_perc[2] = min(1, MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud, CCU_C_O_2_nom_prod_ud / MethSynt_C_O_2_nom_cons)
    self.CCU_max_perc[2] = min(
      1, MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud,
      MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod_ud * MethSynt_C_O_2_nom_cons / CCU_C_O_2_nom_prod_ud)

    self.MethDist_min_perc[3] = MethDist_harmonious_min_perc
    self.MethSynt_min_perc[3] = MethSynt_harmonious_min_perc
    self.CCU_min_perc[3] = CCU_harmonious_min_perc
    self.EY_min_perc[3] = EY_harmonious_min_perc
    self.MethDist_max_perc[3] = MethDist_harmonious_max_perc
    self.MethSynt_max_perc[3] = MethSynt_harmonious_max_perc
    self.CCU_max_perc[3] = CCU_harmonious_max_perc
    self.EY_max_perc[3] = EY_harmonious_max_perc
    let Overall_harmonious_var_cons_at_PB_nom = max(PB_net_min_cap, min(PB_nom_net_cap - Overall_fix_cons, Overall_harmonious_var_max_cons))
    let Overall_harmonious_perc_at_PB_nom = max(Overall_harmonious_min_perc, min(Overall_harmonious_max_perc, Overall_harmonious_max_perc / Overall_harmonious_var_max_cons * Overall_harmonious_var_cons_at_PB_nom))

    for j in 0..<4 {
      self.overall_fix_stby_cons[j] =
        iff(MethDist_min_perc[j] > Double.zero, MethDist_fix_cons, MethDist_stby_cons) + iff(MethSynt_min_perc[j] > 0, MethSynt_fix_cons, MethSynt_stby_cons)
        + iff(CCU_min_perc[j] > Double.zero, CCU_fix_cons, CCU_stby_cons) + iff(EY_min_perc[j] > 0, EY_fix_cons, EY_stby_cons)
      self.overall_var_min_cons[j] =
        EY_min_perc[j] * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + MethSynt_min_perc[j] * MethSynt_var_nom_cons + MethDist_min_perc[j]
        * MethDist_var_nom_cons + CCU_min_perc[j] * CCU_var_nom_cons
      self.overall_var_heat_min_cons[j] =
        EY_var_heat_nom_cons * EY_min_perc[j] + MethDist_var_heat_nom_cons * MethDist_min_perc[j] - MethSynt_var_heat_nom_prod * MethSynt_min_perc[j]
        + CCU_var_heat_nom_cons * CCU_min_perc[j]
      self.RawMeth_min_cons[j] = max(Double.zero, -MethSynt_min_perc[j] * MethSynt_RawMeth_nom_prod_ud + MethDist_min_perc[j] * MethDist_RawMeth_nom_cons)
      self.C_O_2_min_cons[j] = max(Double.zero, -CCU_min_perc[j] * CCU_C_O_2_nom_prod_ud + MethSynt_min_perc[j] * MethSynt_C_O_2_nom_cons)
      self.Hydrogen_min_cons[j] = max(Double.zero, -EY_min_perc[j] * EY_Hydrogen_nom_prod + MethSynt_min_perc[j] * MethSynt_Hydrogen_nom_cons)
      self.overall_stup_cons[j] =
        iff(MethDist_min_perc[j] > Double.zero, Double.zero, MethDist_stup_cons) + iff(MethSynt_min_perc[j] > Double.zero, Double.zero, MethSynt_stup_cons)
        + iff(CCU_min_perc[j] > Double.zero, Double.zero, CCU_stup_cons) + iff(EY_min_perc[j] > Double.zero, Double.zero, EY_stup_cons)
      self.equiv_harmonious_max_perc[j] = max(
        0, ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * MethDist_max_perc[j], Double.zero),
        ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * MethSynt_max_perc[j], Double.zero),
        ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * CCU_max_perc[j], Double.zero),
        ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * EY_max_perc[j], Double.zero))

      self.overall_heat_fix_stby_cons[j] =
        iff(MethDist_max_perc[j] > Double.zero, MethDist_heat_fix_cons, MethDist_heat_stby_cons)
        + iff(MethSynt_max_perc[j] > Double.zero, -MethSynt_heat_fix_prod, MethSynt_heat_stby_cons)
        + iff(CCU_max_perc[j] > Double.zero, CCU_heat_fix_cons, CCU_heat_stby_cons) + iff(EY_max_perc[j] > Double.zero, EY_heat_fix_cons, EY_heat_stby_cons)
      self.overall_var_max_cons[j] =
        EY_max_perc[j] * (EY_var_net_nom_cons_ud + EY_var_aux_nom_cons) + MethSynt_max_perc[j] * MethSynt_var_nom_cons + MethDist_max_perc[j]
        * MethDist_var_nom_cons + CCU_max_perc[j] * CCU_var_nom_cons
      self.overall_var_heat_max_cons[j] =
        EY_var_heat_nom_cons * EY_max_perc[j] + MethDist_var_heat_nom_cons * MethDist_max_perc[j] - MethSynt_var_heat_nom_prod * MethSynt_max_perc[j]
        + CCU_var_heat_nom_cons * CCU_max_perc[j]
      self.RawMeth_max_cons[j] = max(Double.zero, -MethSynt_max_perc[j] * MethSynt_RawMeth_nom_prod_ud + MethDist_max_perc[j] * MethDist_RawMeth_nom_cons)
      self.C_O_2_max_cons[j] = max(Double.zero, -CCU_max_perc[j] * CCU_C_O_2_nom_prod_ud + MethSynt_max_perc[j] * MethSynt_C_O_2_nom_cons)
      self.Hydrogen_max_cons[j] = max(Double.zero, -EY_max_perc[j] * EY_Hydrogen_nom_prod + MethSynt_max_perc[j] * MethSynt_Hydrogen_nom_cons)
      self.overall_heat_stup_cons[j] =
        iff(MethDist_min_perc[j] > Double.zero, Double.zero, MethDist_heat_stup_cons) + iff(MethSynt_min_perc[j] > Double.zero, Double.zero, MethSynt_heat_stup_cons)
        + iff(CCU_min_perc[j] > Double.zero, Double.zero, CCU_heat_stup_cons) + iff(EY_min_perc[j] > Double.zero, Double.zero, EY_heat_stup_cons)
    }

    self.equiv_harmonious_min_perc[0] = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * MethDist_min_perc[0], 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * MethSynt_min_perc[0], 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * CCU_min_perc[0], 0),
      ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * EY_min_perc[0], 0))
    self.equiv_harmonious_min_perc[1] = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * MethDist_min_perc[1], 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * MethSynt_min_perc[1], 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * CCU_min_perc[1], 0),
      ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * EY_min_perc[1], 0))
    self.equiv_harmonious_min_perc[2] = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * MethDist_min_perc[2], 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * MethSynt_min_perc[2], 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * CCU_min_perc[2], 0), 0)
    self.equiv_harmonious_min_perc[3] = max(
      ifFinite(Overall_harmonious_max_perc / MethDist_harmonious_max_perc * MethDist_min_perc[3], 0),
      ifFinite(Overall_harmonious_max_perc / MethSynt_harmonious_max_perc * MethSynt_min_perc[3], 0),
      ifFinite(Overall_harmonious_max_perc / CCU_harmonious_max_perc * CCU_min_perc[3], 0),
      ifFinite(Overall_harmonious_max_perc / EY_harmonious_max_perc * EY_min_perc[3], 0), 0)

    self.MethDist_harmonious_perc_at_PB_nom = MethDist_harmonious_max_perc / Overall_harmonious_max_perc * Overall_harmonious_perc_at_PB_nom
    let MethSynt_harmonious_perc_at_PB_nom = MethSynt_harmonious_max_perc / Overall_harmonious_max_perc * Overall_harmonious_perc_at_PB_nom
    let CCU_harmonious_perc_at_PB_nom = CCU_harmonious_max_perc / Overall_harmonious_max_perc * Overall_harmonious_perc_at_PB_nom
    self.EY_harmonious_perc_at_PB_nom = EY_harmonious_max_perc / Overall_harmonious_max_perc * Overall_harmonious_perc_at_PB_nom
    self.Overall_harmonious_var_heat_cons_at_PB_nom =
      EY_harmonious_perc_at_PB_nom * EY_var_heat_nom_cons + MethDist_harmonious_perc_at_PB_nom * MethDist_var_heat_nom_cons
      - MethSynt_harmonious_perc_at_PB_nom * MethSynt_var_heat_nom_prod + CCU_harmonious_perc_at_PB_nom * CCU_var_heat_nom_cons


      // if nominal_gross_cap == 0 {
      //   self.nominal_gross_cap = 0
      //   max_heat_input = 0
      //   min_heat_input = 0
      //   minimum_gross_cap = 0
      //   nominal_gross_eff = 0
      //   th = Polynomial([0])
      //   el = Polynomial([0])
      //   return
      // }

      // minimum_gross_cap = nominal_gross_cap * min_el_cap_perc

    let PB_Ref_25p_aux_heat_prod: Double = (7.194 * 2775.4 - 5.414 * 167.6 - 1.78 * 649.6) / 1000
    let PB_Ref_30p_aux_heat_prod: Double = (10.778 * 2775.4 - 8.278 * 167.6 - 2.5 * 649.6) / 1000
    let PB_Ref_nom_aux_heat_prod: Double = (23.333 * 2775.4 - 15.167 * 167.6 - 8.167 * 649.6) / 1000
    let TES_cold_tank_T: Double = 304.55
    let TES_dead_mass_ratio: Double = 0.1

     let gross_cap = [  // A29-A33
       PB_Ref_nom_gross_cap, ((((PB_Ref_25p_gross_cap_max_aux_heat + PB_Ref_nom_gross_cap) / 2) + PB_Ref_nom_gross_cap) / 2),
       ((PB_Ref_25p_gross_cap_max_aux_heat + PB_Ref_nom_gross_cap) / 2), PB_Ref_30p_gross_cap, PB_Ref_25p_gross_cap_max_aux_heat,
     ]
      let load_perc: [Double] = gross_cap.map { $0 / PB_Ref_nom_gross_cap }  // B
      let PB_Ref_25p_max_aux_heat_prod: Double = (23.333 * 2775.4 - 15.167 * 167.6 - 8.167 * 649.6) / 1000
      let heat_input = load_perc.map { $0 * PB_nom_gross_cap_ud }  // D
      let factor = seek(goal: 0) { (PB_Ref_25p_heat_cons - PB_Ref_25p_aux_heat_prod * $0) - (PB_Ref_25p_heat_cons_max_aux_heat - PB_Ref_25p_max_aux_heat_prod * $0) } // 0.68792724609375

      let no_extraction = [  // B
        PB_Ref_nom_heat_cons - PB_Ref_nom_aux_heat_prod * factor,
         ((((PB_Ref_25p_heat_cons + PB_Ref_nom_heat_cons) / 2) + PB_Ref_nom_heat_cons) / 2)
           - ((((PB_Ref_25p_aux_heat_prod + PB_Ref_nom_aux_heat_prod) / 2) + PB_Ref_nom_aux_heat_prod) / 2) * factor,
         ((PB_Ref_25p_heat_cons + PB_Ref_nom_heat_cons) / 2) - ((PB_Ref_25p_aux_heat_prod + PB_Ref_nom_aux_heat_prod) / 2) * factor,
        PB_Ref_30p_heat_cons - PB_Ref_30p_aux_heat_prod * factor, PB_Ref_25p_heat_cons - PB_Ref_25p_aux_heat_prod * factor,
      ]

      let ref_eff = zip(gross_cap, no_extraction).map(/)  // C
      let gross = zip(heat_input, ref_eff).map(/)  // E
      let eff = zip(heat_input, gross).map(/)  // K
      let eff_factor = eff.map { $0 / eff[0] }  // L
      let thermal_load_perc = gross.map { $0 / gross[0] }  // J

      self.PB_nom_gross_eff = heat_input[0] / gross[0]
      self.PB_nom_heat_cons = ifFinite(PB_nom_gross_cap_ud / PB_nom_gross_eff, Double.zero)
      self.PB_cold_start_heat_req = PB_nom_heat_cons * PB_cold_start_energyperc
      self.PB_warm_start_heat_req = PB_nom_heat_cons * PB_warm_start_energyperc
      self.PB_hot_start_heat_req = PB_nom_heat_cons * PB_hot_start_energyperc

      let gross_electrical_output = heat_input.map { $0 - PB_fix_aux_el }
      let net_electrical_output = zip(heat_input, gross_electrical_output).map {
        iff($0<=0, 0, $1-PB_nom_var_aux_cons_perc_gross * PB_nom_gross_cap_ud * (POLY($0/PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff)))
      }
      let net_el_output_factor = net_electrical_output.map { $0 / net_electrical_output[0] }
      let var_aux_cons = zip(gross_electrical_output, net_electrical_output).map(-)
      let auxiliary_consumption_factor = var_aux_cons.map { $0 / var_aux_cons[0] }

      let steam_extraction: [Double] = net_electrical_output.map { output -> Double in
        return iff(PB_nom_gross_cap_ud.isZero, Double.zero, (Overall_harmonious_var_heat_cons_at_PB_nom + Overall_heat_fix_cons) / PB_nom_net_cap * output)
      }  // F

      self.th_Coeff = Polynomial.fit(x: thermal_load_perc, y: eff_factor, order: 4)!.coefficients
      self.el_Coeff = Polynomial.fit(x: load_perc, y: eff_factor, order: 4)!.coefficients
      let PBeff = POLY(PB_grs_el_cap_min_perc, el_Coeff)
      self.PB_heat_min_input = ifFinite(PB_gross_min_cap / (PB_nom_gross_eff * PBeff), Double.zero)
      self.PB_gross_min_eff = ifFinite(PB_gross_min_cap / PB_heat_min_input, Double.zero)

      self.PB_Ratio_Heat_input_vs_output = factor * (no_extraction[0] / PB_Ref_nom_aux_heat_prod) / (gross[0] / steam_extraction[0])
      self.PB_n_g_var_aux_el_Coeff = Polynomial.fit(x: net_el_output_factor, y: auxiliary_consumption_factor, order: 4)!.coefficients
      self.PB_var_heat_max_cons = gross[0] + steam_extraction[0] * PB_Ratio_Heat_input_vs_output
      self.PB_nom_var_aux_cons_perc_net = var_aux_cons[0] / net_electrical_output[0]
      self.TES_thermal_cap = TES_full_load_hours_ud * PB_var_heat_max_cons
      self.TES_salt_mass = TES_thermal_cap * 1000 * 3600 / (h_SS(Heater_outlet_T) - h_SS(TES_cold_tank_T)) / 1000 * (1 + TES_dead_mass_ratio)
  }
}

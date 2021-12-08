import Utilities

let _ = 3.39311445520421E-02

let PB_g2n_var_aux_el = Polynomial(
  [
    6.75146424176523E-01, -6.52496244217653E-02, 1.02805131768711E-01,
    2.94370132015919E-01,
  ]
  .reversed()
)

let _ = 6.43407043308906E-03

let fix_aux_el = Polynomial(
  [
    3.30241955243857E-01, -4.95362932865787E-01, 2.93145114445988E-01,
    8.71975863175942E-01,
  ]
  .reversed()
)

let _ = 4.62509835126915E-03
let _ = 5.26407043308906E-03

let fix_stby_el = Polynomial(
  [
    2.11142058373717E-01, -3.16713087560573E-01, 2.14558232294004E-01,
    8.91012796892852E-01,
  ]
  .reversed()
)

let _ = 1.27891539980364E-02
let _ = 5.98157043308906E-03

let fix_stup_el = Polynomial(
  [
    1.85815193367649E-01, -2.78722790051474E-01, 1.98852401739667E-01,
    8.94055194944158E-01,
  ]
  .reversed()
)

let PB_fix_aux_el =
  Ref_PB_nom_gross_cap * PB_fix_aux_elec_cons_perc_of_ref
  * fix_aux_el(PB_nom_gross_cap / Ref_PB_nom_gross_cap)
let PB_nom_var_aux_cons = PB_nom_gross_cap * PB_nom_var_aux_cons_perc_gross
let PB_stby_aux_cons =
  PB_nom_gross_cap * PB_stby_var_aux_elec_cons_perc + Ref_PB_nom_gross_cap
  * PB_stby_fix_aux_elec_cons_perc
  * fix_stby_el(PB_nom_gross_cap / Ref_PB_nom_gross_cap)
let PB_stup_aux_cons =
  PB_nom_gross_cap * PB_stup_var_aux_elec_cons_perc + Ref_PB_nom_gross_cap
  * PB_stup_fix_aux_elec_cons_perc
  * fix_stup_el(PB_nom_gross_cap / Ref_PB_nom_gross_cap)
let PB_gross_cap_at_min_harmonious =
  PB_net_cap_at_min_harmonious + PB_fix_aux_el + PB_nom_net_cap
  * PB_nom_var_aux_cons_perc_net
  * PB_n2g_var_aux_el(PB_net_cap_at_min_harmonious / PB_nom_net_cap)
let PB_net_cap_at_min_harmonious = min(
  PB_nom_net_cap,
  max(PB_net_min_cap, Overall_harmonious_min_var_cons + Overall_fix_aux_cons)
)
let PB_eff_at_min_harmonious = IFERROR(
  PB_nom_gross_eff
    * el(max(PB_gross_min_cap, PB_gross_cap_at_min_harmonious)
        / PB_nom_gross_cap),
  0
)
let PB_heat_input_at_min_harmonious = IFERROR(
  PB_gross_cap_at_min_harmonious / PB_eff_at_min_harmounious,
  0
)
let PB_gross_cap_at_max_harmonious =
  PB_fix_aux_el + PB_net_cap_at_max_harmonious + PB_nom_net_cap
  * PB_nom_var_aux_cons_perc_net
  * PB_n2g_var_aux_el(PB_net_cap_at_max_harmonious / PB_nom_net_cap)
let PB_eff_at_max_harmonious = IFERROR(
  iff(
    PB_gross_cap_at_max_harmonious = PB_nom_gross_cap,
    PB_nom_gross_eff,
    PB_nom_gross_eff
      * el(PB_gross_cap_at_max_harmonious / PB_nom_gross_cap)
  ),
  0
)
let PB_heat_input_at_max_harmonious = IFERROR(
  PB_gross_cap_at_max_harmonious / PB_eff_at_max_harmonious,
  0
)
let CSP_nonsolar_aux_cons = 0.003 * CSP_Loop_Nr
let G96 = 2.7
let G97 = 40
let G98 = Ref_EY_capacity / 55
let G119 = 56227
let G123 = 0
let G124 = 1.1
let G125 = 1.7
let G126 = 17.53
let MethDist_cap_min_perc = 0.5
let EY_fix_aux_elec = 0
// G96
let EY_var_aux_nom_cons = EY_var_net_nom_cons / Ref_EY_capacity
// G96
let _ = 2.7
// G97
let EY_var_heat_nom_cons = 40 * EY_var_net_nom_cons / Ref_EY_capacity
// G98
let EY_H2_nom_prod = Ref_EY_capacity / 55 / Ref_EY_capacity * EY_var_net_nom_cons
// G98

let EY_H2_min_prod = EY_H2_nom_prod * EY_cap_min_perc
let EY_ratio_heat_vs_total_Ein =
  EY_var_heat_nom_cons / El_boiler_efficiency
  / (EY_var_heat_nom_cons / El_boiler_efficiency + EY_var_net_nom_cons
    + EY_var_aux_nom_cons + EY_fix_aux_elec)
let EY_ratio_elec_vs_total_Ein =
  (EY_var_net_nom_cons + EY_var_aux_nom_cons + EY_fix_aux_elec)
  / (EY_var_net_nom_cons + EY_var_aux_nom_cons + EY_fix_aux_elec
    + EY_var_heat_nom_cons / El_boiler_efficiency)
let MethSynt_RawMeth_nom_prod = 50
let MethSynt_RawMeth_min_prod = B108 * MethSynt_cap_min_perc
let MethSynt_H2_nom_cons = MethSynt_RawMeth_nom_prod / G109 * G107
let MethSynt_H2_min_cons = MethSynt_H2_nom_cons * MethSynt_cap_min_perc
let MethSynt_CO2_nom_cons = MethSynt_RawMeth_nom_prod / G109 * G108
let MethSynt_CO2_min_cons = MethSynt_CO2_nom_cons * MethSynt_cap_min_perc
let MethSynt_fix_aux_cons = MethDist_Meth_nom_prod / Ref_meth_hourly_prod_capacity * G110
let MethSynt_var_aux_nom_cons = MethDist_Meth_nom_prod / Ref_meth_hourly_prod_capacity * G111
let MethSynt_var_heat_nom_prod = MethDist_Meth_nom_prod / Ref_meth_hourly_prod_capacity * G112
let MethSynt_heat_stup_stby_cons = MethDist_Meth_nom_prod / Ref_meth_hourly_prod_capacity * G113
let MethDist_Meth_nom_prod = 20
let MethDist_Meth_min_prod = MethDist_cap_min_perc * MethDist_Meth_nom_prod
let MethDist_H2O_nom_prod =
  MethDist_Meth_nom_prod / Ref_meth_prod_capacity * G119
let MethDist_H2O_min_prod =
  MethDist_cap_min_perc * MethDist_Meth_nom_prod / Ref_meth_prod_capacity * G119
let MethDist_RawMeth_nom_cons = MethDist_Meth_nom_prod / Ref_meth_hourly_prod_capacity * G122
let MethDist_RawMeth_min_cons =
  MethDist_RawMeth_nom_cons * MethDist_cap_min_perc
let MethDist_var_heat_nom_cons = MethDist_Meth_nom_prod / Ref_meth_hourly_prod_capacity * G126
let MethDist_fix_aux_cons = MethDist_Meth_nom_prod / Ref_meth_hourly_prod_capacity * G123
let MethDist_var_aux_nom_cons = MethDist_Meth_nom_prod / Ref_meth_hourly_prod_capacity * G124
let MethDist_heat_stup_stby_cons = MethDist_Meth_nom_prod / Ref_meth_hourly_prod_capacity * G125
let RawMeth_storage_cap = 300
let CO2_storage_cap = H2_storage_cap / G100 * G139 / 4
let Ref_CCU_capacity = 22
let G135 = 0
let G136 = 2
let G137 = 22
let CCU_cap_min_perc = 0.5
let CCU_CO2_nom_prod = 30
let CCU_CO2_min_prod = CCU_CO2_nom_prod * CCU_cap_min_perc
let CCU_fix_aux_cons = CCU_CO2_nom_prod / Ref_CCU_capacity * G135
let CCU_var_heat_nom_cons = CCU_CO2_nom_prod / Ref_CCU_capacity * G137
let Overall_fix_aux_cons =
  EY_fix_aux_elec + MethSynt_fix_aux_cons + MethDist_fix_aux_cons
  + CCU_fix_aux_cons
let Overall_harmonious_min_perc =
  Overall_harmonious_max_perc / Overall_harmonious_max_var_cons
  * Overall_harmonious_min_var_cons
let MethDist_harmonious_min_perc = max(
  MethDist_cap_min_perc,
  MethSynt_RawMeth_min_prod / MethDist_RawMeth_nom_cons,
  max(MethSynt_cap_min_perc, EY_H2_min_prod / MethSynt_H2_nom_cons)
    * MethSynt_RawMeth_nom_prod / MethDist_RawMeth_nom_cons,
  max(MethSynt_cap_min_perc, CCU_CO2_min_prod / MethSynt_CO2_nom_cons)
    * MethSynt_RawMeth_nom_prod / MethDist_RawMeth_nom_cons
)
let MethSynt_harmonious_min_perc = max(
  MethSynt_cap_min_perc,
  MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod,
  EY_H2_min_prod / MethSynt_H2_nom_cons,
  CCU_CO2_min_prod / MethSynt_CO2_nom_cons
)
let CCU_harmonious_min_perc = max(
  CCU_cap_min_perc,
  MethSynt_CO2_min_cons / CCU_CO2_nom_prod,
  max(MethSynt_cap_min_perc, EY_H2_min_prod / MethSynt_H2_nom_cons)
    * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod,
  max(
    MethSynt_cap_min_perc,
    MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod
  ) * MethSynt_CO2_nom_cons / CCU_CO2_nom_prod
)
let EY_harmonious_min_perc = max(
  EY_cap_min_perc,
  MethSynt_H2_min_cons / EY_H2_nom_prod,
  max(MethSynt_cap_min_perc, CCU_CO2_min_prod / MethSynt_CO2_nom_cons)
    * MethSynt_H2_nom_cons / EY_H2_nom_prod,
  max(
    MethSynt_cap_min_perc,
    MethDist_RawMeth_min_cons / MethSynt_RawMeth_nom_prod
  ) * MethSynt_H2_nom_cons / EY_H2_nom_prod
)
let Overall_harmonious_min_var_cons =
  EY_harmonious_min_perc * (EY_var_net_nom_cons + EY_var_aux_nom_cons)
  + MethSynt_harmonious_min_perc * MethSynt_var_aux_nom_cons
  + MethDist_harmonious_min_perc * MethDist_var_aux_nom_cons
  + CCU_harmonious_min_perc * CCU_var_aux_nom_cons
let Overall_harmonious_min_var_heat_cons =
  EY_var_heat_nom_cons * EY_harmonious_min_perc + MethDist_var_heat_nom_cons
  * MethDist_harmonious_min_perc - MethSynt_var_heat_nom_prod
  * MethSynt_harmonious_min_perc + CCU_var_heat_nom_cons
  * CCU_harmonious_min_perc
let Overall_harmonious_max_perc = 1
let MethDist_harmonious_max_perc = min(
  1,
  MethSynt_RawMeth_nom_prod / MethDist_RawMeth_nom_cons,
  EY_H2_nom_prod / MethSynt_H2_nom_cons * MethSynt_RawMeth_nom_prod
    / MethDist_RawMeth_nom_cons,
  CCU_CO2_nom_prod / MethSynt_CO2_nom_cons * MethSynt_RawMeth_nom_prod
    / MethDist_RawMeth_nom_cons
)
let MethSynt_harmonious_max_perc = min(
  1,
  MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod,
  EY_H2_nom_prod / MethSynt_H2_nom_cons,
  CCU_CO2_nom_prod / MethSynt_CO2_nom_cons
)
let CCU_harmonious_max_perc = min(
  1,
  MethSynt_CO2_nom_cons / CCU_CO2_nom_prod,
  EY_H2_nom_prod / MethSynt_H2_nom_cons * MethSynt_CO2_nom_cons
    / CCU_CO2_nom_prod,
  MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod * MethSynt_CO2_nom_cons
    / CCU_CO2_nom_prod
)
let EY_harmonious_max_perc = min(
  1,
  MethSynt_H2_nom_cons / EY_H2_nom_prod,
  CCU_CO2_nom_prod / MethSynt_CO2_nom_cons * MethSynt_H2_nom_cons
    / EY_H2_nom_prod,
  MethDist_RawMeth_nom_cons / MethSynt_RawMeth_nom_prod * MethSynt_H2_nom_cons
    / EY_H2_nom_prod
)
let Overall_harmonious_max_var_cons =
  EY_harmonious_max_perc * (EY_var_net_nom_cons + EY_var_aux_nom_cons)
  + MethSynt_harmonious_max_perc * MethSynt_var_aux_nom_cons
  + MethDist_harmonious_max_perc * MethDist_var_aux_nom_cons
  + CCU_harmonious_max_perc * CCU_var_aux_nom_cons
let Overall_harmonious_max_var_heat_cons =
  EY_harmonious_max_perc * EY_var_heat_nom_cons + MethDist_harmonious_max_perc
  * MethDist_var_heat_nom_cons - MethSynt_harmonious_max_perc
  * MethSynt_var_heat_nom_prod + CCU_harmonious_max_perc * CCU_var_heat_nom_cons
let Overall_harmonious_perc_at_PB_min =
  Overall_harmonious_max_perc / Overall_harmonious_max_var_cons
  * Overall_harmonious_var_cons_at_PB_min
let MethDist_harmonious_perc_at_PB_min =
  MethDist_harmonious_max_perc / Overall_harmonious_max_var_cons
  * Overall_harmonious_var_cons_at_PB_min
let MethSynt_harmonious_perc_at_PB_min =
  MethSynt_harmonious_max_perc / Overall_harmonious_max_var_cons
  * Overall_harmonious_var_cons_at_PB_min
let CCU_harmonious_perc_at_PB_min =
  CCU_harmonious_max_perc / Overall_harmonious_max_var_cons
  * Overall_harmonious_var_cons_at_PB_min
let EY_harmonious_perc_at_PB_min =
  EY_harmonious_max_perc / Overall_harmonious_max_var_cons
  * Overall_harmonious_var_cons_at_PB_min
let Overall_harmonious_var_cons_at_PB_min = max(
  PB_net_min_cap,
  Overall_harmonious_min_var_cons
)
let Overall_harmonious_var_heat_cons_at_PB_min =
  Overall_harmonious_var_cons_at_PB_min / Overall_harmonious_max_var_cons
  * Overall_harmonious_max_var_heat_cons
let Overall_harmonious_perc_at_PB_nom =
  Overall_harmonious_max_perc / Overall_harmonious_max_var_cons
  * Overall_harmonious_var_cons_at_PB_nom
let MethDist_harmonious_perc_at_PB_nom = iff(
  PB_nom_net_cap / Overall_harmonious_max_var_cons
    * MethDist_harmonious_max_perc < MethDist_harmonious_min_perc,
  0,
  PB_nom_net_cap / Overall_harmonious_max_var_cons
    * MethDist_harmonious_max_perc
)
let MethSynt_harmonious_perc_at_PB_nom = iff(
  PB_nom_net_cap / Overall_harmonious_max_var_cons
    * MethSynt_harmonious_max_perc < MethSynt_harmonious_min_perc,
  0,
  PB_nom_net_cap / Overall_harmonious_max_var_cons
    * MethSynt_harmonious_max_perc
)
let CCU_harmonious_perc_at_PB_nom = iff(
  PB_nom_net_cap / Overall_harmonious_max_var_cons * CCU_harmonious_max_perc
    < CCU_harmonious_min_perc,
  0,
  PB_nom_net_cap / Overall_harmonious_max_var_cons * CCU_harmonious_max_perc
)
let EY_harmonious_perc_at_PB_nom = iff(
  PB_nom_net_cap / Overall_harmonious_max_var_cons * EY_harmonious_max_perc
    < EY_harmonious_min_perc,
  0,
  PB_nom_net_cap / Overall_harmonious_max_var_cons * EY_harmonious_max_perc
)
let Overall_harmonious_var_cons_at_PB_nom = min(
  PB_nom_net_cap,
  Overall_harmonious_max_var_cons
)
let Overall_harmonious_var_heat_cons_at_PB_nom =
  Overall_harmonious_max_var_heat_cons / Overall_harmonious_max_var_cons
  * Overall_harmonious_var_cons_at_PB_nom

let A_equiv_harmonious_min_perc = max(
  IFERROR(
    Overall_harmonious_max_perc / MethDist_harmonious_max_perc
      * A_MethDist_Min_perc,
    0
  ),
  IFERROR(
    Overall_harmonious_max_perc / MethSynt_harmonious_max_perc
      * A_MethSynt_Min_perc,
    0
  ),
  IFERROR(
    Overall_harmonious_max_perc / CCU_harmonious_max_perc * A_CCU_Min_perc,
    0
  ),
  IFERROR(
    Overall_harmonious_max_perc / EY_harmonious_max_perc * A_EY_Min_perc,
    0
  )
)



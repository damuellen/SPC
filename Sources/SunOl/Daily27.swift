extension TunOl {
  func d27(_ d7: inout [Double], case j: Int, day0: [Double], d1: [Double], d6: [Double]) {
    let (B, C, E, F, G, H, O, P, Q, R, S, T, U, V, W, X) = (365, 730, 0, 365, 730, 1095, 3650, 4015, 4380, 4745, 5110, 5475, 5840, 6205, 6570, 6935)

    let AE = 9490
    let (EA, EB, EC, ED, EE, EF, EG, EH, EI, EJ, EK, EL, EM, EN, EO, EP, EQ, ER, ES, ET, EV, EW, EY, EZ) = (3285, 3650, 4015, 4380, 4745, 5110, 5475, 5840, 6205, 6570, 6935, 7300, 7665, 8030, 8395, 8760, 9125, 9490, 9855, 10220, 10950, 11315, 12045, 12410)

    let DR = 0
    let DS = 365
    let DT = 730
    let DU = 1095
    let DV = 1460
    let DW = 1825
    let DX = 2190
    let DY = 2555
    let DZ = 2920

    let equiv_harmonious_range = equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]

    let ddAE = 45990
    for i in 0..<365 { d7[ddAE + i] = equiv_harmonious_range < 1E-10 ? 1 : (d1[AE + i] - equiv_harmonious_min_perc[j]) / equiv_harmonious_range }
    /// Surplus harm op period el after min day harm op and min night op prep
    let FC = 0
    // EB6+EH6-O6-MIN(EK6,max(0,EA6+E6+G6/El_boiler_eff-EJ6)/BESS_chrg_eff)-MAX(0,Q6-EE6)/El_boiler_eff
    for i in 0..<365 { d7[FC + i] = d6[EB + i] + d6[EH + i] - d1[O + i] - min(d6[EK + i], max(.zero, d6[EA + i] + d1[E + i] + d1[G + i] / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - max(.zero, d1[Q + i] - d6[EE + i]) / El_boiler_eff }

    /// Surplus harm op period el after min day harm op and max night op prep
    let FD = 365
    // EB6+EH6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-MIN(EK6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff-EJ6)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff
    for i in 0..<365 {
      d7[FD + i] =
        d6[EB + i] + d6[EH + i] - (d1[O + i] + (d1[P + i] - d1[O + i]) * d7[ddAE + i]) - min(d6[EK + i], max(.zero, d6[EA + i] + (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddAE + i]) + (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddAE + i]) / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - max(
          .zero, (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddAE + i]) - d6[EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after max day harm op and min night op prep
    let FE = 730
    // EC6+EI6-O6-MIN(EL6,max(0,EA6+E6+G6/El_boiler_eff-EJ6)/BESS_chrg_eff)-MAX(0,Q6-EF6)/El_boiler_eff
    for i in 0..<365 { d7[FE + i] = d6[EC + i] + d6[EI + i] - d1[O + i] - min(d6[EL + i], max(.zero, d6[EA + i] + d1[E + i] + d1[G + i] / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - max(.zero, d1[Q + i] - d6[EF + i]) / El_boiler_eff }

    /// Surplus outside harm op period el after min day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let FF = 1095
    // (EK6+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff
    for i in 0..<365 { d7[FF + i] = (d6[EK + i] + d6[EM + i]) * BESS_chrg_eff + d6[EJ + i] - d1[E + i] - d1[G + i] / El_boiler_eff }

    /// Surplus outside harm op period el after min day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let FG = 1460
    // (EK6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff
    for i in 0..<365 { d7[FG + i] = (d6[EK + i] + d6[EM + i]) * BESS_chrg_eff + d6[EJ + i] - (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddAE + i]) - (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddAE + i]) / El_boiler_eff }

    /// Surplus outside harm op period el after max day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let FH = 1825
    // (EL6+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff
    for i in 0..<365 { d7[FH + i] = (d6[EL + i] + d6[EM + i]) * BESS_chrg_eff + d6[EJ + i] - d1[E + i] - d1[G + i] / El_boiler_eff }

    /// Surplus harm op heat after min day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let FI = 2190
    // EE6+(EB6+EH6-MIN(EK6,max(0,EA6+E6+G6/El_boiler_eff-EJ6)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6
    for i in 0..<365 { d7[FI + i] = d6[EE + i] + (d6[EB + i] + d6[EH + i] - min(d6[EK + i], max(.zero, d6[EA + i] + d1[E + i] + d1[G + i] / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - d1[O + i]) * El_boiler_eff - d1[Q + i] }

    /// Surplus harm op heat after min day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let FJ = 2555
    // EE6+(EB6+EH6-MIN(EK6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff-EJ6)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      d7[FJ + i] =
        d6[EE + i] + (d6[EB + i] + d6[EH + i] - min(d6[EK + i], max(.zero, d6[EA + i] + (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddAE + i]) + (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddAE + i]) / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - (d1[O + i] + (d1[P + i] - d1[O + i]) * d7[ddAE + i])) * El_boiler_eff
        - (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddAE + i])
    }

    /// Surplus harm op heat after max day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let FK = 2920
    // EF6+(EC6+EI6-MIN(EL6,max(0,EA6+E6+G6/El_boiler_eff-EJ6)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6
    for i in 0..<365 { d7[FK + i] = d6[EF + i] + (d6[EC + i] + d6[EI + i] - min(d6[EL + i], max(.zero, d6[EA + i] + d1[E + i] + d1[G + i] / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - d1[O + i]) * El_boiler_eff - d1[Q + i] }

    /// Surplus outside harm op heat after min day harm and min night op prep
    let FL = 3285
    /// Surplus outside harm op heat after min day harm and max night op prep
    let FM = 3650
    /// Surplus outside harm op heat after max day harm and min night op prep
    let FN = 4015
    /// Surplus el boiler cap after min harm op and min night op prep during harm op period
    let FO = 4380
    /// Surplus el boiler cap after min harm op and max night op prep during harm op period
    let FP = 4745
    /// Surplus el boiler cap after max harm op and min night op prep during harm op period
    let FQ = 5110
    /// Surplus el boiler cap after min harm op and min night op prep outside of harm op period
    let FR = 5475
    /// Surplus el boiler cap after min harm op and max night op prep outside of harm op period
    let FS = 5840
    for i in 0..<365 {
      // EG6+ER6*El_boiler_eff-G6
      d7[FL + i] = d6[EG + i] + d6[ER + i] * El_boiler_eff - d1[G + i]
      // EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
      d7[FM + i] = d6[EG + i] + d6[ER + i] * El_boiler_eff - (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddAE + i])
      // EG6+ER6*El_boiler_eff-G6
      d7[FN + i] = d6[EG + i] + d6[ER + i] * El_boiler_eff - d1[G + i]
      // EP6-MAX(0,Q6-EE6)/El_boiler_eff
      d7[FO + i] = d6[EP + i] - max(.zero, d1[Q + i] - d6[EE + i]) / El_boiler_eff
      // EP6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff
      d7[FP + i] = d6[EP + i] - max(.zero, (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddAE + i]) - d6[EE + i]) / El_boiler_eff
      // EQ6-MAX(0,Q6-EF6)/El_boiler_eff
      d7[FQ + i] = d6[EQ + i] - max(.zero, d1[Q + i] - d6[EF + i]) / El_boiler_eff
      // ER6-MAX(0,G6-EG6)/El_boiler_eff
      d7[FR + i] = d6[ER + i] - max(.zero, d1[G + i] - d6[EG + i]) / El_boiler_eff
      // ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff
      d7[FS + i] = d6[ER + i] - max(.zero, (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddAE + i]) - d6[EG + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep outside of harm op period
    let FT = 6205
    /// Surplus RawMeth prod cap after min day harm and min night op prep
    let FU = 6570
    /// Surplus RawMeth prod cap after min day harm and max night op prep
    let FV = 6935
    /// Surplus RawMeth prod cap after max day harm and min night op prep
    let FW = 7300
    /// Surplus CO2 prod cap after min day harm and min night op prep
    let FX = 7665
    /// Surplus CO2 prod cap after min day harm and max night op prep
    let FY = 8030
    /// Surplus CO2 prod cap after max day harm and min night op prep
    let FZ = 8395
    /// Surplus H2 prod cap after min day harm and min night op prep
    let GA = 8760
    /// Surplus H2 prod cap after min day harm and max night op prep
    let GB = 9125
    /// Surplus H2 prod cap after max day harm and min night op prep
    let GC = 9490

    for i in 0..<365 {
      // ER6-MAX(0,G6-EG6)/El_boiler_eff
      d7[FT + i] = d6[ER + i] - max(.zero, d1[G + i] - d6[EG + i]) / El_boiler_eff
      // ES6-S6
      d7[FU + i] = d6[ES + i] - d1[S + i]
      // ES6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
      d7[FV + i] = d6[ES + i] - (d1[S + i] + (d1[T + i] - d1[S + i]) * d7[ddAE + i])
      // ET6-S6
      d7[FW + i] = d6[ET + i] - d1[S + i]
      // EV6-U6
      d7[FX + i] = d6[EV + i] - d1[U + i]
      // EV6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
      d7[FY + i] = d6[EV + i] - (d1[U + i] + (d1[V + i] - d1[U + i]) * d7[ddAE + i])
      // EW6-U6
      d7[FZ + i] = d6[EW + i] - d1[U + i]
      // EY6-W6
      d7[GA + i] = d6[EY + i] - d1[W + i]
      // EY6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
      d7[GB + i] = d6[EY + i] - (d1[W + i] + (d1[X + i] - d1[W + i]) * d7[ddAE + i])
      // EZ6-W6
      d7[GC + i] = d6[EZ + i] - d1[W + i]
    }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let GE = 9855
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/MAX(0,FC6-FE6),1),IFERROR(FF6/MAX(0,FF6-FH6),1),IFERROR(FI6/MAX(0,FI6-FK6),1),IFERROR(FL6/MAX(0,FL6-FN6),1),IFERROR(FO6/MAX(0,FO6-FQ6),1),IFERROR(FR6/MAX(0,FR6-FT6),1),IFERROR(FU6/MAX(0,FU6-FW6),1),IFERROR(FX6/MAX(0,FX6-FZ6),1),IFERROR(GA6/MAX(0,GA6-GC6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      d7[GE + i] = iff(
        or(d7[FC + i] < .zero, d7[FF + i] < .zero, d7[FI + i] < .zero, d7[FL + i] < .zero, d7[FO + i] < .zero, d7[FR + i] < .zero, d7[FU + i] < .zero, d7[FX + i] < .zero, d7[GA + i] < 0), .zero,
        min(
          1, ifFinite(d7[FC + i] / (d7[FC + i] - d7[FE + i]), 1), ifFinite(d7[FF + i] / max(.zero, d7[FF + i] - d7[FH + i]), 1), ifFinite(d7[FI + i] / max(.zero, d7[FI + i] - d7[FK + i]), 1), ifFinite(d7[FL + i] / max(.zero, d7[FL + i] - d7[FN + i]), 1), ifFinite(d7[FO + i] / max(.zero, d7[FO + i] - d7[FQ + i]), 1),
          ifFinite(d7[FR + i] / max(.zero, d7[FR + i] - d7[FT + i]), 1), ifFinite(d7[FU + i] / max(.zero, d7[FU + i] - d7[FW + i]), 1), ifFinite(d7[FX + i] / max(.zero, d7[FX + i] - d7[FZ + i]), 1), ifFinite(d7[GA + i] / max(.zero, d7[GA + i] - d7[GC + i]), 1)) * Overall_harmonious_range + Overall_harmonious_min_perc)
    }

    let ddGE = 46355
    for i in 0..<365 { d7[ddGE + i] = Overall_harmonious_range < 1E-10 ? 1 : (d7[GE + i] - Overall_harmonious_min_perc) / Overall_harmonious_range }

    /// Surplus harm op period el after opt day harm op and min night op prep
    let GF = 10220
    // IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-O6-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),max(0,EA6+E6+G6/El_boiler_eff-EJ6)/BESS_chrg_eff)-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d7[GF + i] = iff(
        d7[GE + i].isZero, .zero,
        round(
          (d6[EB + i] + (d6[EC + i] - d6[EB + i]) * d7[ddGE + i]) + (d6[EH + i] + (d6[EI + i] - d6[EH + i]) * d7[ddGE + i]) - d1[O + i] - min(d6[EK + i] + (d6[EL + i] - d6[EK + i]) * d7[ddGE + i], max(.zero, d6[EA + i] + d1[E + i] + d1[G + i] / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - max(
            .zero, d1[Q + i] - (d6[EE + i] + (d6[EF + i] - d6[EE + i]) * d7[ddGE + i])) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after opt day harm op and max night op prep
    let GG = 10585
    // IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d7[GG + i] = iff(
        d7[GE + i].isZero, .zero,
        round(
          (d6[EB + i] + (d6[EC + i] - d6[EB + i]) * d7[ddGE + i]) + (d6[EH + i] + (d6[EI + i] - d6[EH + i]) * d7[ddGE + i]) - (d1[O + i] + (d1[P + i] - d1[O + i]) * d7[ddAE + i])
            - min(d6[EK + i] + (d6[EL + i] - d6[EK + i]) * d7[ddGE + i], max(.zero, d6[EA + i] + (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddAE + i]) + (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddAE + i]) / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - max(
              .zero, (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddAE + i]) - (d6[EE + i] + (d6[EF + i] - d6[EE + i]) * d7[ddGE + i])) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let GH = 10950
    // IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff,5))
    for i in 0..<365 { d7[GH + i] = iff(d7[GE + i].isZero, .zero, round(((d6[EK + i] + (d6[EL + i] - d6[EK + i]) * d7[ddGE + i]) + d6[EM + i]) * BESS_chrg_eff + d6[EJ + i] - d1[E + i] - d1[G + i] / El_boiler_eff, 5)) }

    /// Surplus outside harm op period el after opt day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let GI = 11315
    // IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 { d7[GI + i] = iff(d7[GE + i].isZero, .zero, round(((d6[EK + i] + (d6[EL + i] - d6[EK + i]) * d7[ddGE + i]) + d6[EM + i]) * BESS_chrg_eff + d6[EJ + i] - (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddAE + i]) - (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddAE + i]) / El_boiler_eff, 5)) }

    /// Surplus harm op heat after opt day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let GJ = 11680
    // IF(GE6=0,0,ROUND((EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6,5))
    for i in 0..<365 {
      d7[GJ + i] = iff(
        d7[GE + i].isZero, .zero,
        round(
          (d6[EE + i] + (d6[EF + i] - d6[EE + i]) * d7[ddGE + i])
            + ((d6[EB + i] + (d6[EC + i] - d6[EB + i]) * d7[ddGE + i]) + (d6[EH + i] + (d6[EI + i] - d6[EH + i]) * d7[ddGE + i]) - min(d6[EK + i] + (d6[EL + i] - d6[EK + i]) * d7[ddGE + i], max(.zero, d6[EA + i] + d1[E + i] + d1[G + i] / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - d1[O + i]) * El_boiler_eff - d1[Q + i], 5))
    }

    /// Surplus harm op heat after opt day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let GK = 12045
    // IF(GE6=0,0,ROUND((EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d7[GK + i] = iff(
        d7[GE + i].isZero, .zero,
        round(
          (d6[EE + i] + (d6[EF + i] - d6[EE + i]) * d7[ddGE + i])
            + ((d6[EB + i] + (d6[EC + i] - d6[EB + i]) * d7[ddGE + i]) + (d6[EH + i] + (d6[EI + i] - d6[EH + i]) * d7[ddGE + i])
              - min(d6[EK + i] + (d6[EL + i] - d6[EK + i]) * d7[ddGE + i], max(.zero, d6[EA + i] + (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddAE + i]) + (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddAE + i]) / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - (d1[O + i] + (d1[P + i] - d1[O + i]) * d7[ddAE + i])) * El_boiler_eff
            - (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddAE + i]), 5))
    }

    /// Surplus outside harm op heat after opt day harm and min night op prep
    let GL = 12410
    // IF(GE6=0,0,ROUND(EG6+ER6*El_boiler_eff-G6,5))
    for i in 0..<365 { d7[GL + i] = iff(d7[GE + i].isZero, .zero, round(d6[EG + i] + d6[ER + i] * El_boiler_eff - d1[G + i], 5)) }

    /// Surplus outside harm op heat after opt day harm and max night op prep
    let GM = 12775
    // IF(GE6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d7[GM + i] = iff(d7[GE + i].isZero, .zero, round(d6[EG + i] + d6[ER + i] * El_boiler_eff - (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddAE + i]), 5)) }

    /// Surplus el boiler cap after opt harm op and min night op prep during harm op period
    let GN = 13140
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { d7[GN + i] = iff(d7[GE + i].isZero, .zero, round((d6[EP + i] + (d6[EQ + i] - d6[EP + i]) * d7[ddGE + i]) - max(.zero, d1[Q + i] - (d6[EE + i] + (d6[EF + i] - d6[EE + i]) * d7[ddGE + i])) / El_boiler_eff, 5)) }

    /// Surplus el boiler cap after opt harm op and max night op prep during harm op period
    let GO = 13505
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { d7[GO + i] = iff(d7[GE + i].isZero, .zero, round((d6[EP + i] + (d6[EQ + i] - d6[EP + i]) * d7[ddGE + i]) - max(.zero, (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddAE + i]) - (d6[EE + i] + (d6[EF + i] - d6[EE + i]) * d7[ddGE + i])) / El_boiler_eff, 5)) }

    /// Surplus el boiler cap after opt harm op and min night op prep outside of harm op period
    let GP = 13870
    // IF(GE6=0,0,ROUND(ER6-MAX(0,G6-EG6)/El_boiler_eff,5))
    for i in 0..<365 { d7[GP + i] = iff(d7[GE + i].isZero, .zero, round(d6[ER + i] - max(.zero, d1[G + i] - d6[EG + i]) / El_boiler_eff, 5)) }

    /// Surplus el boiler cap after opt harm op and max night op prep outside of harm op period
    let GQ = 14235
    // IF(GE6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 { d7[GQ + i] = iff(d7[GE + i].isZero, .zero, round(d6[ER + i] - max(.zero, (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddAE + i]) - d6[EG + i]) / El_boiler_eff, 5)) }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let GR = 14600
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-S6,5))
    for i in 0..<365 { d7[GR + i] = iff(d7[GE + i].isZero, .zero, round((d6[ES + i] + (d6[ET + i] - d6[ES + i]) * d7[ddGE + i]) - d1[S + i], 5)) }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let GS = 14965
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d7[GS + i] = iff(d7[GE + i].isZero, .zero, round((d6[ES + i] + (d6[ET + i] - d6[ES + i]) * d7[ddGE + i]) - (d1[S + i] + (d1[T + i] - d1[S + i]) * d7[ddAE + i]), 5)) }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let GT = 15330
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-U6,5))
    for i in 0..<365 { d7[GT + i] = iff(d7[GE + i].isZero, .zero, round((d6[EV + i] + (d6[EW + i] - d6[EV + i]) * d7[ddGE + i]) - d1[U + i], 5)) }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let GU = 15695
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d7[GU + i] = iff(d7[GE + i].isZero, .zero, round((d6[EV + i] + (d6[EW + i] - d6[EV + i]) * d7[ddGE + i]) - (d1[U + i] + (d1[V + i] - d1[U + i]) * d7[ddAE + i]), 5)) }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let GV = 16060
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-W6,5))
    for i in 0..<365 { d7[GV + i] = iff(d7[GE + i].isZero, .zero, round((d6[EY + i] + (d6[EZ + i] - d6[EY + i]) * d7[ddGE + i]) - d1[W + i], 5)) }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let GW = 16425
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d7[GW + i] = iff(d7[GE + i].isZero, .zero, round((d6[EY + i] + (d6[EZ + i] - d6[EY + i]) * d7[ddGE + i]) - (d1[W + i] + (d1[X + i] - d1[W + i]) * d7[ddAE + i]), 5)) }

    /// Max harmonious day prod after min night prep due to prod cap limits
    let GX = 16790
    // IF(OR(GE6=0,GF6<0,GH6<0,GJ6<0,GL6<0,GN6<0,GP6<0,GR6<0,GT6<0,GV6<0),0,MIN(1,IFERROR(GF6/MAX(0,GF6-GG6),1),IFERROR(GH6/MAX(0,GH6-GI6),1),IFERROR(GJ6/MAX(0,GJ6-GK6),1),IFERROR(GL6/MAX(0,GL6-GM6),1),IFERROR(GN6/MAX(0,GN6-GO6),1),IFERROR(GP6/MAX(0,GP6-GQ6),1),IFERROR(GR6/MAX(0,GR6-GS6),1),IFERROR(GT6/MAX(0,GT6-GU6),1),IFERROR(GV6/MAX(0,GV6-GW6),1))*($AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d7[GX + i] = iff(
        or(d7[GE + i].isZero, d7[GF + i] < .zero, d7[GH + i] < .zero, d7[GJ + i] < .zero, d7[GL + i] < .zero, d7[GN + i] < .zero, d7[GP + i] < .zero, d7[GR + i] < .zero, d7[GT + i] < .zero, d7[GV + i] < 0), .zero,
        min(
          1, ifFinite(d7[GF + i] / max(.zero, d7[GF + i] - d7[GG + i]), 1), ifFinite(d7[GH + i] / max(.zero, d7[GH + i] - d7[GI + i]), 1), ifFinite(d7[GJ + i] / max(.zero, d7[GJ + i] - d7[GK + i]), 1), ifFinite(d7[GL + i] / max(.zero, d7[GL + i] - d7[GM + i]), 1), ifFinite(d7[GN + i] / max(.zero, d7[GN + i] - d7[GO + i]), 1),
          ifFinite(d7[GP + i] / max(.zero, d7[GP + i] - d7[GQ + i]), 1), ifFinite(d7[GR + i] / max(.zero, d7[GR + i] - d7[GS + i]), 1), ifFinite(d7[GT + i] / max(.zero, d7[GT + i] - d7[GU + i]), 1), ifFinite(d7[GV + i] / max(.zero, d7[GV + i] - d7[GW + i]), 1)) * (d1[AE + i] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

    /// Max Equiv harmonious night prod due to prod cap limits
    let GZ = 17155
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/MAX(0,FC6-FD6),1),IFERROR(FF6/MAX(0,FF6-FG6),1),IFERROR(FI6/MAX(0,FI6-FJ6),1),IFERROR(FL6/MAX(0,FL6-FM6),1),IFERROR(FO6/MAX(0,FO6-FP6),1),IFERROR(FR6/MAX(0,FR6-FS6),1),IFERROR(FU6/MAX(0,FU6-FV6),1),IFERROR(FX6/MAX(0,FX6-FY6),1),IFERROR(GA6/MAX(0,GA6-GB6),1))*($AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d7[GZ + i] = iff(
        or(d7[FC + i] < .zero, d7[FF + i] < .zero, d7[FI + i] < .zero, d7[FL + i] < .zero, d7[FO + i] < .zero, d7[FR + i] < .zero, d7[FU + i] < .zero, d7[FX + i] < .zero, d7[GA + i] < 0), .zero,
        min(
          1, ifFinite(d7[FC + i] / max(.zero, d7[FC + i] - d7[FD + i]), 1), ifFinite(d7[FF + i] / max(.zero, d7[FF + i] - d7[FG + i]), 1), ifFinite(d7[FI + i] / max(.zero, d7[FI + i] - d7[FJ + i]), 1), ifFinite(d7[FL + i] / max(.zero, d7[FL + i] - d7[FM + i]), 1), ifFinite(d7[FO + i] / max(.zero, d7[FO + i] - d7[FP + i]), 1),
          ifFinite(d7[FR + i] / max(.zero, d7[FR + i] - d7[FS + i]), 1), ifFinite(d7[FU + i] / max(.zero, d7[FU + i] - d7[FV + i]), 1), ifFinite(d7[FX + i] / max(.zero, d7[FX + i] - d7[FY + i]), 1), ifFinite(d7[GA + i] / max(.zero, d7[GA + i] - d7[GB + i]), 1)) * (d1[AE + i] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period el after min day harm op and opt night op prep
    let HA = 17520
    /// Surplus harm op period el after max day harm op and opt night op prep
    let HB = 17885
    /// Surplus outside harm op period el after min day harm and opt night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let HC = 18250
    /// Surplus outside harm op period el after max day harm and opt night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let HD = 18615
    /// Surplus harm op heat after min day harm and opt night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let HE = 18980
    /// Surplus harm op heat after max day harm and opt night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let HF = 19345
    /// Surplus outside harm op heat after min day harm and opt night op prep
    let HG = 19710
    /// Surplus outside harm op heat after max day harm and opt night op prep
    let HH = 20075
    /// Surplus el boiler cap after min harm op and opt night op prep during harm op period
    let HI = 20440
    /// Surplus el boiler cap after max harm op and opt night op prep during harm op period
    let HJ = 20805
    /// Surplus el boiler cap after min harm op and opt night op prep outside of harm op period
    let HK = 21170
    /// Surplus el boiler cap after max harm op and opt night op prep outside of harm op period
    let HL = 21535
    /// Surplus RawMeth prod cap after min day harm and opt night op prep
    let HM = 21900
    /// Surplus RawMeth prod cap after max day harm and opt night op prep
    let HN = 22265
    /// Surplus CO2 prod cap after min day harm and opt night op prep
    let HO = 22630
    /// Surplus CO2 prod cap after max day harm and opt night op prep
    let HP = 22995
    /// Surplus H2 prod cap after min day harm and opt night op prep
    let HQ = 23360
    /// Surplus H2 prod cap after min day harm and opt night op prep
    let HR = 23725

    let ddGZ = 47085
    for i in 0..<365 { d7[ddGZ + i] = equiv_harmonious_range[j] < 1E-10 ? 1 : (d7[GZ + i] - equiv_harmonious_min_perc[j]) / equiv_harmonious_range[j] }

    // IF(GZ6=0,0,ROUND(EB6+EH6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MIN(EK6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff-ej6)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
    for i in 0..<365 {
      d7[HA + i] = iff(
        d7[GZ + i].isZero, .zero,
        round(
          d6[EB + i] + d6[EH + i] - (d1[O + i] + (d1[P + i] - d1[O + i]) * d7[ddGZ + i]) - min(d6[EK + i], max(.zero, d6[EA + i] + (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddGZ + i]) + (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]) / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - max(
            .zero, (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddGZ + i]) - d6[EE + i]) / El_boiler_eff, 5))

      // IF(GZ6=0,0,ROUND(EC6+EI6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MIN(EL6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff-ej6)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
      d7[HB + i] = iff(
        d7[GZ + i].isZero, .zero,
        round(
          d6[EC + i] + d6[EI + i] - (d1[O + i] + (d1[P + i] - d1[O + i]) * d7[ddGZ + i]) - min(d6[EL + i], max(.zero, d6[EA + i] + (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddGZ + i]) + (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]) / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - max(
            .zero, (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddGZ + i]) - d6[EF + i]) / El_boiler_eff, 5))
      // IF(GZ6=0,0,ROUND((EK6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
      d7[HC + i] = iff(d7[GZ + i].isZero, .zero, round((d6[EK + i] + d6[EM + i]) * BESS_chrg_eff + d6[EJ + i] - (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddGZ + i]) - (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]) / El_boiler_eff, 5))
      // IF(GZ6=0,0,ROUND((EL6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
      d7[HD + i] = iff(d7[GZ + i].isZero, .zero, round((d6[EL + i] + d6[EM + i]) * BESS_chrg_eff + d6[EJ + i] - (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddGZ + i]) - (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]) / El_boiler_eff, 5))
      // IF(GZ6=0,0,ROUND(EE6+(EB6+EH6-MIN(EK6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff-ej6)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d7[HE + i] = iff(
        d7[GZ + i].isZero, .zero,
        round(
          d6[EE + i] + (d6[EB + i] + d6[EH + i] - min(d6[EK + i], max(.zero, d6[EA + i] + (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddGZ + i]) + (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]) / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - (d1[O + i] + (d1[P + i] - d1[O + i]) * d7[ddGZ + i])) * El_boiler_eff
            - (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddGZ + i]), 5))
      // IF(GZ6=0,0,ROUND(EF6+(EC6+EI6-MIN(EL6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff-ej6)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d7[HF + i] = iff(
        d7[GZ + i].isZero, .zero,
        round(
          d6[EF + i] + (d6[EC + i] + d6[EI + i] - min(d6[EL + i], max(.zero, d6[EA + i] + (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddGZ + i]) + (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]) / El_boiler_eff - d6[EJ + i]) / BESS_chrg_eff) - (d1[O + i] + (d1[P + i] - d1[O + i]) * d7[ddGZ + i])) * El_boiler_eff
            - (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddGZ + i]), 5))
      // IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d7[HG + i] = iff(d7[GZ + i].isZero, .zero, round(d6[EG + i] + d6[ER + i] * El_boiler_eff - (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d7[HH + i] = iff(d7[GZ + i].isZero, .zero, round(d6[EG + i] + d6[ER + i] * El_boiler_eff - (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EP6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
      d7[HI + i] = iff(d7[GZ + i].isZero, .zero, round(d6[EP + i] - max(.zero, (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddGZ + i]) - d6[EE + i]) / El_boiler_eff, 5))

      // IF(GZ6=0,0,ROUND(EQ6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
      d7[HJ + i] = iff(d7[GZ + i].isZero, .zero, round(d6[EQ + i] - max(.zero, (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddGZ + i]) - d6[EF + i]) / El_boiler_eff, 5))

      // IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
      d7[HK + i] = iff(d7[GZ + i].isZero, .zero, round(d6[ER + i] - max(.zero, (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]) - d6[EG + i]) / El_boiler_eff, 5))

      // IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
      d7[HL + i] = iff(d7[GZ + i].isZero, .zero, round(d6[ER + i] - max(.zero, (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]) - d6[EG + i]) / El_boiler_eff, 5))

      // IF(GZ6=0,0,ROUND(ES6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d7[HM + i] = iff(d7[GZ + i].isZero, .zero, round(d6[ES + i] - (d1[S + i] + (d1[T + i] - d1[S + i]) * d7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(ET6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d7[HN + i] = iff(d7[GZ + i].isZero, .zero, round(d6[ET + i] - (d1[S + i] + (d1[T + i] - d1[S + i]) * d7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EV6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d7[HO + i] = iff(d7[GZ + i].isZero, .zero, round(d6[EV + i] - (d1[U + i] + (d1[V + i] - d1[U + i]) * d7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EW6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d7[HP + i] = iff(d7[GZ + i].isZero, .zero, round(d6[EW + i] - (d1[U + i] + (d1[V + i] - d1[U + i]) * d7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EY6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d7[HQ + i] = iff(d7[GZ + i].isZero, .zero, round(d6[EY + i] - (d1[W + i] + (d1[X + i] - d1[W + i]) * d7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EZ6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d7[HR + i] = iff(d7[GZ + i].isZero, .zero, round(d6[EZ + i] - (d1[W + i] + (d1[X + i] - d1[W + i]) * d7[ddGZ + i]), 5))
    }

    /// Opt harm op period op during night prio operation
    let HS = 24090
    // IF(OR(GZ3=0,HA3<0,HC3<0,HE3<0,HG3<0,HI3<0,HK3<0,HM3<0,HO3<0,HQ3<0),0,MIN(1,MIN(IFERROR(HA6/MAX(0,HA6-HB6),1),IFERROR(HC6/MAX(0,HC6-HD6),1),IFERROR(HE6/MAX(0,HE6-HF6),1),IFERROR(HG6/MAX(0,HG6-HH6),1),IFERROR(HI6/MAX(0,HI6-HJ6),1),IFERROR(HK6/MAX(0,HK6-HL6),1),IFERROR(HM6/MAX(0,HM6-HN6),1),IFERROR(HO6/MAX(0,HO6-HP6),1),IFERROR(HQ6/MAX(0,HQ6-HR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc))
    for i in 0..<365 {
      d7[HS + i] = iff(
        or(d7[GZ + i].isZero, d7[HA + i] < .zero, d7[HC + i] < .zero, d7[HE + i] < .zero, d7[HG + i] < .zero, d7[HI + i] < .zero, d7[HK + i] < .zero, d7[HM + i] < .zero, d7[HO + i] < .zero, d7[HQ + i] < 0), .zero,
        min(
          1,
          min(
            ifFinite(d7[HA + i] / max(.zero, d7[HA + i] - d7[HB + i]), 1), ifFinite(d7[HC + i] / max(.zero, d7[HC + i] - d7[HD + i]), 1), ifFinite(d7[HE + i] / max(.zero, d7[HE + i] - d7[HF + i]), 1), ifFinite(d7[HG + i] / max(.zero, d7[HG + i] - d7[HH + i]), 1), ifFinite(d7[HI + i] / max(.zero, d7[HI + i] - d7[HJ + i]), 1),
            ifFinite(d7[HK + i] / max(.zero, d7[HK + i] - d7[HL + i]), 1), ifFinite(d7[HM + i] / max(.zero, d7[HM + i] - d7[HN + i]), 1), ifFinite(d7[HO + i] / max(.zero, d7[HO + i] - d7[HP + i]), 1), ifFinite(d7[HQ + i] / max(.zero, d7[HQ + i] - d7[HR + i]), 1)) * Overall_harmonious_range + Overall_harmonious_min_perc))
    }

    /// Heat cons for harm op during harm op period
    let ID = 27740
    /// Heat cons for night prep during harm op period
    let IE = 28105
    /// CSP heat available after harm op during harm op period
    let IF = 28470
    /// El boiler heat prod for harm op during harm op period
    let IG = 28835
    /// El boiler heat prod for night prep during harm op period
    let IH = 29200
    /// el cons for harm op during harm op period
    let HU = 24455
    /// Balance of heat during harm op period
    let II = 29565
    /// el cons for night prep during harm op period
    let HV = 24820
    /// el cons for BESS charging during harm op period
    let HW = 25185
    /// el cons of el boiler for harm op during harm op period
    let HX = 25550
    /// el cons of el boiler for night prep during harm op period
    let HY = 25915
    /// PV available after harm op during harm op period
    let HZ = 26280
    /// grid input for harm op during harm op period
    let IA = 26645

    let ddGX = 46720
    for i in 0..<365 { d7[ddGX + i] = equiv_harmonious_range[j] < 1E-10 ? 1 : (d7[GX + i] - equiv_harmonious_min_perc[j]) / equiv_harmonious_range[j] }

    // IF(GE6=0,0,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d7[ID + i] = iff(d7[GE + i].isZero, .zero, d6[DT + i] + (d6[DU + i] - d6[DT + i]) * d7[ddGE + i])

      // IF(GX6=0,0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
      d7[IE + i] = iff(d7[GX + i].isZero, .zero, (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddGX + i]))

      // IF=IF(GE6=0,EF6,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      d7[IF + i] = iff(d7[GE + i].isZero, d6[EF + i], d6[EE + i] + (d6[EF + i] - d6[EE + i]) * d7[ddGE + i])

      // IG=IF(GE6=0,EO6,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff)
      d7[IG + i] = iff(d7[GE + i].isZero, d6[EO + i], (d6[EN + i] + (d6[EO + i] - d6[EN + i]) * d7[ddGE + i]) * El_boiler_eff)

      // IF(GE6=0,0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,IE6-IF6)))
      d7[IH + i] = iff(d7[GE + i].isZero, .zero, min((d6[EP + i] + (d6[EQ + i] - d6[EP + i]) * d7[ddGE + i]) * El_boiler_eff, max(.zero, d7[IE + i] - d7[IF + i])))

      // IF6+IH6-IE6
      d7[II + i] = d7[IF + i] + d7[IH + i] - d7[IE + i]

      // HU=IF(DR6=0,0,IF(GE6=0,DS6,DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))
      d7[HU + i] = iff(d6[DR + i].isZero, .zero, iff(d7[GE + i].isZero, d6[DS + i], d6[DR + i] + (d6[DS + i] - d6[DR + i]) * d7[ddGE + i]))

      // HV=IF(GX6=0,0,(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
      d7[HV + i] = iff(d7[GX + i].isZero, .zero, (d1[O + i] + (d1[P + i] - d1[O + i]) * d7[ddGX + i]))

      // HW=IF(OR(GE6=0,GX6=0),MIN(EA6/BESS_chrg_eff,EL6),MIN((EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))+MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff-ED6)/BESS_chrg_eff,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))))
      d7[HW + i] = iff(
        or(d7[GE + i].isZero, d7[GX + i].isZero), min(d6[EA + i] / BESS_chrg_eff, d6[EL + i]),
        min((d6[EA + i] + (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddGX + i]) + max(.zero, (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGX + i]) - d6[EG + i]) / El_boiler_eff - d6[ED + i]) / BESS_chrg_eff, (d6[EK + i] + (d6[EL + i] - d6[EK + i]) * d7[ddGE + i])))

      // IF(GE6=0,EO6,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      d7[HX + i] = iff(d7[GE + i].isZero, d6[EO + i], d6[EN + i] + (d6[EO + i] - d6[EN + i]) * d7[ddGE + i])

      // IH6/El_boiler_eff
      d7[HY + i] = d7[IH + i] / El_boiler_eff

      // HZ=IF(GE6=0,EC6,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      d7[HZ + i] = iff(d7[GE + i].isZero, d6[EC + i], d6[EB + i] + (d6[EC + i] - d6[EB + i]) * d7[ddGE + i])
      // IF(GE6=0,DZ6,DY6+(DZ6-DY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      d7[IA + i] = iff(d7[GE + i].isZero, d6[DZ + i], d6[DY + i] + (d6[DZ + i] - d6[DY + i]) * d7[ddGE + i])
    }

    /// grid input for night prep during harm op period
    let IB = 27010
    // IB=MIN(IF(GE6=0,0,EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)),MAX(0,-(HZ6-HV6-HW6-HY6)))
    for i in 0..<365 { d7[IB + i] = min(iff(d7[GE + i].isZero, .zero, d6[EH + i] + (d6[EI + i] - d6[EH + i]) * d7[ddGE + i]), max(.zero, -(d7[HZ + i] - d7[HV + i] - d7[HW + i] - d7[HY + i]))) }

    /// Balance of electricity during harm op period
    let IC = 27375
    // HZ6+IB6-HV6-HW6-HY6
    for i in 0..<365 { d7[IC + i] = d7[HZ + i] + d7[IB + i] - d7[HV + i] - d7[HW + i] - d7[HY + i] }

    /// heat cons for harm op outside of harm op period
    let IQ = 32485
    // IF(OR(GE6=0,GX6=0),0,G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[IQ + i] = iff(or(d7[GE + i].isZero, d7[GX + i].isZero), .zero, d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGX + i]) }

    /// heat from CSP outside of harm op period
    let IR = 32850
    // IF(OR(GE6=0,GX6=0),0,EG6)
    for i in 0..<365 { d7[IR + i] = iff(or(d7[GE + i].isZero, d7[GX + i].isZero), .zero, d6[EG + i]) }

    /// heat from el boiler outside of harm op period
    let IS = 33215
    // IF(OR(GE6=0,GX6=0),0,MIN(ER6*El_boiler_eff,MAX(0,IQ6-IR6)))
    for i in 0..<365 { d7[IS + i] = iff(or(d7[GE + i].isZero, d7[GX + i].isZero), .zero, min(d6[ER + i] * El_boiler_eff, max(.zero, d7[IQ + i] - d7[IR + i]))) }

    /// Balance of heat outside of harm op period
    let IT = 33580
    // IR6+IS6-IQ6
    for i in 0..<365 { d7[IT + i] = d7[IR + i] + d7[IS + i] - d7[IQ + i] }

    /// el cons for harm op outside of harm op period
    let IJ = 29930
    // IF(OR(GE6=0,GX6=0),0,E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[IJ + i] = iff(or(d7[GE + i].isZero, d7[GX + i].isZero), .zero, d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddGX + i]) }

    /// el cons by el boiler outside of harm op period
    let IK = 30295
    // IS6/El_boiler_eff
    for i in 0..<365 { d7[IK + i] = d7[IS + i] / El_boiler_eff }

    /// el cons for aux cons outside of harm op period
    let IL = 30660
    // IF(OR(GE6=0,GX6=0),0,EA6)
    for i in 0..<365 { d7[IL + i] = iff(or(d7[GE + i].isZero, d7[GX + i].isZero), .zero, d6[EA + i]) }

    /// el from PV outside of harm op period
    let IM = 31025
    // IF(OR(GE6=0,GX6=0),0,ED6)
    for i in 0..<365 { d7[IM + i] = iff(or(d7[GE + i].isZero, d7[GX + i].isZero), .zero, d6[ED + i]) }

    /// el from BESS outside of harm op period
    let IN = 31390
    // HW6*BESS_chrg_eff
    for i in 0..<365 { d7[IN + i] = d7[HW + i] * BESS_chrg_eff }

    /// grid input outside of harm op period
    let IO = 31755
    // IF(OR(GE6=0,GX6=0),0,MIN(EJ6+EA6,MAX(0,-(IM6+IN6-IJ6-IK6-IL6))))
    for i in 0..<365 { d7[IO + i] = iff(or(d7[GE + i].isZero, d7[GX + i].isZero), .zero, min(d6[EJ + i] + d6[EA + i], max(.zero, -(d7[IM + i] + d7[IN + i] - d7[IJ + i] - d7[IK + i] - d7[IL + i])))) }

    /// Balance of electricity outside of harm op period
    let IP = 32120
    // IM6+IN6+IO6-IJ6-IK6-IL6
    for i in 0..<365 { d7[IP + i] = d7[IM + i] + d7[IN + i] + d7[IO + i] - d7[IJ + i] - d7[IK + i] - d7[IL + i] }

    /// Pure Methanol prod with min night prep and resp day op
    let IU = 33945
    // MAX(0,HU6-$C6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+MAX(0,IJ6-$B6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud
    for i in 0..<365 { d7[IU + i] = max(.zero, d7[HU + i] - day0[C + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud + max(.zero, d7[IJ + i] - day0[B + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud }

    /// grid export
    let IV = 34310
    // MIN(IC6,IF(OR(GE6=0,GX6=0),DW6,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))))+MIN(IP6,IF(OR(GE6=0,GX6=0),0,DX6))
    for i in 0..<365 { d7[IV + i] = min(d7[IC + i], iff(or(d7[GE + i].isZero, d7[GX + i].isZero), d6[DW + i], (d6[DV + i] + (d6[DW + i] - d6[DV + i]) * d7[ddGE + i]))) + min(d7[IP + i], iff(or(d7[GE + i].isZero, d7[GX + i].isZero), .zero, d6[DX + i])) }

    /// grid import
    let IW = 34675
    // IA6+IB6+IO6
    for i in 0..<365 { d7[IW + i] = d7[IA + i] + d7[IB + i] + d7[IO + i] }

    /// Checksum
    let IX = 35040
    // MAX(0,-IC6)+MAX(0,-II6)+MAX(0,-IP6)+MAX(0,-IT6)
    for i in 0..<365 {
      let _IX = max(.zero, -d7[IC + i]) + max(.zero, -d7[II + i]) + max(.zero, -d7[IP + i]) + max(.zero, -d7[IT + i])
      // if IX > 1E-13 { print("Checksum error daily 2", i, j, IX) }
      d7[IX + i] = _IX
    }

    let ddHS = 47450
    for i in 0..<365 { d7[ddHS + i] = Overall_harmonious_range < 1E-10 ? 1 : (d7[HS + i] - Overall_harmonious_min_perc) / Overall_harmonious_range }

    /// Heat cons for harm op during harm op period
    let JI = 38690
    // JI=IF(OR(HS6=0,GZ6=0),0,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 { d7[JI + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, d6[DT + i] + (d6[DU + i] - d6[DT + i]) * d7[ddHS + i]) }

    /// Heat cons for night prep during harm op period
    let JJ = 39055
    // JJ=IF(OR(HS6=0,GZ6=0),0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 { d7[JJ + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, (d1[Q + i] + (d1[R + i] - d1[Q + i]) * d7[ddGZ + i])) }

    /// CSP heat available after harm op during harm op period
    let JK = 39420
    // JK=IF(OR(HS6=0,GZ6=0),EF6,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 { d7[JK + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), d6[EF + i], d6[EE + i] + (d6[EF + i] - d6[EE + i]) * d7[ddHS + i]) }

    /// El boiler heat prod for harm op during harm op period
    let JL = 39785
    // JL=IF(OR(HS6=0,GZ6=0),EO6,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))*El_boiler_eff)
    for i in 0..<365 { d7[JL + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), d6[EO + i], (d6[EN + i] + (d6[EO + i] - d6[EN + i]) * d7[ddHS + i]) * El_boiler_eff) }

    /// El boiler heat prod for night prep during harm op period
    let JM = 40150
    // IF(OR(HS6=0,GZ6=0),0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,JJ6-JK6)))
    for i in 0..<365 { d7[JM + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, min((d6[EP + i] + (d6[EQ + i] - d6[EP + i]) * d7[ddHS + i]) * El_boiler_eff, max(.zero, d7[JJ + i] - d7[JK + i]))) }

    /// Balance of heat during harm op period
    let JN = 40515
    // JK6+JM6-JJ6
    for i in 0..<365 { d7[JN + i] = d7[JK + i] + d7[JM + i] - d7[JJ + i] }

    /// el cons for harm op during harm op period
    let IZ = 35405
    // IZ=IF(DR6=0,0,IF(OR(HS6=0,GZ6=0),DS6,DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc)))
    for i in 0..<365 { d7[IZ + i] = iff(d6[DR + i].isZero, .zero, iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), d6[DS + i], d6[DR + i] + (d6[DS + i] - d6[DR + i]) * d7[ddHS + i])) }

    /// el cons for night prep during harm op period
    let JA = 35770
    // JA=IF(GZ6=0,0,(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 { d7[JA + i] = iff(d7[GZ + i].isZero, .zero, (d1[O + i] + (d1[P + i] - d1[O + i]) * d7[ddGZ + i])) }

    /// el cons for BESS charging during harm op period
    let JB = 36135
    // JB=IF(OR(HS6=0,GZ6=0),MIN(EA3/BESS_chrg_eff,EL3),MIN((EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff-ED6)/BESS_chrg_eff,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      d7[JB + i] = iff(
        or(d7[HS + i].isZero, d7[GZ + i].isZero), min(d6[EA + i] / BESS_chrg_eff, d6[EL + i]),
        min((d6[EA + i] + (d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddGZ + i]) + max(.zero, (d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]) - d6[EG + i]) / El_boiler_eff - d6[ED + i]) / BESS_chrg_eff, (d6[EK + i] + (d6[EL + i] - d6[EK + i]) * d7[ddHS + i])))
    }

    /// el cons of el boiler for harm op during harm op period
    let JC = 36500
    // JC=IF(OR(HS6=0,GZ6=0),EO6,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 { d7[JC + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), d6[EO + i], d6[EN + i] + (d6[EO + i] - d6[EN + i]) * d7[ddHS + i]) }

    /// el cons of el boiler for night prep during harm op period
    let JD = 36865
    // JM6/El_boiler_eff
    for i in 0..<365 { d7[JD + i] = d7[JM + i] / El_boiler_eff }

    /// PV available after harm op during harm op period
    let JE = 37230
    // IF(OR(HS6=0,GZ6=0),EC6,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 { d7[JE + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), d6[EC + i], d6[EB + i] + (d6[EC + i] - d6[EB + i]) * d7[ddHS + i]) }

    /// grid input for harm op during harm op period
    let JF = 37595
    // IF(OR(HS6=0,GZ6=0),DZ6,DY6+(DZ6-DY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 { d7[JF + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), d6[DZ + i], d6[DY + i] + (d6[DZ + i] - d6[DY + i]) * d7[ddHS + i]) }

    /// grid input for night prep during harm op period
    let JG = 37960
    // IF(OR(HS6=0,GZ6=0),0,MIN(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc),MAX(0,-(JE6-JA6-JB6-JD6))))
    for i in 0..<365 { d7[JG + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, min(d6[EH + i] + (d6[EI + i] - d6[EH + i]) * d7[ddHS + i], max(.zero, -(d7[JE + i] - d7[JA + i] - d7[JB + i] - d7[JD + i])))) }

    /// Balance of electricity during harm op period
    let JH = 38325
    // JE6+JG6-JA6-JB6-JD6
    for i in 0..<365 { d7[JH + i] = d7[JE + i] + d7[JG + i] - d7[JA + i] - d7[JB + i] - d7[JD + i] }

    /// heat cons for harm op outside of harm op period
    let JV = 43435
    // IF(OR(HS6=0,GZ6=0),0,G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[JV + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, d1[G + i] + (d1[H + i] - d1[G + i]) * d7[ddGZ + i]) }

    /// heat from CSP outside of harm op period
    let JW = 43800
    // IF(OR(HS6=0,GZ6=0),0,EG6)
    for i in 0..<365 { d7[JW + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, d6[EG + i]) }

    /// heat from el boiler outside of harm op period
    let JX = 44165
    // IF(OR(HS6=0,GZ6=0),0,MIN(ER6*El_boiler_eff,MAX(0,JV6-JW6)))
    for i in 0..<365 { d7[JX + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, min(d6[ER + i] * El_boiler_eff, max(.zero, d7[JV + i] - d7[JW + i]))) }

    /// Balance of heat outside of harm op period
    let JY = 44530
    // JW6+JX6-JV6
    for i in 0..<365 { d7[JY + i] = d7[JW + i] + d7[JX + i] - d7[JV + i] }

    /// el cons for harm op outside of harm op period
    let JO = 40880
    // IF(OR(HS6=0,GZ6=0),0,E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[JO + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, d1[E + i] + (d1[F + i] - d1[E + i]) * d7[ddGZ + i]) }

    /// el cons by el boiler outside of harm op period
    let JP = 41245
    /// el cons for aux cons outside of harm op period
    let JQ = 41610
    /// el from PV outside of harm op period
    let JR = 41975
    /// el from BESS outside of harm op period
    let JS = 42340
    for i in 0..<365 {
      // JX6/El_boiler_eff
      d7[JP + i] = d7[JX + i] / El_boiler_eff
      // IF(OR(HS6=0,GZ6=0),0,EA6)
      d7[JQ + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, d6[EA + i])
      // IF(OR(HS6=0,GZ6=0),0,ED6)
      d7[JR + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, d6[ED + i])
      // JB6*BESS_chrg_eff
      d7[JS + i] = d7[JB + i] * BESS_chrg_eff
    }

    /// grid input outside of harm op period
    let JT = 42705
    // IF(OR(HS6=0,GZ6=0),0,MIN(EJ6+EA6,MAX(0,-(JR6+JS6-JO6-JP6-JQ6))))
    for i in 0..<365 { d7[JT + i] = iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, min(d6[EJ + i] + d6[EA + i], max(.zero, -(d7[JR + i] + d7[JS + i] - d7[JO + i] - d7[JP + i] - d7[JQ + i])))) }

    /// Balance of electricity outside of harm op period
    let JU = 43070
    // JR6+JS6+JT6-JO6-JP6-JQ6
    for i in 0..<365 { d7[JU + i] = d7[JR + i] + d7[JS + i] + d7[JT + i] - d7[JO + i] - d7[JP + i] - d7[JQ + i] }

    /// Pure Methanol prod with min night prep and resp day op
    let JZ = 44895
    // MAX(0,IZ6-C6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+MAX(0,JO6-B6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud
    for i in 0..<365 { d7[JZ + i] = max(.zero, d7[IZ + i] - day0[C + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud + max(.zero, d7[JO + i] - day0[B + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud }

    /// grid export
    let KA = 45260
    // MIN(JH6,IF(OR(HS6=0,GZ6=0),DW6,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))))+MIN(JU6,IF(OR(HS6=0,GZ6=0),0,DX6))
    for i in 0..<365 { d7[KA + i] = min(d7[JH + i], iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), d6[DW + i], (d6[DV + i] + (d6[DW + i] - d6[DV + i]) * d7[ddHS + i]))) + min(d7[JU + i], iff(or(d7[HS + i].isZero, d7[GZ + i].isZero), .zero, d6[DX + i])) }

    /// grid import
    let KB = 45625
    // JF6+JG6+JT6
    for i in 0..<365 { d7[KB + i] = d7[JF + i] + d7[JG + i] + d7[JT + i] }

    /// Checksum
    // let KC = 45990
    // MAX(0,-JH6)+MAX(0,-JN6)+MAX(0,-JU6)+MAX(0,-JY6)
    // for i in 0..<365 {
    //   let KC = max(.zero, -d7[JH + i]) + max(.zero, -d7[JN + i]) + max(.zero, -d7[JU + i]) + max(.zero, -d7[JY + i])
    // if KC > 1E-13 { print("Checksum error daily 2", i, j, KC) }
    //   d7[KC + i] = KC
    //  }
  }
}

extension TunOl {
  func d23(_ d23: inout [Double], case j: Int, day0: [Double], d21: [Double], d22: [Double]) {
    let (B, C, E, F, G, H, O, P, Q, R, S, T, U, V, W, X) = (365, 730, 0, 365, 730, 1095, 3650, 4015, 4380, 4745, 5110, 5475, 5840, 6205, 6570, 6935)

    let AE = 9490
    let (EA, EB, EC, _, EE, EF, EG, EH, EI, EJ, EK, EL, EM, EN, EO, EP, EQ, ER, ES, ET, EV, EW, EY, EZ) = (3285, 3650, 4015, 4380, 4745, 5110, 5475, 5840, 6205, 6570, 6935, 7300, 7665, 8030, 8395, 8760, 9125, 9490, 9855, 10220, 10950, 11315, 12045, 12410)

    let DR = 0
    let DS = 365
    let DT = 730
    let DU = 1095
    let DV = 1460
    let DW = 1825
    let DX = 2190

    /// Surplus harm op period el after min day harm op and min night op prep
    let FC = 0
    // =EB6+EH6-O6-MAX(0,EA6+E6+MAX(0,G6-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,Q6-EE6)/El_boiler_eff
    for i in 0..<365 { 
      d23[FC + i] = d22[EB + i] + d22[EH + i] - d21[O + i] - max(.zero, d22[EA + i] + d21[E + i] + max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(.zero, d21[Q + i] - d22[EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after min day harm op and max night op prep
    let FD = 365
    // =EB6+EH6-P6-MAX(0,EA6+F6+MAX(0,H6-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,R6-EE6)/El_boiler_eff
    for i in 0..<365 {
      d23[FD + i] = d22[EB + i] + d22[EH + i] - d21[P + i] - max(.zero, d22[EA + i] + d21[F + i] + max(.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(.zero, d21[R + i] - d22[EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after max day harm op and min night op prep
    let FE = 730
    // =EC6+EI6-O6-MAX(0,EA6+E6+MAX(0,G6-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,Q6-EF6)/El_boiler_eff
    for i in 0..<365 { d23[FE + i] = d22[EC + i] + d22[EI + i] - d21[O + i] - max(.zero, d22[EA + i] + d21[E + i] + max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(.zero, d21[Q + i] - d22[EF + i]) / El_boiler_eff }


    /// Surplus outside harm op period el after min day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let FF = 1095
    // =(EK6+EM6)*BESS_chrg_eff+EJ6-EA6-E6-MAX(0,G6-EG6)/El_boiler_eff
    for i in 0..<365 { d23[FF + i] = (d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[E + i] -  max(.zero ,d21[G + i] - d22[EG + i]) / El_boiler_eff }

    /// Surplus outside harm op period el after min day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let FG = 1460
    // =(EK6+EM6)*BESS_chrg_eff+EJ6-EA6-F6-MAX(0,H6-EG6)/El_boiler_eff
    for i in 0..<365 { d23[FG + i] = (d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[F + i] - max(.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff }

    /// Surplus outside harm op period el after max day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let FH = 1825
    // =(EL6+EM6)*BESS_chrg_eff+EJ6-EA6-E6-MAX(0,G6-EG6)/El_boiler_eff
    for i in 0..<365 { d23[FH + i] = (d22[EL + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[E + i] - max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff }

    /// Surplus harm op heat after min day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let FI = 2190
    // =EE6+MIN(EP6,MAX(0,EB6+EH6-MAX(0,EA6+E6+MAX(0,G6-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-O6))*El_boiler_eff-Q6
    for i in 0..<365 {
      d23[FI + i] = d22[EE + i] + min(d22[EP + i], max(.zero, d22[EB + i] + d22[EH + i] - max(.zero, d22[EA + i] + d21[E + i] + max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - d21[O + i])) * El_boiler_eff - d21[Q + i]
    }


    /// Surplus harm op heat after min day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let FJ = 2555
    // =EE6+MIN(EP6,MAX(0,EB6+EH6-MAX(0,EA6+F6+MAX(0,H6-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-P6))*El_boiler_eff-R6
    for i in 0..<365 {
      d23[FJ + i] =
        d22[EE + i] + min(d22[EP + i], max(.zero, d22[EB + i] + d22[EH + i] - max(.zero, d22[EA + i] + d21[F + i] + max(.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - d21[P + i])) * El_boiler_eff - d21[R + i]
    }

    /// Surplus harm op heat after max day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let FK = 2920
    // =EF6+MIN(EQ6,MAX(0,EC6+EI6-MAX(0,EA6+E6+MAX(0,G6-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-O6))*El_boiler_eff-Q6
    for i in 0..<365 { 
      d23[FK + i] = d22[EF + i] + min(d22[EQ + i], max(.zero, d22[EC + i] + d22[EI + i] - max(.zero, d22[EA + i] + d21[E + i] + max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - d21[O + i])) * El_boiler_eff - d21[Q + i]
    }

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
      // =$EG6+MIN($ER6,MAX(0,($EK6+$EM6)*BESS_chrg_eff+$EJ6-$EA6-$E6))*El_boiler_eff-$G6
      d23[FL + i] = d22[EG + i] + min(d22[ER + i], max(.zero, (d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[E + i])) * El_boiler_eff - d21[G + i]
      // =EG6+MIN(ER6,MAX(0,(EK6+EM6)*BESS_chrg_eff+EJ6-EA6-F6))*El_boiler_eff-H6
      d23[FM + i] = d22[EG + i] + min(d22[ER + i], max(.zero, (d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[F + i])) * El_boiler_eff - d21[H + i]
      // =EG6+MIN(ER6,MAX(0,(EL6+EM6)*BESS_chrg_eff+EJ6-EA6-E6))*El_boiler_eff-G6
      d23[FN + i] = d22[EG + i] + min(d22[ER + i], max(.zero, (d22[EL + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[E + i])) * El_boiler_eff - d21[G + i]
      // EP6-MAX(0,Q6-EE6)/El_boiler_eff
      d23[FO + i] = d22[EP + i] - max(.zero, d21[Q + i] - d22[EE + i]) / El_boiler_eff
      // =EP6-MAX(0,R6-EE6)/El_boiler_eff
      d23[FP + i] = d22[EP + i] - max(.zero, d21[R + i] - d22[EE + i]) / El_boiler_eff
      // EQ6-MAX(0,Q6-EF6)/El_boiler_eff
      d23[FQ + i] = d22[EQ + i] - max(.zero, d21[Q + i] - d22[EF + i]) / El_boiler_eff
      // ER6-MAX(0,G6-EG6)/El_boiler_eff
      d23[FR + i] = d22[ER + i] - max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff
      // =ER6-MAX(0,H6-EG6)/El_boiler_eff
      d23[FS + i] = d22[ER + i] - max(.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff
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
      d23[FT + i] = d22[ER + i] - max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff
      // ES6-S6
      d23[FU + i] = d22[ES + i] - d21[S + i]
      // =ES6-T6
      d23[FV + i] = d22[ES + i] - d21[T + i]
      // ET6-S6
      d23[FW + i] = d22[ET + i] - d21[S + i]
      // EV6-U6
      d23[FX + i] = d22[EV + i] - d21[U + i]
      // =EV6-V6
      d23[FY + i] = d22[EV + i] - d21[V + i]
      // EW6-U6
      d23[FZ + i] = d22[EW + i] - d21[U + i]
      // EY6-W6
      d23[GA + i] = d22[EY + i] - d21[W + i]
      // =EY6-X6
      d23[GB + i] = d22[EY + i] - d21[X + i]
      // EZ6-W6
      d23[GC + i] = d22[EZ + i] - d21[W + i]
    }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let GE = 9855
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/MAX(0,FC6-FE6),1),IFERROR(FF6/MAX(0,FF6-FH6),1),IFERROR(FI6/MAX(0,FI6-FK6),1),IFERROR(FL6/MAX(0,FL6-FN6),1),IFERROR(FO6/MAX(0,FO6-FQ6),1),IFERROR(FR6/MAX(0,FR6-FT6),1),IFERROR(FU6/MAX(0,FU6-FW6),1),IFERROR(FX6/MAX(0,FX6-FZ6),1),IFERROR(GA6/MAX(0,GA6-GC6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      d23[GE + i] = iff(
        or(d23[FC + i] < .zero, d23[FF + i] < .zero, d23[FI + i] < .zero, d23[FL + i] < .zero, d23[FO + i] < .zero, d23[FR + i] < .zero, d23[FU + i] < .zero, d23[FX + i] < .zero, d23[GA + i] < 0), .zero,
        min(
          1, ifFinite(d23[FC + i] / (d23[FC + i] - d23[FE + i]), 1), ifFinite(d23[FF + i] / max(.zero, d23[FF + i] - d23[FH + i]), 1), ifFinite(d23[FI + i] / max(.zero, d23[FI + i] - d23[FK + i]), 1), ifFinite(d23[FL + i] / max(.zero, d23[FL + i] - d23[FN + i]), 1), ifFinite(d23[FO + i] / max(.zero, d23[FO + i] - d23[FQ + i]), 1),
          ifFinite(d23[FR + i] / max(.zero, d23[FR + i] - d23[FT + i]), 1), ifFinite(d23[FU + i] / max(.zero, d23[FU + i] - d23[FW + i]), 1), ifFinite(d23[FX + i] / max(.zero, d23[FX + i] - d23[FZ + i]), 1), ifFinite(d23[GA + i] / max(.zero, d23[GA + i] - d23[GC + i]), 1)) * Overall_harmonious_range + Overall_harmonious_min_perc)
    }

    let ddGE = 46355
    for i in 0..<365 { d23[ddGE + i] = Overall_harmonious_range < 1E-10 ? 1 : (d23[GE + i] - Overall_harmonious_min_perc) / Overall_harmonious_range }

    /// Surplus harm op period el after opt day harm op and min night op prep
    let GF = 10220
    // =IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-O6-MAX(0,EA6+E6+MAX(0,G6-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d23[GF + i] = iff(d23[GE + i].isZero, 0, round((d22[EB + i] + (d22[EC + i] - d22[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc)) + (d22[EH + i] + (d22[EI + i] - d22[EH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc)) - d21[O + i] - max(.zero, d22[EA + i] + d21[E + i] + max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(.zero, d21[Q + i] - (d22[EE + i] + (d22[EF + i] - d22[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc))) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after opt day harm op and max night op prep
    let GG = 10585
    // =IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-P6-MAX(0,EA6+F6+MAX(0,H3-EG3)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,R6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d23[GG + i] = iff(d23[GE + i].isZero, 0, round((d22[EB + i] + (d22[EC + i] - d22[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc)) + (d22[EH + i] + (d22[EI + i] - d22[EH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc)) - d21[P + i] - max(.zero, d22[EA + i] + d21[F + i] + max(.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(.zero, d21[R + i] - (d22[EE + i] + (d22[EF + i] - d22[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc))) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let GH = 10950
    // =IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-EA6-E6-MAX(0,G6-EG6)/El_boiler_eff,5))
    for i in 0..<365 { d23[GH + i] = iff(d23[GE + i].isZero, .zero, round(((d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[ddGE + i]) + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[E + i] - max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff, 5)) }

    /// Surplus outside harm op period el after opt day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let GI = 11315
    // =IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-EA6-F6-MAX(0,H6-EG6)/El_boiler_eff,5))
    for i in 0..<365 { 
      d23[GI + i] = iff(d23[GE + i].isZero, .zero, round(((d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[ddGE + i]) + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[F + i] - max(.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus harm op heat after opt day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let GJ = 11680
    // =IF(GE6=0,0,ROUND(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)+MIN(EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),MAX(0,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)+EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)-MAX(0,EA6+E6+MAX(0,G6-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-O6))*El_boiler_eff-Q6,5))
    for i in 0..<365 {
      d23[GJ + i] = iff(d23[GE + i].isZero, 0, round(d22[EE + i] + (d22[EF + i] - d22[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc) + min(d22[EP + i] + (d22[EQ + i] - d22[EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc), max(.zero, d22[EB + i] + (d22[EC + i] - d22[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc) + d22[EH + i] + (d22[EI + i] - d22[EH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc) - max(.zero, d22[EA + i] + d21[E + i] + max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - d21[O + i])) * El_boiler_eff - d21[Q + i], 5))
    }

    /// Surplus harm op heat after opt day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let GK = 12045
    // =IF(GE6=0,0,ROUND(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)+MIN(EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),MAX(0,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)+EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)-MAX(0,EA6+F6+MAX(0,H6-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-P6))*El_boiler_eff-R6,5))
    for i in 0..<365 { 
      d23[GK + i] = iff(d23[GE + i].isZero, 0, round(d22[EE + i] + (d22[EF + i] - d22[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc) + min(d22[EP + i] + (d22[EQ + i] - d22[EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc), max(.zero, d22[EB + i] + (d22[EC + i] - d22[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc) + d22[EH + i] + (d22[EI + i] - d22[EH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc) - max(.zero, d22[EA + i] + d21[F + i] + max(.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - d21[P + i])) * El_boiler_eff - d21[R + i], 5))
    }


    /// Surplus outside harm op heat after opt day harm and min night op prep
    let GL = 12410
    // =IF(GE6=0,0,ROUND(EG6+MIN(ER6,MAX(0,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)+EM6)*BESS_chrg_eff+EJ6-EA6-E6))*El_boiler_eff-G6,5))
    for i in 0..<365 { 
      d23[GL + i] = iff(d23[GE + i].isZero, .zero, round(d22[EG + i] + min(d22[ER + i], max(.zero, (d22[EK + i] + (d22[EL + i] - d22[EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc) + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[E + i])) * El_boiler_eff - d21[G + i], 5))
    }


    /// Surplus outside harm op heat after opt day harm and max night op prep
    let GM = 12775
    // =IF(GE6=0,0,ROUND(EG6+MIN(ER6,MAX(0,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)+EM6)*BESS_chrg_eff+EJ6-EA6-F6))*El_boiler_eff-H6,5))
    for i in 0..<365 { 
      d23[GM + i] = iff(d23[GE + i].isZero, .zero, round(d22[EG + i] + min(d22[ER + i], max(.zero, (d22[EK + i] + (d22[EL + i] - d22[EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc) + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[F + i])) * El_boiler_eff - d21[H + i], 5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep during harm op period
    let GN = 13140
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { d23[GN + i] = iff(d23[GE + i].isZero, .zero, round((d22[EP + i] + (d22[EQ + i] - d22[EP + i]) * d23[ddGE + i]) - max(.zero, d21[Q + i] - (d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[ddGE + i])) / El_boiler_eff, 5)) }

    /// Surplus el boiler cap after opt harm op and max night op prep during harm op period
    let GO = 13505
    // =IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,R6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { 
      d23[GO + i] = iff(d23[GE + i].isZero, .zero, round((d22[EP + i] + (d22[EQ + i] - d22[EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc)) - max(.zero, d21[R + i] - (d22[EE + i] + (d22[EF + i] - d22[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc))) / El_boiler_eff, 5))    
    }

    /// Surplus el boiler cap after opt harm op and min night op prep outside of harm op period
    let GP = 13870
    // IF(GE6=0,0,ROUND(ER6-MAX(0,G6-EG6)/El_boiler_eff,5))
    for i in 0..<365 { d23[GP + i] = iff(d23[GE + i].isZero, .zero, round(d22[ER + i] - max(.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff, 5)) }

    /// Surplus el boiler cap after opt harm op and max night op prep outside of harm op period
    let GQ = 14235
    // =IF(GE6=0,0,ROUND(ER6-MAX(0,H6-EG6)/El_boiler_eff,5))
    for i in 0..<365 { d23[GQ + i] = iff(d23[GE + i].isZero, .zero, round(d22[ER + i] - max(.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff, 5)) }


    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let GR = 14600
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-S6,5))
    for i in 0..<365 { d23[GR + i] = iff(d23[GE + i].isZero, .zero, round((d22[ES + i] + (d22[ET + i] - d22[ES + i]) * d23[ddGE + i]) - d21[S + i], 5)) }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let GS = 14965
    // =IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-T6,5))
    for i in 0..<365 { d23[GS + i] = iff(d23[GE + i].isZero, .zero, round((d22[ES + i] + (d22[ET + i] - d22[ES + i]) * d23[ddGE + i]) - d21[T + i], 5)) }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let GT = 15330
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-U6,5))
    for i in 0..<365 { d23[GT + i] = iff(d23[GE + i].isZero, .zero, round((d22[EV + i] + (d22[EW + i] - d22[EV + i]) * d23[ddGE + i]) - d21[U + i], 5)) }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let GU = 15695
    // =IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-V6,5))
    for i in 0..<365 { d23[GU + i] = iff(d23[GE + i].isZero, .zero, round((d22[EV + i] + (d22[EW + i] - d22[EV + i]) * d23[ddGE + i]) - d21[V + i], 5)) }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let GV = 16060
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-W6,5))
    for i in 0..<365 { d23[GV + i] = iff(d23[GE + i].isZero, .zero, round((d22[EY + i] + (d22[EZ + i] - d22[EY + i]) * d23[ddGE + i]) - d21[W + i], 5)) }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let GW = 16425
    // =IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-X6,5))
    for i in 0..<365 { d23[GW + i] = iff(d23[GE + i].isZero, .zero, round((d22[EY + i] + (d22[EZ + i] - d22[EY + i]) * d23[ddGE + i]) - d21[X + i], 5)) }

    /// Max harmonious day prod after min night prep due to prod cap limits
    let GX = 16790
    // =IF(OR($AE6=0,GE6=0,GF6<0,GH6<0,GJ6<0,GL6<0,GN6<0,GP6<0,GR6<0,GT6<0,GV6<0),0,MIN(1,IFERROR(GF6/MAX(0,GF6-GG6),1),IFERROR(GH6/MAX(0,GH6-GI6),1),IFERROR(GJ6/MAX(0,GJ6-GK6),1),IFERROR(GL6/MAX(0,GL6-GM6),1),IFERROR(GN6/MAX(0,GN6-GO6),1),IFERROR(GP6/MAX(0,GP6-GQ6),1),IFERROR(GR6/MAX(0,GR6-GS6),1),IFERROR(GT6/MAX(0,GT6-GU6),1),IFERROR(GV6/MAX(0,GV6-GW6),1))*($AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d23[GX + i] = iff(
        or(d21[AE + i].isZero, d23[GE + i].isZero, d23[GF + i] < .zero, d23[GH + i] < .zero, d23[GJ + i] < .zero, d23[GL + i] < .zero, d23[GN + i] < .zero, d23[GP + i] < .zero, d23[GR + i] < .zero, d23[GT + i] < .zero, d23[GV + i] < 0), .zero,
        min(
          1, ifFinite(d23[GF + i] / max(.zero, d23[GF + i] - d23[GG + i]), 1), ifFinite(d23[GH + i] / max(.zero, d23[GH + i] - d23[GI + i]), 1), ifFinite(d23[GJ + i] / max(.zero, d23[GJ + i] - d23[GK + i]), 1), ifFinite(d23[GL + i] / max(.zero, d23[GL + i] - d23[GM + i]), 1), ifFinite(d23[GN + i] / max(.zero, d23[GN + i] - d23[GO + i]), 1),
          ifFinite(d23[GP + i] / max(.zero, d23[GP + i] - d23[GQ + i]), 1), ifFinite(d23[GR + i] / max(.zero, d23[GR + i] - d23[GS + i]), 1), ifFinite(d23[GT + i] / max(.zero, d23[GT + i] - d23[GU + i]), 1), ifFinite(d23[GV + i] / max(.zero, d23[GV + i] - d23[GW + i]), 1)) * (d21[AE + i] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

    /// Max Equiv harmonious night prod due to prod cap limits
    let GZ = 17155
    // =IF(OR($AE6=0,FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/MAX(0,FC6-FD6),1),IFERROR(FF6/MAX(0,FF6-FG6),1),IFERROR(FI6/MAX(0,FI6-FJ6),1),IFERROR(FL6/MAX(0,FL6-FM6),1),IFERROR(FO6/MAX(0,FO6-FP6),1),IFERROR(FR6/MAX(0,FR6-FS6),1),IFERROR(FU6/MAX(0,FU6-FV6),1),IFERROR(FX6/MAX(0,FX6-FY6),1),IFERROR(GA6/MAX(0,GA6-GB6),1))*($AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d23[GZ + i] = iff(
        or(d21[AE + i].isZero, d23[FC + i] < .zero, d23[FF + i] < .zero, d23[FI + i] < .zero, d23[FL + i] < .zero, d23[FO + i] < .zero, d23[FR + i] < .zero, d23[FU + i] < .zero, d23[FX + i] < .zero, d23[GA + i] < 0), .zero,
        min(
          1, ifFinite(d23[FC + i] / max(.zero, d23[FC + i] - d23[FD + i]), 1), ifFinite(d23[FF + i] / max(.zero, d23[FF + i] - d23[FG + i]), 1), ifFinite(d23[FI + i] / max(.zero, d23[FI + i] - d23[FJ + i]), 1), ifFinite(d23[FL + i] / max(.zero, d23[FL + i] - d23[FM + i]), 1), ifFinite(d23[FO + i] / max(.zero, d23[FO + i] - d23[FP + i]), 1),
          ifFinite(d23[FR + i] / max(.zero, d23[FR + i] - d23[FS + i]), 1), ifFinite(d23[FU + i] / max(.zero, d23[FU + i] - d23[FV + i]), 1), ifFinite(d23[FX + i] / max(.zero, d23[FX + i] - d23[FY + i]), 1), ifFinite(d23[GA + i] / max(.zero, d23[GA + i] - d23[GB + i]), 1)) * (d21[AE + i] - equiv_harmonious_min_perc[j])
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

    for i in 0..<365 { 
      if d23[GZ + i].isZero {
        d23[HA + i] = .zero
        d23[HB + i] = .zero
        d23[HC + i] = .zero
        d23[HD + i] = .zero
        d23[HE + i] = .zero
        d23[HF + i] = .zero
        d23[HG + i] = .zero
        d23[HH + i] = .zero
        d23[HI + i] = .zero
        d23[HJ + i] = .zero
        d23[HK + i] = .zero
        d23[HL + i] = .zero
        d23[HM + i] = .zero
        d23[HN + i] = .zero
        d23[HO + i] = .zero
        d23[HP + i] = .zero
        d23[HQ + i] = .zero
        d23[HR + i] = .zero
        continue
      }
      d23[ddGZ + i] = (d23[GZ + i] - equiv_harmonious_min_perc[j]) / (d21[AE + i] - equiv_harmonious_min_perc[j])

      // =IF(GZ6=0,0,ROUND(EB6+EH6-(O6+(P6-O6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MAX(0,EA6+(E6+(F6-E6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+MAX(0,G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,Q6+(R6-Q6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)-EE6)/El_boiler_eff,5))
      d23[HA + i] = 
        round(
          d22[EB + i] + d22[EH + i] - (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[ddGZ + i]) - max(.zero, d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[ddGZ + i]) + max(.zero, d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(
            .zero, d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[ddGZ + i] - d22[EE + i]) / El_boiler_eff, 5)

      // =IF(GZ6=0,0,ROUND(EC6+EI6-(O6+(P6-O6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MAX(0,EA6+E6+(F6-E6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)+MAX(0,G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,Q6+(R6-Q6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)-EF6)/El_boiler_eff,5))
      d23[HB + i] = round(
        d22[EC + i] + d22[EI + i] - (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[ddGZ + i]) - max(.zero, d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[ddGZ + i]) + max(.zero, d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(
          .zero, d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[ddGZ + i] - d22[EF + i]) / El_boiler_eff, 5)

      // =IF(GZ6=0,0,ROUND((EK6+EM6)*BESS_chrg_eff+EJ6-EA6-(E6+(F6-E6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MAX(0,G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)-EG6)/El_boiler_eff,5))

      d23[HC + i] = round((d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[ddGZ + i]) - max(.zero, d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i] - d22[EG + i]) / El_boiler_eff, 5)
      // =IF(GZ6=0,0,ROUND((EL6+EM6)*BESS_chrg_eff+EJ6-EA6-(E6+(F6-E6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MAX(0,G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)-EG6)/El_boiler_eff,5))

      d23[HD + i] = round((d22[EL + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[ddGZ + i]) - max(.zero, d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i] - d22[EG + i]) / El_boiler_eff, 5)
      // =IF(GZ6=0,0,ROUND(EE6+MIN(EP6,MAX(0,EB6+EH6-MAX(0,EA6+E6+(F6-E6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)+MAX(0,G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)-EG6)/El_boiler_eff-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff-(O6+(P6-O6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))))*El_boiler_eff-(Q6+(R6-Q6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))

      d23[HE + i] = round(
        d22[EE + i] + min(d22[EP + i], max(.zero, d22[EB + i] + d22[EH + i] - max(.zero, d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[ddGZ + i]) +  max(.zero, d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[ddGZ + i]))) * El_boiler_eff - (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[ddGZ + i]), 5)

      // =IF(GZ6=0,0,ROUND($EF6+MIN($EQ6,MAX(0,$EC6+$EI6-MAX(0,$EA6+$E6+($F6-$E6)/($AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)+MAX(0,$G6+($H6-$G6)/($AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)-$EG6)/El_boiler_eff-$EJ6-$EM6*BESS_chrg_eff)/BESS_chrg_eff-($O6+($P6-$O6)/($AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))))*El_boiler_eff-($Q6+($R6-$Q6)/($AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))

      // =IF(RD3=0,0,ROUND($EF3+MIN($EQ3,MAX(0,$EC3+$EI3-MAX(0,$EA3+$BI3+($BJ3-$BI3)/($CI3-C_equiv_harmonious_min_perc)*(RD3-C_equiv_harmonious_min_perc)+MAX(0,$BK3+($BL3-$BK3)/($CI3-C_equiv_harmonious_min_perc)*(RD3-C_equiv_harmonious_min_perc)-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-($BS3+($BT3-$BS3)/($CI3-C_equiv_harmonious_min_perc)*(RD3-C_equiv_harmonious_min_perc))))*El_boiler_eff-($BU3+($BV3-$BU3)/($CI3-C_equiv_harmonious_min_perc)*(RD3-C_equiv_harmonious_min_perc)),5))
      d23[HF + i] = round(
        d22[EF + i] + min(d22[EQ + i], max(.zero, d22[EC + i] + d22[EI + i] - max(.zero, d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[ddGZ + i]) +  max(.zero, d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[ddGZ + i]))) * El_boiler_eff - (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[ddGZ + i]), 5)
      // =IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d23[HG + i] = round(d22[EG + i] + d22[ER + i] * El_boiler_eff - (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i]), 5)

      // =IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d23[HH + i] = round(d22[EG + i] + d22[ER + i] * El_boiler_eff - (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i]), 5)

      // =IF(GZ6=0,0,ROUND(EP6-MAX(0,(Q6+(R6-Q6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
      d23[HI + i] = round(d22[EP + i] - max(.zero, (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[ddGZ + i]) - d22[EE + i]) / El_boiler_eff, 5)

      // =IF(GZ6=0,0,ROUND(EQ6-MAX(0,(Q6+(R6-Q6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
      d23[HJ + i] = round(d22[EQ + i] - max(.zero, (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[ddGZ + i]) - d22[EF + i]) / El_boiler_eff, 5)

      // =IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
      d23[HK + i] = round(d22[ER + i] - max(.zero, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i]) - d22[EG + i]) / El_boiler_eff, 5)

      // =IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
      d23[HL + i] = round(d22[ER + i] - max(.zero, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i]) - d22[EG + i]) / El_boiler_eff, 5)

      // =IF(GZ6=0,0,ROUND(ES6-(S6+(T6-S6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d23[HM + i] = round(d22[ES + i] - (d21[S + i] + (d21[T + i] - d21[S + i]) * d23[ddGZ + i]), 5)

      // =IF(GZ6=0,0,ROUND(ET6-(S6+(T6-S6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d23[HN + i] = round(d22[ET + i] - (d21[S + i] + (d21[T + i] - d21[S + i]) * d23[ddGZ + i]), 5)

      // =IF(GZ6=0,0,ROUND(EV6-(U6+(V6-U6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d23[HO + i] = round(d22[EV + i] - (d21[U + i] + (d21[V + i] - d21[U + i]) * d23[ddGZ + i]), 5)

      // =IF(GZ6=0,0,ROUND(EW6-(U6+(V6-U6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d23[HP + i] = round(d22[EW + i] - (d21[U + i] + (d21[V + i] - d21[U + i]) * d23[ddGZ + i]), 5)

      // =IF(GZ6=0,0,ROUND(EY6-(W6+(X6-W6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d23[HQ + i] = round(d22[EY + i] - (d21[W + i] + (d21[X + i] - d21[W + i]) * d23[ddGZ + i]), 5)

      // =IF(GZ6=0,0,ROUND(EZ6-(W6+(X6-W6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      d23[HR + i] = round(d22[EZ + i] - (d21[W + i] + (d21[X + i] - d21[W + i]) * d23[ddGZ + i]), 5)
      if j == 2 && i == 2 {

      }
    }

    /// Opt harm op period op during night prio operation
    let HS = 24090
    // =IF(OR(GE6=0,HA6<0,HC6<0,HE6<0,HG6<0,HI6<0,HK6<0,HM6<0,HO6<0,HQ6<0),0,MIN(1,IFERROR(HA6/MAX(0,HA6-HB6),1),IFERROR(HC6/MAX(0,HC6-HD6),1),IFERROR(HE6/MAX(0,HE6-HF6),1),IFERROR(HG6/MAX(0,HG6-HH6),1),IFERROR(HI6/MAX(0,HI6-HJ6),1),IFERROR(HK6/MAX(0,HK6-HL6),1),IFERROR(HM6/MAX(0,HM6-HN6),1),IFERROR(HO6/MAX(0,HO6-HP6),1),IFERROR(HQ6/MAX(0,HQ6-HR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      if 24255 == i + HS {
        
      }
      d23[HS + i] = iff(
        or(d23[GE + i].isZero, d23[HA + i] < .zero, d23[HC + i] < .zero, d23[HE + i] < .zero, d23[HG + i] < .zero, d23[HI + i] < .zero, d23[HK + i] < .zero, d23[HM + i] < .zero, d23[HO + i] < .zero, d23[HQ + i] < 0), .zero,
        min(
          1,
            ifFinite(d23[HA + i] / max(.zero, d23[HA + i] - d23[HB + i]), 1), ifFinite(d23[HC + i] / max(.zero, d23[HC + i] - d23[HD + i]), 1), ifFinite(d23[HE + i] / max(.zero, d23[HE + i] - d23[HF + i]), 1), ifFinite(d23[HG + i] / max(.zero, d23[HG + i] - d23[HH + i]), 1), ifFinite(d23[HI + i] / max(.zero, d23[HI + i] - d23[HJ + i]), 1),
            ifFinite(d23[HK + i] / max(.zero, d23[HK + i] - d23[HL + i]), 1), ifFinite(d23[HM + i] / max(.zero, d23[HM + i] - d23[HN + i]), 1), ifFinite(d23[HO + i] / max(.zero, d23[HO + i] - d23[HP + i]), 1), ifFinite(d23[HQ + i] / max(.zero, d23[HQ + i] - d23[HR + i]), 1)) * Overall_harmonious_range + Overall_harmonious_min_perc)
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

    let DM = 13140
    let DN = 13505
    let DO = 13870
    let ddGX = 46720
    // ID=IF(DT6=0,0,IF(GE6=0,DU6,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      d23[ddGX + i] = (d23[GX + i]-equiv_harmonious_min_perc[j]) / (d21[AE + i] - equiv_harmonious_min_perc[j]) 
      d23[ID + i] = iff(
        d22[DT + i].isZero, .zero,
        iff(
          d23[GE + i].isZero, d22[DU + i],
          d22[DT + i] + (d22[DU + i] - d22[DT + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc)))

      // =IF(GX6=0,0,(Q6+(R6-Q6)/(AE6-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
      d23[IE + i] = iff(d23[GX + i].isZero, .zero, (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[ddGX + i]))

      // IF=IF(GE6=0,EF6,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      d23[IF + i] = iff(d23[GE + i].isZero, d22[EF + i], d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[ddGE + i])

      // IG=IF(GE6=0,EO6,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff)
      d23[IG + i] = iff(d23[GE + i].isZero, d22[EO + i], (d22[EN + i] + (d22[EO + i] - d22[EN + i]) * d23[ddGE + i]) * El_boiler_eff)

      // IF(GE6=0,0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,IE6-IF6)))
      d23[IH + i] = iff(d23[GE + i].isZero, .zero, min((d22[EP + i] + (d22[EQ + i] - d22[EP + i]) * d23[ddGE + i]) * El_boiler_eff, max(.zero, d23[IE + i] - d23[IF + i])))

      // IF6+IH6-IE6
      d23[II + i] = d23[IF + i] + d23[IH + i] - d23[IE + i]

      // HU=IF(DR6=0,0,IF(GE6=0,MAX(0,DS6-MAX(0,EA6/BESS_chrg_eff-EM6-EL6)),DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))
      if d22[DR + i].isZero {
        d23[HU + i] = .zero
      } else if d23[GE + i].isZero {
        d23[HU + i] = max(.zero, d22[DS + i] - max(.zero, d22[EA + i] / BESS_chrg_eff - d22[EM + i] - d22[EL + i]))
      } else {
        d23[HU + i] = d22[DR + i] + (d22[DS + i] - d22[DR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[GE + i] - Overall_harmonious_min_perc)
      }

      // HV=IF(GX6=0,0,($O6+($P6-$O6)/($AE6-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
      d23[HV + i] = iff(d23[GX + i].isZero, .zero, (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[ddGX + i]))

      // HW=IF(OR(GE6=0,GX6=0),MIN(MAX(0,EA6/BESS_chrg_eff-EM6),EL6),MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(QI6-Overall_harmonious_min_perc),MAX(0,EA6+E6+(F6-E6)/(AE6-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)+MIN(ER6,MAX(0,G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)-EG6)/El_boiler_eff)-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff))
      d23[HW + i] = iff(
        or(d23[GE + i].isZero, d23[GX + i].isZero), min(max(.zero, d22[EA + i] / BESS_chrg_eff - d22[EM + i]), d22[EL + i]), min(d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[ddGE + i], max(.zero, d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[ddGX + i]) + min(d22[ER + i], max(.zero, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGX + i]) - d22[EG + i]) / El_boiler_eff) - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff))

      // IF(GE6=0,EO6,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      d23[HX + i] = iff(d23[GE + i].isZero, d22[EO + i], d22[EN + i] + (d22[EO + i] - d22[EN + i]) * d23[ddGE + i])

      // IH6/El_boiler_eff
      d23[HY + i] = d23[IH + i] / El_boiler_eff

      // HZ=IF(GE6=0,MAX(0,EC6-MAX(0,EA6/BESS_chrg_eff-EL6-EM6)),EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      d23[HZ + i] = iff(d23[GE + i].isZero, max(.zero, d22[EC + i] - max(.zero, d22[EA + i] / BESS_chrg_eff - d22[EL + i] - d22[EM + i])), d22[EB + i] + (d22[EC + i] - d22[EB + i]) * d23[ddGE + i])
      // IA=IF(GE6=0,DN6,DM6+(DN6-DM6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      d23[IA + i] = iff(d23[GE + i].isZero, d22[DN + i], d22[DM + i] + (d22[DM + i] - d22[DN + i]) * d23[ddGE + i])
    }

    /// grid input for night prep during harm op period
    let IB = 27010
    // IB=MIN(IF(GE6=0,0,EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)),MAX(0,-(HZ6-HV6-HW6-HY6)))
    for i in 0..<365 { d23[IB + i] = min(iff(d23[GE + i].isZero, .zero, d22[EH + i] + (d22[EI + i] - d22[EH + i]) * d23[ddGE + i]), max(.zero, -(d23[HZ + i] - d23[HV + i] - d23[HW + i] - d23[HY + i]))) }

    /// Balance of electricity during harm op period
    let IC = 27375
    // =ROUND(HZ6+IB6-HV6-HW6-HY6,5)
    for i in 0..<365 { d23[IC + i] = round(d23[HZ + i] + d23[IB + i] - d23[HV + i] - d23[HW + i] - d23[HY + i], 5) }

    /// heat cons for harm op outside of harm op period
    let IQ = 32485
    // IQ=IF(GX6=0,0,G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d23[IQ + i] = iff(d23[GX + i].isZero, .zero, d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGX + i]) }

    /// heat from CSP outside of harm op period
    let IR = 32850
    // IR=EG6
    for i in 0..<365 { d23[IR + i] = d22[EG + i] }

    /// heat from el boiler outside of harm op period
    let IS = 33215
    // IF(OR(GE6=0,GX6=0),0,MIN(ER6*El_boiler_eff,MAX(0,IQ6-IR6)))
    for i in 0..<365 { d23[IS + i] = iff(or(d23[GE + i].isZero, d23[GX + i].isZero), .zero, min(d22[ER + i] * El_boiler_eff, max(.zero, d23[IQ + i] - d23[IR + i]))) }

    /// Balance of heat outside of harm op period
    let IT = 33580
    // IR6+IS6-IQ6
    for i in 0..<365 { d23[IT + i] = d23[IR + i] + d23[IS + i] - d23[IQ + i] }

    /// el cons for harm op outside of harm op period
    let IJ = 29930
    // IJ=IF(GX6=0,0,E6+(F6-E6)/(AE6-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d23[IJ + i] = iff(d23[GX + i].isZero, .zero, d21[E + i] + (d21[F + i] - d21[E + i]) * d23[ddGX + i]) }

    /// el cons by el boiler outside of harm op period
    let IK = 30295
    // IS6/El_boiler_eff
    for i in 0..<365 { d23[IK + i] = d23[IS + i] / El_boiler_eff }

    /// el cons for aux cons outside of harm op period
    let IL = 30660
    // IL=$EA6
    for i in 0..<365 { d23[IL + i] = d22[EA + i] }

    /// el from BESS outside of harm op period
    let IN = 31390
    // HW6*BESS_chrg_eff
    for i in 0..<365 { d23[IN + i] = d23[HW + i] * BESS_chrg_eff }

    /// el from PV outside of harm op period
    let IM = 31025
    // IM=MIN(MAX(0,IL6+IK6+IJ6-IN6)/BESS_chrg_eff,EM6)
    for i in 0..<365 { 
      d23[IM + i] = min(max(.zero, d23[IL + i] + d23[IK + i] + d23[IJ + i] - d23[IN + i]) / BESS_chrg_eff, d22[EM + i])
    }

    /// grid input outside of harm op period
    let IO = 31755
    // IO=MIN(DO6+EJ6,MAX(0,-IM6*BESS_chrg_eff-IN6+IJ6+IK6+IL6))
    for i in 0..<365 { 
      d23[IO + i] = min(d22[DO + i] + d22[EJ + i], max(.zero, -d23[IM + i] * BESS_chrg_eff - d23[IN + i] + d23[IJ + i] + d23[IK + i] + d23[IL + i]))
    }

    /// Balance of electricity outside of harm op period
    let IP = 32120
    // IP=ROUND(IM6*BESS_chrg_eff+IN6+IO6-IJ6-IK6-IL6,5)
    for i in 0..<365 { d23[IP + i] = round(d23[IM + i] * BESS_chrg_eff + d23[IN + i] + d23[IO + i] - d23[IJ + i] - d23[IK + i] - d23[IL + i], 5) }

    /// Pure Methanol prod with min night prep and resp day op
    let IU = 33945
    // IU=MAX(0,HU6-C6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+IF(IJ6=0,0,IF(A_overall_var_max_cons=0,B6*GX6,MAX(0,IJ6-B6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc)*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      d23[IU + i] = max(0, d23[HU + i] - day0[C + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud
        + iff(d23[IJ + i].isZero, 0, iff(overall_var_max_cons[j].isZero, day0[B + i] * d23[GX + i], max(0, d23[IJ + i] - day0[B + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j]) * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let IV = 34310
    // IV=ROUND(MAX(0,MIN(IC6,IF(GE6=0,DW6,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))))+MAX(0,MIN(IP6,IF(OR(GE6=0,GX6=0),0,DX6))),5)
    for i in 0..<365 { d23[IV + i] = round(max(.zero, min(d23[IC + i], iff(or(d23[GE + i].isZero, d23[GX + i].isZero), d22[DW + i], (d22[DV + i] + (d22[DW + i] - d22[DV + i]) * d23[ddGE + i]))) + min(d23[IP + i], iff(or(d23[GE + i].isZero, d23[GX + i].isZero), .zero, d22[DX + i]))), 5) }

    /// grid import
    let IW = 34675
    // IW=ROUND((MAX(0,-IC6)+MAX(0,-IP6))*EDG_elec_cost_factor+IA6+IB6+IO6,5)
    for i in 0..<365 { d23[IW + i] = round((max(.zero, -d23[IC + i]) + max(.zero, -d23[IP + i])) * EDG_elec_cost_factor + d23[IA + i] + d23[IB + i] + d23[IO + i], 5) }

    /// Checksum
    let IX = 35040
    // MAX(0,-IC6)+MAX(0,-II6)+MAX(0,-IP6)+MAX(0,-IT6)
    for i in 0..<365 {
      let _IX = max(.zero, -d23[IC + i]) + max(.zero, -d23[II + i]) + max(.zero, -d23[IP + i]) + max(.zero, -d23[IT + i])
      // if IX > 1E-13 { print("Checksum error daily 2", i, j, IX) }
      d23[IX + i] = _IX
    }

    let ddHS = 47450
    for i in 0..<365 { d23[ddHS + i] = Overall_harmonious_range < 1E-10 ? 1 : (d23[HS + i] - Overall_harmonious_min_perc) / Overall_harmonious_range }

    /// Heat cons for harm op during harm op period
    let JI = 38690
    // JI=IF(DT6=0,0,IF(HS6=0,DU6,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS7-Overall_harmonious_min_perc)))
    for i in 0..<365 { d23[JI + i] = iff(d22[DT + i].isZero, .zero,iff(d23[HS + i].isZero, d22[DU + i] , d22[DT + i] + (d22[DU + i] - d22[DT + i]) * d23[ddHS + i])) }

    /// Heat cons for night prep during harm op period
    let JJ = 39055
    // JJ=IF(GZ6=0,0,(Q6+(R6-Q6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 { d23[JJ + i] = iff(or(d23[HS + i].isZero, d23[GZ + i].isZero), .zero, (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[ddGZ + i])) }

    /// CSP heat available after harm op during harm op period
    let JK = 39420
    // JK=IF(HS6=0,EF6,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS7-Overall_harmonious_min_perc))
    for i in 0..<365 { d23[JK + i] = iff(d23[HS + i].isZero, d22[EF + i], d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[ddHS + i]) }

    /// El boiler heat prod for harm op during harm op period
    let JL = 39785
    // JL=IF(HS6=0,EO6,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS7-Overall_harmonious_min_perc))*El_boiler_eff)
    for i in 0..<365 { d23[JL + i] = iff(d23[HS + i].isZero, d22[EO + i], (d22[EN + i] + (d22[EO + i] - d22[EN + i]) * d23[ddHS + i]) * El_boiler_eff) }

    /// El boiler heat prod for night prep during harm op period
    let JM = 40150
    // JM=IF(HS6=0,0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS7-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,JJ6-JK6)))
    for i in 0..<365 { d23[JM + i] = iff(d23[HS + i].isZero, .zero, min((d22[EP + i] + (d22[EQ + i] - d22[EP + i]) * d23[ddHS + i]) * El_boiler_eff, max(.zero, d23[JJ + i] - d23[JK + i]))) }

    /// Balance of heat during harm op period
    let JN = 40515
    // JK6+JM6-JJ6
    for i in 0..<365 { d23[JN + i] = d23[JK + i] + d23[JM + i] - d23[JJ + i] }

    /// el cons for harm op during harm op period
    let IZ = 35405
    // IZ=IF($DR3=0,0,IF(HS3=0,MAX(0,$DS3-MAX(0,$EA3/BESS_chrg_eff-$EL3-$EM3)),$DR3+($DS3-$DR3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS3-Overall_harmonious_min_perc)))
    for i in 0..<365 { d23[IZ + i] = iff(d22[DR + i].isZero, 0, iff(d23[HS + i].isZero, max(0, d22[DS + i] - max(0, d22[EA + i] / BESS_chrg_eff - d22[EL + i] - d22[EM + i])), d22[DR + i] + (d22[DS + i] - d22[DR + i]) * d23[ddHS + i])) }

    /// el cons for night prep during harm op period
    let JA = 35770
    // JA=IF(GZ6=0,0,(O6+(P6-O6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 { d23[JA + i] = iff(d23[GZ + i].isZero, .zero, (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[ddGZ + i])) }

    /// el cons for BESS charging during harm op period
    let JB = 36135
    // JB=IF(OR(GZ6=0,HS6=0),MIN(MAX(0,EA6/BESS_chrg_eff-EM6),EL6),MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(RW6-Overall_harmonious_min_perc),MAX(0,EA6+E6+(F6-E6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)+MIN(ER6,MAX(0,G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)-EG6)/El_boiler_eff)-EJ6-EM6*BESS_chrg_eff)/BESS_chrg_eff))
    for i in 0..<365 {
      d23[JB + i] = iff(
        or(d23[HS + i].isZero, d23[GZ + i].isZero), min(max(.zero, d22[EA + i] / BESS_chrg_eff - d22[EM + i]), d22[EL + i]),
        min(d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[ddHS + i], max(.zero, d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[ddGZ + i]) + min(d22[ER + i], max(.zero, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i]) - d22[EG + i]) / El_boiler_eff) - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff))
      }

    /// el cons of el boiler for harm op during harm op period
    let JC = 36500
    // JC=IF(HS6=0,EO6,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS7-Overall_harmonious_min_perc))
    for i in 0..<365 { d23[JC + i] = iff(d23[HS + i].isZero, d22[EO + i], d22[EN + i] + (d22[EO + i] - d22[EN + i]) * d23[ddHS + i]) }

    /// el cons of el boiler for night prep during harm op period
    let JD = 36865
    // JM6/El_boiler_eff
    for i in 0..<365 { d23[JD + i] = d23[JM + i] / El_boiler_eff }

    /// PV available after harm op during harm op period
    let JE = 37230
    // JE=IF(HS6=0,MAX(0,EC6-MAX(0,EA6/BESS_chrg_eff-EL6-EM6)),EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 { 
      d23[JE + i] = iff(d23[HS + i].isZero, max(.zero, d22[EC + i] - max(.zero, d22[EA + i] / BESS_chrg_eff - d22[EL + i] - d22[EM + i])), d22[EB + i] + (d22[EC + i] - d22[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d23[HS + i] - Overall_harmonious_min_perc))
    }

    /// grid input for harm op during harm op period
    let JF = 37595
    // JF=IF(HS6=0,DN6,DM6+(DN6-DM6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 { d23[JF + i] = iff(or(d23[HS + i].isZero, d23[GZ + i].isZero), d22[DN + i], d22[DN + i] + (d22[DN + i] - d22[DM + i]) * d23[ddHS + i]) }

    /// grid input for night prep during harm op period
    let JG = 37960
    // JG=MIN(IF(HS6=0,0,EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc)),MAX(0,-(JE6-JA6-JB6-JD6)))
    for i in 0..<365 { d23[JG + i] = min(iff(d23[HS + i].isZero, .zero, d22[EH + i] + (d22[EI + i] - d22[EH + i]) * d23[ddHS + i]), max(.zero, -(d23[JE + i] - d23[JA + i] - d23[JB + i] - d23[JD + i]))) }

    /// Balance of electricity during harm op period
    let JH = 38325
    // =ROUND(JE6+JG6-JA6-JB6-JD6,5)
    for i in 0..<365 { d23[JH + i] = round(d23[JE + i] + d23[JG + i] - d23[JA + i] - d23[JB + i] - d23[JD + i], 5) }

    /// heat cons for harm op outside of harm op period
    let JV = 43435
    // JV=IF(GZ6=0,0,G6+(H6-G6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d23[JV + i] = iff(d23[GZ + i].isZero, .zero, d21[G + i] + (d21[H + i] - d21[G + i]) * d23[ddGZ + i]) }

    /// heat from CSP outside of harm op period
    // let JW = 43800
    // JW=IF(OR(HS6=0,GZ6=0),0,EG6)
    

    /// heat from el boiler outside of harm op period
    let JX = 44165
    // IF(OR(HS6=0,GZ6=0),0,MIN(ER6*El_boiler_eff,MAX(0,JV6-JW6)))
    for i in 0..<365 { d23[JX + i] = iff(or(d23[HS + i].isZero, d23[GZ + i].isZero), .zero, min(d22[ER + i] * El_boiler_eff, max(.zero, d23[JV + i] - d22[EG + i]))) }

    /// Balance of heat outside of harm op period
    let JY = 44530
    // JW6+JX6-JV6
    for i in 0..<365 { d23[JY + i] = d22[EG + i] + d23[JX + i] - d23[JV + i] }

    /// el cons for harm op outside of harm op period
    let JO = 40880
    // JO=IF(GZ6=0,0,E6+(F6-E6)/(AE6-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d23[JO + i] = iff(d23[GZ + i].isZero, .zero, d21[E + i] + (d21[F + i] - d21[E + i]) * d23[ddGZ + i]) }

    /// el cons by el boiler outside of harm op period
    let JP = 41245
    /// el from PV outside of harm op period
    let JR = 47815
    /// el from harm op period charged BESS discharging for stby outside of harm op period
    let JS = 42340
    for i in 0..<365 {
      // JX6/El_boiler_eff
      d23[JP + i] = d23[JX + i] / El_boiler_eff
      // JQ=EA7
      // d23[JQ + i] = d22[EA + i] //iff(or(d23[HS + i].isZero, d23[GZ + i].isZero), .zero, d22[EA + i])
      // =JB6*BESS_chrg_eff
      d23[JS + i] = d23[JB + i] * BESS_chrg_eff
      // JR=MIN(MAX(0,JQ6+JP6+JO6-JS6)/BESS_chrg_eff,$EM6)
      d23[JR + i] = min(max(.zero, d22[EA + i] + d23[JP + i] + d23[JO + i] - d23[JS + i]) / BESS_chrg_eff, d22[EM + i])
    }

    /// grid input outside of harm op period
    let JT = 42705
    // JT=MIN(DO6+EJ6,MAX(0,-JR6*BESS_chrg_eff-JS6+JO6+JP6+JQ6))
    for i in 0..<365 { d23[JT + i] = min(d22[DO + i] + d22[EJ + i], max(.zero, -d23[JR + i] * BESS_chrg_eff - d23[JS + i] + d23[JO + i] + d23[JP + i] + d22[EA + i])) }

    /// Balance of electricity outside of harm op period
    let JU = 43070
    // JU=ROUND(JR6*BESS_chrg_eff+JS6+JT6-JO6-JP6-JQ6,5)
    for i in 0..<365 { d23[JU + i] = round(d23[JR + i] * BESS_chrg_eff + d23[JS + i] + d23[JT + i] - d23[JO + i] - d23[JP + i] - d22[EA + i], 5) }

    /// Pure Methanol prod with min night prep and resp day op
    let JZ = 44895
    // JZ=MAX(0,IZ6-C6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+IF(JO6=0,0,IF(A_overall_var_max_cons=0,B6*GZ6,MAX(0,JO6-B6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc)*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      d23[JZ + i] = max(0, d23[IZ + i] - day0[C + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud
        + iff(d23[JO + i].isZero, 0, iff(overall_var_max_cons[j].isZero, day0[B + i] * d23[GZ + i], max(0, d23[JO + i] - day0[B + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j]) * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let KA = 45260
    // KA=ROUND(MAX(0,MIN(JH6,IF(HS6=0,DW6,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc)))))+MAX(0,MIN(JU6,IF(OR(HS6=0,GZ6=0),0,DX6))),5)
    for i in 0..<365 { d23[KA + i] = round(max(.zero, min(d23[JH + i], iff(or(d23[HS + i].isZero, d23[GZ + i].isZero), d22[DW + i], (d22[DV + i] + (d22[DW + i] - d22[DV + i]) * d23[ddHS + i])))) + max(.zero, min(d23[JU + i], iff(or(d23[HS + i].isZero, d23[GZ + i].isZero), .zero, d22[DX + i]))), 5) }

    /// grid import
    let KB = 45625
    // KB=ROUND((MAX(0,-JH6)+MAX(0,-JU6))*EDG_elec_cost_factor+JF6+JG6+JT6,5)
    for i in 0..<365 { 
      d23[KB + i] = round((max(.zero, -d23[JH + i]) + max(.zero, -d23[JU + i])) * EDG_elec_cost_factor + d23[JF + i] + d23[JG + i] + d23[JT + i], 5)
    }

    /// Checksum
    // let KC = 45990
    // MAX(0,-JH6)+MAX(0,-JN6)+MAX(0,-JU6)+MAX(0,-JY6)
    // for i in 0..<365 {
    //   let KC = max(.zero, -d23[JH + i]) + max(.zero, -d23[JN + i]) + max(.zero, -d23[JU + i]) + max(.zero, -d23[JY + i])
    // if KC > 1E-13 { print("Checksum error daily 2", i, j, KC) }
    //   d23[KC + i] = KC
    //  }
  }
}

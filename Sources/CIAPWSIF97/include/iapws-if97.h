//p6 eqs.(6)
static double B23_T_p(double pi);

//p6  ��λ:Mpa,K  eqs.(7)
static double gamma_R1(double pi,double tau);

//p8  ��λ:Mpa,K
static double gamma_tau_R1(double pi,double tau);

//p8  ��λ:Mpa,K
static double gamma_pi_R1(double pi, double tau);

//p13  ��λ:Mpa,K  eqs.(16)
static double gamma_ideal_R2(double pi,double tau);

//p13 ��λ:Mpa,K   eqs.(17)
static double gamma_res_R2(double pi, double tau);

//p16 ��λ:Mpa
static double gamma_pi_ideal_R2(double pi);

//p16  ��λ:Mpa,K
static double gamma_pi_res_R2(double pi, double tau);

//p16 ��λ:K
static double gamma_tau_ideal_R2(double tau);

//p16  ��λ:Mpa,K
static double gamma_tau_res_R2(double pi, double tau);

//p40_book
static double B34_ps_h_eq(double h);

//p56_book
static double B34_ps_s_eq(double s);


//p21  eqs.(21)
static double R2_Bbc_h_p(double pi);


//p33   eqs.(30)
double ps_T(double T);

//p35    eqs.(31)
double Ts_p(double p);

//p11_book
int region_pT(double p, double T);

double v_pT(double p, double T, int region);

double s_pT(double p, double T, int region);

double h_pT(double p, double T, int region);

//p37_book
static int region_ph(double p, double h);

//p53_book
static int region_ps(double p, double s);

double T_ph(double p, double h);


double T_ps(double p, double s);

//p152 book
double viscosity_ideal(double theta);

//p152 book
double viscosity_second(double delta, double theta);

//p152 book
double eta_vT(double v,double T);

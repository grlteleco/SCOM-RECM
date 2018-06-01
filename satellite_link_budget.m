%% Constants
T0 = 290;                                       % Temperature 0 (K)
c = 3e8;  

%% BW calculations
ntot_fw = ;                                 % Spectral efficiency forward link
ntot_rt = ;                                 % Spectral efficiency return link
N_houses = ;                                 % Number of users (houses + boats) 
N_boats = ; 
T_con = ;                                   % Concurrency rate
BR_forward = (20e9*N_houses + 15e9*N_boats)*T_con/30/3600;
BW_fw = BR_forward/ntot_fw*1.2*0.85;
BW_rt = BW_fw*0.15/0.85*ntot_fw/ntot_rt;

%% Parameters
% Return link
f_up = 13220e6;                                 % Frequency return (Hz)
lambda_up =c/f_up;                              % Wavelength return link (m)

% Forward link
f_dw = 11456e6;                                 % Frequency forward (Hz)
lambda_dw =c/f_dw;                              % Wavelength forward link (m)

% Satellite segment
G_T_sat = 6.5;                                  % G/T (dB/K)
Los = -30;                                      % Orbital Position (º E)
EIRP_sat_fw = 54 + 10*log10(BW_fw/36e6);        % Satellite EIRP (dBW)
EIRP_sat_rt = 54 + 10*log10(BW_rt/36e6);        % Satellite EIRP (dBW)
asi = power(10, 4);                             % Interference from adjacent satellite
c_im = power(10,4.3);                           % Carrier to intermodulation noise

% House antenna + LNB
F_er = 0.6;                                     % Rx. antenna noise figure(dB)
Tant_er = 43;                                   % Rx. antenna temperature (K)
Loe = 2.64;                                     % Longitude (º E) (estimation)
Lae = 39.56;                                    % Latitude (º N) (estimation)
Tlnb = T0*(power(10,F_er/10) - 1);              % LNB temperature (K)
G_er_rx = 41.8;                                % Gain at reception (dB)
G_er_tx = 43.3;                                % Gain at transmission (dB)
T_er = Tant_er + Tlnb/(power(10, G_er_rx/10));  % Equivalent temperature (K)
G_T_er = G_er_rx-1.2-10*log10(T_er);            % G/T (dB/K)
Pt_er = 10*log10(3);                            % Transmitted power (dBW)
EIRP_er = Pt_er + G_er_tx;                      % EIRP (dBW)

% Boat antenna
Pt_bt = 10*log10(16);                           % Transmitted power (dBW)
G_bt_tx = 37.7;                                 % Gain at transmission (dB)
G_bt_rx = 36.3;                                 % Gain at reception (dB)
G_T_bt = 15.7;                                  % G/T (dB/K)
EIRP_bt = Pt_bt + G_bt_tx;                      % EIRP (dBW)

% Ground control segment
Loe_gc = -3.44;                                  % Longitude (º E)
Lae_gc = 40.3;                                  % Latitude (º N)
EIRP_gc = 56;                                   % EIRP (dBW)
EIRP_gc = 62 + 10*log10(BW_fw/36e6);
G_T_gc = 39;                                    % G/T (dB/K)

%% Distance calculations
% Mallorca <-> Satellite
gamma_mal = acos(cos(deg2rad(Lae))*cos(deg2rad(Loe-Los)));      % Gamma (rad) 
d_mal = 42242000*sqrt(1.02274 - 0.301596*cos(gamma_mal));       % Distance (m)
El_mal = acos(42242*sin(gamma_mal)/(d_mal/1000));               % Elevation (rad) 

% Satellite <-> Ground Control
gamma_gc = acos(cos(deg2rad(Lae_gc))*cos(deg2rad(Loe_gc-Los))); % Gamma (rad)
d_gc = 42242000*sqrt(1.02274 - 0.301596*cos(gamma_gc));         % Distance (m)
El_gc = acos(42242*sin(gamma_gc)/(d_gc/1000));                  % Elevation (rad)

%% Rain attenuation
hr = 2.5 + 0.36;                                    % Effective height (km) (ITU-R)
hs_gc = 0.650;                                      % Ground control Station height (km)
hs_bt = 0.004;                                      % Boat Station height (km)
hs_mal = 0.850;                                     % Mallorca Station height (km)

Ls_gc = (hr - hs_gc)/sin(El_gc);                    % Respective Slant path lengths (km)
Ls_bt = (hr - hs_bt)/sin(El_mal);                   
Ls_mal = (hr - hs_mal)/sin(El_mal);

R = 42;                                             % Rain intensity (mm/h) (Zone K)
k_up       = 4.21e-5*(f_up/1e9)^2.42;               % Parameter k
k_dw       = 4.21e-5*(f_dw/1e9)^2.42;                     
alpha_up   = 1.41*(f_up/1e9)^(-0.0779);             % Parameter alpha
alpha_dw   = 1.41*(f_dw/1e9)^(-0.0779);
gamma_r_up = k_up*R^alpha_up;                       % Parameter gamma (dB/km)
gamma_r_dw = k_dw*R^alpha_dw;

L_rain_up_gc  = gamma_r_up*Ls_gc;                   % Rain Attenuations (dB)
L_rain_dw_gc  = gamma_r_dw*Ls_gc;
L_rain_up_mal = gamma_r_up*Ls_mal;
L_rain_dw_mal = gamma_r_dw*Ls_mal;
L_rain_up_bt  = gamma_r_up*Ls_bt;
L_rain_dw_bt  = gamma_r_dw*Ls_bt;

%% Free space + additional losses
% Additional losses
L_gas = 0.5;                                        % Attenuation gasses (dB)   

% Return link (Mallorca - Satellite)
lbf_mal_sat = (4*pi*d_mal/lambda_up)^2;             % Free space losses (n.u.)
Lbf_mal_sat = 10*log10(lbf_mal_sat);                % Free space losses (dB)
L_mal_sat = Lbf_mal_sat + L_gas;                    % Total losses (dB)
L_bt_sat = L_mal_sat;

% Forward link (Satellite - Mallorca)
lbf_sat_mal = (4*pi*d_mal/lambda_dw)^2;             % Basic propagation losses (n.u.)
Lbf_sat_mal = 10*log10(lbf_sat_mal);                % Basic propagation losses (dB)
L_sat_mal = Lbf_sat_mal + L_gas;                    % Total losses (dB)
L_sat_bt = L_sat_mal;

% Return link (Satellite - Ground Control)
lbf_sat_gc = (4*pi*d_gc/lambda_dw)^2;               % Basic propagation losses (n.u.)
Lbf_sat_gc = 10*log10(lbf_sat_gc);                  % Basic propagation losses (dB)
L_sat_gc = Lbf_sat_gc + L_gas;                      % Total losses (dB)

% Forward link (Grouond Control - Satellite)
lbf_gc_sat = (4*pi*d_gc/lambda_up)^2;               % Basic propagation losses (n.u.)
Lbf_gc_sat = 10*log10(lbf_gc_sat);                  % Basic propagation losses (dB)
L_gc_sat = Lbf_gc_sat + L_gas;                      % Total losses (dB)

% Rain considerations
L_mal_sat = [L_mal_sat, L_mal_sat, L_mal_sat + L_rain_up_mal];
L_sat_mal = [L_sat_mal, L_sat_mal, L_sat_mal + L_rain_dw_mal];
L_sat_bt  = [L_sat_bt,  L_sat_bt, L_sat_bt  + L_rain_dw_bt];
L_bt_sat  = [L_bt_sat,  L_bt_sat, L_bt_sat  + L_rain_up_bt];
L_sat_gc  = [L_sat_gc,  L_sat_gc  + L_rain_dw_gc, L_sat_gc];   
L_gc_sat  = [L_gc_sat,  L_gc_sat  + L_rain_up_gc, L_gc_sat];

%% C/NI forward link
% Uplink
cn_sat_up = c_n(EIRP_gc, G_T_sat, L_gc_sat, BW_fw);

% Downlink
cn_mal = c_n(EIRP_sat_fw, G_T_er, L_sat_mal, BW_fw);
cn_bt = c_n(EIRP_sat_fw, G_T_bt, L_sat_bt, BW_fw);

% C/NI total
CNI_fw_bt = c_ni_total(cn_sat_up, cn_bt, asi, c_im);
CNI_fw_mal = c_ni_total(cn_sat_up, cn_mal, asi, c_im);

%% C/NI return link
% Uplink
cn_mal_up = c_n(EIRP_er, G_T_sat, L_mal_sat, BW_rt);
cn_bt_up = c_n(EIRP_bt, G_T_sat, L_bt_sat, BW_rt);

% Downlink
cn_gc = c_n(EIRP_sat_rt, G_T_gc, L_sat_gc, BW_rt);

% C/NI total
CNI_rt_bt = c_ni_total(cn_bt_up, cn_gc, asi, c_im);
CNI_rt_mal = c_ni_total(cn_mal_up, cn_gc, asi, c_im);

%% Eb/No
Ad_deg = 1;                 % Additional degradation
Imp_mar = 1.5;              % Implementation margin

Es_No_fw_mal = EsNo(CNI_fw_mal, Ad_deg, Imp_mar);
Es_No_fw_bt  = EsNo(CNI_fw_bt, Ad_deg, Imp_mar);
Es_No_rt_mal = EsNo(CNI_rt_mal, Ad_deg, Imp_mar);
Es_No_rt_bt  = EsNo(CNI_rt_bt, Ad_deg, Imp_mar);

%% Functions
function [cn] = c_n(EIRP, G_T, L, BW)
    k = 1.38e-23;                                   % Boltzman constant (J/K)
    CN = EIRP + G_T - L - 10*log10(k*BW);
    cn = power(10, CN/10);
end
function [CNI_total] = c_ni_total(cn_up, cn_dw, asi, c_im)
    inv_cn = ((1./cn_up) + (1./cn_dw));
    cn_total = 1./inv_cn; 
    cni_total = 1./(1./cn_total+1/asi+1/c_im);
    CNI_total = 10*log10(cni_total);
end
function [Es_No] = EsNo(CNI, Ad_deg, Imp_marg)
    Es_No = CNI - Ad_deg - Imp_marg;
end
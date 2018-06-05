clear 
close all

%% Data

% Users and density
concurrency = 0.15;
% percentage5G = 0.10;
users = ;
km2 = ; %km2

users = users/km2;

% Frequency
freq5G = 26e9;  % highest band-> Our main objective is very high speed
f = freq5G;

% Bitrates
bitrateDL5G = 300e6;
bitrateUL5G = 100e6;

% Bandwidth 
BW5G = 500e6;

% MIMO
MIMO5G = 8;

% Spectral efficiency [T = R implies that C is multiplied by T]
spectralEffDL5G = 30;
spectralEffUL5G = 15;

%% Coverage
BSPower5G = 20.97; % dBm

sensitivity5G = -90; % dBm
Lmax5G = BSPower5G - sensitivity5G;
Lmax = [Lmax5G];

% A-B-G
a = 4.6; b = 0.0075; c = 12.6; 
hb = 25;                       % BS height
gamma = a - b*hb + c/hb; 
d0 = 100;                      % By default
lambda = 3e8./f;
A = 20*log10(4*pi*d0./lambda);  % Free space losses
Xf = 6*log10((f/10^6)/2000);
hr = 1.5;                      % Receiver height
Xh = -10.8*log10(hr/2000);
S = 0.65*(log10(f./(10^6))).^2 - 1.3*log10(f./(10^6)) + 5.2;

d = d0*10.^((Lmax - A - Xf - Xh - S)/(10*gamma));

fprintf('\nThe coverage of the 5G station is %f m \n',d(1));

%% Traffic
% DL
offer5G = BW5G * (spectralEffDL5G/(pi*d(1)^2/10^6));
user5G = users*bitrateDL5G*concurrency;

% UL
offer5GUL = BW5G * (spectralEffUL5G/(pi*d(1)^2/10^6));
user5GUL = users*bitrateUL5G*concurrency;


%% BS
f_sola = 0.7;
BS = ceil((km2*10^6)/(pi*d^2*f_sola))

% Usando distancia y no área (descomentar si se usa)
% distanceStreet = 720;
% BS_dist = ceil(distanceStreet/(f_sola*d))
%% Display
fprintf('\n Downlink: \n')
fprintf('\nThe 5G offer in Mallorca is %f Gb/s/km2 and the user need is %f Gb/s/km2 \n',offer5G/10^9,user5G/10^9);

fprintf('\n Uplink: \n')
fprintf('\nThe 5G offer in Mallorca is %f Gb/s/km2 and the user need is %f Gb/s/km2 \n',offer5GUL/10^9,user5GUL/10^9);

fprintf('\n');
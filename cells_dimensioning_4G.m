clear 
close all

%% Data

% Users and density
concurrency = 0.17;
users = 86459;

km2 = 11.14; %km2

usersDensity = users/km2;

% Frequency
freq4G = 0.8e9; % lowest band (enough for this speed)
f = [freq4G];

% Bitrates
bitrateDL4G = 40e6;
bitrateUL4G = 15e6;


% MIMO
MIMO4G = 4;

% Spectral efficiency [T = R implies that C is multiplied by T]
spectralEffDL4G = 30*MIMO4G;
spectralEffUL4G = 15*MIMO4G;

% Bandwidth 
BW4G = 100e6;

%% Coverage
BSPower4G = 10*log10(15000); % dBm

sensitivity4G = -90; % dBm

Lmax4G = BSPower4G - sensitivity4G;
Lmax = [Lmax4G];

% Okumura-Hata
firstCarrier = 800; % MHZ
corr = 1.3203;
d = 10^(Lmax - 69.55 - 26.16*log10(firstCarrier + BW4G/10^6) + 13.82*log10(30) + (3.2*(log10(11.75*1.5))^2 -4.97) - corr)/(44.9 - 6.55*log10(30));

% Limitation of the covergae by traffic (manual uncomment)
d = 263;

fprintf('\nThe coverage of the 4G stations is %f m\n',d(1));

%% Traffic
% DL
% Mallorca
offer4GMallorca = BW4G * (spectralEffDL4G/(pi*d(1)^2/10^6));
user4GMallorca = usersDensity*bitrateDL4G*concurrency;

% UL
% Mallorca
offer4GMallorcaUL = BW4G * (spectralEffUL4G/(pi*d(1)^2/10^6));
user4GMallorcaUL = usersDensity*bitrateUL4G*concurrency;

%% BS by coverage
BS = ceil((km2/((pi*(d)^2)*10^-6)))

%% Display
fprintf('\n Downlink: \n')
fprintf('\nThe 4G offer in Mallorca is %f Gb/s/km2 and the user need is %f Gb/s/km2 \n',offer4GMallorca/10^9,user4GMallorca/10^9);

fprintf('\n Uplink: \n')
fprintf('\nThe 4G offer in Mallorca is %f Gb/s/km2 and the user need is %f Gb/s/km2 \n',offer4GMallorcaUL/10^9,user4GMallorcaUL/10^9);
fprintf('\n');

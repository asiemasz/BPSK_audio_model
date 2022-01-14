spb = 48; %samples per bit 8 24 48 96
fSpan = 4;
FS = 48000;
FC = 16000;
FB = FS/spb;

%TRANSMITTER

%input data
data = [0;0;0;1;1;0;0;1;1;0;1;0;0;0;0;1; 1;0;0;1;0;1;0;1];
%data = [0;0;1;1;1;0;1;1];% 0; 1; 0; 0; 0; 0; 1; 1; 1; 1;0;1;0;1;0 ;1; 0; 1; 0; 1; 0;1 ;1;0;1;0;1;1;0;1;0; 1];
%DPSK modulation
modData = real(dpskmod(data, 2));
%oversample input data
y = repmat(modData, 1, spb).';
y = y(:).';

%squared root raised cosine filter
h2 = rcosdesign(0.25, fSpan, spb);

%filtering
yf = conv(y, h2); 
yf = yf((fSpan*spb/2 + 1):(fSpan*spb/2 + length(data)*spb));
%generate carrier
sine = generateWave(1, FC, pi/2, FS, length(yf));
yf_ = yf;
%mix
yf = yf.*sine;

%add some noise
yf_noise = yf + 20*generateWave(1, 3000, 0, 48000, spb*length(data)) + 100*generateWave(1, 200, 0, 48000, spb*length(data));
yf_noise = awgn(yf_noise,1);

%RECEIVER

%BP filter
yf_noise = bandpass(yf_noise, [15000 19000], 48000);

%mix with carrer
rx = yf_noise.*sine;

%matched filter
rx = conv(rx, h2); 
rx = rx((fSpan*spb/2 + 1):(fSpan*spb/2 + length(data)*spb));
rx_ = rx;

%demodulation
rx = sign(rx);

%downsample, get data
DPSK_demodulation_simple;

%calculate errors
[numErr, ber] = biterr(data,out)



spb = 48; %samples per bit 8 24 48 96
fSpan = 4;
FS = 48000;
FC = 8000;
FB = FS/spb;

%TRANSMITTER
%barker code
barker = [0; 0; 0; 1; 0];
%input data
data = [0;1;1;0;1;1;0;1];%; 1;0;1;0;0;0;0;1; 1;0;0;1;0;1;0;1];
%data = [0;1;1;0;1;0;0;1];
%BPSK modulation
modData = real(pskmod(data,2));
barkerCode = real(pskmod(barker,2));
%oversample input data
y = repmat([barkerCode; modData], 1, spb).';
y = y(:).';

%squared root raised cosine filter
h2 = rcosdesign(0.25, fSpan, spb);

%filtering
yf = conv(y, h2); 
yf = yf((fSpan*spb/2 + 1):(length(yf) - fSpan*spb/2)); correct = yf;

%generate carrier
sine = generateWave(1, FC, pi/2, FS, length(yf));
%mix
yf = yf.*sine;

%add some noise
yf_noise = awgn(yf,1);

%RECEIVER


%mix with carrer
rx = yf.*sine;

%matched filter
rx = conv(rx, h2); 
rx = rx((fSpan*spb/2 + 1):(length(rx) - fSpan*spb/2));

%demodulation
%rx = sign(rx);

%downsample, get data
demodulation_simple;

%calculate errors
[numErr, ber] = biterr(data,out)



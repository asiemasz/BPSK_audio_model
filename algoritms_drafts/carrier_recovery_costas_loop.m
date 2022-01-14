%signal = buffer_filtered(2427:2427);
signal = buffer;
%% BPSK parameters
spb = 48; %samples per bit 8 24 48 96
fSpan = 4;
FS = 48000;
FC = 8000;
FB = FS/spb;

%% Costas Loop variables
%IIR filter variables (matched filter)
B = [0.2452372752527856 0.2452372752527856];
A = [1.0 -0.5095254494944288];

phase = 0;
omega = 2*pi*FC/FS;
error = 0;

Ns = length(signal);
alpha = 0.1;
beta = alpha.^2 / 4;
errtot = 0;

%%IIR variables
pos1i = 0;
pos2i = 0;
n1i = length(B) - 1;
n2i = length(A) - 1;
buf1i = zeros(n1i);
buf2i = zeros(n2i);

pos1q = 0;
pos2q = 0;
n1q = length(B) - 1;
n2q = length(A) - 1;
buf1q = zeros(n1q);
buf2q = zeros(n2q);

for i = 1:Ns
    sample = signal(i);

    phase = phase + omega;
    phase = phase + alpha * error;

    omega = omega + beta * error;

    freq = omega * FS / (2*pi);

    if(freq < FC-500)
        freq = FC-500;
        omega = 2*pi*freq/FS;
    end

    if(freq > FS/2)
        freq = FS/2;
        omega = 2*pi*freq/FS;
    end

    if(phase > 2*pi)
        phase = phase - 2*pi;
    end

    si = cos(phase);
    sq = -sin(phase);

    sim = si * sample;
    sqm = sq * sample;

    acc = B(1) * sim;
    for j = 1:n1i
        p = mod(pos1i + n1i - j, n1i);
        acc = acc + B(j+1) * buf1i(p+1);
    end
    for j = 1:n2i
        p = mod(pos2i + n2i - j, n2i);
        acc = acc - A(j+1) * buf2i(p+1);
    end
    if n1i > 0
        buf1i(pos1i+1) = sim;
        pos1i = mod(pos1i + 1, n1i);
    end
    if n2i > 0
        buf2i(pos2i+1) = sim;
        pos2i = mod(pos2i + 1, n2i);
    end
    sim = acc;

    acc = B(1) * sqm;
    for j = 1:n1q
        p = mod(pos1q + n1q - j, n1q);
        acc = acc + B(j+1) * buf1q(p+1);
    end
    for j = 1:n2q
        p = mod(pos2q + n2q - j, n2q);
        acc = acc - A(j+1) * buf2q(p+1);
    end
    if n1q > 0
        buf1q(pos1q+1) = sqm;
        pos1q = mod(pos1q + 1, n1q);
    end
    if n2q > 0
        buf2q(pos2q+1) = sqm;
        pos2q = mod(pos2q + 1, n2q);
    end
    sqm = acc;

    error = sim * sqm;

    errtot = errtot + error;
    freq = omega * FS / (2*pi);
    a(i) = freq;
    b(i) = si;
    c(i) = phase;
end
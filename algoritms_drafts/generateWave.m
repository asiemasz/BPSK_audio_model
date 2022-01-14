function wave = generateWave(A, f, phi, fs, N)
dt = 1/fs;
t = 0:dt:(N-1)*dt;
wave = A * sin(2.*pi.*f.*t + phi);
end


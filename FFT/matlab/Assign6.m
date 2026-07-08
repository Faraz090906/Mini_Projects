clc;
clear;
close all;

%% Fixed-point parameters
FRAC = 5;
scale = 2^FRAC;
N = 8;

%% Define 4 test cases
cases = cell(4,1);

% Case 1: impulse
cases{1} = [1+0j, 0, 0, 0, 0, 0, 0, 0];

% Case 2: all ones
cases{2} = [1,1,1,1,1,1,1,1];

% Case 3: real sequence
cases{3} = [1,2,3,4,0,0,0,0];

% Case 4: complex sequence
cases{4} = [1+1j, 2-1j, -1+2j, 0.5+0.25j, 0, 0, 0, 0];

for c = 1:4
    x = cases{c};

    % Quantize to Q3.5 integers
    xr_q = round(real(x) * scale);
    xi_q = round(imag(x) * scale);

    % Clip to signed 8-bit
    xr_q = max(min(xr_q, 127), -128);
    xi_q = max(min(xi_q, 127), -128);

    % Write integer input for Verilog
    in_name = sprintf('input_case%d.txt', c);
    fid = fopen(in_name, 'w');
    for k = 1:N
        fprintf(fid, '%d %d\n', xr_q(k), xi_q(k));
    end
    fclose(fid);

    % Quantized value as actually seen by hardware
    xq = (xr_q + 1j*xi_q) / scale;

    % MATLAB FFT of quantized input
    X = fft(xq, N);

    % Save MATLAB FFT output too
    out_name = sprintf('matlab_output_case%d.txt', c);
    fid = fopen(out_name, 'w');
    for k = 1:N
        fprintf(fid, '%.12f %.12f\n', real(X(k)), imag(X(k)));
    end
    fclose(fid);

    fprintf('Generated input_case%d.txt and matlab_output_case%d.txt\n', c, c);
end
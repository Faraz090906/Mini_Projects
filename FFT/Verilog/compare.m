clc;
clear;
close all;

FRAC = 5;
scale = 2^FRAC;
N = 8;

perm = [1 5 3 7 2 6 4 8]; % bit-reversal fix for 8-point DIF

for c = 1:4
    matlab_file  = sprintf('matlab_output_case%d.txt', c);
    verilog_file = sprintf('output_case%d.txt', c);

    Xmat_data = readmatrix(matlab_file);
    Xmat = Xmat_data(:,1) + 1j*Xmat_data(:,2);

    Yver_data = readmatrix(verilog_file);

    if isempty(Yver_data)
        fprintf('Case %d: output file empty\n', c);
        continue;
    end

    Yver = (Yver_data(:,1) + 1j*Yver_data(:,2)) / scale;

    if length(Yver) < N
        fprintf('Case %d: less than 8 outputs\n', c);
        continue;
    end

    best_err = inf;
    best_y = [];
    best_mode = '';
    best_start = -1;

    for s = 1:(length(Yver)-N+1)
        yw = Yver(s:s+N-1);

        err_raw = max(abs(Xmat - yw));
        yw_re = yw(perm);
        err_re = max(abs(Xmat - yw_re));

        if err_raw < best_err
            best_err = err_raw;
            best_y = yw;
            best_mode = 'raw';
            best_start = s;
        end

        if err_re < best_err
            best_err = err_re;
            best_y = yw_re;
            best_mode = 'reordered';
            best_start = s;
        end
    end

    fprintf('\nCase %d\n', c);
    fprintf('Best start = %d\n', best_start);
    fprintf('Mode = %s\n', best_mode);
    fprintf('Max abs error = %g\n', best_err);

    % -------- Magnitude Plot --------
    figure;
    stem(0:N-1, abs(Xmat), 'filled');
    hold on;
    stem(0:N-1, abs(best_y), '--');
    grid on;
    title(sprintf('Case %d Magnitude', c));
    xlabel('k');
    ylabel('|X[k]|');
    legend('MATLAB','Verilog');

    % -------- Real + Imag in Same Figure --------
    figure;

    % Real Part
    subplot(2,1,1);
    stem(0:N-1, real(Xmat), 'filled');
    hold on;
    stem(0:N-1, real(best_y), '--');
    grid on;
    title(sprintf('Case %d Real Part', c));
    ylabel('Real');
    legend('MATLAB','Verilog');

    % Imaginary Part
    subplot(2,1,2);
    stem(0:N-1, imag(Xmat), 'filled');
    hold on;
    stem(0:N-1, imag(best_y), '--');
    grid on;
    title(sprintf('Case %d Imaginary Part', c));
    xlabel('k');
    ylabel('Imag');
    legend('MATLAB','Verilog');

end
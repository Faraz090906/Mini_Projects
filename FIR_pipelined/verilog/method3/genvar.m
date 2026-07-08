clc;
clear;
close all;

%% Parameters
fs = 1e4;
fc = 1000;
taps = 100;
scale = 2^14;
pipeline_delay = taps - 1;

%% MATLAB FIR design
b = fir1(taps-1, fc/(fs/2));

%% Read input signals
x950_q  = readmatrix('sig_950_q214.txt');
x1100_q = readmatrix('sig_1100_q214.txt');
x2000_q = readmatrix('sig_2000_q214.txt');

%% Read Verilog outputs
y950_v_q  = readmatrix('out_genvar_950_q214.txt');
y1100_v_q = readmatrix('out_genvar_1100_q214.txt');
y2000_v_q = readmatrix('out_genvar_2000_q214.txt');

%% Convert fixed point to float
x950  = double(x950_q)  / scale;
x1100 = double(x1100_q) / scale;
x2000 = double(x2000_q) / scale;

y950_v  = double(y950_v_q)  / scale;
y1100_v = double(y1100_v_q) / scale;
y2000_v = double(y2000_v_q) / scale;

%% MATLAB reference
y950_m  = filter(b, 1, x950);
y1100_m = filter(b, 1, x1100);
y2000_m = filter(b, 1, x2000);

%% Remove initial pipeline-fill outputs
y950_v  = y950_v(1 + pipeline_delay : end);
y1100_v = y1100_v(1 + pipeline_delay : end);
y2000_v = y2000_v(1 + pipeline_delay : end);

%% Match lengths
L950  = min(length(y950_m),  length(y950_v));
L1100 = min(length(y1100_m), length(y1100_v));
L2000 = min(length(y2000_m), length(y2000_v));

y950_m  = y950_m(1:L950);
y950_v  = y950_v(1:L950);

y1100_m = y1100_m(1:L1100);
y1100_v = y1100_v(1:L1100);

y2000_m = y2000_m(1:L2000);
y2000_v = y2000_v(1:L2000);

%% Time axes
t950  = (0:L950-1)/fs;
t1100 = (0:L1100-1)/fs;
t2000 = (0:L2000-1)/fs;

%% Comparison plots
figure

subplot(3,1,1)
plot(t950, y950_m, 'LineWidth', 2)
hold on
plot(t950, y950_v, '--', 'LineWidth', 1)
grid on
xlabel('Time (s)')
ylabel('Amplitude')
title('Genvar FIR: 950 Hz')
legend('MATLAB','Verilog')
xlim([0 0.05])

subplot(3,1,2)
plot(t1100, y1100_m, 'LineWidth', 2)
hold on
plot(t1100, y1100_v, '--', 'LineWidth', 1)
grid on
xlabel('Time (s)')
ylabel('Amplitude')
title('Genvar FIR: 1100 Hz')
legend('MATLAB','Verilog')
xlim([0 0.05])

subplot(3,1,3)
plot(t2000, y2000_m, 'LineWidth', 2)
hold on
plot(t2000, y2000_v, '--', 'LineWidth', 1)
grid on
xlabel('Time (s)')
ylabel('Amplitude')
title('Genvar FIR: 2000 Hz')
legend('MATLAB','Verilog')
xlim([0 0.05])

%% Error signals
e950  = y950_m  - y950_v;
e1100 = y1100_m - y1100_v;
e2000 = y2000_m - y2000_v;

%% Error plots
figure

subplot(3,1,1)
plot(t950, e950, 'LineWidth', 1.5)
grid on
xlabel('Time (s)')
ylabel('Error')
title('Error Plot: MATLAB - Verilog (950 Hz)')
xlim([0 0.05])

subplot(3,1,2)
plot(t1100, e1100, 'LineWidth', 1.5)
grid on
xlabel('Time (s)')
ylabel('Error')
title('Error Plot: MATLAB - Verilog (1100 Hz)')
xlim([0 0.05])

subplot(3,1,3)
plot(t2000, e2000, 'LineWidth', 1.5)
grid on
xlabel('Time (s)')
ylabel('Error')
title('Error Plot: MATLAB - Verilog (2000 Hz)')
xlim([0 0.05])
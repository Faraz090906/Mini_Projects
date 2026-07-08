fs = 1e4;
fc_h = 1e3;
taps = 100;
scale = 2^14;

n = taps - 1;
b = fir1(n, fc_h/(fs/2));

t = 0:1/fs:1;
sineWave1 = sin(2*pi*950*t);
sineWave2 = sin(2*pi*1100*t);
sineWave3 = sin(2*pi*2000*t);

b_q = q_point(b);
x_950 = q_point(sineWave1);
x_1100 = q_point(sineWave2);
x_2000 = q_point(sineWave3);

fid = fopen('C:\Users\pshar\OneDrive\文档\DSP\Experiment 4\matlab\coeffs_q214.txt','w');
fprintf(fid,'%d\n', b_q);
fclose(fid);

fid = fopen('C:\Users\pshar\OneDrive\文档\DSP\Experiment 4\matlab\sig_950_q214.txt','w');
fprintf(fid,'%d\n', x_950);
fclose(fid);

fid = fopen('C:\Users\pshar\OneDrive\文档\DSP\Experiment 4\matlab\sig_1100_q214.txt','w');
fprintf(fid,'%d\n', x_1100);
fclose(fid);

fid = fopen('C:\Users\pshar\OneDrive\文档\DSP\Experiment 4\matlab\sig_2000_q214.txt','w');
fprintf(fid,'%d\n', x_2000);
fclose(fid);

fid = fopen('C:\Users\pshar\OneDrive\文档\DSP\Experiment 4\verilog\coeffs_q214.txt','w');
fprintf(fid,'%d\n', b_q);
fclose(fid);

fid = fopen('C:\Users\pshar\OneDrive\文档\DSP\Experiment 4\verilog\sig_950_q214.txt','w');
fprintf(fid,'%d\n', x_950);
fclose(fid);

fid = fopen('C:\Users\pshar\OneDrive\文档\DSP\Experiment 4\verilog\sig_1100_q214.txt','w');
fprintf(fid,'%d\n', x_1100);
fclose(fid);

fid = fopen('C:\Users\pshar\OneDrive\文档\DSP\Experiment 4\verilog\sig_2000_q214.txt','w');
fprintf(fid,'%d\n', x_2000);
fclose(fid);

y950_q = fir_q(x_950, b_q, 2, 14, 2, 14, 2, 14);
y1100_q = fir_q(x_1100, b_q, 2, 14, 2, 14, 2, 14);
y2000_q = fir_q(x_2000, b_q, 2, 14, 2, 14, 2, 14);

y950 = double(y950_q) / scale;
y1100 = double(y1100_q) / scale;
y2000 = double(y2000_q) / scale;

figure

subplot(3,1,1)
plot((0:length(y950)-1)/fs, y950,'LineWidth',1.5)
grid on
xlabel('Time (s)')
ylabel('Amplitude')
title('FIR Output for 950 Hz Input')
xlim([0 0.05])

subplot(3,1,2)
plot((0:length(y1100)-1)/fs, y1100,'LineWidth',1.5)
grid on
xlabel('Time (s)')
ylabel('Amplitude')
title('FIR Output for 1100 Hz Input')
xlim([0 0.05])

subplot(3,1,3)
plot((0:length(y2000)-1)/fs, y2000,'LineWidth',1.5)
grid on
xlabel('Time (s)')
ylabel('Amplitude')
title('FIR Output for 2000 Hz Input')
xlim([0 0.05])

function x_q = q_point(x)
scale = 2^14;
x_q = int32(round(x * scale));
x_q(x_q > 32767) = 32767;
x_q(x_q < -32768) = -32768;
end

function y = fir_q(x, h, ax, bx, ah, bh, a, b)
N = length(x);
M = length(h);
y = zeros(1, N, 'int32');

for n = 1:N
    acc = int32(0);
    for k = 1:M
        if n-k+1 > 0
            p = q_mul(h(k), x(n-k+1), ah, bh, ax, bx, a, b);
            acc = q_add(acc, p, a, b, a, b, a, b);
        end
    end
    y(n) = acc;
end
end

function c = q_add(x1, x2, a1, b1, a2, b2, a, b)
a3 = max(a1,a2) + 1;
b3 = max(b1,b2);

x1 = int64(x1);
x2 = int64(x2);

if b1 < b3
    x1 = bitshift(x1, b3 - b1);
elseif b1 > b3
    x1 = bitshift(x1, -(b1 - b3));
end

if b2 < b3
    x2 = bitshift(x2, b3 - b2);
elseif b2 > b3
    x2 = bitshift(x2, -(b2 - b3));
end

t = x1 + x2;

if b3 < b
    t = bitshift(t, b - b3);
elseif b3 > b
    t = bitshift(t, -(b3 - b));
end

maxv = int64(2^(a+b-1) - 1);
minv = int64(-2^(a+b-1));

if t > maxv
    c = int32(maxv);
elseif t < minv
    c = int32(minv);
else
    c = int32(t);
end
end

function c = q_sub(x1, x2, a1, b1, a2, b2, a, b)
w = a2 + b2;
x2 = int64(x2);
x2_tc = bitcmp(x2, 'int64') + 1;
mask = bitshift(int64(1), w) - 1;
x2_tc = bitand(x2_tc, mask);
if bitget(x2_tc, w) == 1
    x2_tc = x2_tc - bitshift(int64(1), w);
end
c = q_add(x1, int32(x2_tc), a1, b1, a2, b2, a, b);
end

function c = q_mul(x1, x2, a1, b1, a2, b2, a, b)
t = int64(x1) * int64(x2);
b3 = b1 + b2;

if b3 < b
    t = bitshift(t, b - b3);
elseif b3 > b
    t = bitshift(t, -(b3 - b));
end

maxv = int64(2^(a+b-1) - 1);
minv = int64(-2^(a+b-1));

if t > maxv
    c = int32(maxv);
elseif t < minv
    c = int32(minv);
else
    c = int32(t);
end
end
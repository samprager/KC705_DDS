function plot_psd_umts_duc_mask(Fs, Nfft, Fc)

if (nargin < 3)
    Fc = 0;
end

if (nargin < 2)
    Nfft = 1024;
end

fillcolor = [0.7, 0.7, 0.9];
ff = [2.5, 2.5, 2.7, 3.5, 3.5, Fs, Fs] + Fc;
MM = [  0, -56, -56, -68, -70, -70, 0];
fill(ff, MM, fillcolor);
hold on; grid on; zoom on;
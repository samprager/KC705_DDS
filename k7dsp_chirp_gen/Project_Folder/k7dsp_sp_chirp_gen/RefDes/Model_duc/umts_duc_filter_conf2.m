function [h1, h2, h12] = umts_duc_filter_conf2(Quantize, Nfft, ShowPlots)

if (nargin<3)
    ShowPlots = 0;
end

if (nargin<2)
    Nfft = 32768;
end

Fs = 3.84;

% First Interpolation Filter - RRC
Hd = srrc;
h1 = Hd.Numerator;
H1 = 20*log10(eps + abs(fftshift(fft(h1, Nfft))));
if Quantize
    h1 = xquantize(h1, 18, 1)/2^17;
    H1 = 20*log10(eps + abs(fftshift(fft(h1, Nfft))));
end
Fs = Fs*2;

if ShowPlots
    figure
    plot(linspace(-Fs/2,Fs/2,Nfft), H1-max(H1), 'b');
    axis([0,Fs/2,-100,0])
    hold on; grid on; zoom on;
    title('Magnitude Response of RRC Filter');
    xlabel('Frequency (MHz)')
    ylabel('dB')
    plot_psd_umts_duc_mask(Fs, Nfft)
    legend('Filter Response', 'Spectral Mask');
end

% Second Interpolation Filter 
Hd = filter2_conf2;
h2 = Hd.Numerator;
H2 = 20*log10(eps + abs(fftshift(fft(h2, Nfft))));
if Quantize
    h2 = xquantize(h2, 18)/2^17;
    H2 = 20*log10(eps + abs(fftshift(fft(h2, Nfft))));
end
Fs = Fs*8;

if ShowPlots
    figure
    H11 = 20*log10(eps + abs(fftshift(fft(upsample(h1, 8), Nfft))));
    plot(linspace(-Fs/2,Fs/2,Nfft), H11-max(H11), 'g');
    hold on; grid on; zoom on;  
    plot(linspace(-Fs/2,Fs/2,Nfft), H2-max(H2), 'b');
    axis([0,Fs/2,-100,0])
    title('Magnitude Response of Second Interpolation Filter');
    xlabel('Frequency (MHz)')
    ylabel('dB')
    legend('Upsampled Input', 'Filter Response');
end

% Cascade All Filters
h12 = upfirdn(h1, h2, 8, 1);
H12 = 20*log10(eps + abs(fftshift(fft(h12, Nfft))));

if ShowPlots
    figure
    plot(linspace(-Fs/2,Fs/2,Nfft), H12-max(H12), 'b');
    axis([0,Fs/2,-100,0])
    hold on; grid on; zoom on;
    title('Overall Filter Response');
    xlabel('Frequency (MHz)')
    ylabel('dB')
    plot_psd_umts_duc_mask(Fs, Nfft)
    legend('Filter Response', 'Spectral Mask');
end


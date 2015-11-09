function [h1, h2, h3] = umts_ddc_filter_conf2(Quantize, Nfft, ShowPlots)

if (nargin<3)
    ShowPlots = 0;
end

if (nargin<2)
    Nfft = 32768;
end

Fs = 61.44;

% First Decimation Filter 
Hd = ddc_conf2_h1;
h1 = Hd.Numerator;
H1 = 20*log10(eps + abs(fftshift(fft(h1, Nfft))));
if Quantize
    h1 = xquantize(h1, 18)/2^17;
    H1 = 20*log10(eps + abs(fftshift(fft(h1, Nfft))));
end

if ShowPlots
    figure
    plot(linspace(-Fs/2,Fs/2,Nfft), H1-max(H1), 'b');
    axis([0,Fs/2,-100,0])
    hold on; grid on; zoom on;
    title('Magnitude Response of First Halfband Filter');
    xlabel('Frequency (MHz)')
    ylabel('dB')
    legend('Filter Response');
end

% Second Decimation Filter
Fs = Fs/2;
Hd = ddc_conf2_h2;
h2 = Hd.Numerator;
H2 = 20*log10(eps + abs(fftshift(fft(h2, Nfft))));
if Quantize
    h2 = xquantize(h2, 18)/2^17;
    H2 = 20*log10(eps + abs(fftshift(fft(h2, Nfft))));
end

if ShowPlots
    figure
    plot(linspace(-Fs/2,Fs/2,Nfft), H2-max(H2), 'b');
    hold on; grid on; zoom on;
    axis([0,Fs/2,-100,0])
    title('Magnitude Response of Second Halfband Filter');
    xlabel('Frequency (MHz)')
    ylabel('dB')
    legend('Filter Response');
end

% Third Decimation Filter
Fs = Fs/2;
Hd = ddc_srrc;
h3 = Hd.Numerator;
H3 = 20*log10(eps + abs(fftshift(fft(h3, Nfft))));
if Quantize
    h3 = xquantize(h3, 18)/2^17;
    H3 = 20*log10(eps + abs(fftshift(fft(h3, Nfft))));
end

if ShowPlots
    figure
    plot(linspace(-Fs/2,Fs/2,Nfft), H3-max(H3), 'b');
    hold on; grid on; zoom on;
    axis([0,Fs/2,-100,0])
    title('Magnitude Response of Third Decimation Filter (RRC)');
    xlabel('Frequency (MHz)')
    ylabel('dB')
    legend('Filter Response');
end
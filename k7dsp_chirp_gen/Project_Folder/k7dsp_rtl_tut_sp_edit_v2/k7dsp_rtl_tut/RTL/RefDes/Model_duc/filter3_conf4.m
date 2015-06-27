function Hd = filter3_conf4
%FILTER3_CONF4 Returns a discrete-time filter object.

%
% M-File generated by MATLAB(R) 7.1 and the Signal Processing Toolbox 6.4.
%
% Generated on: 09-Feb-2007 17:47:12
%

% Equiripple Lowpass filter designed using the FIRPM function.

% All frequency values are in MHz.
Fs = 61.44;  % Sampling Frequency

Fpass = 2.3424;            % Passband Frequency
Fstop = 13.0176;           % Stopband Frequency
Dpass = 0.00011512925414;  % Passband Ripple
Dstop = 0.000177827941;    % Stopband Attenuation
dens  = 16;                % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);

set(Hd, 'Arithmetic', 'double');


% [EOF]

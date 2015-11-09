function Hd = ddc_conf2_h1
%DDC_CONF2_H1 Returns a discrete-time filter object.

%
% M-File generated by MATLAB(R) 7.2 and the Signal Processing Toolbox 6.5.
%
% Generated on: 01-Mar-2007 15:28:28
%

% Equiripple Halfband lowpass filter designed using the FIRPM function.

% All frequency values are in MHz.
Fs = 61.44;  % Sampling Frequency

Fpass = 2.3424;             % Passband Frequency
Dpass = 1.1512925464e-005;  % Passband Ripple

% Calculate the coefficients using the FIRPM function.
b  = firhalfband('minorder', Fpass/(Fs/2), Dpass);
Hd = dfilt.dffir(b);



% [EOF]
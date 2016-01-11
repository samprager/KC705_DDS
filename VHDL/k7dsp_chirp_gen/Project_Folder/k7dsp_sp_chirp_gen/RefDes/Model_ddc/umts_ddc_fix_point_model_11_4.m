%*******************************************************************************
% DISCLAIMER OF LIABILITY
%
% This text/file contains proprietary, confidential
% information of Xilinx, Inc., is distributed under license
% from Xilinx, Inc., and may be used, copied and/or
% disclosed only pursuant to the terms of a valid license
% agreement with Xilinx, Inc. Xilinx hereby grants you a 
% license to use this text/file solely for design, simulation, 
% implementation and creation of design files limited 
% to Xilinx devices or technologies. Use with non-Xilinx 
% devices or technologies is expressly prohibited and 
% immediately terminates your license unless covered by
% a separate agreement.
%
% Xilinx is providing this design, code, or information 
% "as-is" solely for use in developing programs and 
% solutions for Xilinx devices, with no obligation on the 
% part of Xilinx to provide support. By providing this design, 
% code, or information as one possible implementation of 
% this feature, application or standard, Xilinx is making no 
% representation that this implementation is free from any 
% claims of infringement. You are responsible for 
% obtaining any rights you may require for your implementation. 
% Xilinx expressly disclaims any warranty whatsoever with 
% respect to the adequacy of the implementation, including 
% but not limited to any warranties or representations that this
% implementation is free from claims of infringement, implied 
% warranties of merchantability or fitness for a particular 
% purpose.
%
% Xilinx products are not intended for use in life support
% appliances, devices, or systems. Use in such applications is
% expressly prohibited.
%
% Any modifications that are made to the Source Code are 
% done at the user’s sole risk and will be unsupported.
%
%
% Copyright (c) 2007 Xilinx, Inc. All rights reserved.
%
% This copyright and support notice must be retained as part 
% of this text at all times. 
%
%*******************************************************************************

Quantize = 1;     % double (0) or quantized (1) coefficients and data 
Nfft = 1024;      % FFT size for spectral plot
ShowPlots = 0;    % Show filter impluse response plots
Config = 2;       % Configuration 1~2 (different DDC structure)
gain = 1;
coding_gain = 3.84e6/12.2e3;  % coding gain = chip rate/baseband data rate

% DDC input generation
% uncomment the line if need to perform different tests

%Input generated from corresponding DUC MATLAB model of XAPP1018
%[ddc_in, duc_ref, h_duc] = umts_ddc_input(Fc);  gain = 1;

% Take input to the DDC directly from DUC I/F output of System Generator 'To Workspace' blocks
ddc_in = IQ_if;

% Adjacent channel selectivity and blocking test input
%[ddc_in, duc_ref, h_duc] = acs_test_input(Fc);  gain = 16;

% Intermodulation input
%[ddc_in, duc_ref, h_duc] = intermodulation_input(Fc);  gain = 16;

% Sinusoids test input
%ddc_in = sum_sinusoids_test_input;  gain = 0.5;

% Constructors for quantizer object
qin = quantizer('fixed', 'wrap', 'round', [16 15]);
q1 = quantizer('fixed', 'wrap', 'round', [17 15]);
q2 = quantizer('fixed', 'wrap', 'round', [18 15]); 
q3 = quantizer('fixed', 'wrap', 'round', [18 14]); 
q4 = quantizer('fixed', 'wrap', 'round', [16 12]);

% Quantize input to 14 bits
u0_q = xquantize(ddc_in, 14)/2^13;

% % Normalize and quantize the carrier frequency to 28 bits
% w = 2*pi*round(Fc/Fs*2^28)/2^28;

% Complex Mixing Stage, quantize to 16.15
DDC_y0 = u0_q .* exp(-j*w*[1:length(u0_q)]');  
DDC_y0 = quantize(qin, y0);

% Filter Coefficients and Decimation filtering
% There are a total of 2 configurations for evaluation and simulation
% The implementation is using configuration 2
if Config == 1
    [h1_ddc, h2_ddc] = umts_ddc_filter_conf1(Quantize, Nfft, ShowPlots);   
    % First stage of filtering, output quantized to 18.15
    DDC_y1 = upfirdn(DDC_y0, h1_ddc, 1, 4);  DDC_y1 = quantize(q2, DDC_y1);
    % Second stage of filtering, output quantized to 18.14
    DDC_y2 = upfirdn(DDC_y1, h2_ddc, 1, 2);  DDC_y2 = quantize(q3, DDC_y2);
    % Output gain control, quantize to 16.12 
    x = gain*DDC_y2;  x = quantize(q4, x);
elseif Config == 2
    [h1_ddc, h2_ddc, h3_ddc] = umts_ddc_filter_conf2(Quantize, Nfft, ShowPlots);
    % First stage of filtering, output quantized to 17.15
    DDC_y1 = upfirdn(DDC_y0, h1_ddc, 1, 2);  DDC_y1 = quantize(q1, DDC_y1);
    % Second stage of filtering, output quantized to 18.15
    DDC_y2 = upfirdn(DDC_y1, h2_ddc, 1, 2);  DDC_y2 = quantize(q2, DDC_y2);
    % Third stage of filtering, output quantized to 18.14
    DDC_y3 = upfirdn(DDC_y2, h3_ddc, 1, 2);  DDC_y3 = quantize(q3, DDC_y3);
    % Output gain control, quantize to 16.12
    x = gain*DDC_y3;  x = quantize(q4, x);
end

% Plot the PSD and calculate the performance metrics
% only if it hasn't been calculated already
% if (~exist('sim_performance', 'var') | sim_performance == 1)
%     ddc_performance_metrics;
% end

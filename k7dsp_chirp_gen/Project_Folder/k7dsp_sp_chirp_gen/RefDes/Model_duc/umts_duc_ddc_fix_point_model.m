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

close all
Quantize = 1;     % double (0) or quantized (1) coefficients and data 
Nfft = 8192;      % FFT size for spectral plot
ShowPlots = 0;    % Show filter impluse response plots
Config = 1;       % Configuration 1~4 (different DUC structure)

% Sampling Frequency
Fs = 61.44;
% Carrier Frequency
Fc = 12;

test_mode = 0;    % select input stimulus

if (test_mode == 1) 
    u0 = zeros(1,1000); %Impulse stimulus into system ... simulation time should be set to 200
    u0(1) = 0.5;
elseif (test_mode == 2)
    u0 = zeros(1,1000) + sqrt(-1)*zeros(1,1000); %Impulse stimulus into system ... simulation time should be set to 200
    u0(1) = 0.5 + sqrt(-1)*0.5;
else
    % Generate floating point input based on Test Model 1 from 3GPP standard
    % Run the model to generate input data if doesn't exist
    if ~exist('tm1.mat', 'file')
        u0 = wcdma_input_tm1;
        u0 = u0/abs(max(u0));
        save tm1 u0;
    else
        load tm1;
    end
end

% Normalize and quantize the carrier frequency to 28 bits
w = 2*pi*round(Fc/Fs*2^28)/2^28;
   
% Constructors for quantizer object
qin = quantizer('fixed', 'saturate', 'round', [16 15]);
q1 = quantizer('fixed', 'wrap', 'round', [16 15]); 
q2 = quantizer('fixed', 'wrap', 'round', [17 16]); 
q3 = quantizer('fixed', 'wrap', 'round', [18 17]); 

% Quantize input to 16 bits
u0_q = quantize(qin, u0);

% Filter Coefficients and Interpolation filtering
% There are a total of 4 configurations for evaluation and simulation
% The implementation is using configuration 1
if Config == 1
    [h1_duc, h2_duc, h3_duc, h4_duc, h_duc] = umts_duc_filter_conf1(Quantize, Nfft, ShowPlots);
    % first stage of filtering, output quantized to 16.15
    y1 = upfirdn(u0_q, h1_duc, 2, 1);  y1 = quantize(q1, y1); 
    % second stage of filtering, output quantized to 17.16
    y2 = upfirdn(y1, h2_duc, 2, 1);    y2 = quantize(q2, y2); 
    % third stage of filtering, output quantized to 17.16
    y3 = upfirdn(y2, h3_duc, 2, 1);    y3 = quantize(q2, y3); 
    % final stage of filtering, output quantized to 18.17
    y = upfirdn(y3, h4_duc, 2, 1);     y = quantize(q3, y);
elseif Config == 2
    [h1_duc, h2_duc, h_duc] = umts_duc_filter_conf2(Quantize, Nfft, ShowPlots);
    % first stage of filtering, output quantized to 17.16
    y1 = upfirdn(u0_q, h1_duc, 2, 1);  y1 = quantize(q2, y1);
    % final stage of filtering, output quantized to 18.17
    y = upfirdn(y1, h2_duc, 8, 1);     y = quantize(q3, y);
elseif Config == 3
    [h1_duc, h2_duc, h3_duc, h_duc] = umts_duc_filter_conf3(Quantize, Nfft, ShowPlots);
    % first stage of filtering, output quantized to 16.15
    y1 = upfirdn(u0_q, h1_duc, 2, 1);  y1 = quantize(q1, y1);
    % second stage of filtering, output quantized to 17.16
    y2 = upfirdn(y1, h2_duc, 4, 1);    y2 = quantize(q2, y2);
    % final stage of filtering, output quantized to 18.17
    y = upfirdn(y2, h3_duc, 2, 1);     y = quantize(q3, y);
else
    [h1_duc, h2_duc, h3_duc, h_duc] = umts_duc_filter_conf4(Quantize, Nfft, ShowPlots);
    % first stage of filtering, output quantized to 16.15
    y1 = upfirdn(u0_q, h1_duc, 2, 1);  y1 = quantize(q1, y1);
    % second stage of filtering, output quantized to 17.16
    y2 = upfirdn(y1, h2_duc, 2, 1);    y2 = quantize(q2, y2);
    % final stage of filtering, output quantized to 18.17
    y = upfirdn(y2, h3_duc, 4, 1);     y = quantize(q3, y);
end

% Complex Mixing Stage in DUC, quantize to 16.15
yout = y .* exp(j*w*[0:length(y)-1]);  
yout = quantize(q1, yout);

% Complex Mixing Stage in DDC, quantize to 16.15
y0 = yout .* exp(-j*w*[1:length(yout)]);  
y0 = quantize(qin, y0);

% Plot the PSD and calculate the performance metrics
% only if it hasn't been calculated already
if (~exist('sim_performance', 'var') | sim_performance == 1)
    duc_performance_metrics;
end    

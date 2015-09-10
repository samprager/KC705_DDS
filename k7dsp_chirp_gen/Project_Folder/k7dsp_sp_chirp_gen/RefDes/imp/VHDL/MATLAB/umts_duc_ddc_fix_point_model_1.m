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
% Copyright (c) 2010 Xilinx, Inc. All rights reserved.
%
% This copyright and support notice must be retained as part 
% of this text at all times. 
%
%**************************************************************************
% Company: 	Avnet
% Engineer:	Luc Langlois
% Date: Jan 26, 2010
%
% This MATLAB model is for validation of DUC / DDC reference design for
% Xilinx Virtex-6 FPGA DSP Kit.
% This design is based on the Digital Up Converter and Digital Down Converter documented in 
% Xilinx Appnote XAPP1018 'Designing Efficient Wireless Digital Up and Down Converters Leveraging Core Generator and System Generator'
%
% The DUC / DDC design has been designed to support the WDCMA standard. The chip rate for WDCMA is 3.84 Mcps (Mega Chips per Second).  
% An IF sample rate of 30.72 Msps has been selected for this design. To allow the user to mix to a higher IF and to increase sampling 
% rate further to relax requirements on the post-DAC analog filters, 2x30.72 Msps is selected as the IF sampling rate.
%
% Consequently, the input data to the DUC has a sample period of 16 simulation ticks / sample, 
% while the output data from the DDC has a sample period of 8 simulation ticks / sample.
%
% *************** MATLAB Model of UMTS DUC ********************************

close all
Quantize = 1;     % double (0) or quantized (1) coefficients and data 
Nfft = 8192;      % FFT size for spectral plot
ShowPlots = 0;    % Show filter impluse response plots
Config = 1;       % Configuration 1~4 (different DUC structure)

% Sampling Frequency
% Fs = 61.44;
Fs = 4*61.44;
% Carrier Frequency
Fc = 12;

% add the path that includes simulation scripts and sub-functions
addpath ../../../model_duc

if (exist('load_IQ_data') && (load_IQ_data == true))
    % Generate floating point input based on Test Model 1 from 3GPP standard ... simulation time should be set between 2000 and 38400
    % Run the model to generate input data if doesn't exist
    if ~exist('tm1.mat', 'file')
        u0 = wcdma_input_tm1;
        u0 = u0/abs(max(u0));
        save tm1 u0;
    else
        load tm1;
    end
else
    u0 = zeros(1,1000); %Impulse stimulus into system ... simulation time should be set to 200
    u0(1) = 0.5;
end

% Constructors for phase quantizer object
phase_q = quantizer('fixed', 'saturate', 'round', [16 15]);

% Normalize and quantize the carrier frequency to 30 bits
w = 2*pi*round(Fc/Fs*2^30)/2^30;
w = 2*pi*round(Fc/Fs*2^16)/2^16;
% w = quantize(phase_q,w);
   
% Constructors for quantizer object
ddc_qin = quantizer('fixed', 'saturate', 'round', [16 15]);
ddc_q1 = quantizer('fixed', 'wrap', 'round', [16 15]); 
ddc_q2 = quantizer('fixed', 'wrap', 'round', [17 16]); 
ddc_q3 = quantizer('fixed', 'wrap', 'round', [18 17]);

% Quantize input to 16 bits
u0_q = quantize(ddc_qin, u0);

% Filter Coefficients and Interpolation filtering
% There are a total of 4 configurations for evaluation and simulation
% The implementation is using configuration 1
if Config == 1
    [duc_srrc, duc_imf1, duc_imf2, duc_imf3, h_duc] = umts_duc_filter_conf1(Quantize, Nfft, ShowPlots);
    % first stage of filtering, output quantized to 16.15
    h1_duc = duc_srrc;
    h2_duc = duc_imf1;
    h3_duc = duc_imf2;
    h4_duc = duc_imf3;
    
    y_duc_srrc = upfirdn(u0_q, duc_srrc, 2, 1);  y_duc_srrc = quantize(ddc_q1, y_duc_srrc); 
    % second stage of filtering, output quantized to 17.16
    y_duc_imf1 = upfirdn(y_duc_srrc, duc_imf1, 2, 1);    y_duc_imf1 = quantize(ddc_q2, y_duc_imf1); 
    % third stage of filtering, output quantized to 17.16
    y_duc_imf2 = upfirdn(y_duc_imf1, duc_imf2, 2, 1);    y_duc_imf2 = quantize(ddc_q2, y_duc_imf2); 
    % final stage of filtering, output quantized to 18.17
    y_duc_imf3 = upfirdn(y_duc_imf2, duc_imf3, 2, 1);     y_duc_imf3 = quantize(ddc_q3, y_duc_imf3);
elseif Config == 2
    [duc_srrc, duc_imf1, h_duc] = umts_duc_filter_conf2(Quantize, Nfft, ShowPlots);
    % first stage of filtering, output quantized to 17.16
    y_duc_srrc = upfirdn(u0_q, duc_srrc, 2, 1);  y_duc_srrc = quantize(ddc_q2, y_duc_srrc);
    % final stage of filtering, output quantized to 18.17
    y_duc_imf3 = upfirdn(y_duc_srrc, duc_imf1, 8, 1);     y_duc_imf3 = quantize(ddc_q3, y_duc_imf3);
elseif Config == 3
    [duc_srrc, duc_imf1, duc_imf2, h_duc] = umts_duc_filter_conf3(Quantize, Nfft, ShowPlots);
    % first stage of filtering, output quantized to 16.15
    y_duc_srrc = upfirdn(u0_q, duc_srrc, 2, 1);  y_duc_srrc = quantize(ddc_q1, y_duc_srrc);
    % second stage of filtering, output quantized to 17.16
    y_duc_imf1 = upfirdn(y_duc_srrc, duc_imf1, 4, 1);    y_duc_imf1 = quantize(ddc_q2, y_duc_imf1);
    % final stage of filtering, output quantized to 18.17
    y_duc_imf3 = upfirdn(y_duc_imf1, duc_imf2, 2, 1);     y_duc_imf3 = quantize(ddc_q3, y_duc_imf3);
else
    [duc_srrc, duc_imf1, duc_imf2, h_duc] = umts_duc_filter_conf4(Quantize, Nfft, ShowPlots);
    % first stage of filtering, output quantized to 16.15
    y_duc_srrc = upfirdn(u0_q, duc_srrc, 2, 1);  y_duc_srrc = quantize(ddc_q1, y_duc_srrc);
    % second stage of filtering, output quantized to 17.16
    y_duc_imf1 = upfirdn(y_duc_srrc, duc_imf1, 2, 1);    y_duc_imf1 = quantize(ddc_q2, y_duc_imf1);
    % final stage of filtering, output quantized to 18.17
    y_duc_imf3 = upfirdn(y_duc_imf1, duc_imf2, 4, 1);     y_duc_imf3 = quantize(ddc_q3, y_duc_imf3);
end

duc_bb = y_duc_imf3;

% Make MATLAB_duc_IQ_if = DUC I/F (Intermediate Frequency) output
% Complex Mixing Stage in DUC, quantize to 16.15
MATLAB_duc_IQ_if = duc_bb .* exp(j*w*[0:length(duc_bb)-1]);  
MATLAB_duc_IQ_if = quantize(ddc_q1, MATLAB_duc_IQ_if);


% *************** MATLAB Model of UMTS DDC ********************************

Nfft = 1024;      % FFT size for spectral plot
Config = 2;       % Configuration 1~2 (different DDC structure)
gain = 1;
coding_gain = 3.84e6/12.2e3;  % coding gain = chip rate/baseband data rate

% Take input to the DDC directly from DUC I/F output
ddc_in = MATLAB_duc_IQ_if;

% Constructors for quantizer object
% duc_qin = quantizer('fixed', 'wrap', 'round', [16 15]);
duc_qin = quantizer('fixed', 'wrap', 'round', [18 17]);
duc_q1 = quantizer('fixed', 'wrap', 'round', [18 16]);
duc_q2 = quantizer('fixed', 'wrap', 'round', [18 15]); 
duc_q3 = quantizer('fixed', 'wrap', 'round', [18 14]); 
duc_q4 = quantizer('fixed', 'wrap', 'round', [16 12]);

% Complex Mixing Stage, quantize to 16.15
ddc_bb = ddc_in .* exp(-j*w*[0:length(ddc_in) - 1]);  
ddc_bb = quantize(duc_qin, ddc_bb);

% add the path that includes simulation scripts and sub-functions
addpath ../../../model_ddc

% Filter Coefficients and Decimation filtering
% There are a total of 2 configurations for evaluation and simulation
% The implementation is using configuration 2
if Config == 1
    [ddc_imf2, ddc_imf1] = umts_ddc_filter_conf1(Quantize, Nfft, ShowPlots);   
    % First stage of filtering, output quantized to 18.15
    y_ddc_imf2 = upfirdn(ddc_bb, ddc_imf2, 1, 4);  y_ddc_imf2 = quantize(duc_q2, y_ddc_imf2);
    % Second stage of filtering, output quantized to 18.14
    y_ddc_imf1 = upfirdn(y_ddc_imf2, ddc_imf1, 1, 2);  y_ddc_imf1 = quantize(duc_q3, y_ddc_imf1);
    % Output gain control, quantize to 16.12 
    MATLAB_ddc_IQ_bb_out = gain*y_ddc_imf1;  MATLAB_ddc_IQ_bb_out = quantize(duc_q4, MATLAB_ddc_IQ_bb_out);
elseif Config == 2
    [ddc_imf2, ddc_imf1, ddc_srrc] = umts_ddc_filter_conf2(Quantize, Nfft, ShowPlots);
    h1_ddc = ddc_imf2;
    h2_ddc = ddc_imf1;
    h3_ddc = ddc_srrc;
    % First stage of filtering, output quantized to 18.16
    y_ddc_imf2 = upfirdn(ddc_bb, ddc_imf2, 1, 2);  y_ddc_imf2 = quantize(duc_q1, y_ddc_imf2);
    % Second stage of filtering, output quantized to 18.15
    y_ddc_imf1 = upfirdn([(0 + j*0) y_ddc_imf2], ddc_imf1, 1, 2);  y_ddc_imf1 = quantize(duc_q2, y_ddc_imf1);   % [(0 + j*0) y_ddc_imf2] drives odd phase into halfband decimator for symmetrical response
                                                                                                            % This matches behavior of FIR Compiler halfband decimator in cascade
    % Third stage of filtering, output quantized to 18.14
    y_ddc_srrc = upfirdn(y_ddc_imf1, ddc_srrc, 1, 2);  y_ddc_srrc = quantize(duc_q3, y_ddc_srrc);
    % Output gain control, quantize to 16.12
    MATLAB_ddc_IQ_bb_out = gain*y_ddc_srrc;  MATLAB_ddc_IQ_bb_out = quantize(duc_q4, MATLAB_ddc_IQ_bb_out);
end

% MATLAB_ddc_IQ_bb_out = DDC baseband complex output

% % remove the path that includes simulation scripts and sub-functions
rmpath ../../../model_duc
rmpath ../../../model_ddc

% Display MATLAB model values in integer format to match bitwidths of ISIM simulation at various nodes in the signal chain
% Display from start up to a few samples beyond summit of impulse response
results = [2^17*duc_bb(1:250)' 2^17*quantize(duc_q3,cos(w*[0:249])') 2^17*quantize(duc_q3,sin(w*[0:249])') 2^(34-19)*real(MATLAB_duc_IQ_if(1:250))' 2^(34-19)*imag(MATLAB_duc_IQ_if(1:250))' 2^17*real(ddc_bb(1:250))' 2^17*imag(ddc_bb(1:250))' 2^16*real(y_ddc_imf2(1:250))' 2^15*real(y_ddc_imf1(1:250))' 2^12*real(MATLAB_ddc_IQ_bb_out(1:250))'];
title1 = 'DUC Interpolation FIR       cos(wn)   sin(wn)         DUC Mixer  DUC Mixer  DDC Mixer  DDC Mixer  DDC halfband 1  DDC halfband 2  DDC SRRC';
title2 = 'I Output                                              I Output   Q Output   I Output   Q Output   I Output        I Output        I Output';
title3 = 'Quantization 18 bits                                  16 bits    16 bits    18 bits    18 bits    18 bits         18 bits         16 bits';

fid = fopen('matlab_duc_ddc.txt','w');
fprintf(fid, '%s\r\n', title1);  
fprintf(fid, '%s\r\n', title2);  
fprintf(fid, '%s\r\n', title3);
fprintf(fid, '%s\r\n', '');

for row = 1:250
    fprintf(fid, '%5d %27d %10d %10d %10d %10d %10d %10d %15d %15d\r\n', results(row,1), results(row,2), results(row,3), results(row,4), results(row,5), results(row,6), results(row,7), results(row,8), results(row,9), results(row,10));
end

fclose(fid);

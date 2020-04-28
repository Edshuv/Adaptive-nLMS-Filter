% Copyright 2020 by Eduard Shuvaev. All rights reserved.

function recieved_signal = noise_nlms (noise_signal, RIR, level, shift, L, recieved_excitation_signal) 

% noise signal = music, speech, random noise
% RIR = room impulse response 
% level = level of the noise signal 
% shift = if needed than shifted sample of the noise signal to retrive 
%         the noticible noise
% L = length of the noise
% white_noise_signal = signal 

% part d - add audio noise 
[noise,Fs_noise] = audioread(noise_signal);
p = shift + L-1;
noise = noise(shift:p,1);

% part e - convolution x_new with a new room 
[y_RIR,Fs_RIR] = audioread(RIR); % read the sound with Fs=96000
y_RIR = resample (y_RIR,32000,96000); % resample to 32KHz
y_RIR_noise = conv(y_RIR,noise) * level;
% plot([white_noise_signal,y_RIR_noise]);
% legend('white_noise_signal','RIR_noise')
% part f - add res_noise and extsig
recieved_signal = recieved_excitation_signal + y_RIR_noise;

end
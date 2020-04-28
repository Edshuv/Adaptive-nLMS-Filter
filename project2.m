%% Copyright 2020 by Eduard Shuvaev. All rights reserved.

clear all, clc

%% Part 1 (generate learned impulse response)
% the examples of RIR was taken from 
% http://isophonics.net/content/room-impulse-response-data-set

%% step 1
% part a
[RIR00,Fs] = audioread('00x00y.wav'); % read the sound with Fs=96000
RIR00 = resample (RIR00,32000,96000); % resample to 32KHz

% part b - generate white noise with length 64000
L = 64000;
noise=randn(L,1);

% part c - convolution 
excitation_signal = conv(RIR00,noise);
% sound(extsig);

% part d - add audio noise 
[music,Fs2] = audioread('music.mp3');
p = 60000 + L;
coef = 1;
music = music(60001:p,1) * coef;

% part e - convolution x_new with a new room 
[y10,Fs3] = audioread('00x10y.wav'); % read the sound with Fs=96000
y10_res = resample (y10,32000,96000); % resample to 32KHz
y10_noise = conv(y10_res,music);

% part f - add res_noise and extsig
recieved_signal = excitation_signal + y10_noise;

%% Step 2
% use sign(recieved audio signal) - 1.f and extsig (recieved excitation signal) - 1.c
% apply NLMS filter
K = 64000; % length of the filter
step = 0.5; % step size
[e_nlms,w_nlms,y_nlms] = nlms_Ed (recieved_signal,noise,step,K);


%% Step 3

%% Speech Noise
% noise generation 
SNR_3 = zeros(length(0:3:21),1);
error_3 = zeros(length(0:3:21),1);
nn = 1;
for level_2 = 0:3:21
shift_2 = 1;
L = 64000;
recieved_signal_2 = noise_nlms('speech.wav','00x10y.wav',level_2, shift_2, L,excitation_signal);
K = 64000; % length of the filter
step = 0.5; % step size
[e_nlms_2,w_nlms_2,y_nlms_2] = nlms_Ed (recieved_signal_2,excitation_signal,step,K);
% sound(y_nlms_2, 32000);
% sound(w_nlms_2, 32000);
SNR_3(nn,1) = snr(excitation_signal,recieved_signal_2);
error_3(nn,1) = mean(e_nlms_2);
nn = nn+1;
end

%% Speech / Music Noise

% noise generation 
shag = 0.2;
posled = 1; 
SNR_4 = zeros(length(0:shag:posled),1);
mse_4 = zeros(length(0:shag:posled),1);
mse_400 = zeros(length(0:shag:posled),1);
mse__one_third = zeros(length(0:shag:posled),1);

nn4 = 1;
for level_3 = 0:shag:posled
% for speech shift_3 = 1;
% for music shift_3 = 60000;
shift_3 = 1;
L = 64000;
% for speech name file = 'speech.wav';
% for music name file  = 'music.mp3';
recieved_signal_3 = noise_nlms('speech.wav','00x10y.wav',level_3, shift_3, L, excitation_signal);
K = 64000; % length of the filter
step = 0.5; % step size
[e_nlms_3,w_nlms_3,y_nlms_3] = nlms_Ed (recieved_signal_3,excitation_signal,step,K);
% signal to noise ratio
SNR_4(nn4,1) = snr(excitation_signal,recieved_signal_3);
% MSE of whole signal
w4 = w_nlms_3(3:end);
exsig4 = RIR00(3:end);
mse_4(nn4,1) = (norm(exsig4 - w4)^2)/(norm(exsig4)^2);
% MSE of the first 400 samples
w400 = w_nlms_3(3:400);
exsig400 = RIR00(3:400);
mse_400(nn4,1) = (norm(exsig400 - w400)^2)/(norm(exsig400)^2);
% MSE of the last 1/3 samples
two_third = round(length(RIR00)*2/3);
w_one_third = w_nlms_3(two_third:end);
exsig_one_third = RIR00(two_third:end);
mse__one_third(nn4,1) = (norm(exsig_one_third - w_one_third)^2)/(norm(exsig_one_third)^2);
nn4 = nn4+1;
end
%plot([0:shag:posled],SNR_4)
%plot([0:shag:posled],error_4)

%% clean version generation 
level_C = 1;
recieved_signal_clean = excitation_signal * level_C;
K = 64000; % length of the filter
step = 0.5; % step size
[e_nlms_C,w_nlms_C,y_nlms_C] = nlms_Ed (recieved_signal_clean,excitation_signal,step,K);
SNR_C = snr(excitation_signal,recieved_signal_clean);
wC = w_nlms_C(1:end);
exsig4 = RIR00(1:end);
mse_C = (norm(exsig4 - wC)^2)/(norm(exsig4)^2);
wC400 = w_nlms_C(1:400);
exsig400 = RIR00(1:400);
mseC_400 = (norm(exsig400 - wC400)^2)/(norm(exsig400)^2);
two_third_C = round(length(RIR00)*2/3);
wC_one_third = w_nlms_C(two_third_C:end);
exsig_one_third = RIR00(two_third:end);
mseC__one_third = (norm(exsig_one_third - wC_one_third)^2)/(norm(exsig_one_third)^2);

%% Part 2 (estimation of the delay between speaker and microphone)

% the sound with different type and level background noise was used below
arrayLoad = ["carpetroom_music0.mat", "carpetroom_music1.mat", "carpetroom_music2.mat",...
              "carpetroom_music3.mat","carpetroom_quiet.mat","tileroom_music0.mat",...
              "tileroom_music1.mat","tileroom_music2.mat","tileroom_quiet.mat",...
              "woodfloor_medium_music0.mat","woodfloor_medium_music1.mat",...
              "woodfloor_medium_music2.mat","woodfloor_medium_music3.mat",...
              "woodfloor_medium_quiet.mat"];
arraySave = ["carpetroom_music0_ED.mat", "carpetroom_music1_ED.mat", "carpetroom_music2_ED.mat",...
              "carpetroom_music3_ED.mat","carpetroom_quiet_ED.mat","tileroom_music0_ED.mat",...
              "tileroom_music1_ED.mat","tileroom_music2_ED.mat","tileroom_quiet_ED.mat",...
              "woodfloor_medium_music0_ED.mat","woodfloor_medium_music1_ED.mat",...
              "woodfloor_medium_music2_ED.mat","woodfloor_medium_music3_ED.mat",...
              "woodfloor_medium_quiet_ED.mat"];
for ss = 6  %length(arrayLoad)
s_m = load(arrayLoad(ss));
sound_my = s_m.y;
sound_mx = s_m.x;

% find delay using correlation function
[correlation, lag] = xcorr(sound_my,sound_mx); % return correlation and lag
% lets find index of the max value of the correlation 
[~, m] = max(correlation);
% lets find value of delay corresponding to lag index (m)
delay_m0 = lag(m);

s_mx = [zeros(delay_m0,1); sound_mx];
s_my = [sound_my; zeros(delay_m0,1)];

K = 337294; % length of the filter
step = 0.5; % step size
[e_nlms_Room,w_nlms_Room,y_nlms_Room] = nlms_Ed (s_my,s_mx,step,K);


% save(arraySave(ss),'w_nlms_Room');

end

%%  Plots 


for qq = 1:4
    poradok = 11;
    subplot (4,1,qq);
    pl = load (arraySave(poradok));
    plot(pl.w_nlms_Room);
    ylabel('Amplitude');
    xlabel('Samples');
    title (arraySave(poradok));
    poradok = poradok + 1;
end








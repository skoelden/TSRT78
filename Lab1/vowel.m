%% Init
close all; clear all; clc;
load('vowel.mat');

aaa = aaa([fSamp*2:fSamp*4]);
ooo = ooo([fSamp*3:fSamp*5]);

aaaest = aaa(1:floor(2*end/3));
aaaval = aaa(ceil(2*end/3:end));

oooest = ooo(1:floor(2*end/3));
oooval = ooo(ceil(2*end/3:end));

%% Estimate model order
maxModelOrder = 30;
modAloss = zeros(maxModelOrder,1);
modOloss = zeros(maxModelOrder,1);

for(modelOrder = [1:maxModelOrder])
    modA = ar(aaaest, modelOrder);
    modO = ar(oooest, modelOrder);
    
    modAloss(modelOrder) = mean(resid(modA, aaaval).^2);
    modOloss(modelOrder) = mean(resid(modO, oooval).^2);
end

figure(1)
clf
hold on
plot(modAloss)
plot(modOloss)
title('Estimation of suitable model order')
xlabel('Model order')
ylabel('Loss function')
legend('A', 'O')
hold off

%% Find frequency of pulse train
AAA = fft(aaa);
OOO = fft(ooo);
freq = fSamp*[0:1/(length(aaa)-1):0.2];

figure(2)
clf
hold on
plot(freq, abs(AAA(1:length(freq))))
plot(freq, abs(OOO(1:length(freq))))
title('DFT of signals')
xlabel('Frequency (Hz)')
legend('A', 'O')
hold off

%% Validate estimates
aaaEst = aaa(1:floor(2*end/3));
aaaVal = aaa(ceil(2*end/3):end);
oooEst = ooo(1:floor(2*end/3));
oooVal = ooo(ceil(2*end/3):end);

aFreq = 114; % From previous section
oFreq = 162;
 
Ainput = zeros(2*fSamp,1);
Ainput(1:floor(fSamp/aFreq):end) = 1;

Oinput = zeros(2*fSamp,1);
Oinput(1:floor(fSamp/oFreq):end) = 1;

orderA = [5, 12, 40];
orderB = [5, 12, 18];

figure(3)
clf
h1 = spectrumplot(etfe(iddata(aaa,[],1/fSamp), 100), '--')
figure(4)
h2 = spectrumplot(etfe(iddata(ooo,[],1/fSamp), 100), '--')
for i=1:length(orderA)
    ma = ar(aaaEst, orderA(i));
    ma.Ts = 1/fSamp;
    mo = ar(oooEst, orderB(i));
    mo.Ts = 1/fSamp;
    figure(3)
    hold on
    spectrum(ma);
    hold off
    figure(4)
    hold on
    spectrum(mo);
    hold off

end
figure(3)
hold on
title('Power spectrum of A')
legend('Non-parametric estimate', '5', '12', '16', 'Location', 'SouthWest')
hold off

figure(4)
hold on
title('Power spectrum of O')
legend('Non-parametric estimate', '5', '12', '18', 'Location', 'SouthWest')
hold off

setoptions(h1,'FreqUnits','Hz','FreqScale','log','Xlim',{[10 4000]},'MagUnits','db');
setoptions(h2,'FreqUnits','Hz','FreqScale','log','Xlim',{[10 4000]},'MagUnits','db');


%% Simulate AR models
aFreq = 114;
oFreq = 162;

modA = ar(aaaEst, 12);
modA18 = ar(aaaEst, 18);
modO = ar(oooEst , 5);
modO18 = ar(oooEst , 18);

Ainput = zeros(2*fSamp,1);
Ainput(1:floor(fSamp/aFreq):end) = 1;

Oinput = zeros(2*fSamp,1);
Oinput(1:floor(fSamp/oFreq):end) = 1;

aaasim = sim(modA, Ainput);
aaasim16 = sim(modA18, Ainput);
ooosim = sim(modO, Oinput);
ooosim18 = sim(modO18, Oinput);

%%
AAA = fft(aaa);
OOO = fft(ooo);

figure(5)
clf
hold on
plot(fSamp*[0:1/(length(aaa)-1):1/4], abs(AAA(1:4001)))
AAASIM = fft(aaasim);
AAASIM16 = fft(aaasim16);
plot(fSamp*[0:1/(length(aaasim)-1):1/4], abs(AAASIM(1:4000)), 'LineWidth', 5)
plot(fSamp*[0:1/(length(aaasim)-1):1/4], abs(AAASIM16(1:4000)), 'LineWidth', 2)
title('Power spectrum of A and the AR-models')
xlabel('Frequency (Hz)')
legend('Non-parametric estimate', 'AR(5)', 'AR(16)')
hold off

figure(6)
clf
hold on
plot(fSamp*[0:1/(length(ooo)-1):1/8], abs(OOO(1:2001)))
OOOSIM = fft(ooosim);
OOOSIM18 = fft(ooosim18);
plot(fSamp*[0:1/(length(ooosim)-1):1/8], abs(OOOSIM(1:2000)), 'LineWidth', 5)
plot(fSamp*[0:1/(length(ooosim)-1):1/8], abs(OOOSIM18(1:2000)), 'LineWidth', 2)
title('Power spectrum of O and the AR-models')
xlabel('Frequency (Hz)')
legend('Non-parametric estimate', 'AR(8)', 'AR(18)')
hold off

%% Play sounds
sound(30*aaasim, fSamp)
pause(2.5);
%%
sound(30*aaasim16, fSamp)
pause(2.5)
%%
sound(30*ooosim, fSamp)
pause(2.5);
%%
sound(30*ooosim18, fSamp)
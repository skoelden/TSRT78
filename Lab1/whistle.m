close all; clear all; clc;
load('whistle.mat')

yOrig = y;
nSampOrig = nSamp;

y = y(1.5*fSamp:3.5*fSamp);
nSamp = length(y);
duration = nSamp/fSamp;

Y = fft(y);
freq = fSamp*[-0.5:1/(nSamp-1):0.5];

figure(1)
plot(freq, fftshift(abs(Y)))
title('DFT of whistle')
xlabel('Frequency (Hz)')

domFreq = 1728; % Hz
delta = 30; % Span of what is considered to be the dominating frequency

% Energy of signal, computed in the time domain
Wn = [domFreq-delta, domFreq+delta]./fSamp;
[b, a] = butter(5, 2*Wn);

yDom = filter(b,a,y);

EtotTime = duration*sum(y.^2)/nSamp;
EdomTime = duration*sum(yDom.^2)/nSamp;

purityTime = 1 - EdomTime/EtotTime;

% Energy of signal, computed in the frequency domain
EtotFreq = sum(abs(Y/fSamp).^2)/duration;
EdomFreq = sum(abs(Y(floor(Wn(1)*nSamp):ceil(Wn(2)*nSamp))/fSamp).^2)*2/duration;

purityFreq = 1 - EdomFreq/EtotFreq;

% AR-simulation
mod = ar(detrend(y), 2);
mod30 = ar(detrend(y), 30);
input = randn(nSamp, 1);
yAR = sim(mod, input);
yAR30 = sim(mod30, input);

figure(2)
mod.Ts = 1/fSamp;
mod30.Ts = 1/fSamp;
h1 = spectrumplot(mod);
hold on
spectrumplot(mod30);
hold off
title('Power spectrum of AR models')
legend('Order 2', 'Order 30', 'Location', 'SouthWest')
setoptions(h1,'FreqUnits','Hz','FreqScale','log','Xlim',{[100 4000]}, 'Ylim', {[-130 -50]}, 'MagUnits','db', 'IOGrouping', 'none');

figure(3)
h2 = spectrumplot(etfe(iddata(detrend(y), [], 1/fSamp),[]));
title('Power spectrum of signal')
setoptions(h2,'FreqUnits','Hz','FreqScale','log','Xlim',{[100 4000]}, 'Ylim', {[-130 -50]}, 'MagUnits','db');

abs(roots(mod.a))


purityTime
purityFreq
%purityAR

%% Play AR(2)
sound(30*yAR, 8000);
%% play AR(30)
sound(30*yAR30, 8000);
%% play original recording
sound(30*y, 8000);
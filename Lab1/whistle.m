clc;
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
mod = ar(y, 20);
input = randn(nSamp, 1);
yAR = sim(mod, input);

YAR = fft(yAR);

figure(2)
plot(freq, fftshift(abs(YAR)))
title('DFT of AR-model')
xlabel('Frequency (Hz)')

EtotAR = sum(abs(YAR/fSamp).^2)/duration;
EdomAR = sum(abs(YAR(floor(Wn(1)*nSamp):ceil(Wn(2)*nSamp))/fSamp).^2)*2/duration;

purityAR = 1 - EdomAR/EtotAR;
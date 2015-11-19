load('vowel.mat');

aaa = aaa([fSamp*2:fSamp*4]);
ooo = ooo([fSamp*3:fSamp*5]);

%% Estimate model order
maxModelOrder = 20;
modAloss = zeros(maxModelOrder,1);
modOloss = zeros(maxModelOrder,1);

for(modelOrder = [1:maxModelOrder])
    modA = ar(aaa, modelOrder);
    modO = ar(ooo, modelOrder);
    
    modAloss(modelOrder) = sum(resid(modA, aaa).^2);
    modOloss(modelOrder) = sum(resid(modO, ooo).^2);
end

figure(1)
clf
hold on
plot(modAloss)
plot(modOloss)
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
hold off


%% Simulate AR models
aFreq = 114;
oFreq = 162;

modA = ar(aaa, 12);
modO = ar(ooo , 5);

Ainput = zeros(2*fSamp,1);
Ainput(1:floor(fSamp/aFreq):end) = 1;

Oinput = zeros(2*fSamp,1);
Oinput(1:floor(fSamp/oFreq):end) = 1;

aaasim = sim(modA, Ainput);
ooosim = sim(modO, Oinput);

sound(10*aaasim, fSamp)
pause(3);
sound(10*ooosim, fSamp)

%% Validate estimates
aaaEst = aaa(1:floor(end/2));
aaaVal = aaa(ceil(end/2):end);
oooEst = ooo(1:floor(end/2));
oooVal = ooo(ceil(end/2):end);

aFreq = 114;
oFreq = 162;

Ainput = zeros(2*fSamp,1);
Ainput(1:floor(fSamp/aFreq):end) = 1;

Oinput = zeros(2*fSamp,1);
Oinput(1:floor(fSamp/oFreq):end) = 1;

order = [3, 5, 11, 13];
modA = zeros(length(order));
modO = zeros(length(order));
aaasim = zeros(length(order));
ooosim = zeros(length(order));

for i=1:length(order)
    modA(i) = ar(aaaEst, order(i));
    modO(i) = ar(oooEst, order(i));
    aaasim(i) = sim(modA(i), Ainput);
    ooosim(i) = sim(modO(i), Oinput);
end




AAA = fft(aaa);
OOO = fft(ooo);

figure(2)
clf
hold on
plot(fSamp*[0:1/(length(aaa)-1):1/8], abs(AAA(1:2001)))
AAASIM = fft(aaasim);
plot(fSamp*[0:1/(length(aaasim)-1):1/8], abs(AAASIM(1:2000)))
hold off

figure(3)
clf
hold on
plot(fSamp*[0:1/(length(ooo)-1):1/8], abs(OOO(1:2001)))
OOOSIM = fft(ooosim);
plot(fSamp*[0:1/(length(ooosim)-1):1/8], abs(OOOSIM(1:2000)))
hold off
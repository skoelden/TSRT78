close all; clear all; clc;
load('speech.mat')

yhat = zeros(size(y));

order = 12;
len = 160;
segments = length(y)/len;
models = zeros(segments, order + 3);

for segment = [0:segments-1]
    mod = ar(detrend(y(segment*len+1:(segment+1)*len)), order);
    
    rot = roots(mod.a);
    
    for i = [1:order]
        ab = abs(rot(i)); 
        if(ab>1)
            a = ab - 1;
            rot(i) = (1-a)/((1+a))*rot(i);
        end
    end
    
    models(segment+1, 1:order+1) = poly(rot);
    e = filter(mod.a,1,y(segment*len+1:(segment+1)*len));
    r = covf(e,100);
    [A, D] = max(r(20:end));
    D = D+19;
    
    models(segment+1, 10) = sqrt(A);
    models(segment+1, 11) = D;
    
    %A = 1;
    
    ehat = zeros(len, 1);
    ehat(1:D:end) = sqrt(A);
    
    yhat(segment*len+1:(segment+1)*len) = filter(1,mod.a, ehat);
end

sound(50*yhat, 8000)

% the first infile is to list all the data sessions to be analysed
% the second infile is to list number of trials to be included for each
% session

%plot_psychocurve ('path.txt', 'trial.txt', 0.29, 1.2, 1.8)

function plot_psychocurve (inputFile, inputFile_trial, threshold, slope, Dprime_thres)

%read the input file and get the behavioral files.
fid = fopen(inputFile,'r');
i = 1;
while ~feof(fid)
    file_data_all{i} = fgetl(fid);    
    i = i+1;
end
fclose(fid);

%read the input file and get the trial included for each session.
fid2 = fopen(inputFile_trial,'r');
i = 1;
while ~feof(fid2)
    readtrial{1,i} = fgetl(fid2);    
    i = i+1;
end
fclose(fid2);

for ii = 1: length(readtrial)
a =  str2double(split(readtrial{ii},','));
starttrial(ii) = a(1);
endtrial(ii) = a (2);
end

coherence_all = [];
correct_all = [];
trial_days = [];
D_prime_all = [];

for itr = 1:size(file_data_all,2)

load (file_data_all{itr});
try
 NumInternalCtrl = SessionData.NumInternalCtrl;
catch
 NumInternalCtrl = 3;
end

% get the trial starts and ends of training and testing
nTrials = (endtrial(itr)-starttrial(itr))+1;
alltrial =  starttrial(itr):endtrial(itr); %SessionData.TrialTypes;
Trial_testing = (starttrial(itr)+NumInternalCtrl): (NumInternalCtrl+1): endtrial(itr);
Trial_training = setdiff(alltrial, Trial_testing);

% D' in training blocks 

hits_training = 0;
for k = 1:numel(Trial_training)
    if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.Hit(1))
       hits_training = hits_training + 1;
    end
end

miss_training = 0;
for k = 1:numel(Trial_training)
    if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.Miss(1))
       miss_training = miss_training + 1;
    end
end


FA_training = 0;
for k = 1:numel(Trial_training)
    if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.FalseAlarm(1))
       FA_training = FA_training + 1;
    end
end

CR_training = 0;
for k = 1:numel(Trial_training)
    if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.CorrectRejection(1))
       CR_training = CR_training + 1;
    end
end

if hits_training == 0
    % hits_training = 0.000001;
   hits_training = 1;
end

if miss_training == 0
    % miss_training = 0.000001;
    miss_training = 1;
end

if FA_training == 0
    % FA_training = 0.000001;
    FA_training = 1;
end

if CR_training == 0
    % CR_training = 0.000001;
    CR_training = 1;
end

D_prime = norminv(hits_training/(hits_training+miss_training))-norminv(FA_training/(FA_training+CR_training));
if D_prime >= 1.75 && D_prime < 1.8
    D_prime = round(D_prime,1);
end

fprintf('The D_prime of test day %d is %4.2f.\n', itr, D_prime)
trial_90 (itr,1) = hits_training+miss_training+FA_training+CR_training;

%  percentage of correct at each coherence in testing blocks
coherence = SessionData.CoherenceTypes(Trial_testing);
correct = zeros(1,length(coherence));
    for i = 1: length(coherence)
        if ~isnan(SessionData.RawEvents.Trial{Trial_testing(i)}.States.Hit(1)) || ~isnan(SessionData.RawEvents.Trial{Trial_testing(i)}.States.CorrectRejection(1))
         correct(i) = 1;
        end
    end
 
 trial_coh = floor (nTrials/((NumInternalCtrl+1)*10));
 [coherence_sorted,idx] = sort (coherence);
 correct_sorted = correct(idx);
 correct_sorted = correct_sorted (1: (trial_coh * 10));
 correct_coh = [];
 for jj = 1:trial_coh:length(correct_sorted)
     correct_coh_temp = sum(correct_sorted(jj:(jj+ trial_coh-1)));    
     correct_coh  = [correct_coh correct_coh_temp];
 end

correct_all = [correct_all correct];
coherence_all = [coherence_all coherence]; 
trial_days = [trial_days trial_coh];
D_prime_all = [D_prime_all D_prime];
correct_days (itr,1:10) = correct_coh;


if D_prime_all (itr) < Dprime_thres
   correct_days (itr,:) = NaN;
   trial_days (:,itr) = NaN;
end
correct90 = hits_training + CR_training;
correct_days (itr,11) = correct90;

end

correct_testing = sum (correct_days,1,'omitnan');
trial_total = sum(trial_days,2,'omitnan');
trial_total90 = sum(trial_90,1,'omitnan');

% Raw data plot
% subplot(1,2,1);
perf  = correct_testing(1:end-1)./trial_total*100; 
perf  = [perf correct_testing(end)./trial_total90*100]; 
coh_plot = 0.08:0.08:0.9;

plot(log(coh_plot), perf,'ko','MarkerFaceColor','k');
hold on

% psychometric curve
pGuess.t = threshold;
pGuess.b = slope;
x = linspace (0.08,0.9,101);
y= Weibull(pGuess,x);
plot(log(x),y*100,'k-','LineWidth',2);   % comment if fitting curve is
                                             % not requred
logx2raw;
xlim([log(0.08),log(0.9)])
set(gca,'YLim',[40,100]);
xticks(log(0.08:0.08:0.9));
xticklabels({'8','16','24','32','40','48','56','64','72','80','90'})
hold on
plot(log([min(x),pGuess.t,pGuess.t]),100*(1/2)^(1/ 1.9434)*[1,1,0],'k--');
coh_thres = pGuess.t*100; 
xlabel('% Coherence (log)')
ylabel('% Raw Correct trials')
str = sprintf('%2.1f %%',coh_thres); 


results.intensity = reshape(coherence_all, 1, []);
results.response = reshape(correct_all, 1, []);

likelihood = fitPsychometricFunction(pGuess,results,'Weibull');

% to find the best threshold and slope
pInit.t = threshold;
pInit.b = slope;

[pBest,logLikelihoodBest] = fit('fitPsychometricFunction',pInit,{'b','t'},results,'Weibull');
 sprintf ('The best threshold is %0.2f.', pBest.t)
 sprintf ('The best slope is %0.2f.', pBest.b)
 sprintf ('Threshold coherence is %0.0f.', pBest.t*100)

% saving
% T = struct ('trial_days',trial_days,...
%            'D_prime_all',D_prime_all, ...
%            'correct_days', correct_days,...
%            'correct_testing', correct_testing,...
%            'trial_total', trial_total,...      
%            'threshold', pBest.t*100,... 
%            'slope', slope, ...
%            'perf', perf);
% 
% save(sprintf('Behavior_data_%s.mat',datetime('now','Format','ddMMMyyyy_hhmm')),'T')
 end


function logx2raw(base,precision)
%logx2raw([base],[precision])
%
%Converts X-axis labels from log to raw values.
%base:    	base of log transform; default base is e.
%precision:	number of decimal places;  default  is two.
%
%Example:
% x=linspace(-3,0,11);
% plot(log(x),log(x.^2));
% logx2raw
% logy2raw

%SEE ALSO;   Logy2raw
%11/17/96	gmb	Wrote it.
%6/6/96	        gmb added precision argument
%01/30/02       gmb updated it to use cell arrays, and to use original
%                xtick values instead of converting labels.  This way,
%		multiple calls to this function doesn't keep converting
%		the axis.

if ~exist('base','var') 
    base=exp(1);
end

if ~exist('precision','var')
	precision=2;
end

origXTick = get(gca,'XTick');
newXTick = base.^(origXTick);
newXLabel = num2str(newXTick',precision);
set(gca,'XTickLabel',newXLabel);


end


function y = Weibull(p,x)
%y = Weibull(p,x)
%
%Parameters:  p.b slope
%             p.t threshold yeilding ~80% correct
%             x   intensity values.

g = 0.5;  %chance performance
% e = (.5)^(1/3);  %threshold performance ( ~80%)
e = (.5)^(1/ 1.9434);  %threshold performance ( ~70%)

%here it is.
k = (-log( (1-e)/(1-g)))^(1/p.b);
y = 1- (1-g)*exp(- (k*x/p.t).^p.b);
end
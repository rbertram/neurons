% ME_09.m

% From "Correlation Analysis: A Tool for Comparing Relaxation-Type Models
% to Experimental Data", M. Tomaiuolo, J. Tabak, and R. Bertram, 
% Methods in Enzymology, Vol. 467, pp 1-22, 2009.

% This Matlab file reads in data from a user-provided data file, plots the data,
% and determines correlation coefficients as described in the book chapter. The
% data file should have two columns. The first is time and the second is an observable
% that exhibits a relaxation or bursting pattern, such as the membrane potential.
% See comments in the program for more information.

%% load data

filename = 'myfile.text';
data = dlmread(strcat('C:\path\',filename));

% first column is time, second column is voltage
time=data(:,1);
v=data(:,2);

% uncomment the line below if you want to rescale time from msec to sec
%time = time/1000;

% take a look at the data if you want
plot(time,v);

%% detects spikes and collects them into bursts

% this is the threshold for spike detection
% needs to be decided from visual inspection
thresh = -40; 
onset = []; 
endeps = []; 
peaks = [];

% this loop collects the spike times in the peaks array
for thisindex = 20:(length(v)-10),
    if(v(thisindex)>thresh)
        peaks = [peaks,thisindex];
    end
end

% this defines the maximum interspike interval
% spikes that are more than 'recmin' apart 
% belong to different bursts
recmin = 1000;

onset(1) = peaks(1);

% this groups episodes into bursts

for fin = 2:(length(peaks)),
    if((peaks(fin) - peaks(fin-1)) > recmin)
        endeps = [endeps,peaks(fin-1)];
        onset = [onset,peaks(fin)];
    end
end

%% visual inspection of burst detection
% this makes a jacket around each burst
% it helps to visually check if
% burst detection was successfull
newvec = [];

% floor and ceiling of the burst jacket
lowval = -40;  
highval = 10;

newvec(1:onset(1))= lowval;

for sin = 1:length(endeps-1),
   newvec(onset(sin)+1:endeps(sin))=highval;
   newvec(endeps(sin)+1:onset(sin+1)) = lowval;
end

newvec(endeps(length(endeps)):length(V)) = lowval;

% set start and finish to plot data and episodes detection
start=1;
finish=500000;

% plot data and episodes detected for visual inspection
plot(time(start:finish),V(start:finish),time(start:finish),newvec(start:finish));

%% computes correlations
% now we collect
% the bursts durations and the silent phases durations
neps=size(endeps,2);
ronset = onset(1:length(onset)-1);

% burst episode durations
int=time(endeps(2:neps-1))-time(ronset(2:neps-1));
% previous silent phase duration
prevdur=time(ronset(2:neps-1))-time(endeps(1:neps-2));
% next silent phase duration
nextdur=time(ronset(3:neps))-time(endeps(2:neps-1));

% computes the correlations
[R,P] = corrcoef(prevdur,int);
correlation_prev = R(1,2);
pnull_prev = P(1,2);
[R,P] = corrcoef(nextdur,int);
correlation_next = R(1,2);
pnull_next = P(1,2);

% plots the correlations
subplot(2,1,1);
plot(prevdur,int,'b* ');
xlabel({' previous silent duration (sec)'},'FontSize',18);
ylabel('active duration (sec)','FontSize',18);
title(['r = ', num2str(correlation_prev), '  pnull = ', num2str(pnull_prev)],'FontSize',12);
subplot(2,1,2);
plot(nextdur,int,'b* ');
xlabel({' next silent duration (sec)'},'FontSize',18);
ylabel('active duration (sec)','FontSize',18);
title(['r = ', num2str(correlation_next) '  pnull = ', num2str(pnull_next)],'FontSize',12);

% enf of script

% info = inputdlg(["Start day","Interval","End day"], 'double');
% 
% start_day = str2num(cell2mat(info(1)));
% interval = str2num(cell2mat(info(2)));
% end_day = str2num(cell2mat(info(3)));

start_day = 6;  %First recordings on P6
interval = 2;   %Record every 2 days
end_day = 18;   %Last recordings on P18
n_days = length(start_day:interval:end_day);

%% initialize variables
m_tonality = [];
se_tonality = [];

%% Get daily means for all variables

subj_means_tonality = [];
subj_sds = [];
subj_names = unique(T.Var2);

for k=1:n_days
    day = (start_day-interval)+(k*interval);
    indexes = T.Var1==int2str(day);
    subT = T(indexes,:);
    
    m_tonality(end+1) = mean(subT.Tonality);
    for n=1:length(subj_names)
        indiv_indexes = subT.Var2==subj_names(n);
        subsubT = subT(indiv_indexes,:);
        subj_means_tonality(n,k) = mean(subsubT.Tonality);
        subj_sds(n,k) = std(subsubT.Tonality);
    end
    
    m_tonality(end) = mean(subT.Tonality); %Mean tonality for all calls that day
end

se_tonality = std(subj_sds, 'omitnan');
daily_subject_means = mean(subj_means_tonality, 'omitnan');  %Mean across subjects per day
subject_7day = mean(subj_means_tonality, 2, 'omitnan');      %Mean across days per subject
%% Figures

[p,tab,stats] = kruskalwallis(subj_means_tonality);
hold on;
box off;
xticklabels([start_day:interval:end_day]);
title('Tonality');
xlabel('Postnatal Day');
ylabel('Mean subject USV tonality (dB/kHz)');

figure(3);
hold on;
errorbar(daily_subject_means,se_tonality,'k-','LineWidth',1)
%plot(daily_subject_means,'k-','LineWidth',1)
box off;
zoom out;
xticklabels([start_day:interval:end_day]);

figure(3)
hold on;
plotSpread(subj_means_tonality)
title('Tonality');
xlabel('Postnatal Day');
ylabel('Mean subject USV tonality (dB/kHz)');
%% Check stopping/flickering rate during mouse-tracking task
%% set path
addpath('/Users/boshen/Documents/GuiltMsTrck/utils');
Ggldrive = '/Volumes/GoogleDrive/My Drive/GuiltMsTrck';
data_dir = '/Volumes/BOSHEN/Research/MouseTracking/1111jifang/log'; % fullfile(Ggldrive, 'data', '1111jifang', 'log');s
plot_dir = fullfile(Ggldrive, 'PNASRevisionI', 'flickercheck');
if ~exist(plot_dir, 'dir')
    mkdir(plot_dir);
end
%% extract values
lag = 4;
tmp = dir(fullfile(data_dir,'18*'));
glist  = {tmp.name};
subj = 0;
flicker = {};
off_grp = {};
for g = 1:numel(glist)
    tmp = dir(fullfile(data_dir,glist{g},'MainTask','MsTrck*'));
    sublist = {tmp.name};
    sublist = sublist(1:end/2);
    for s = 1:numel(sublist)
        subj = subj + 1;
        indv_dir = fullfile(data_dir,glist{g}, 'MainTask', sublist{s});
        filelist = dir(fullfile(indv_dir,'block*.mat'));
        nfl = zeros([length(filelist),1]);
        h = figure; hold on;
        off_indv = [];
        for f = 1:numel(filelist)
            %hitline = strsplit(filelist(f).name,'hitline');
            %hitline = str2double(hitline{2}(1));
            load(fullfile(indv_dir,filelist(f).name));
            plot(record(:,5),record(:,2));
            flag = 1;
            off = [];
            for ti = (lag+1):length(record(:,5))
                if record(ti ,2) >= record(ti - lag, 2)
                    plot(record(ti,5),record(ti,2),'r.'); % plot extinguish
                    if flag == 1 % extinguish and count one flick
                        flag = 0;
                        nfl(f) = nfl(f) + 1;
                    end
                else
                    flag = 1;
                end
                off(ti) = ~flag;
            end
            dp = 1:length(record(:,1));
            dpp = 1:(max(dp) - 1)/100:max(dp);
            off_indv(:,f) = interp1(dp,off,dpp,'pchip');
        end
        xlabel('Time/secs');
        ylabel('y coordinate');
        savefigs(h, sublist{s}, plot_dir, 14, [4 4]);
        flicker(subj) = {nfl};
        off_grp(subj) = {off_indv};
    end
end


%% statistics
% Number of flickering
% Average over trials and subjects
m = @(x)mean(x);
meanval = cellfun(m, flicker)
mean(meanval)
mx = @(x)max(x);
maxval = cellfun(mx, flicker)
max(maxval)
mn = @(x)min(x);
minval = cellfun(mn, flicker)
Nsubj = 37;
allsub = [];
for subi = 1:Nsubj
    allsub = [allsub;flicker{subi}]; 
end
h = figure; hold on;
histogram(allsub, 'FaceColor','white');
xlabel('N flckr each trial');
ylabel('Frequency');
savefigs(h, 'allsub_hist', plot_dir, 14, [4 4]);
% n flicker over trials
counttrial = @(x)length(x);
Ntrials = cellfun(counttrial, flicker);
meantrl = [];
setrl = [];
for ti = 1:max(Ntrials)
    trlvec = [];
    for si = 1:Nsubj
        if Ntrials(si) >= ti
            trlvec = [trlvec, flicker{si}(ti)];
        end
    end
    meantrl(ti) = mean(trlvec);
    setrl(ti) = std(trlvec)/sqrt(length(trlvec));
end
h = figure;
hold on;
barx = bar(1:max(Ntrials),meantrl, 'FaceColor','white');
for ti = 1:max(Ntrials)
    plot([barx.XData(ti),barx.XData(ti)], [meantrl(ti) - setrl(ti), meantrl(ti) + setrl(ti)],'k-', 'LineWidth',1.5);
end
xlabel('Trial');
ylabel('N flckr across subjects');
savefigs(h, 'overtrials_hist', plot_dir, 14, [4 4]);
% N flicker over time
h = figure; hold on;
y = 0;
x = 0:100;
suby = [];
for subi = 1:Nsubj
    y = y + 100;
    suby(subi) = y*.1;
    for ti = 1:Ntrials(subi)
        y = y + 1;
        pltmsk = off_grp{subi}(:,ti) == 1;
        plot(x(pltmsk)-rand(1,sum(pltmsk)),ones(1,sum(pltmsk))+y*.1,'k.','MarkerSize',5);
    end
end
xlim([0,100]);
yticks(suby);
yticklabels(num2cell([1:37]));
xlabel('Time bin');
ylabel('Subjects');
savefigs(h, 'Overtimebin_raster', plot_dir, 14, [8 6]);
PSTH = [];
for subi = 1:Nsubj
    PSTH(:,subi) = sum(off_grp{subi},2);
end
h = figure;
barx = bar(x, mean(PSTH,2),'FaceColor','white');
xlabel('Time bin');
ylabel('N trials stimuli off');
xlim([0,100]);
savefigs(h, 'Overtimebin_PSTH', plot_dir, 14, [8 1.5]);

save(fullfile(plot_dir,'CmputedFiles.mat'),'flicker','off_grp');
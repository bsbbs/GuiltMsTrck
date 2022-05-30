%% Check stopping/flickering rate during mouse-tracking task
Ggldrive = '/Volumes/GoogleDrive/My Drive/GuiltMsTrck';
datadir = '';
data_dir = 'E:\ShenBo\MouseTracking\1111jifang\log';
plot_dir = 'E:\ShenBo\MouseTracking\MsTrckPreprocessing\Preprocessing_cut_interpolate_100';
mkdir(plot_dir);
tmp = dir(fullfile(data_dir,'18*'));
glist  = {tmp.name};
for g = 1:numel(glist)
    tmp = dir(fullfile(data_dir,glist{g},'MainTask','MsTrck*'));
    sublist = {tmp.name};
    sublist = sublist(1:end/2);
    for s = 1:numel(sublist)
        indv_dir = fullfile(data_dir,glist{g}, 'MainTask', sublist{s});
        filelist = dir(fullfile(indv_dir,'block*.mat'));
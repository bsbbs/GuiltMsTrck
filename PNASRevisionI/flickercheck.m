%% Check stopping/flickering rate during mouse-tracking task
Ggldrive = '/Volumes/GoogleDrive/My Drive/GuiltMsTrck';
data_dir = fullfile(Ggldrive, 'data', '1111jifang', 'log');
plot_dir = fullfile(Ggldrive, 'Preprocessing' 'Preprocessing_cut_interpolate_100');
if ~exist(plot_dir, 'dir')
    mkdir(plot_dir);
end
tmp = dir(fullfile(data_dir,'18*'));
glist  = {tmp.name};
for g = 1:numel(glist)
    tmp = dir(fullfile(data_dir,glist{g},'MainTask','MsTrck*'));
    sublist = {tmp.name};
    sublist = sublist(1:end/2);
    for s = 1:numel(sublist)
        indv_dir = fullfile(data_dir,glist{g}, 'MainTask', sublist{s});
        filelist = dir(fullfile(indv_dir,'block*.mat'));
    end
end
%% preprocessing
%% parameters
Nstage = 100;
%%
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
        H = figure;
        prepro_dir = fullfile(indv_dir,'preprocess_cut_interpolate_100');
        if ~exist(prepro_dir,'dir')
            mkdir(prepro_dir);
        end;
        for f = 1:numel(filelist)
            hitline = strsplit(filelist(f).name,'hitline');
            hitline = str2double(hitline{2}(1));
            if hitline
                load(fullfile(indv_dir,filelist(f).name));
                % record contains [x real, y real, x noise, y real, time]
                subplot(2,3,1);
                hold on;
                plot(record(:,1),1080-record(:,2));
                xlim([-1 1921]);
                ylim([-1 1081]);
                title('RawData');
                %% predelete data points before start moving
                mask = record(:,2) >= record(1,2) & record(:,1) == record(1,1);
                mask(find(mask == 1, 1, 'last' )) = 0;
                record(mask,:) = [];
                if ~isempty(record)
                    
                    %% spatial normalization
                    startpoint = [960 1060];
                    record(:,1:2) = [record(:,1) - startpoint(1), startpoint(2) - record(:,2)];
                    endpoint = size(record,1);
                    % cut if hit the boundary
%                     left = 0;
%                     right = 0;
%                     up = 0;
%                     tmp = find(record(:,1) == min(record(:,1)));
%                     if all(record(min(tmp):end,1) == min(record(:,1))) && length(tmp) > 1
%                         left = 1;
%                         endpoint = min([endpoint tmp']);
%                     end;
%                     tmp = find(record(:,1) == max(record(:,1)));
%                     if all(record(min(tmp):end,1) == max(record(:,1))) && length(tmp) > 1
%                         right = 1;
%                         endpoint = min([endpoint, tmp']);
%                     end;
%                     if left && right
%                         plot(record(:,1),record(:,2));
%                         error('Ooooops');
%                     end;
%                     tmp = find(record(:,2) == max(record(:,2)));
%                     if all(record(min(tmp):end,2) == max(record(:,2))) && length(tmp) > 1
%                         up = 1;
%                         endpoint = min([endpoint, tmp']);
%                     end;
                    xend = record(endpoint,1);
                    yend = record(endpoint,2);
                    record(:,1) = (record(:,1))/abs(xend)*100;
                    record(:,2) = (record(:,2))/abs(yend)*100;
                    subplot(2,3,2);
                    hold on;
                    plot(record(:,1),record(:,2));
                     xlim([-120 120]);
                    ylim([-15 120]);
                    title('Spatial Normalized');
                    %% temporal interpolate
                    xp = [];
                    yp = [];
                    angle = [];
                    v = [];
                    a = [];
                    dp = 1:length(record(:,1));
                    dpp = 1:(max(dp) - 1)/100:max(dp);
                    recordp(:,1) = interp1(dp,record(:,1),dpp,'pchip');
                    recordp(:,2) = interp1(dp,record(:,2),dpp,'pchip');
                    recordp(:,5) = interp1(dp,record(:,5),dpp,'pchip');
                    i = 0;
                    for ti = 1:Nstage+1
                        tl = recordp(ti,5);
                        tmp = recordp(recordp(:,5) == tl,:);
                        if i == 0
                            xp0 = tmp(end,1);
                            yp0 = tmp(end,2);
                            tp0 = tmp(end,5);
                            v0 = 0;
                            a0 = 0;
                        elseif i == 1
                            xp = tmp(end,1);
                            yp = tmp(end,2);
                            tp = tmp(end,5);
                            deltax = xp(i) - xp0;
                            deltay = yp(i) - yp0;
                            angle(i) = atan(deltax/deltay)/pi*180;
                            if deltay < 0 && deltax < 0
                                angle(i) = -90 - angle(i);
                            elseif deltay < 0 && deltax > 0
                                angle(i) = 90 - angle(i);
                            end;
                            v(i) = sqrt(deltax^2+deltay^2)/(tp(i) - tp0);
                            vh(i) = deltax/(tp(i) - tp0);
                            a(i) = (v(i) - v0)/(tp(i) - tp0);
                        else
                            xp(i) = tmp(end,1);
                            yp(i) = tmp(end,2);
                            tp(i) = tmp(end,5);
                            deltax = xp(i) - xp(i-1);
                            deltay = yp(i) - yp(i-1);
                            angle(i) = atan(deltax/deltay)/pi*180;
                            if deltay < 0 && deltax < 0
                                angle(i) = -90 - angle(i);
                            elseif deltay < 0 && deltax > 0
                                angle(i) = 90 - angle(i);
                            end;
                            v(i) = sqrt(deltax^2+deltay^2)/(tp(i) - tp(i-1));
                            vh(i) = deltax/(tp(i) - tp(i-1));
                            a(i) = (v(i) - v(i-1))/(tp(i) - tp(i-1));
                        end;
                        i = i + 1;
                    end;
                    %mask = (angle == 0 & (xp == 100 | xp == -100)) | ((angle == -90 | angle == 90) & (yp <= 0 | yp >= 100));
                    %angle(mask) = NaN;
                    processed = [xp; yp; tp; angle; v; a; vh]';
                    subplot(2,3,3);
                    hold on;
                    plot(recordp(:,1),recordp(:,2));
                    xlim([-120 120]);
                    ylim([-15 120]);
                    title('Spatial&Temporal Normalized');
                    subplot(2,3,4);
                    hold on;
                    plot(1:Nstage,processed(:,4));
                    %xlim([0 Nstage]);
                    xlabel('time point');
                    title('angle');
                    subplot(2,3,5);
                    hold on;
                    plot(1:Nstage,processed(:,5));
                    %xlim([0 Nstage]);
                    xlabel('time point');
                    title('velocity');
                    subplot(2,3,6);
                    hold on;
                    plot(1:Nstage,processed(:,7));
                    %xlim([0 Nstage]);
                    xlabel('time point');
                    title('v horizontal');
                    save(fullfile(prepro_dir,['TSH' filelist(f).name]),'processed');
                end;
            end;
        end;
        saveas(H,fullfile(plot_dir,sprintf('sub%s.tiff',sublist{s})));
    end;
end;


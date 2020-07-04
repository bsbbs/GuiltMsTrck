clear
%% calculate autocorrelation for each channel
datadir = 'E:\ShenBo\MouseTracking\Analysis\MsTrck_RelativeWeight_Stan_vh_NoIntercept-w2normI\Extract_RandomEffects';
plotdir = 'E:\ShenBo\MouseTracking\Analysis\MsTrck_Brms_angle\permutation test';
mydat_all = tdfread(fullfile(datadir,'randeffs.txt'));
i = 0;
for context = [1,2,3] %{'swpc','swpw','scpw'}
    for v = {'w10x2Emean', 'w20x2Emean'}
        i = i + 1;
        clear X;
        mask = mydat_all.condi == context;
        mydat.subid = mydat_all.subid(mask);
        mydat.time = mydat_all.time(mask);
        mydat.w10x2Emean = mydat_all.w10x2Emean(mask);
        mydat.w20x2Emean = mydat_all.w20x2Emean(mask);
        T = length(unique(mydat.time));
        N = length(unique(mydat.subid));
        zs = mydat.(v{1});
        subjlist = unique(mydat.subid);
        for time = 1:T
            for subi = 1:N
                subj = subjlist(subi);
                z = zs(mydat.subid == subj & mydat.time == time);
                if ~isempty(z)
                    X(subi,time) = z;
                else
                    X(subi,time) = mean(zs(mydat.time == time));
                end;
            end;
        end;
        %%% calculate residule matrix Z
        % X is N*T matrix
        ma=mean(X);
        figure;
        plot(ma);
        for z=1:T
            X(:,z)= X(:,z)-ma(z);
        end;
        [L,G,R]=svd(X); %
        
        k=rank(G);
        Gk=G;
        Gk(k,k)=0;
        Xk=L*Gk*R';
        Z=X-Xk;
        %%% estimate first-order autocorrelation
        tZ=Z';
        me=mean(tZ);
        for j=1:N
            
            Z(j,:)=Z(j,:)-me(j);
            gamma_1=0; gamma_0=0;
            
            for m=2:T
                gamma_1=gamma_1+Z(j,m-1)*Z(j,m);
            end
            for n=1:T
                gamma_0=gamma_0+Z(j,n)*Z(j,n);
            end
            Rho(j)= gamma_1/ gamma_0;
            %
        end
        
        autocor(i)=mean(Rho); % first order autocorrelation coeffietiont
        
    end;
end;


maxauto = max(autocor)%%% .0264 


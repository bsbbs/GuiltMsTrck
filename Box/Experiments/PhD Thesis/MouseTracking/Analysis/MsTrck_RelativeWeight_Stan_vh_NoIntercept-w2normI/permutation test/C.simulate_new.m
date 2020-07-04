%simulate
clear
Rho=.0264; %.1465;
T=100;
N=37;
% point=3;

% R, T*T  matrix with ones on the diagonal and Rho^k in the kth position
% removed from the diagonal
R=zeros(T,T);
for i=1:T
    R(i,i)=1;
    for j=1:i-1
        R(i,j)=Rho^(i-j);
    end
    for j=i+1:T
        R(i,j)=Rho^(j-i);
    end
end

A=sqrtm(R);

% generate T*N matrix Y of independent pseudorandom normal numbers with
% zero mean and  unit variance
seq=[];
n=0;
point = 2;
for i=1:100000
    randn('seed',sum(10000*clock));
    Y=randn(T,N);
    X=A*Y; % 100*37
    X=X';
    seX=std(X)/sqrt(N);
    for q=1:T
        t(q)=mean(X(:,q))/seX(q);
    end
    p=tcdf(t,N-1);
    [a,c]=find(p>0.975);
    %
    %    [a,c]=find(abs(t)>1.753);
    b(i)=length(a);
    if b(i)>point-1
        n=n+1;
        seq(n,1:b(i))=c;
    end
end
save seq  seq
%max(b)

for point = 1:max(b)
    list.point(point) = point;
    num=0;
    id=[];
    [M,N]=size(seq);
    for i=1:M
        for j=1:N-(point-1)
            if seq(i,j+(point-1))==seq(i,j)+(point-1)
                num=num+1;
                id=[id i];
                break;
            else
                num=num;
            end
        end
    end
    list.num(point) = num;
    pval = num/100000;
    list.pval(point) = pval;
end;
%
% list =
% 
% point: [1 2 3 4 5 6 7 8 9 10 11 12]
% num: [70944 11207 585 28 1 0 0 0 0 0 0 0]
% pval: [0.7094 0.1121 0.0059 2.8000e-04 1.0000e-05 0 0 0 0 0 0 0]

function [Rsquare, Predict] = OLS_TS_pred(timeseries, num)

[M,N] = size(timeseries);

X=[];
Y=[];
days=5;
%test_days=40;
%N=-test_days;
%Test=timeseries(:, N-test_days-num:N);

for i=1:N-num-days
    X=cat(1,X, timeseries(:,i:i+num));
    Y=cat(1,Y, timeseries(:,i+num+days));
    
end


coeff=inv(X'*X)*X'*Y;

SStot = sum((Y-mean(Y)).^2);
SSlast = sum((Y-X(:,num+1)).^2);
SSres = sum((Y-X*coeff).^2);
Rsquare = 1 - SSres/SStot;
Rsquare_pre = 1 - SSres/SSlast;

Predict_unsorted = X*coeff;

[MP,~]=size(Predict_unsorted);

Predict=zeros(M, MP/M);
for i=1:MP/M
    Predict(:,i)=Predict_unsorted((i-1)*M+1:i*M);
end


end

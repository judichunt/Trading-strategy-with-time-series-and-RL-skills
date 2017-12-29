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

% X_test=[];
% Y_test=[];
% for i=1:test_days-days
%     X_test=cat(1,X_test, Test(:,i:i+num));
%     Y_test=cat(1,Y_test, Test(:,i+num+days));
%     %Y_test=cat(1,Y_test,prod(Test(:,i:i+num+days),2));
% end
% 
% % size(Y_test)
% % size(X_test)
% % size(coeff)
% 
% 
% SStot_test = sum((Y_test-mean(Y_test)).^2);
% SSres_test = sum((Y_test-X_test*coeff).^2);
% Rsquare_test = 1 - SSres_test/SStot_test;
% 
% mean_return = mean(Y_test./X_test(:,num+1));
% 
% SSlast_test = sum((Y_test-X_test(:,num+1)).^2);
% SSpre_test = sum((Y_test-X_test(:,num+1)*mean_return).^2);
% Rsquare_pre_test = 1 - SSres_test/SSpre_test;



end
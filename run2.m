load('Universe.mat');
load('selected_Universe.mat');

month_int_rate=readtable('month_int_rate.csv');
risk_free_rate=month_int_rate.TB3MS(26:121,1)/100;
[N,M]=size(selected_returns);


sharpe_ratio=zeros(N,M);
returns_last_week=zeros(N,M);

Var=diag(Covar);
for i=6:M
    returns_last_week(:,i)=(selected_AdjClose(:,i)./selected_AdjClose(:,i-5))-1;
    sharpe_ratio(:,i)=(returns_last_week(:,i)-risk_free_rate(floor(i/21)+1)/52)./Var;
end


regression_days=50;
Rsquare_AdjClose=0;
start=20;
for i=1:N
    [Rsquare, Predict] = OLS_TS_pred(selected_AdjClose(i,start:end), regression_days-1);
    Rsquare_AdjClose=Rsquare_AdjClose+Rsquare;
    Predict_AdjClose(i,:)=Predict;
end
Rsquare_AdjClose=Rsquare_AdjClose/N;

[Rsquare_returns, Predict] = OLS_TS_pred(returns_last_week(:,start:end), regression_days-1);
Predict_returns=(Predict+1).*selected_AdjClose(:, regression_days+5+start-1:end);


[Rsquare_sharpe_ratio, Predict] = OLS_TS_pred(sharpe_ratio(:,start:end), regression_days-1);

for i=1:M-regression_days-4-start+1
    Predict_sharpe_ratio(:,i)=Predict(:,i).*Var+risk_free_rate(floor((i+regression_days)/21)+1)/52;
end
Predict_sharpe_ratio=(Predict_sharpe_ratio+1).*selected_AdjClose(:, regression_days+5+start-1:end);

True=selected_AdjClose(:, regression_days+5+5+start-1:end);

Predict_AdjClose = Predict_AdjClose(:,1:end-50);
Predict_returns = Predict_returns(:,1:end-50);
Predict_sharpe_ratio = Predict_sharpe_ratio(:,1:end-50);
True=True(:,1:end-45);
[pred_stocks, pred_days]=size(True);
pred_nums=pred_stocks*pred_days;

MSE=[sum(sum((Predict_AdjClose-True).^2))/pred_nums, sum(sum((Predict_returns-True).^2))/pred_nums, sum(sum((Predict_sharpe_ratio-True).^2))/pred_nums]

errorA=abs(Predict_AdjClose-True)./True;
errorR=abs(Predict_returns-True)./True;
errorS=abs(Predict_sharpe_ratio-True)./True;
meanError_each=[mean(mean((errorA),2)) mean(mean((errorR),2)) mean(mean((errorS),2))];


save('pre_prices.mat', 'Predict_AdjClose', 'Predict_returns', 'Predict_sharpe_ratio', 'True');

Statistics_names={'mean', 'STD', 'min', 'max'};
xlswrite('Selected_data.xlsx',selected_Ticker,'summary statistics','A2');      %Write row header
xlswrite('Selected_data.xlsx',Statistics_names,'summary statistics','B1');
Table1=table(mean(True,2),std(True,1,2), min(True,[],2), max(True,[],2), 'VariableNames',Statistics_names);
xlswrite('Selected_data.xlsx',table2array(Table1),'summary statistics','B2');







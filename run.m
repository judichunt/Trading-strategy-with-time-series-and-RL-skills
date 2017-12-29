load('Universe.mat')
regression_days=50;
OLS_TSacc=zeros(201,3);
coeff_all=zeros(200, regression_days);
for i=1:200
    [Rsquare, coeff, Rsquare_pre, Rsquare_pre_test] = OLS_TS(AdjClose(i,:), regression_days-1);
    OLS_TSacc(i,:)=[Rsquare, Rsquare_pre, Rsquare_pre_test];
    coeff_all(i,:)=coeff';
end
OLS_TSacc(201,:)=mean(OLS_TSacc(1:200,:));


ind=(OLS_TSacc(1:200,3)>0.05);
selected_AdjClose=AdjClose(ind,:);
selected_returns=returns(ind,:);
selected_Ticker=Ticker(ind,:);
selected_Shares=Shares(ind,:);



for i=1:M/5
    Weakly_returns(:,i)=selected_AdjClose(:,i*5)./selected_AdjClose(:,(i-1)*5+1);
end

Weakly_returns = Weakly_returns-1;


Covar=cov(Weakly_returns');
Relation=corrcoef(C);



save('selected_Universe.mat', 'selected_AdjClose','selected_returns','Covar','Relation','Weakly_returns','selected_Ticker','OLS_TSacc', 'selected_Shares');

Statistics_names={'Rsquare', 'Rsquare_pre', 'Rsquare_pre_test'};
xlswrite('Selected_data.xlsx',Ticker(1:200),'OLS_TSacc','A2');      %Write row header
xlswrite('Selected_data.xlsx',Statistics_names,'OLS_TSacc','B1');
%Table1=table(OLS_TSacc(:,1), OLS_TSacc(:,2), OLS_TSacc(:,3), 'VariableNames',Statistics_names);
xlswrite('Selected_data.xlsx',OLS_TSacc,'OLS_TSacc','B2');



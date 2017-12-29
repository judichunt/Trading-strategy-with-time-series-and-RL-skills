stocks=hist_stock_data('31122008','31122016','NASDAQ_Top_Stock.txt');
universe=hist_stock_data('31122008','31122016','^IXIC');
M=length(universe(1).Date);
Market_Cap = xlsread('companylist.csv');
Shares = Market_Cap (:,4)./Market_Cap (:,3);
Market_Cap = Market_Cap (:,4);
incomplete=[];
AdjClose=[];
for i=1:length(stocks)
    if length(stocks(i).Date)<M
        incomplete=cat(2, incomplete, i);
    else
        AdjClose=cat(1, AdjClose, stocks(i).AdjClose');
    end
end
stocks(incomplete)=[];
Market_Cap(incomplete)=[];
Shares(incomplete)=[];
%AdjClose(incomplete)=[];

num=200;

stocks=stocks(1:num);
AdjClose=AdjClose(1:num,:);
AdjClose=cat(1, AdjClose, universe(1).AdjClose');
Market_Cap=Market_Cap(1:num);
Shares=Shares(1:num);
stocks(num+1)=universe;

stocks(num+2).Ticker=' equally weighted returns';
stocks(num+3).Ticker=' market cap weighted daily returns';


returns=AdjClose(:,2:M)./AdjClose(:,1:M-1);
returns=cat(2, ones(num+1,1), returns);
returns(num+2,:)=ones(1, M);
weight=ones(num,1)/num;
for i=1:M
    returns(num+2,i)=returns(1:num,i)' * weight  ;
    %weight = weight.*returns(1:num,i);
    %weight=weight/sum(weight);
end

weight=Market_Cap ./ AdjClose(1:num,M) .* AdjClose(1:num,1);
weight=weight/sum(weight);

returns(num+3,:)=ones(1, M);
for i=1:M
    returns(num+3,i)=returns(1:num,i)' * weight  ;
    weight = weight.*returns(1:num,i);
    weight=weight/sum(weight);
end

for i=1:M/20
    Monthly_returns(:,i)=prod(returns(:,(i-1)*20+1:i*20),2);
end

Monthly_returns = Monthly_returns-1;
returns=returns-1;


Ticker={};
Date(1,1:M)=stocks(1).Date;
for i=1:num+3
    Ticker=cat(1,Ticker,stocks(i).Ticker);
end
%output(1:33,2:M+1)=returns;

%xlswrite('features.xls',[c1,c2]);
%output_matrix=[{' '} Ticker; Date returns];      %col_header; row_header data_cells
xlswrite('Universe.xlsx',returns,'Sheet1','B2');     %Write data
xlswrite('Universe.xlsx',Date,'Sheet1','B1');     %Write column header
xlswrite('Universe.xlsx',Ticker,'Sheet1','A2');      %Write row header


Statistics_names={'mean', 'STD', 'min', 'max', 'skewness', 'kurtosis'};

xlswrite('Universe.xlsx',Ticker,'Sheet3','A2');      %Write row header
xlswrite('Universe.xlsx',Statistics_names,'Sheet2','B1');
Table1=table(mean(returns,2),std(returns,1,2), min(returns,[],2), max(returns,[],2), skewness(returns,1,2), kurtosis(returns,1,2),'VariableNames',Statistics_names);
xlswrite('Universe.xlsx',table2array(Table1),'Sheet2','B2');


%writetable(Table1,'Universe.xlsx','Sheet',1,'Range','BYO1');

xlswrite('Universe.xlsx',Ticker,'Sheet3','A2');      %Write row header
xlswrite('Universe.xlsx',Statistics_names,'Sheet2','B1');
Table2=table(mean(Monthly_returns,2),std(Monthly_returns,1,2), min(Monthly_returns,[],2), max(Monthly_returns,[],2), skewness(Monthly_returns,1,2), kurtosis(Monthly_returns,1,2),'VariableNames',Statistics_names);
%writetable(Table2,'Universe.xlsx','Sheet',3,'Range','B1');
xlswrite('Universe.xlsx',table2array(Table1),'Sheet3','B2');


C=cov(returns');
R=corrcoef(C);

xlswrite('Universe.xlsx',R,'Sheet4','B2');     %Write data
xlswrite('Universe.xlsx',Ticker','Sheet4','B1');     %Write column header
xlswrite('Universe.xlsx',Ticker,'Sheet4','A2');      %Write row header

xlswrite('Universe.xlsx',C,'Sheet5','B2');     %Write data
xlswrite('Universe.xlsx',Ticker','Sheet5','B1');     %Write column header
xlswrite('Universe.xlsx',Ticker,'Sheet5','A2');      %Write row header

save('Universe.mat', 'AdjClose', 'R', 'C', 'Table1', 'Table2', 'Ticker', 'returns', 'M', 'Shares');





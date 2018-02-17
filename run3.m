load('pre_prices.mat');
load('selected_Universe.mat');

[M,N]=size(True);
weight=ones(3,N)/3;

learning_rate=0.001;

for r=1:10
    learning_rate=0.001/(2^(r-1));
    learning_r(r)=learning_rate;
for i=1:M
    weight=ones(3,N)/3;
    weight_temp=ones(3,1)/3;
    for j=1:N-1
        para=[Predict_AdjClose(i,j) Predict_returns(i,j) Predict_sharpe_ratio(i,j)];
        sgn=sign(para*weight_temp-True(i,j));
        weight_temp=weight_temp-sgn*learning_rate*para';
        weight(:,j+1)=weight_temp;

    end
    Predict_combin(i,:)=sum([Predict_AdjClose(i,:); Predict_returns(i,:); Predict_sharpe_ratio(i,:)].*weight)';

end

errorC=abs(Predict_combin-True)./True;
meanError(r)=mean(mean((errorC),2));

end
figure();
plot(learning_r, meanError);
xlabel('learning rate');
ylabel('mean L1-loss');

figure();
plot(learning_r, meanError);
xlabel('learning rate');
ylabel('mean L1-loss');
set(gca, 'XScale', 'log');


learning_rate=0.0001;
for i=1:M
    weight=ones(3,N)/3;
    weight_temp=ones(3,1)/3;
    for j=1:N-1
        para=[Predict_AdjClose(i,j) Predict_returns(i,j) Predict_sharpe_ratio(i,j)];
        sgn=sign(para*weight_temp-True(i,j));
        weight_temp=weight_temp-sgn*learning_rate*para';
        weight(:,j+1)=weight_temp;

    end
    Predict_combin(i,:)=sum([Predict_AdjClose(i,:); Predict_returns(i,:); Predict_sharpe_ratio(i,:)].*weight)';

end

errorC=abs(Predict_combin-True)./True;
meanErrorC=mean(mean((errorC),2));
meanErrorC_final=mean(mean((errorC(:,100:end)),2));


for i=1:(N-100)/5
    ranged_weekly_returns(:,i) = True(:,100+i*5)./True(:,100+(i-1)*5)-1;
    Pre_weekly_returns(:,i) = Predict_combin(:,100+i*5)./Predict_combin(:,100+(i-1)*5)-1;

end

sigma=cov(ranged_weekly_returns');

Pre_weekly_alpha=Pre_weekly_returns-mean(ranged_weekly_returns);


cap_weight(:,1)=selected_Shares.* True(:,100);
cap_weight(:,1)=cap_weight(:,1)/sum(cap_weight(:,1));


for i=1:(N-100)/5
    cap_returns(1,i)=(1+ranged_weekly_returns(:,i))'*cap_weight(:,i);
    cap_weight(:,i+1) = cap_weight(:,i).*(1+ranged_weekly_returns(:,i));
    cap_weight(:,i+1)=cap_weight(:,i+1)/sum(cap_weight(:,i+1));
end
cap_returns=cap_returns-1;

sigma_all=cov([ranged_weekly_returns; cap_returns]');
Beta = sigma_all(1:M,M+1)/sigma_all(M+1,M+1);

lambda=[1, 10, 20:20:100, 200:200:4000];
for k=1:27

for i=1:(N-100)/5
    active_weight(:,i) = Optimize(cap_weight(:,i), Pre_weekly_alpha(:,i) , sigma, Beta,lambda(k));

end

Wp=(cap_weight(:,1:end-1)+active_weight);
Portfolio_return=sum(Wp.*ranged_weekly_returns);
TE(k)=std(cap_returns-Portfolio_return)*sqrt(52)


end

figure();
grid on;
plot(lambda, TE);
xlabel('lambda');
ylabel('Tracking Error');
set(gca, 'XScale', 'log');

for k=1:27
    if TE(k)<0.03
        lam=lambda(k);
        break
    end
end
        

for i=1:(N-100)/5
    active_weight(:,i) = Optimize(cap_weight(:,i), Pre_weekly_alpha(:,i) , sigma, Beta,lam);

end

[~,weeks]=size(Portfolio_return);
Wp=(cap_weight(:,1:end-1)+active_weight);
Portfolio_return=sum(Wp.*ranged_weekly_returns);
MeanPortfolioRetern=mean(Portfolio_return);
MeanCapRetern=mean(cap_returns);
TE=std(cap_returns-Portfolio_return)*sqrt(52)
IR=(prod(MeanPortfolioRetern)^(52/weeks)-prod(MeanCapRetern)^(52/weeks))/TE
IC=IR/sqrt(52)

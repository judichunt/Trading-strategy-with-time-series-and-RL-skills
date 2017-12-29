function active_weight = Optimize(cap_weight, alpha , sigma,Beta,lambda)

%lambda=1600;
[M,~]=size(cap_weight);

Aeq=ones(1,M);
beq=0;
lb=-cap_weight;
ub=1-cap_weight;
H=0.5*lambda*sigma;
f=-alpha';
A=[Beta'; -Beta'];
b=[0.3; 0.3];

active_weight= quadprog(H,f,A,b,Aeq,beq,lb,ub);


Beta'*active_weight;
sqrt(active_weight'*sigma*active_weight);





end


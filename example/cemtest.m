clear
n = 32;
tn = n*2;
CEMOPT1 = cemoption;
CEMOPT1.set('norm','L2')
CEMOPT1.set('N',[n n 1])
CEMOPT1.set('h',[1/n 1/n 0]);

CEMOPT2 = cemoption;
CEMOPT2.set('norm','L2')
CEMOPT2.set('N',[tn+1 tn+1 1])
CEMOPT2.set('h',[1/tn 1/tn 0]);

CEM1 = cem(CEMOPT1);
CEM2 = cem(CEMOPT2);


Z1 = zeros(n^2,5000);
Z2 = zeros(n^2,5000);

for i = 1 : 5000
    Z1(:,i) = CEM1.generate_vector;
    z = CEM2.generate_matrix;
    Z2(:,i) = reshape(z(2:2:end-1,2:2:end-1),n^2,1);
end

CEM1.build_cov;
C1 = cov(Z1');
C2 = cov(Z2');
figure(1)
mesh(C1-CEM1.R);
figure(2)
mesh(C1-C2);
% figure(3)
% mesh(cov(Z1')-cov(Z2'));
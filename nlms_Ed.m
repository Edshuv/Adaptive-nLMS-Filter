function [e,w,y] = nlms_Ed(x,d,mu,L)

% x = recieved audio signal 
% d = excitation signal
% note y = d_hat, L = length of the filter (iterations)
% beta = coef, mu = step size 
w = zeros(L,1);         % weigth when w[1] = 0;
y = zeros(length(x),1);
e = zeros(length(x),1);
x_hat = zeros(L,1);


for n = 1:1:length(x)
    if(n<L)
        x_hat = circshift(x_hat,1);
        x_hat(1) = x(n);
    else 
    x_hat = x(n:-1:n-L+1);
    end
    y(n) = transpose(w)*x_hat;
    e(n) = d(n)-y(n);
    %w = w+(mu/(eps+transpose(x_hat)*x_hat))*x_hat*e(n);
     w = w+(mu/(eps+(norm(x_hat))^2 ) )*x_hat*e(n);
end
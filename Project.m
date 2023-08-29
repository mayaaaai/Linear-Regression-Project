clear variables;
syms k;

%% Extracting data & obtaining both identification and validation data set

load("product_6.mat");

time_id = time(1:round((80*length(time))/100));
y_id = y(1:round((80*length(y))/100));

time_val = time(round((80*length(time))/100):end);
y_val = y(round((80*length(y))/100):end);

MSEs_id = zeros(7, 1);
MSEs_val = zeros(7, 1);

%% Computing the structure of the function in order to use the linear regression method 

for m = 1:7
    n = 2*m + 2;
    phi = zeros(1, n);
    for k = 1:length(time_id)
        i = 1;
        for j = 3:n
            if i <= m
                phi(k,1) = 1;
                phi(k,2) = k;
                if (mod(j,2)==0)
                    phi(k,j) = sin(2*pi*i*k/12);
                    i = i + 1;
                end
                if (mod(j,2)~=0)
                    phi(k,j) = cos(2*pi*i*k/12); 
                end
            end
        end
    end

    tetha = phi\y_id;

    % Identification - obtaining the approximation of the function:
    for  k = 1:length(time_id)
        ff(k) = tetha(1)*1 + tetha(2).*k;
        for i = 1:m
            ff(k) = ff(k) + tetha(2*i+1)*cos(2*pi*i.*k/12) + tetha(2*i+2)*sin(2*pi*i.*k/12);
        end
    end
    
    % Computing the error for the identification data set:
    mse_id = 1/length(time_id) * sum((y_id - ff').^2);
    MSEs_id(m, 1) = mse_id;

    % Validation - obtaining the approximation of the function:
    for k_v = 75:94
        ff_v(k_v) = tetha(1)*1 + tetha(2).*k_v;
        for i = 1:m
            ff_v(k_v) = ff_v(k_v) + tetha(2*i+1)*cos(2*pi*i.*k_v/12) + tetha(2*i+2)*sin(2*pi*i.*k_v/12);
        end
    end
    ff_vf = ff_v(75:94);

    % Computing the error for the validation data set:
    mse_val = 1/length(time_val) * sum((y_val - ff_vf').^2);
    MSEs_val(m, 1) = mse_val;

    % Plot:
    figure,
    plot(time_id, y_id, '-b'); hold; grid;
    plot(time_val, y_val, '--r') 
    plot(time_id, ff, '-m')
    plot(time_val, ff_vf,'-g')
    title('m = ', m); xlabel('t'); ylabel('y');
    legend('y_{id}', 'y_{val}', 'y_{id}hat', 'y_{val}hat');
end

figure,
plot(1:7, MSEs_id); grid;
title('MSE - Identification');

figure,
plot(1:7, MSEs_val); grid;
title('MSE - Validation');

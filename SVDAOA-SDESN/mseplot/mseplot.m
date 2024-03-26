
warning off             % 关闭报警信息
close all               % 关闭开启的图窗
clear                   % 清空变量
clc                     % 清空命令行
tic

%% 输入数据 
data1 = load('ESN_MSE.mat');  
data1 = data1.ESN_MSE;
data2 = load('AOAESN_MSE.mat');  
data2 = data2.AOAESN_MSE;

%% plot
figure
plot(1:length(data1), data1,'b-*')
hold on
plot(1:length(data2), data2,'rp-')
legend('ESN-MSE', 'AOA-ESN-MSE');
xlabel('Prediction horzion')
ylabel('MSE')
title('the relationship between the MSE and prediction horzion')
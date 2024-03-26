function error = fitness(W, esn, trX, trY, washout)
%�ú�������������Ӧ��ֵ
            seqDim = size(trX{1},2);
            N = length(trX);
            trainLen = size(trY,1);
            
            esn.Win = esn.inputScaling * (rand(esn.Nr, size(trX{1},2)) * 2 - 1);
            esn.Wb = esn.biasScaling * (rand(esn.Nr, 1) * 2 - 1);
            esn.Wr = full(sprand(esn.Nr,esn.Nr, esn.connectivity));
            esn.Wr(esn.Wr ~= 0) = esn.Wr(esn.Wr ~= 0) * 2 - 1;
            esn.Wr = esn.Wr * (esn.rho / max(abs(eig(esn.Wr))));
            
            X = zeros(1+seqDim+esn.Nr, trainLen);
            idx = 1;
            for s = 1:N
                U = trX{s}';
                x = zeros(esn.Nr,1);
                for i = 1:size(U,2)
                    u = U(:,i);
                    x_ = tanh(esn.Win*u + esn.Wr*x + esn.Wb); 
                    x = (1-esn.alpha)*x + esn.alpha*x_;
                    if i > washout
                        X(:,idx) = [1;u;x];
                        idx = idx+1;
                    end
                end
            end
            esn.internalState = X(1+seqDim+1:end,:);
            error = ridgeregression0( W, esn.internalState, trY, esn);
end



%load data inputnum hiddennum_best outputnum net inputn outputn inputn_test outputs output_test

%��ȡ
% w1=x(1:inputnum*hiddennum_best);%ȡ������������������ӵ�Ȩֵ
% B1=x(inputnum*hiddennum_best+1:inputnum*hiddennum_best+hiddennum_best);%��������Ԫ��ֵ
% w2=x(inputnum*hiddennum_best+hiddennum_best+1:inputnum*hiddennum_best+hiddennum_best+hiddennum_best*outputnum);%ȡ������������������ӵ�Ȩֵ
% B2=x(inputnum*hiddennum_best+hiddennum_best+hiddennum_best*outputnum+1:inputnum*hiddennum_best+hiddennum_best+hiddennum_best*outputnum+outputnum);%�������Ԫ��ֵ
% 
% net.trainParam.showWindow=0;  %���ط������
% 
% %����Ȩֵ��ֵ
% net.iw{1,1}=reshape(w1,hiddennum_best,inputnum);%��w1��1��inputnum*hiddennum��תΪhiddennum��inputnum�еĶ�ά����
% net.lw{2,1}=reshape(w2,outputnum,hiddennum_best);%���ľ���ı����ʽ
% net.b{1}=reshape(B1,hiddennum_best,1);%1��hiddennum�У�Ϊ���������Ԫ��ֵ
% net.b{2}=reshape(B2,outputnum,1);
% 
% %����ѵ��
% net=train(net,inputn,outputn);
% 
% an=sim(net,inputn_test);
% test_simu=mapminmax('reverse',an,outputs);
% 
% error=mse(output_test,test_simu);
% 



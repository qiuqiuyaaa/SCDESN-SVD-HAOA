   

function [s]  =creatbox(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,Function_name)
item = 30;
PntSet1 = zeros(item,1);
PntSet2 =zeros(item,1);
PntSet3 = zeros(item,1);
PntSet4 = zeros(item,1);
PntSet5 = zeros(item,1);
% PntSet6 = zeros(item,1);
% PntSet7 = zeros(item,1);
% PntSet8 = zeros(item,1);
for i = 1:item
% 'HAOA','AOA','SCA','GWO','SSA','WOA','DAOA','APAOA'
[PntSet1(i),~,~]=HSMAAOA(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,Function_name);
[PntSet2(i),~,~]=AOA(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,Function_name);
[PntSet4(i),~,~]=SCAAOA(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,Function_name);
[PntSet3(i),~,~]=SSA(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,Function_name);
% [PntSet5(i),~,~]=AOA2(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,Function_name);
[PntSet5(i),~,~]=AOA1(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,Function_name);
% [PntSet7(i),~,~]=SCA(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,Function_name);
% [PntSet8(i),~,~]=IAOA(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,Function_name);

end
s = [PntSet1,PntSet2,PntSet3,PntSet4,PntSet5];
end


function h = barycentric_plot(samples, probs, names, fs)
% -------------------------------------------------------------------------
% Input
%     sample = an array of size Tx3. Column 1: theta_left, column 2: 
%              theta_rope, column 3: theta_right. If rope == 0, the 
%              middle column contains NaN.
%     probs = [p_left, p_rope, p_right]
%     names = a cell array with the two classifier names.
%     fs = font size
%
% Output: 
%     h = handle with fields: outer, inner, text, axes
%
% -------------------------------------------------------------------------
% L.Kuncheva 26/06/2020

if nargin == 3, fs = 12; end

% Orange layout
ht = sqrt(1-0.25); % height of the triangle
figure, hold on
h.outer = plot([0 1 0.5 0],[0 0 ht 0],'r-','color',...
    [1 0.5 0],'linewidth',1.8);
h.inner = plot([0.25 0.75 0.5; 0.5 0.5 0.5],[[0.5 0.5 0]*ht; ...
    [1 1 1]*ht/3], 'r-','color',[1 0.5 0],'linewidth',1);

% Data
x = samples(:,3) + 0.5*samples(:,2);
y = ht*samples(:,2);
density_plot(x,y,30)
axis equal off

% Lettering
s1 = sprintf('p(%s) = %.3f',names{1},probs(1));
s2 = sprintf('p(%s) = %.3f',names{2},probs(3));
s3 = sprintf('p(Rope) = %.3f',probs(2));
h.text = text([0,1,0.5],[0 0 ht],{s1,s2,s3});
set(h.text,'FontSize',fs)
adjust_text(h.text)
title('AOA vs HAOA for Bayesian Signed Rank Test',FontSize=14)
% Axes
h.axes = gca;
end

function adjust_text(v)
e1 = v(1).Extent; % left
v(1).Position = [-e1(3)/2 -e1(4)];
e2 = v(2).Extent; % right
v(2).Position = [1-e2(3)/2 -e2(4)];
e3 = v(3).Extent; % rope
v(3).Position = [0.5-e3(3)/2 e3(2)+e3(4)+0.02];
axis([-e1(3)/2 1+e2(3)/2 -e1(4)/2 e3(2)+e3(4)+0.02])
end
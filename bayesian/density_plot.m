function density_plot(x,y,ps)
% -------------------------------------------------------------------------
% Input
%     x,y = columns of point coordinates
%     ps = point size
%
% Output: 
%     plot in the current axes
%
% -------------------------------------------------------------------------
% Lucy Kuncheva 27/06/2020

% Find the k nearest neighbours
k = 100;
[~,dist] = knnsearch([x,y],[x,y],'k',k); 
dens = dist(:,end); 
z = prctile(dens,90);
dens(dens > z) = z; % clip the highest values

% the smaller the distance, the lighter the colour

% Create colour map
nc = 80; % number of colours
cm = jet(nc);


% Scale according to colour map and retrieve colours
dens_index = ceil((max(dens) - dens)/(max(dens)-min(dens))*nc + eps);
colours = cm(dens_index,:);

range(dens_index)
% Plot
scatter(x,y,ps,colours,'.')

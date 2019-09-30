% works on matlab 64
% calculates using 'single'

function [D_ext, sample] = FPS_graph(G, N, first_idx)

nv = size(G,1);

if(~exist('first_idx', 'var'))   
    first_idx = randi(nv);
end

sample = zeros(N, 1);

D = zeros(N, nv);

for i=1:N   
    
    if(i == 1)
        idx = first_idx;
    elseif (i == 2)
        [~, idx] = max(D(1, :));
    else
        [~, idx] = max(min(D(1:i-1, :)));
    end
    
    sample(i) = idx;
    D(i, :) = graphshortestpath(G, idx);
    
%     i
end

D_ext = D;
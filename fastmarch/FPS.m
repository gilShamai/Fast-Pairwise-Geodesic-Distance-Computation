% works on matlab 64
% calculates using 'single'

function [D_ext, sample] = FPS(S, N, first_idx)

nv = length(S.X);
options.mode = 'single';
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
    src = inf(nv, 1);
    src(idx) = 0;
    
    D(i, :) = fastmarch(S.TRIV, S.X, S.Y, S.Z, src, options);
%     i
end

D_ext = D;
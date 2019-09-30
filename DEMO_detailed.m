%{
    In this demo:

    Computing all pairwise geodesic distances of a 50K vertices mesh 
    Preprocessing time: 2-3 seconds.
    Query time: < 1 milisecond.
    
    
    If using these ideas please cite:

    [1] Gil Shamai, Michael Zibulevsky, and Ron Kimmel. "Efficient 
    Inter-Geodesic Distance Computation and Fast Classical Scaling". 
    IEEE transactions on pattern analysis and machine intelligence (2018).
    
    [2] Gil Shamai, Michael Zibulevsky, and Ron Kimmel. 
    "Accelerating the computation of canonical forms for 3D nonrigid 
    objects using multidimensional scaling." In Proceedings of the 
    2015 Eurographics Workshop on 3D Object Retrieval, pp. 71-78. 
    Eurographics Association, 2015.
%}

close all;
clear all;
clc;
addpath('fastmarch');

IsGraph = false; % false for 3D triangle mesh. True for an arbitrary graph (e.g. create a graph from a 3D point by connecting near neighbors).
%% load a triangular mesh

if ~IsGraph
    fprintf('Creating shape...\n');
    load 'david0.mat';
    
    nv = length(surface.X);

    figure;
    trisurf(surface.TRIV, surface.X, surface.Y, surface.Z, zeros(nv,1)); axis equal;axis off; 
    shading interp;lighting phong;cameratoolbar;camlight headlight
end
%% instead - create a graph
if IsGraph
    fprintf('Creating graph...\n');
    load 'david0.mat';
    
    nv = length(surface.X);
    G = sparse(nv, nv);
    TRIV = surface.TRIV;
    V = [surface.X surface.Y surface.Z];
    for i=1:size(TRIV,1)        
        dd = squareform(pdist(V(TRIV(i,:),:)));    
        G(TRIV(i,:), TRIV(i,:)) = dd;
    end
end

%% farthest point sampling
fprintf('Fartherst point sampling...\n');
N = 20; % number of samples. more samples should increase accuracy, but increase complexities (quasy linearly). 
% recomended 10-200 according to application (See [1] for accuracy and time analysis).

tic
if ~IsGraph
    [~, first_idx] = FPS(surface, 1);
    [D_ext, sample2] = FPS(surface, N, first_idx);
else
    [~, first_idx] = FPS_graph(G, 1);
    [D_ext, sample2] = FPS_graph(G, N, first_idx);
end
t = toc;
fprintf('Finished in %f seconds. \n', t);
R = D_ext';

%% Fast geodesic computation 
fprintf('Compute S and T...\n');
%{
    Based on NMDS method in [1]. 
%}
tic
[S, T] = FastGeodesics(R, sample2); % D ~ S*T*S';
t2 = toc;
fprintf('Finished in %f seconds. \n', t2);

%% Distance query
fprintf('Fast Geodesics...\n');
idx = 30000;
tic
d_fg = S(idx, :)*T*S'; % fast geodesics computation
t = toc;
fprintf('Query time: %f seconds. \n', t);

%% Compare with fast marching (mesh) or to dijkstra (graph)
tic
if ~IsGraph
    str = 'Fast marching';
    fprintf([str '...\n']);
    options.mode = 'single';
    src = inf(nv, 1);
    src(idx) = 0;
    d_fm = fastmarch(surface.TRIV, surface.X, surface.Y, surface.Z, src, options); % fast geodesics computation
else
    str = 'Dijkstra';
    fprintf([str '...\n']);
    d_fm = graphshortestpath(G, idx);    
end

t = toc;
fprintf('Query time: %f seconds. \n', t);

figure;
scatter(d_fm, d_fg, 1, 'black','.');
axis equal
axis([0 max(d_fm) 0 max(d_fm)])
xlabel(str);
ylabel('Fast Geodesics');
set(gca, 'fontsize', 20);

figure;
subplot(1, 2, 1);
trisurf(surface.TRIV, surface.X, surface.Y, surface.Z, d_fg); axis equal;axis off; 
shading interp;lighting phong;cameratoolbar;camlight headlight
hold on;
scatter3(surface.X(idx), surface.Y(idx), surface.Z(idx), 150, 'r', 'filled');
title(str, 'fontsize', 20);

subplot(1, 2, 2);
trisurf(surface.TRIV, surface.X, surface.Y, surface.Z, d_fm); axis equal;axis off; 
hold on;
shading interp;lighting phong;cameratoolbar;camlight headlight
scatter3(surface.X(idx), surface.Y(idx), surface.Z(idx), 150, 'r', 'filled');
title('Fast Geodesics', 'fontsize', 20);

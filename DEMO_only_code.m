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

N = 20; % number of samples
%% preprocessing
load 'david0.mat';
nv = length(surface.X);
[~, first_idx] = FPS(surface, 1);
[D_ext, sample2] = FPS(surface, N, first_idx);
R = D_ext';
[S, T] = FastGeodesics(R, sample2); % D ~ S*T*S';

%% distance query: from vertex 30000 to the rest
idx = 30000;
d = S(idx, :)*T*S'; % fast geodesics computation

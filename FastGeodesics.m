%{ 
    FastGeodesics - Fast geodesic distance computation for large shapes    

    Description:

     extract S and T such that D ~ S*T*S', where S and T are 
     small matrices. 
    
    Input: 
    
     sample2 - N x 1 - indices of samples.
     R - nv x N geodesic distances from samples to the rest.
    
    Output: 
    
     S and T - S is nv x [N/2] and T is [N/2] x [N/2], where nv is the 
               number of vertices and N is the number of samples. 
               S and T approximate the pairwise-geodesics D as D ~ S*T*S'

    References:

    [1] Gil Shamai, Michael Zibulevsky, and Ron Kimmel. "Efficient 
    Inter-Geodesic Distance Computation and Fast Classical Scaling". 
    IEEE transactions on pattern analysis and machine intelligence (2018).
    
    [2] Gil Shamai, Michael Zibulevsky, and Ron Kimmel. 
    "Accelerating the computation of canonical forms for 3D nonrigid 
    objects using multidimensional scaling." In Proceedings of the 
    2015 Eurographics Workshop on 3D Object Retrieval, pp. 71-78. 
    Eurographics Association, 2015.
   
    FOR ACADEMIC USE ONLY.
    ANY ACADEMIC USE OF THIS CODE MUST CITE THE ABOVE REFERENCE. 
    FOR ANY OTHER USE PLEASE CONTACT THE AUTHORS.
%}

function [S, T] = FastGeodesics(R, sample2)
N = length(sample2);
N1 = round(0.5*N);

% Compute the approximation components
U = R(sample2, :);
[V,D] = eigs(0.5*(U + U'), N1, 'lm');
d = diag(D);
d_ = 1./d(1:N1);
D_ = diag(d_);

S = R;
T = V*D_*V';

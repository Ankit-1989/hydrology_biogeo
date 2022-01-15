function [A] = func_init_array(H)
%%
cn = 0;  % For inactive cavity column

% Intitializing concentration array for transport code
A.CO{1} = zeros(11,1);
A.CO{2} = zeros(4,1);
A.CO{3} = zeros(4,1);
%% Cavity variable initialization

A.u_ca_all = zeros(H.meshtri.n_elements,1);
A.q_ca_all = zeros(H.meshtri.n_elements,1);
A.h_ca_all = zeros(H.meshtri.n_elements,1);
A.bio_geo = zeros(H.meshtri.n_elements,1);
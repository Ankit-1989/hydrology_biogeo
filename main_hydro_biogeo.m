%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Hydrology-biogeochemistry model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars
%% load hydrological simulation data
[H] = func_load_data();

%% Initialize the arrays 
[A] = func_init_array(H);

%% Constants
C = func_const();

%% Hydrology model calculation
% arrange_channel_info % Extract values
[A]= func_arrange_channel(H,A);

%% time loop 
for tt = 130:220
    tt
% Cavity: for all cavity
[A,C] = func_all_cavity(H,A,C,tt);

%% Channel: only active channel    
for no_channel = 1:numel(H.II_ch)-1
    
[A]= func_channel_init(A,no_channel);
    
%% transport code     
% Advection
[A] = func_TVD_irrregular_grid(A,C,tt,no_channel);
% Dispersion
if no_channel ==1, A.delxi(10,1) = A.delxi(10,1)+1; end  % same lengenth of channel segment giving Nan's.. To solve the problem
[A] = func_dispersion_irregular_grid(A,tt,no_channel);

%% Calculation for cavities associated to active channels
[A]= func_active_cavity(H,A,no_channel,tt);

%%  This part is calculating exchange between cavities and channels
A.volc = A.delxi_n{1}(8,1).*A.X_chn{1}(8,tt);
A.vol_ch = A.delxi .* A.X_ch2(:,tt);

% Source-sink calculation - cavity-channel
% if q_ca is negative cavity acts as sink, else as source for channel.. 
[A] = func_source_sink(A,C,no_channel);

% Channel-Cavity
% Channel Biogeo
A.dCh = (A.So_ca_ch + A.Si_ch_ca) .* C.dt;

%active cavity Bio
A.dCa = (A.So_ch_ca + A.Si_ca_ch) .* C.dt;

% Final concentration in channel (transport+exchange)
% A.CO_final{no_channel}(:,tt) = A.CO{no_channel} + A.dCh;  
A.CO{no_channel} = A.CO{no_channel} + A.dCh;

% Just saving the concentration of each timestep 
A.CO_final{no_channel}(:,tt) = A.CO{no_channel};
                     
end

%% Exchange between channels
% exchange between channels at junction

[A] = func_exchange_between_channels(H,A,tt);

% Updating the saved conc. after exchange
% A.CO_final{no_channe}(:,tt) = A.CO{no_channel} + A.dCh;  
A.CO_final{1}(:,tt) = A.CO{1};

%% Biogeochemistry

% initialise biogeochemical variables
% biogeochem_setup

% run active cavity biogeochemical processes
% active_cavity_biogeochem

% run other cavity biogeochemical processes     
%other_cavity_biogeochem
    
end

%% plotting 
figure
for no_channel = 1:numel(H.II_ch)-1
subplot(numel(H.II_ch)-1,2,(no_channel*2)-1)
n = length(H.II_ch{no_channel});
ch_seg = A.delxi_n{no_channel};
plot(cumsum(ch_seg(1:n)),A.CO_final{no_channel}(1:n,:)); 
hold on
% plot(cumsum(ch_seg(1:n)),CO_TVD{no_channel}(1:n,:)); 
title(['advection - channel number:' num2str(no_channel)])
end


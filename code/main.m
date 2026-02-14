
% ======================================================================= %
%                                                                         %
% This script visually compares two gap-filling methods in time (standard %
% and custom) on a global surface ocean dataset of chlorophyll a          %
% concentration (from OC-CCI), which is affected by ice masking. Sea ice  % 
% fraction data (from CMEMS PHYS reanalysis) is used to mask areas that   %
% do not need to be filled with data. The script first calculates the sea % 
% ice fraction above which phytoplankton growth is unlikely by analysing  %
% chlorophyll concentrations.                                             %
%                                                                         % 
%   WRITTEN BY A. RUFAS, UNIVERISTY OF OXFORD                             %
%   Anna.RufasBlanco@earth.ox.ac.uk                                       %
%                                                                         %
%   Version 1.0 - Completed 4 Feb 2025                                    %
%                                                                         %
% ======================================================================= %

close all; clear all; clc
addpath(genpath(fullfile('code')));
addpath(genpath(fullfile('resources','external'))); 
addpath(genpath(fullfile('resources','internal'))); 
addpath(genpath(fullfile('figures')))

% =========================================================================
%%
% -------------------------------------------------------------------------
% SECTION 1 - PRESETS
% -------------------------------------------------------------------------

% Output files
fullpathOutputChlaGapFilledCustom = fullfile('data','processed','gapfilled_custom_chla_occci.mat');
fullpathOutputChlaGapFilledStd    = fullfile('data','processed','gapfilled_standard_chla_occci.mat');
fullpathOutputMask                = fullfile('data','processed','mask_custom_icefrac_cmems_chla_occci.mat');
fullpathLogFile                   = fullfile('logs','logGapFilling.txt');

% Load the chlorophyll dataset
load(fullfile('data','raw','chla_occci.mat'),'chla','chla_lat','chla_lon')

% Load sea ice fraction
load(fullfile('data','raw','icefrac_cmems_phys.mat'),'icefrac','icefrac_lat','icefrac_lon')

% Constants for gap-filling methods
GAPFILLING_METHOD_CUSTOM = 1; % use custom gap-filling method
GAPFILLING_METHOD_STD = 0;    % use standard interp1 gap-filling method

% Log progress
logID = fopen(fullpathLogFile,'w'); 

% =========================================================================
%%
% -------------------------------------------------------------------------
% SECTION 2 - CALCULATE AND PLOT MEAN SEA ICE FRACTION THRESHOLD
% -------------------------------------------------------------------------

meanIceFracThresholdThatAllowsPhytoGrowth = calculateSeaIceFractionThreshold(...
    chla,icefrac,chla_lat,chla_lon,icefrac_lat,icefrac_lon,(1:12),logID); % 0.3419 (Aqua-MODIS), 0.3219 (OC-CCI)

% =========================================================================
%%
% -------------------------------------------------------------------------
% SECTION 3 - COMPARE GAP-FILLING INTERPOLATION METHODS IN TIME AND USE 
% THE MASK
% -------------------------------------------------------------------------

% Custom method
chlaFilledMethodCustom = manageGapsInOceanDataIceMasked(chla,icefrac,...
    chla_lat,chla_lon,icefrac_lat,icefrac_lon,(1:12),logID,...
    meanIceFracThresholdThatAllowsPhytoGrowth,GAPFILLING_METHOD_CUSTOM);

save(fullpathOutputChlaGapFilledCustom,'chlaFilledMethodCustom','chla_lat','chla_lon','-v7.3')
prepareDataForPlotting(fullpathOutputChlaGapFilledCustom,[],'mg m^{-3}',...
    0,1,true,'fig_gapfilled_custom_chla_occci','Chla OC-CCI gap-filled custom')

% Standard method
chlaFilledMethodStd = manageGapsInOceanDataIceMasked(chla,icefrac,...
    chla_lat,chla_lon,icefrac_lat,icefrac_lon,(1:12),logID,...
    meanIceFracThresholdThatAllowsPhytoGrowth,GAPFILLING_METHOD_STD);

save(fullpathOutputChlaGapFilledStd,'chlaFilledMethodStd','chla_lat','chla_lon','-v7.3')
prepareDataForPlotting(fullpathOutputChlaGapFilledStd,[],'mg m^{-3}',...
    0,1,true,'fig_gapfilled_standard_chla_occci','Chla OC-CCI gap-filled interp1')

% Close the log file after all operations are done
fclose(logID); 

% =========================================================================
%%
% -------------------------------------------------------------------------
% SECTION 4 - CREATE A MASK BASED ON THE COMBINED USE OF CHLA AND SEA ICE
% FRACTION
% -------------------------------------------------------------------------

% Custom method
mask = chlaFilledMethodCustom;
mask(mask >= 0) = 1;   % valid data points (where chla points were filled)
mask(isnan(mask)) = 0; % invalid data points (where filling of chla points was not possible)

% Save
mask_lat = chla_lat;
mask_lon = chla_lon;
save(fullpathOutputMask,'mask','mask_lat','mask_lon','-v7.3')

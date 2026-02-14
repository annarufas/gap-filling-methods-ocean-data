function meanIceFracThatAllowsPhytoGrowth = calculateSeaIceFractionThreshold(...
    chlaData,iceFracMask,chla_lat,chla_lon,icefrac_lat,icefrac_lon,t,logID)

% CALCULATESEAICEFRACTIONTHRESHOLD Calculates the sea ice fraction above 
% which phytoplankton cannot grow on average. It uses chlorophyll a 
% concentration to account for phytoplankton growth. This ensures 
% biologically plausible outputs, as ice alone does not necessarily prevent 
% phytoplankton growth, unless it exceeds a threshold value.
%
%   INPUT: 
%       chlaData    - chla data array containing gaps (NaN values)
%       iceFracMask - sea ice fraction array used to apply a mask
%       chla_lat    - latitude vector for chla data 
%       chla_lon    - longitude vector for chla data 
%       icefrac_lat - latitude vector for sea ice fraction
%       icefrac_lon - longitude vector for sea ice fraction 
%       t           - time vector indices corresponding to the data (e.g., 1:12 for monthly data)
%       logID       - to record progress
%
%   OUTPUT:
%       meanIceFracThatAllowsPhytoGrowth - global mean sea ice fraction threshold allowing phytoplankton growth
%
%   WRITTEN BY A. RUFAS, UNIVERISTY OF OXFORD
%   Anna.RufasBlanco@earth.ox.ac.uk
%
%   Version 1.0 - Completed 14 Jan 2024  
%
% =========================================================================
%%
% -------------------------------------------------------------------------
% PROCESSING STEPS
% -------------------------------------------------------------------------

%% Input validation

% Check if data and mask number of dimensions match
if ndims(chlaData) ~= ndims(iceFracMask)
    throwError(logID,'ERROR: input data array and mask must have the same no. dimensions');
end

% Check time vector length based on dimensions
if ndims(chlaData) == 3 % a lat x lon x time array
    if length(t) ~= size(chlaData, 3)
        throwError(logID,'ERROR: time vector length must match the 3rd dimension of the data array');
    end
elseif isvector(chlaData) % a time vector
    if length(t) ~= numel(chlaData)
        throwError(logID,'ERROR: time vector length must match the length of the data array');
    end
end

%%  Regrid the mask to same grid used by data

if ndims(chlaData) == 3 && ~isequal(size(chlaData), size(iceFracMask))
    iceFracMask = regridVariable(chla_lat,chla_lon,[],t,iceFracMask,...
        icefrac_lat,icefrac_lon,[],t);
    icefrac_lat = chla_lat;
    icefrac_lon = chla_lon;
end

%% Calculate

iceFracThatAllowsPhytoGrowth = NaN(size(chlaData,1), size(chlaData,2));
   
for iRow = 1:size(chlaData,1)
    for iCol = 1:size(chlaData,2)
        localChla = squeeze(chlaData(iRow,iCol,:)); 
        localIceFrac = squeeze(iceFracMask(iRow,iCol,:));
        
        % Compute valid points where data exists and ice fraction mask 
        % could potentially be applied
        validPoints = ~isnan(localChla) & (localIceFrac > 0);
        if any(validPoints)
            iceFracThatAllowsPhytoGrowth(iRow,iCol) = mean(localIceFrac(validPoints));
        end

    end
end

% Calculate mean sea ice fraction across the grid
meanIceFracThatAllowsPhytoGrowth = mean(iceFracThatAllowsPhytoGrowth(:), 'omitnan');
fprintf(logID, 'The ice fraction threshold is %.2f.\n', meanIceFracThatAllowsPhytoGrowth);

%% Plot

myColourMap = flipud(brewermap(1000,'RdYlBu')); % flip to have blue colours for low values

plotOceanVariableMaps(iceFracThatAllowsPhytoGrowth,icefrac_lon,icefrac_lat,...
    myColourMap,'Fraction',0,1,true,{'Mean sea ice fraction that allows presence of chla'},...
    'fig_mean_icefrac_for_phyto_growth',[])

end % calculateSeaIceFractionThreshold
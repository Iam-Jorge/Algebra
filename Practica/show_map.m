% Created on 2021 by José Ángel Martín Baos
% Algebra & Discrete Mathematics
% Escuela Superior de Informática, University of Castilla-La Mancha, Spain

function [] = show_map(ax, bounds, map_label, data_dir, map_filename)
% Fix plot bounds and draw the raster map of the city
% Input params:
% - ax: Axes object. Created using: fig = figure(); ax = axes('Parent', fig);
% - bounds: Bounds of the map
% - map_label: Label of the map (ex: 'Map of Ciudad Real')
% - data_dir: Directory where the datafiles are located
% - map_filename: Name of the map file (without extension)

hold(ax, 'on')

% Have you provided an image?
if ~isempty(map_filename)
    map_img_filename = strcat(data_dir, map_filename, '.png');
    map_img = imread(map_img_filename);
    image('Parent', ax, 'CData', flip(map_img,1),...
          'XData', bounds(1,1:2), 'YData', bounds(2,1:2))
end

plot(ax, [bounds(1,1), bounds(1,1), bounds(1,2), bounds(1,2), bounds(1,1)],...
         [bounds(2,1), bounds(2,2), bounds(2,2), bounds(2,1), bounds(2,1)],...
         'ro-')

xlabel(ax, 'Longitude (^o)')
ylabel(ax, 'Latitude (^o)')
title(ax, map_label)

axis(ax, 'image')
axis(ax, [bounds(1, :), bounds(2, :)])
lat_lon_proportions(ax)

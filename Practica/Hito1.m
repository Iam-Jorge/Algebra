% Incremental practice for Algebra & Discrete Mathematics
% 2021-22
% 
% Name of the student: Georgi Angelov Chervenyashki
% Hito 1

% Maps are downloaded from: https://www.openstreetmap.org/
% Remark: To convert from .osm file to the input data, you can use the
% Python script at: https://github.com/AndGem/OsmToRoadGraph

clear all;
clc;

%% Variable definition
data_dir = 'data/'; % Relative path to the data
map_filename = 'ESI'; % Values: ESI, RondaCiudadReal, CiudadReal

% Set the bounds for the map (do not change)
switch map_filename
    case 'ESI'
        bounds = [-3.9272, -3.9140; 38.9871, 38.9940];
    case 'RondaCiudadReal'
        bounds = [-3.9388, -3.9136; 38.9795, 38.9965];
    case 'CiudadReal'
        bounds = [-3.9568, -3.8964; 38.9670, 39.0038];
    otherwise
        error("Wrong value for variable `map_filename`");
end

%% Load graph data
[n_nodes, nodes, n_edges, edges] = load_pycgr(data_dir, map_filename);

%% Construct the graph
% Undirected graph for visualization
G = graph(edges.source, edges.target);
fig = figure();
ax = axes('Parent', fig); 
show_map(ax, bounds, "Mapa de " + map_filename ,data_dir, map_filename)
p = plot(G, '-b','MarkerSize', 2);
p.XData = nodes.lon';
p.YData = nodes.lat';

% Obtener todas las calles bidireccionales y sus características
for calle = 1:size(edges.source)
    % Encontrar las calles bidireccionales
    if(edges.bidirectional(calle) == 1)
        % Intercambio origen/destino y mantengo caracteristicas
        edges.source(end+1) = edges.target(calle);
        edges.target(end+1) = edges.source(calle);
        edges.length(end+1) = edges.length(calle);
        edges.maxspeed(end+1) = edges.maxspeed(calle);
        edges.name(end+1) = edges.name(calle);
        edges.bidirectional(end+1) = edges.bidirectional(calle);
        edges.type(end+1) = edges.type(calle);
    end
end

% Creación del digrafo
D = digraph(edges.source, edges.target, edges.length);

%% Plot the graph
p = plot(G, '-b');

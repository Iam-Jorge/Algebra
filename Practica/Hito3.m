% Incremental practice for Algebra & Discrete Mathematics
% 2021-22
% 
% Name of the student: Georgi Angelov Chervenyashki
% Hito 3

% Maps are downloaded from: https://www.openstreetmap.org/
% Remark: To convert from .osm file to the input data, you can use the
% Python script at: https://github.com/AndGem/OsmToRoadGraph

clear all;
clc;

%% Variable definition
data_dir = 'data/'; % Relative path to the data
map_filename = 'CiudadReal'; % Values: ESI, RondaCiudadReal, CiudadReal

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
G = graph(edges.source, edges.target);

% Cargar ODmatrix
ODmatrix = xlsread('data\ODmatrix.xlsx');

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

% Creo el digrafo
D = digraph(edges.source, edges.target, edges.length);
% Calcular el tiempo estimado
for edge = 1:length(D.Edges.EndNodes)
    found = findedge(D, edges.source(edge), edges.target(edge));
    D.Edges.Weight(found) = (edges.length(edge)/(edges.maxspeed(edge)* 90/100) * 60/1000);
    D.Edges.length(found) = edges.length(edge);
    D.Edges.maxspeed(found) = edges.maxspeed(edge);
    D.Edges.name(found) = edges.name(edge);
end

% Demanda de la zona y asignación de la matriz
G.Edges.Flow(:) = 0;
D.Edges.Flow(:) = 0;
demand = sum(ODmatrix);
for i = 1:length(ODmatrix)
    for j = 1:length(ODmatrix)
        % Evitar viajes intrazonales
        if(i~=j)
            % Viajes generados por la zona i
            tripsGenerated = ODmatrix(i,3);
            % Viajes atraidos por la zona j
            tripsAttracted = ODmatrix(j,2);
            % Demanda de la zona i a la zona j
            trafficFlow = tripsGenerated * tripsAttracted / demand(2);
            % Camino minimo por cada par i,j
            path = shortestpath(D, ODmatrix(i), ODmatrix(j));
            for x = 1:length(path)-1
                % Comprobar si la arista esta en el camino minimo y sumar
                % su flujo
                D.Edges.Flow(findedge(D, path(x), path(x+1))) = D.Edges.Flow(findedge(D, path(x), path(x+1))) + trafficFlow;
            end
        end
    end
end

% Copio los valores de D (digrafo) a G (grafo simple)
% Teniendo en cuenta las calles bidireccionales
for i = 1:length(D.Edges.EndNodes)
    if(findedge(G, D.Edges.EndNodes(i,1), D.Edges.EndNodes(i,2))~=0)
        G.Edges.Flow(findedge(G, D.Edges.EndNodes(i,1), D.Edges.EndNodes(i,2))) = D.Edges.Flow(i);
    elseif(findedge(G, D.Edges.EndNodes(i,2), D.Edges.EndNodes(i,1))~=0)
        G.Edges.Flow(findedge(G, D.Edges.EndNodes(i,2), D.Edges.EndNodes(i,1))) = D.Edges.Flow(i);
    else
    end
end

% Plot del grafo
fig = figure('Name','Simulando el tráfico en la ciudad','NumberTitle','off');
ax = axes('Parent', fig); 
show_map(ax, bounds, "Simulando el tráfico en la ciudad",data_dir, map_filename)
p = plot(G, '-b','MarkerSize', 1, 'LineWidth', 10*G.Edges.Flow/max(G.Edges.Flow) + 0.01);
p.XData = nodes.lon';
p.YData = nodes.lat';
highlight(p,[ODmatrix(:,1,1)'],'NodeColor','r','MarkerSize',3);
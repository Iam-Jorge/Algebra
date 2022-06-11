% Incremental practice for Algebra & Discrete Mathematics
% 2021-22
% 
% Name of the student: Georgi Angelov Chervenyashki
% Hito 5

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

% Ruta óptima 3
fig3 = figure('Name','Ruta óptima 3 desde la Granja a ITSI','NumberTitle','off');
ax = axes('Parent', fig3); 
show_map(ax, bounds, "Ruta óptima 3 desde la Granja a ITSI",data_dir, map_filename)
p3 = plot(G, '-b','MarkerSize', 1);
p3.XData = nodes.lon';
p3.YData = nodes.lat';

% Ruta óptima 2
fig2 = figure('Name','Ruta óptima 2 desde ITSI hasta la Granja','NumberTitle','off');
ax = axes('Parent', fig2); 
show_map(ax, bounds, "Ruta óptima 2 desde ITSI hasta la Granja",data_dir, map_filename)
p2 = plot(G, '-b','MarkerSize', 1);
p2.XData = nodes.lon';
p2.YData = nodes.lat';

% Ruta óptima 1
fig1 = figure('Name','Ruta óptima 1 desde el Hospital a la ESI','NumberTitle','off');
ax = axes('Parent', fig1); 
show_map(ax, bounds, "Ruta óptima 1 desde el Hospital a la ESI",data_dir, map_filename)
p = plot(G, '-b','MarkerSize', 1);
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

% Creo el digrafo
G = digraph(edges.source, edges.target, edges.length);
% Calcular el tiempo estimado de viaje
for edge = 1:length(G.Edges.EndNodes)
    found = findedge(G, edges.source(edge), edges.target(edge));
    G.Edges.Weight(found) = (edges.length(edge)/(edges.maxspeed(edge)* 90/100) * 60/1000);
    G.Edges.length(found) = edges.length(edge);
    G.Edges.maxspeed(found) = edges.maxspeed(edge);
    G.Edges.name(found) = edges.name(edge);
end

% Cargar ODmatrix
ODmatrix = xlsread('data\ODmatrix.xlsx');

% Demanda de la zona y asignación de la matriz
G.Edges.Flow(:) = 0;
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
            path = shortestpath(G, ODmatrix(i), ODmatrix(j));
            for x = 1:length(path)-1
                % Comprobar si la arista esta en el camino minimo y sumar
                % su flujo
                G.Edges.Flow(findedge(G, path(x), path(x+1))) = G.Edges.Flow(findedge(G, path(x), path(x+1))) + trafficFlow;
            end
        end
    end
end

% Calculo de la congestion por cada arista
G.Edges.Congestion(:) = 0;
for i = 1:length(G.Edges.EndNodes)
    edges.Congestion(i) = G.Edges.Weight(i) * (1 + 0.2 * (G.Edges.Flow(i)/500)^4);
end
% Creo nuevo digrafo con la congestion como peso
G = digraph(edges.source, edges.target, edges.Congestion);

% Ruta 1. Calcular el camino minimo y resaltar
path = shortestpath(G,4034,3350);
highlight(p,[4034 3350],'NodeColor','r');
highlight(p,path,'EdgeColor','r','LineWidth',3.5);
% Calcular distancia con los nodos que componen el path
distancia = 0.0;
extimated_travel_time = 0.0;
for nodo = 1:numel(path)-1
    distancia = distancia + G.Edges.Weight(findedge(G, path(nodo), path(nodo + 1)));
    extimated_travel_time = extimated_travel_time + G.Edges.Weight(findedge(G, path(nodo), path(nodo + 1)));
end
disp('Ruta 1: Desde el Hospital a la ESI');
disp("-La distancia aproximada del camino más corto es: " + distancia + " metros.");
disp("-El tiempo estimado es de: " + round(extimated_travel_time) + " minutos.");

% Ruta 2. Calcular el camino minimo y resaltar
path2 = shortestpath(G,4785,5683);
highlight(p2,[4785 5683],'NodeColor','r');
highlight(p2,path2,'EdgeColor','r','LineWidth',3.5);
distancia2 = 0.0;
extimated_travel_time2 = 0.0;
for nodo = 1:numel(path2)-1
    distancia2 = distancia2 + G.Edges.Weight(findedge(G, path2(nodo), path2(nodo + 1)));
    extimated_travel_time2 = extimated_travel_time2 + G.Edges.Weight(findedge(G, path2(nodo), path2(nodo + 1)));
end
disp('Ruta 2: Desde ITSI hasta la Granja');
disp("-La distancia aproximada del camino más corto es: " + distancia2 + " metros.");
disp("-El tiempo estimado es de: " + round(extimated_travel_time2) + " minutos.");

% Ruta 3. Calcular el camino minimo y resaltar 
path3 = shortestpath(G,5683,4785);
highlight(p3,[5683 4785],'NodeColor','r');
highlight(p3,path3,'EdgeColor','r','LineWidth',3.5);
distancia3 = 0.0;
extimated_travel_time3 = 0.0;
for nodo = 1:numel(path3)-1
    distancia3 = distancia3 + G.Edges.Weight(findedge(G, path3(nodo), path3(nodo + 1)));
    extimated_travel_time3 = extimated_travel_time3 + G.Edges.Weight(findedge(G, path3(nodo), path3(nodo + 1)));
end
disp('Ruta 3: Desde la Granja a ITSI');
disp("-La distancia aproximada del camino más corto es: " + distancia3 + " metros.");
disp("-El tiempo estimado es de: " + round(extimated_travel_time3) + " minutos.");

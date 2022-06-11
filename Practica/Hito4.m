% Incremental practice for Algebra & Discrete Mathematics
% 2021-22
% 
% Name of the student: Georgi Angelov Chervenyashki
% Hito 4

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

% Undirected graph for visualization
fig1 = figure('Name','Análisis de la intervención en la red','NumberTitle','off');
ax = axes('Parent', fig1); 
show_map(ax, bounds, "Análisis de la intervención en la red",data_dir, map_filename)
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
G = digraph(edges.source, edges.target, []);
% Calcular el tiempo estimado
for edge = 1:length(G.Edges.EndNodes)
    found = findedge(G, edges.source(edge), edges.target(edge));
    G.Edges.Weight(found) = (edges.length(edge)/(edges.maxspeed(edge)* 90/100) * 60/1000);
    G.Edges.length(found) = edges.length(edge);
    G.Edges.maxspeed(found) = edges.maxspeed(edge);
    G.Edges.name(found) = edges.name(edge);
end

% Busqueda de las calles que vamos a modificar
peatonal1 = find(G.Edges.name == "Calle Elisa Cendreros");
peatonal2 = find(G.Edges.name == "Calle de la Paloma");
cambiarSentido = find(G.Edges.name == "Calle Toledo");
ronda = find(startsWith(G.Edges.name, "Ronda"));

% Calcular el tiempo de viaje 
% ta tiempo en atravesar la arista a (90% de la velocidad maxima)
% fa flujo de trafico de la arista a
T = 0;
for i = 1:length(G.Edges.EndNodes)
    T = T + ((G.Edges.maxspeed(i) * 90/100) + G.Edges.Weight(i));
end
disp("<strong>Escenario </strong><strong>     T </strong>");
disp("------------------------"); 
disp("Caso inicial: " + T * 60/1000);
disp("------------------------"); 

% Modificaciones sobre las calles
% Escenario 1
% Calles peatonales
for i = 1:length(peatonal1)
    G2 = rmnode(G,peatonal1(i));
end
for i = 1:length(peatonal2)
    G2 = rmnode(G,peatonal2(i));
end
T = 0;
for i = 1:length(G2.Edges.EndNodes)
    T = T + ((G2.Edges.maxspeed(i) * 90/100) + G2.Edges.Weight(i));
end
disp("Escenario 1:  " + T * 60/1000); 

% Escenario 2
% Cambiar el sentido a la calle Toledo
flipCambioSentido = flip(cambiarSentido);
for i = 1:length(cambiarSentido)
%     G = flipedge(G, cambiarSentido(i), flipCambioSentido(i));
    G3 = flipedge(G,cambiarSentido(i));
end
T = 0;
for i = 1:length(G3.Edges.EndNodes)
    T = T + ((G3.Edges.maxspeed(i) * 90/100) + G3.Edges.Weight(i));
end
disp("Escenario 2:  " + T * 60/1000);  

% Escenario 3
% Modificar la velocidad maxima de la ronda
for i = 1:length(ronda)
    G3.Edges.maxspeed(ronda(i)) = 30;
end
T = 0;
for i = 1:length(G3.Edges.EndNodes)
    T = T + ((G3.Edges.maxspeed(i) * 90/100) + G3.Edges.Weight(i));
end
disp("Escenario 3:  " + T * 60/1000);  

% Generar la estructura con las aristas pertenecientes a las calles para
% poder representar las en el grafo
nodosPeatonal = [];
for i = 1:length(peatonal1)
    nodosPeatonal(end + 1) = G.Edges.EndNodes(peatonal1(i),1);
    nodosPeatonal(end + 1) = G.Edges.EndNodes(peatonal1(i),2);
end
for i = 1:length(peatonal2)
    nodosPeatonal(end + 1) = G.Edges.EndNodes(peatonal2(i),1);
    nodosPeatonal(end + 1) = G.Edges.EndNodes(peatonal2(i),2);
end
nodosCambioSentido = [];
for i = 1:length(cambiarSentido)
    nodosCambioSentido(end + 1) = G.Edges.EndNodes(cambiarSentido(i),1);
    nodosCambioSentido(end + 1) = G.Edges.EndNodes(cambiarSentido(i),2);
end
nodosRonda = [];
for i = 1:length(ronda)
    nodosRonda(end + 1) = G.Edges.EndNodes(ronda(i),1);
    nodosRonda(end + 1) = G.Edges.EndNodes(ronda(i),2);
end
highlight(p,nodosPeatonal,'EdgeColor','red','LineWidth',3.5);
highlight(p,nodosCambioSentido,'EdgeColor','green','LineWidth',3.5);
highlight(p,nodosRonda,'EdgeColor','magenta','LineWidth',3.5);

% Created on 2021 by José Ángel Martín Baos
% Algebra & Discrete Mathematics
% Escuela Superior de Informática, University of Castilla-La Mancha, Spain

function [n_nodes, nodes, n_edges, edges] = load_pycgr(data_dir, map_filename)
% Load the graph data from the .pycgr and .pycgr_names files
% Input params:
% - data_dir: Directory where the datafiles are located
% - map_filename: Name of the map file (without extension)

fid = fopen(strcat(data_dir, map_filename, '.pycgr'));

% Discart the lines starting with #
tline = fgetl(fid);
while startsWith(tline, '#')
    tline = fgetl(fid); 
end

% Get the number of nodes and edges
n_nodes = str2num(tline);
n_edges = str2num(fgetl(fid)); 

% Load the nodes
C_nodes = textscan(fid, '%d %f %f', n_nodes);
nodes = {};
nodes.id = C_nodes{1,1} + 1; % +1 to avoid index 0
nodes.lat = C_nodes{1,2};
nodes.lon = C_nodes{1,3};

% Load the edges
C_edges = textscan(fid, '%d %d %f %s %d %d', n_edges);
edges = {};
edges.source = C_edges{1,1} + 1; % +1 to avoid index 0
edges.target = C_edges{1,2} + 1; % +1 to avoid index 0
edges.length = C_edges{1,3};
edges.type = C_edges{1,4};
edges.maxspeed = single(C_edges{1,5});
edges.bidirectional = C_edges{1,6};

fclose(fid);

% Load the name of the streets
edges.name = [];
fid2 = fopen(strcat(data_dir, map_filename, '.pycgr_names'));
for i = 1:n_edges
    edges.name = [edges.name; string(fgetl(fid2))];
end
fclose(fid2);

end


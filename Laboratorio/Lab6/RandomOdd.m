function g = RandomOdd()
%   RandomOdd generates an odd 64-bit random symbolic number.

rng('shuffle');
V = randi([0, 4294967295], 'uint32'); % Remark: 4294967295 = 2^32 - 1 (which is the maximum 32-bit integer)
g = sym(bitor(V, 1)); % Ensures that the generated number is odd by forcing the last bit to 1
V = randi([0, 4294967295], 'uint32');
g = g + V*sym(4294967296); % Remark: 4294967296 = 2^32 (in binary: 100000000000000000000000000000000)

end
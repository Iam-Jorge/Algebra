function Y = RandomPrime(bits)
%       RandomPrime generates a pseudo-random prime number with as many bits 
%       as indicated in the bits variable, which must be a positive
%       integer.

b = ceil(bits-1);   % Ensure bits is a positive integer
% We divide the number of bits by 32
q = floor(b/32);
r = mod(b, 32);

TwoToPower32 = 2^32;
TwoToPowerr  = 2^r;
Base = sym(TwoToPower32);

rng('shuffle');
if q>0
    V = randi([0, TwoToPower32-1], 1, q, 'uint32');
    Y = sym(V(1));
    for i=2:q
        Y = Y + V(i)*Base;
        Base = TwoToPower32*Base;
    end
    Y = Y + (randi([0, TwoToPowerr-1], 'uint32') + TwoToPowerr)*Base;
else
    Y = sym(randi([0, TwoToPowerr-1], 'uint32') + TwoToPowerr);
end

Y = nextprime(Y);

end

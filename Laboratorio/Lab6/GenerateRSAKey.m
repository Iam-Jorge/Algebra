function [N, E, D] = GenerateRSAKey(bits)
%       GenerateRSAKey generates a pseudo-random RSA key with as many bits
%       as indicated in the variable bits, which should be a positive
%       integer.
%       Returned values:
%       - N = The modulus of the key.
%       - E = The public exponent of the key.
%       - D = The private key.

b = floor(bits/2);  
P = RandomPrime(b);
Q = RandomPrime(b+1);

N = P*Q;

LAMBDA = lcm(P-1, Q-1);

E = sym(2)^32 + 1;  % Fermat number.  As e is public, it doesn't matter which prime is chosen.
while gcd(E, LAMBDA) > 1 % We assure that e and lamda are coprimes
    E = nextprime(E);
end

D = powermod(E,-1, LAMBDA);

end

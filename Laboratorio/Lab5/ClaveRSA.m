function [N,E,D] = ClaveRSA(bits)

b = floor(bits/2);
P = randprimo(b);
Q = randprimo(b+1);

N = P*Q;

LAMBDA = lcm(P-1, Q-1);

E = sym(2)^32 + 1; % Número de Fermat (público)
while gcd(E, LAMBDA) > 1
    E = nextprime(E);
end

D = powermod(E, -1, LAMBDA);

end


function primo = randprimo(bits)

a = sym(2)^(bits-1);
b = sym(2)^(bits)-1;

longIntervalo = b-a;

primo = b+1;
while(primo > b)
    aleatorio = a+(floor(rand*longIntervalo));
    primo = nextprime(aleatorio);
end

end


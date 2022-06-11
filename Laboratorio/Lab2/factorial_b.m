function resultado = factorial_b(n)

if n == 1
    resultado = 1;
else 
    resultado = n * factorial_b(n-1);

end


function resultado = Bell(n)
resultado = 0;
for k=1:n
    resultado = resultado + Stirling2(n,k);
end

end


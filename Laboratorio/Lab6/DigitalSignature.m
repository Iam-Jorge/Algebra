function [hash firma] = DigitalSignature(ruta,modulo,privada)

% Generar la funcion hash con MD5
hash = MD5(ruta);

% Transformacion hash en caracteres transformar a valor numerico
m = sym(strcat('0x',hash));

% Primero se hace sym del numero pequeño
DosA128 = sym(2)^128;

% RandomOdd Funcion que genera el numero aleatorio
g = RandomOdd();

g_1 = powermod(g, -1, DosA128);

h = mod(g_1*m, DosA128);

M = g * DosA128 + h;

f =  powermod(M, privada, modulo);

% Decimal a hexadecimal
firma = dec2hex(f);

end


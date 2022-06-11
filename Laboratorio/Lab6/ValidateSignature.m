function [valido, m_str, hash] = ValidateSignature(ruta,firma,modulo,exponente)

hash = MD5(ruta);

DosA128 = sym(2)^128;

F = sym(strcat('0x',firma));

M = powermod(F,exponente,modulo);

[g, h] = quorem(M,DosA128);

m = mod(g*h, DosA128);

m_str = dec2hex(m);

valido = strcmp(hash,m_str);

end


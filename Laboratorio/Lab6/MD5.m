function hash = MD5(target_file)
%   MD5: The MD5 hash function
%   Parameters:
%   - target_file: an string containing the name of the file. If the file
%       with this name exists, the hash of the file is calculated. If it 
%       does not exist, the hash for the string is computed.
%   Returned values:        
%       hash: The hash function on hexadecimal representation.

if isfile(target_file)
    hash = Simulink.getFileChecksum(target_file);
elseif ischar(target_file)
    % Create a temporal binary file:
    [fileID, msg] = fopen('temporalfile.bin', 'w'); 
    error(msg);
    fwrite(fileID, target_file);
    fclose(fileID);
    % Compute the hash of the file:
    hash = Simulink.getFileChecksum('temporalfile.bin');
    % Delete the temporal file:
    delete 'temporalfile.bin';
else
    display('Data type not supported');
    hash = '';
end
end
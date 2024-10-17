function boolout = issicd(filename)
% Sensor independent complex data (version >= 0.3)
%
% Written by: Wade Schwartzkopf, NGA/IDT
%
% //////////////////////////////////////////
% /// CLASSIFICATION: UNCLASSIFIED       ///
% //////////////////////////////////////////

try
    nitf_meta = read_sicd_nitf_offsets(filename);
    fid = fopen(filename,'r');
    fseek(fid, nitf_meta.minimal.desOffsets(1), 'bof'); % First DES must be SICD XML
    domnode = read_xml(fread(fid,nitf_meta.minimal.desLengths(1),'uint8=>char'));
    fclose(fid);
    boolout = strncmpi('SICD', domnode.getDocumentElement.getNodeName,4);
    if boolout  % Possible to have non-complex data with SICD DES
        nitf_meta = read_nitf_meta(filename);
        boolout = nitf_meta.imagesubhdr{1}.NBANDS == 2;
    end
catch
    % read_sicd_nitf_offsets throws an error for non-NITF files
    % non-XML DES will also throw error
    boolout = false; % Not SICD either way
end

end

% //////////////////////////////////////////
% /// CLASSIFICATION: UNCLASSIFIED       ///
% //////////////////////////////////////////
function [ meta, symmetry ] = meta2sicd_tiffrs( tiff_filename, gen )
%META2SICD_TIFFRS Compile SICD metadata for RS2 or RCM data package
%
% Written by: Wade Schwartzkopf, NGA/IDT
%
% //////////////////////////////////////////
% /// CLASSIFICATION: UNCLASSIFIED       ///
% //////////////////////////////////////////

% Initialize outputs
meta=struct();
symmetry=[0 0 0];

% RS2/RCM TIFF doesn't have much metadata in the TIFF itself, but it should
% have a co-located product.xml file
[pathname, fileonly, ext] = fileparts(tiff_filename);

jFile = java_file(tiff_filename);

tiff_filename = char(jFile.getCanonicalPath);
if strcmp(gen, 'RS2')
    productxmlfile = fullfile(pathname,'product.xml'); % Main metadata file
elseif strcmp(gen, 'RCM')
    productxmlfile = fullfile(fileparts(pathname),'metadata','product.xml'); % Main metadata file
end
files_found = dir(productxmlfile);
if length(files_found)==1
    xp = xpath();
    rsxml_meta=read_xml(productxmlfile);
    meta=meta2sicd_rs_xml(rsxml_meta);
    
    % XML describes all images of a polarimetric collection
    % Select metadata associated with only this TIFF file
    % Must be a more elegant way to do this in a single call to XPath...
    for i=1:length(meta)
        if strcmp(gen, 'RS2')
            current_file_pol=char(xp.evaluate(['/*[local-name()=''product'']'...
                                       '/*[local-name()=''imageAttributes'']'...
                                       '/*[local-name()=''fullResolutionImageData'']'...
                                       '[' num2str(i) ']'],...
                                      rsxml_meta)); % Check name of one image
        elseif strcmp(gen, 'RCM')
            current_file_pol=char(xp.evaluate(['/*[local-name()=''product'']'...
                                       '/*[local-name()=''sceneAttributes'']'...
                                       '/*[local-name()=''imageAttributes'']'...
                                       '[' num2str(i) ']'...
                                       '/*[local-name()=''ipdf'']'],...
                                      rsxml_meta)); % Check name of one image
        end
        jFile = java_file(fullfile(fileparts(productxmlfile), current_file_pol));
        current_file_pol = char(jFile.getCanonicalPath);  % RCM IDPF are given as relative paths
        if strcmp(tiff_filename,current_file_pol) % Does it match this TIFF?
            meta=meta{i}; % If so, use the pole value from this image
            meta.native.product_xml=rsxml_meta;
            if strcmp(gen, 'RS2')
                pol=char(xp.evaluate(['/*[local-name()=''product'']'...
                                      '/*[local-name()=''imageAttributes'']'...
                                      '/*[local-name()=''fullResolutionImageData'']'...
                                      '[' num2str(i) ']/@pole'],...
                                      rsxml_meta));
                pol = {pol(1) pol(2)};
            elseif strcmp(gen, 'RCM')
                pol=char(xp.evaluate(['/*[local-name()=''product'']'...
                                      '/*[local-name()=''sceneAttributes'']'...
                                      '/*[local-name()=''imageAttributes'']'...
                                      '[' num2str(i) ']'...
                                      '/*[local-name()=''ipdf'']/@pole'],...
                                      rsxml_meta));
                M = struct('H','H','V','V','C','RHC');
                pol = {M.(pol(1)) M.(pol(2))};
            end
            meta.ImageFormation.RcvChanProc.ChanIndex = i;
            meta.ImageFormation.TxRcvPolarizationProc=[pol{1} ':' pol{2}];
            break;
        end
    end
    if ~iscell(meta) % File was one of the components pointed to by this XML
        % Compute symmetry
        lookdir=upper(char(xp.evaluate(['/*[local-name()=''product'']'...
                               '/*[local-name()=''sourceAttributes'']'...
                               '/*[local-name()=''radarParameters'']'...
                               '/*[local-name()=''antennaPointing'']'],...
                              rsxml_meta)));
        if strcmp(gen, 'RS2')
            ia_str = 'imageAttributes';
        elseif strcmp(gen, 'RCM')
            ia_str = 'imageReferenceAttributes';
        end
        lineOrder=char(xp.evaluate(['/*[local-name()=''product'']'...
                                    '/*[local-name()=''' ia_str ''']'...
                                    '/*[local-name()=''rasterAttributes'']'...
                                    '/*[local-name()=''lineTimeOrdering'']'],...
                                    rsxml_meta));
        sampleOrder=char(xp.evaluate(['/*[local-name()=''product'']'...
                                 '/*[local-name()=''' ia_str ''']'...
                                 '/*[local-name()=''rasterAttributes'']'...
                                 '/*[local-name()=''pixelTimeOrdering'']'],...
                                rsxml_meta));
        symmetry(1)=xor(strcmp(lineOrder,'Decreasing'),lookdir(1)=='L');
        symmetry(2)=strcmp(sampleOrder,'Decreasing');
    end
end

% //////////////////////////////////////////
% /// CLASSIFICATION: UNCLASSIFIED       ///
% //////////////////////////////////////////
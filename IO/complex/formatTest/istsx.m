function boolout = istsx( filename )
%ISTSX Test for TerrSAR-X XML description file
%
% Written by: Wade Schwartzkopf, NGA/IDT
%
% //////////////////////////////////////////
% /// CLASSIFICATION: UNCLASSIFIED       ///
% //////////////////////////////////////////

if mightbexml(filename)
    xp = xpath();
    try
        boolout=isequal(regexp(char(xp.evaluate('level1Product/generalHeader/mission',read_xml(filename))),'T[SD]X-1|PAZ-1'),1);
    catch
        boolout=false;
    end
else
    boolout=false;
end

end

% //////////////////////////////////////////
% /// CLASSIFICATION: UNCLASSIFIED       ///
% //////////////////////////////////////////
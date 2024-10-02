function [ doc ] = read_xml(filename)
%READ_XML Octave implementation of read_xml to read from a file or a string
%
% INPUTS:
%   filename: required - filename or a string to be parsed 
%
% OUTPUTS:
%   DOM Node: The XML Document

if exist(filename, 'file')
    if is_octave
        parser = javaObject('org.apache.xerces.parsers.DOMParser');
        parser.parse(filename); 
        doc = parser.getDocument();
    else
        doc = xmlread(filename);
    end
else
    % input is a string to be parsed
    xml_string = filename;
    if is_octave
        factory = javaMethod('newInstance', 'javax.xml.parsers.DocumentBuilderFactory');
        db = factory.newDocumentBuilder();
        is = javaObject('org.xml.sax.InputSource');
        is.setCharacterStream(javaObject('java.io.StringReader', xml_string));
        doc = db.parse(is);
    else
        doc = xmlread(java.io.StringBufferInputStream(xml_string));
    end    
end

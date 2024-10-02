function [ xml_str ] = write_xml(doc, varargin)
%WRITE_XML Wraps Java to write a XML doc to a string
%
% INPUTS:
%   doc: required - XML Document
%   indent: optional - Boolean, whether to indent the XML doc output
%   omit_xml_decl: optional - Boolean, whether to omit the XML header decl
%
% OUTPUTS:
%   xml_str: The XML Document as a string

p = inputParser;
addRequired(p,'doc');
addOptional(p,'indent',false);
addOptional(p, 'omit_xml_decl', true);
parse(p, doc, varargin{:});

transformerFactory = javaMethod('newInstance', 'javax.xml.transform.TransformerFactory');
t = transformerFactory.newTransformer();

if p.Results.indent 
  t.setParameter('indent', 'yes');
else
  t.setParameter('indent', 'no');
end

if p.Results.omit_xml_decl
    t.setOutputProperty('omit-xml-declaration', 'yes');
else
    t.setOutputProperty('omit-xml-declaration', 'no');
end

sw = javaObject('java.io.StringWriter');
t.transform(javaObject('javax.xml.transform.dom.DOMSource', doc), javaObject('javax.xml.transform.stream.StreamResult', sw));

if is_octave()
  xml_str = sw.toString;
else
  s = sw.toString;
  xml_str = s.toCharArray;
end

function [ doc ] = create_xml_doc(root_name, ns)
%CREATE_XML_DOC Wraps Java to create a XML document
%
% INPUTS:
%   root_name: required - filename or a string to be parsed 
%   ns: optional - xml namespace to use
%
% OUTPUTS:
%   doc: The XML Document

if is_octave
    factory = javaMethod('newInstance', 'javax.xml.parsers.DocumentBuilderFactory');
    db = factory.newDocumentBuilder;
    doc = db.newDocument;
    if nargin > 1 && ~isempty(ns)
        root = doc.createElementNS(ns, root_name);
    else
        root = doc.createElement(root_name);
    end
    doc.appendChild(root);
else
    doc = com.mathworks.xml.XMLUtils.createDocument(root_name);
    root_node = doc.getDocumentElement;
    if nargin > 1 && ~isempty(ns)
        root_node.setAttribute('xmlns', ns);
    end
end
function [] = validate_xml(xml_string, schema_filename)
%VALIDATE_XML Octave implementation of read_xml to read from a file or a string
%
% Throws an exception if the input is not valid
%
% INPUTS:
%   xml_string: required - xml string to validate
%   schema_filename: required - schema to validate xml against

jFile = java_file(schema_filename);
factory = javaMethod('newInstance', 'javax.xml.validation.SchemaFactory', 'http://www.w3.org/2001/XMLSchema');
schema = factory.newSchema(jFile);
src = javaObject('javax.xml.transform.stream.StreamSource', javaObject('java.io.StringBufferInputStream', xml_string));
validator = schema.newValidator;
validator.validate(src);
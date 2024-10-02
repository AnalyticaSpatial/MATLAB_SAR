function [ jFile ] = java_file(filename)
%JAVA_FILE Octave implementation of read_xml to read from a file or a string
%
% INPUTS:
%   filename: required - the filename to open as a java file
%
% OUTPUTS:
%   jFile: the Java File

jFile = javaObject('java.io.File', filename);


function [ xp ] = xpath()
%XPATH Octave implementation of xpath
%
% OUTPUTS:
%   XPATH object: The xpath object

xp = javaMethod('newXpath', javaMethod('javax.xml.xpath.XPathFactory.newInstance'));

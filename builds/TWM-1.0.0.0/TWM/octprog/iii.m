clc;
clear all;

addpath([fileparts(mfilename('fullpath')) filesep() 'info'])

data = tpq_load_record('F:\Data\LVprog\TracePQM\data\test');

fieldnames(data)
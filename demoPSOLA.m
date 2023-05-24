clc 
clear all
close all

% SET: file to be shifted 
fullFileName = "vocals.wav";
[filepath,filename,ext] = fileparts(fullFileName);

% read audio file to buffer
[x,Fs] = audioread(fullFileName);

% windowing variables
winLength = round(0.05*Fs); 
overlapLength = round(0.045*Fs);

% SET: pitch shift in semitones
semitones = -2;

% SET: time stretching factor
timeStretch = 0.7;

% SET: formant shifting factor
formantShift = 0.9;

% pitch shifting factor: semitones to ratio
pitchShift = pow2(semitones/12);

tic
% pitch detection for PSOLA
pitch = pitch(x,Fs,Range=[50,500],Method="PEF",WindowLength=winLength,OverlapLength=overlapLength);

% create list of analysis pitch marks based on pitch detection output
pitchMarks = getPitchMarks(x,Fs,pitch,(winLength-overlapLength),winLength);

% run PSOLA
psolaOut = psola(x,pitchMarks,timeStretch,pitchShift,formantShift);
toc

psolaFileName = sprintf("output/%s S=%g T=%g F=%g.wav",filename,semitones,timeStretch,formantShift);

audiowrite(psolaFileName,psolaOut,Fs);
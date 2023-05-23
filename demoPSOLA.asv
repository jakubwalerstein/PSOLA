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
semitones = 3;

% SET: time stretching factor
timeStretch = 1.2;

% SET: formant shifting factor
formantShift = 0.8;

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

psolaFileName = sprintf("output/%s s=%g t=%g f=%g.wav",filename,semitones,timeStretch,formantShift);

audiowrite(psolaFileName,psolaOut,Fs);
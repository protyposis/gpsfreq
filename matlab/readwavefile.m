function [ x, t, Fs, len ] = readwavefile( filename )
%READWAVEFILE Reads a wave file and returns the samples, time scale,
%sampling rate, and length.
    [x, Fs] = audioread(filename);
    
    dt = 1/Fs;                   % seconds per sample
    len = length(x) / Fs;             % seconds
    t = (0:dt:len-dt)';
end


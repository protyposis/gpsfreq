function [ x, t, fs ] = sinewave( l, f, fs, drift )
%SINEWAVE Generate a sine wave.
%   Generate a sine wave with length l in seconds, frequency f in Hz,
%   sampling rate fs in Hz, and with a drift given in ppm.
%
%   Returns the samples (x), time scale (t), and sampling frequency (fs).

    t = (0:l*fs-1) / fs;
    fdrifted = f * (1 - drift/1000000);
    x = sin(t * 2 * pi * fdrifted);
end


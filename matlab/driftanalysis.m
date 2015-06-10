function [ ppm, ppmSum, t ] = driftanalysis( Fs, Fr, samples )
%DRIFTANALYSIS Analyzes timedrift in a recorded sine wave
%
%   Analysis works by determining the sine frequency though counting of
%   the interpolated zero crossings and converting the frequency deviation
%   to the drift value in ppm.
%
% INPUT Fs: sampling frequency
%       Fr: base frequency of sine wave in src (reference measurement
%           frequency)
%       samples: recorded sine wave to be analyzed
%
% OUTPUT ppm: a vector over time, containing the average ppm per second
%        ppmSum: a vector over time, containing the accumulated average ppm 
%                per second
%        t: vector time scale
%

    cycleLength = Fs / Fr / 2;
    nCycles = ceil(length(samples) / cycleLength);
    sampleLength = 1/Fs;
    
    startIndex = findNextZeroCrossing(samples,1);
    lastIndex = startIndex;
    
    interpolatedIndex = interpolateZeroCrossing( ...
                startIndex, samples(startIndex), ...
                startIndex+1, samples(startIndex+1));
    lastInterpolatedIndex = interpolatedIndex;
    
    
    ppm = zeros(nCycles,1); % average ppm per second
    ppmSum = zeros(nCycles,1); % accumulated average ppm per second
    offsetBuffer = zeros(ceil(Fs / cycleLength * 2), 1); % intermediate buffer of offsets for average calculation
    offsetCount = 0;
    
    nextMeasureSampleCount = Fs;
    second = 0;
    
    while true
        index = findNextZeroCrossing(samples,lastIndex+1);
        %fprintf('%d of %d \n',index,len);

        if index == -1
            break;
        end
        
        interpolatedIndex = interpolateZeroCrossing( ...
                index, samples(index), ...
                index+1, samples(index+1));
        
        offset = ((interpolatedIndex-lastInterpolatedIndex) - cycleLength);
        
        lastIndex = index;
        lastInterpolatedIndex = interpolatedIndex;
        
        % add offset to the buffer
        offsetCount = offsetCount + 1;
        offsetBuffer(offsetCount) = offset;
        
        if(index >= nextMeasureSampleCount)
            % set next measurement point
            nextMeasureSampleCount = nextMeasureSampleCount + Fs;
            
            % calculate offset average and convert to ppm
            offsetSum = sum(offsetBuffer(1:offsetCount));
            second = second + 1;
            ppm(second) = ((offsetSum) * sampleLength) * 10^6;

            if(second == 1)
                ppmSum(second) = ppm(second);
            else
                ppmSum(second) = ppmSum(second-1) + ppm(second);
            end
            
            % reset offset avg calc buffer
            offsetCount = 0;
        end
    end

    ppm = ppm(1:second); % shorten array if there are trailing zeros because of too large initialization
    ppmSum = ppmSum(1:second);
    t = (1:length(ppm))';
end

function i = findNextZeroCrossing(samples, startIndex)
% returns the next index at/after which a zero-crossing happens, or -1 if
% none happens.
    i = -1;
    
    if(length(samples) > startIndex)
        for j = startIndex:length(samples)-1
            if samples(j) == 0 || samples(j)*samples(j+1) < 0
                i = j;
                break;
            end
        end
    end
end

function i = interpolateZeroCrossing(x1,y1,x2,y2)
    if y1 == 0
        i = x1;
    elseif y2 == 0
        i = x2;
    else
        k = (y2-y1)/(x2-x1);
        d = -k*x1 + y1;
        i = (0-d)/k;
    end
end

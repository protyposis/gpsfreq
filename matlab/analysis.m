% This script measures the drift in audio recordings. To measure the 
% recording drift of a device

%% Configuration

% SET THE PATHS TO THE RECORDINGS TO BE ANALYZED IN THIS CELL ARRAY:
inputs = cell(1);
inputs{01} = 'C:\testrecordings\device1.wav';
inputs{02} = 'C:\testrecordings\device2.wav';

% For testing purposes, sine waves can be specified instead of file paths.
% NOTE: comment out to analyze the files specified above
inputs = cell(1);
inputs{01} = [100, 440, 44100, 0];
inputs{02} = [100, 440, 44100, 5];
inputs{03} = [100, 440.01, 44100, 0];
inputs{04} = [100, 439.99, 44100, 0];

% inputs = cell(1);
% inputs{01} = '\\Mediacenter\h\Datasets\drifttests\drifttestuni\drifttestuni01\galaxys2.wav';
% inputs{02} = '\\Mediacenter\h\Datasets\drifttests\drifttestuni\drifttestuni01\h120.wav';
% % inputs{03} = '\\Mediacenter\h\Datasets\drifttests\drifttestuni20131003-04_rawdata\drifttestuni01\galaxys2.wav';
% % inputs{04} = '\\Mediacenter\h\Datasets\drifttests\drifttestuni20131003-04_rawdata\drifttestuni01\h120.wav';
% 
% inputs = cell(1);
% inputs{01} = 'C:\Users\Mario\Desktop\galaxys2.wav';
% inputs{02} = 'C:\Users\Mario\Desktop\h120.wav';

% SET THE FREQUENCY OF THE MEASUREMENT SIGNAL:
F = 440; % Hz
Fd = 0; % drift in ppm
% Alternative 1: Set the drifted playback frequency of the signal if known:
% F = 440.00324986;
% Alternative 2: Set the playback drift of the signal:
% Fd = 16.342;

% SET FREQUENCY FILTERING
% if the input waveforms are noisy, set to true for a prefiltering to keep
% only the measurement frequency
filtering = false;

%% Analysis code

F = F * (1 + Fd/1000000); % adjust the measurement freq by its drift
legendEntries = cell(1);
ppms = cell(1);
ppmSums = cell(1);

if filtering
    Hd = bandpassfilter(Fs, F, 2);
end

figure, title('Summed drift over time'), xlabel('Seconds'), ylabel('ppm'), hold all;

for f = 1:length(inputs)
    input = inputs{f};

    if ischar(input)
        [~,filename,fileext] = fileparts(input);
        fname = [filename,fileext];
        [x,t,Fs] = readwavefile(input);
    else
        [x,t,Fs] = sinewave(input(1), input(2), input(3), input(4));
        fname = ['testsine ', num2str(input(2)), ' Hz @ ', num2str(input(4)), ' ppm'];
        x = x';
    end
    
    fprintf('x len=%d, t len=%d\n', length(x), length(t));
    
    if filtering
        fprintf('filtering...\n');
        x = filter(Hd, x);
    end
    
    [ ppm, ppmSum, t ] = driftanalysis(Fs, F, x);
    avgdrift = mean(ppm);
    
    legendEntries{f} = [fname,': ',num2str(avgdrift, '%.3f'),' ppm'];

    plot(t,ppmSum);
    legend(legendEntries);
    
    ppms{f} = ppm;
    ppmSums{f} = ppmSum;
end

% display ppm of last 5 minutes
%for (x = 1:length(ppms)) disp(mean(ppms{x}(length(ppms{x})-5*60:length(ppms{x})))); end

hold off;
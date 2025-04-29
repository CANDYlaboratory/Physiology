function [hr, rmssd] = HRVcal(cardtrigger, Fs, Nfrs, TR)
% function [hr, rmssd] = HRVcal(cardtrigger,Fa\s, TR)
% Calculate the averaged heart rate and root mean square of successive differences of the R-R intervals 
% Input -- cardtrigger:  cardiac peak events indices
%       -- Fs: frequency of the cardiac signal
%       -- Nfrs: # of MR time frames 
%       -- TR: MR repetition time 
% Output -- hr: averged heart rate 
%        -- rmssd: root mean square of successive differences of the R-R intervals

hbi = diff(cardtrigger/Fs);
diff_hbi = diff(hbi);
rmssd = sqrt(sum(diff_hbi .^ 2, 'omitnan')/(length(hbi)-1));

Num_min = (Nfrs*TR)/60;
hr = length(cardtriigger)/Num_min;

end

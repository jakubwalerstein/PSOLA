% in: audio buffer to shift
% m: list of analysis pitch marks
% timeStretch: time stretching factor
% pitchShift: pitch shifting factor
% formantShift: formant shifting factor
function out=psola(in,m,timeStretch,pitchShift,formantShift)

% do nothing if all shifting factors = 1
if timeStretch == 1 && pitchShift == 1 && formantShift == 1
    out = in;
    return;
end

% sum input to mono
in = in(:,1) + in(:,2);

% get pitch periods from pitch marks 
periods = diff(m); 

%remove first pitch mark if needed
if m(1) <= periods(1) 
   m = m(2:end); 
   periods = periods(2:end); 
end

%remove last pitch mark if needed
if m(end) + periods(end) > length(in) 
    m = m(1:end-1);
else
    % add period to match in length
    periods = [periods periods(end)]; 
end

out = zeros(ceil(length(in)*timeStretch),1); 

% synthesis pitch mark
tk = periods(1)+1;
while round(tk) < length(out)
 % find closest analysis segment
 [~, i] = min(abs(timeStretch*m-tk));    
 pit = periods(i);

 % find grain start and end using analysis pitch mark
 grainStart = m(i) - pit;
 grainEnd   = m(i) + pit;

 % prevent grains from exceeding input array bounds
 if grainStart < 1 
     grainStart = 1;
 end
 if grainEnd > length(in)
    grainEnd = length(in);
 end

 % extract grain
 gr = in(grainStart:grainEnd);

 if formantShift ~= 1
    % resample segment to get new formant
    gr = resample(gr,floor(length(gr)/formantShift),length(gr));
 end

 % resize resampled grains if needed
 if (m(i) - length(gr/2)) < 1
    grainEnd = (m(i) - round(length(gr/2))) + length(gr);
    gr = gr(1:grainEnd);
 end

 % apply hanning envelope
 gr = gr .* hanning(length(gr));

 % use synthesis pitch mark to get position of grain in output buffer
 outStart = round(tk) - round(length(gr)/2);
 outEnd = outStart + length(gr);

 % prevent grains from exceeding output array bounds
 if outStart < 1
     outStart = 1;
 end
 if outEnd > length(out)
     break;
 end

 % handle off-by-one mismatch from rounding
 if length(outStart:outEnd) == length(gr)+1
     outEnd = outEnd - 1;
 elseif length(outStart:outEnd) == length(gr)-1
     outEnd = outEnd + 1;
 end

 % handle transposition mismatch
 if size(out(outStart:outEnd)) == size(gr')
    gr = gr';
 end

 % fprintf("outSize: %s\n",num2str(size(outStart:outEnd)))
 % fprintf("grainSize: %s\n",num2str(size(gr)))

 % overlap and add
 out(outStart:outEnd) = out(outStart:outEnd) + gr; 

 % calculate next synthesis pitch mark
 tk = tk + pit/pitchShift;
end 
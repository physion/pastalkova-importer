function epochs = splitEpochs(laps)
    
    for i = 1:length(laps.lapID)
        epochs(i).startTimeSeconds = laps.startT(i); %#ok<*AGROW>
        epochs(i).endTimeSeconds = laps.endT(i);
        
        epochs(i).lfpStartIndex = laps.startLfpInd(i);
        epochs(i).lfpEndIndex = laps.endLfpInd(i);
    end
end
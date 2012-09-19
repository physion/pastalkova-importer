function epochs = importEpochs(group, params, data)
    
    import ovation.*;
    epochDescriptors = splitEpochs(data.Laps);
    
    for i = 1:length(epochDescriptors)
        disp(['  Epoch ' num2str(i) '...']);
        epochs(i) = importEpoch(group, params, data, epochDescriptors(i)); %#ok<AGROW>
    end
end

function [tm, numberOfRec, header] = importDataVersion1(obj, h, fileId)

    % Read file version. Based on version call correct handler
    % Expects that Labview data is little endian.

     % Header format
%             header.version  uint8
%             header.seqNo    uint32
%             header.dataType uint8
%             header.pattern; uint16
%             header.fLow;    uint32
%             header.fHigh;   uint32
%             header.gain;    uint16
%             header.sampleRate; uint32
%             header.attenuation; uint16
%             header.verticalRange; uint16
%             header.noRec;     uint16
%             header.vPipe;     uint16
%             header.transducerType;  uint16
    errorMsg = 'Error reading header, Hit EOF';

    if( not(obj.supportedFileVersion == h.version))
        error('File version not supported');
    end

    % SEQ NO
    [h.seqNo, count] = fread(fileId, 1,'uint32');                        
    if count < 1
        error(errorMsg);
    end                

    % DATA TYPE: shotData or noise
    [h.dataType, count] = fread(fileId, 1,'uint8');                        
    if count < 1
        error(errorMsg);
    end

    % Pattern
    [h.pattern, count] = fread(fileId, 1,'uint8');                        
    if count < 1
        error(errorMsg);
    end            

    % F LOW
    [h.fLow, count] = fread(fileId, 1,'uint32');                        
    if count < 1
        error(errorMsg);
    end

    % F HIGH
    [h.fHigh, count] = fread(fileId, 1,'uint32');                        
    if count < 1
        error(errorMsg);
    end

    % Gain
    [h.gain, count] = fread(fileId, 1,'uint16');                        
    if count < 1
        error(errorMsg);
    end

    [h.sampleRate, count] = fread(fileId, 1,'uint32');                        
    if count < 1
        error(errorMsg);
    end

    [h.attenuation, count] = fread(fileId, 1,'uint8');                        
    if count < 1
        error(errorMsg);
    end

    [h.verticalRange, count] = fread(fileId, 1,'uint8');                        
    if count < 1
        error(errorMsg);
    end

    [h.numRec, count] = fread(fileId, 1,'uint16');                        
    if count < 1
        error(errorMsg);
    end

    numberOfRec = h.numRec;

    [h.vPipe, count] = fread(fileId, 1,'uint16');                        
    if count < 1
        error(errorMsg);
    end


    % Check number of transducer records
    if h.numRec < 1
        fclose(fileId);
        error('File contain no records')
    end

    import ppPkg.TransducerMeasurement

    % Set header info
    header.setNo = h.seqNo;
    header.pulsePattern = h.pattern;   % Default for version 1
    header.pulseLength = 0;            % Default for version 1
    header.dataType = h.dataType;
    header.fileVersion = h.version;

    % TODO: need to define data types for each field
    % transducerId  uint16
    % startTime     uint16
    % numSamples    uint16
    % xPos          int16    ( single? )
    % yPos          int16
    % zPos          int16
    % samples       single   ( 4 bytes ) 

    % TODO: Error handling:
    % How do we avoid corrupted data while reading?

    for n = 1:h.numRec;                                
        numberOfSamples = 0;
        % Create a new tm object.       
        tm(n) = TransducerMeasurement;

        % Set common header data
        tm(n).sampleRate = h.sampleRate;
        tm(n).fLow = h.fLow;
        tm(n).fHigh = h.fHigh;

        % Set specific header data
        [tm(n).startTimeRec, count] = fread(fileId, 1,'single');
        if count < 1
            error(errorMsg);
        end

        [numberOfSamples, count] = fread(fileId, 1,'uint16');
        if count < 1
            error(errorMsg);
        end                               

        %
        [tm(n).xPos, count] = fread(fileId, 1,'double');
        if count < 1
            error(errorMsg);
        end

        [tm(n).yPos, count] = fread(fileId, 1,'double');
        if count < 1
            error(errorMsg);
        end

        [tm(n).zPos, count] = fread(fileId, 1,'double');
        if count < 1
            error(errorMsg);
        end

        [tm(n).transducerId, count] = fread(fileId, 1,'uint8');
        if count < 1
            error(errorMsg);
        end

        % Read data 
        [tm(n).signal, count] = fread(fileId, numberOfSamples,'single');
        if count < numberOfSamples
            error(errorMsg);
        end                                                
    end         
end
     
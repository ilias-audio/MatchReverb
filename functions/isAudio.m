function Out = isAudio(TempPath,MessageErr)
    if ischar(TempPath)
        [~,~,ext] = fileparts(TempPath);
        if isequal(ext,'.wav') || isequal(ext,'.wav') || isequal(ext,'.ogg') || isequal(ext,'.flac') || isequal(ext,'.au') || isequal(ext,'.aiff') || isequal(ext,'.aif') || isequal(ext,'.aifc') || isequal(ext,'.mp3') || isequal(ext,'.m4a') || isequal(ext,'.mp4') 
            Out = 1;
        else 
            Out = 0;
            if MessageErr == 1
                error('The path does not lead to a format compatible with audioread')
            end
        end
    else
        error('Entry is not a Char')
    end
end
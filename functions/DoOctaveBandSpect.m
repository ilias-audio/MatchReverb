function [Spectrum,cf,Sig,fs] = DoOctaveBandSpect(AudioIn,BandsPerOctave,varargin)
%%% INPUTS
% AudioIn can be a:
%   - Character array leading to 
%   - Vector/Matrix signal
% BandsPerOctave defines the number of band per octave when computing the
% spectrum. Must be equal to 1, 3/2 , 2 , 3, 6, 12, 24, 48 or 96.
% Varargin:
%   - length can be equal to one
%   - set the frequency sample if audio input is double


%%% OUTPUTS
% Spectrum: Spectrum of the AudioIn (in dB)
% cf: center frequency of the band 
% Sig: Signal of AudioIn
% fs: frequency sampling of the signal

% ----------------------------------------------------------------------- %
%%% SET AND TEST THE INPUTS
if ~ischar(AudioIn) && ~isa(AudioIn,'double')
    error('The input must be a cell variable, or Character array.')
end

if length(varargin) > 1
    error('Only three inputs parameters max')
end

if nargin == 3
    if isscalar(varargin{1})
        fs = varargin{1};
    else
        error('Third input (fs) must be a scalar')
    end
end
if all(BandsPerOctave == [1, 3/2 , 2 , 3, 6, 12, 24, 48, 96])
    error('The second input (BandsPerOctave) must be equal to 1, 3/2 , 2 , 3, 6, 12, 24, 48, or 96')
end

if ischar(AudioIn)
    if isAudio(AudioIn)
        [Sig,fs] = audioread(AudioIn);
        [Spectrum,cf] = poctave(Sig,fs,'BandsPerOctave',BandsPerOctave);
    else
        error('The input path does not lead to a audiofile')
    end
end

if isa(AudioIn,'double')
    Sig = AudioIn;
    [Spectrum,cf] = poctave(Sig,fs,'BandsPerOctave',BandsPerOctave);
    Spectrum = pow2db(Spectrum);
end
    

end


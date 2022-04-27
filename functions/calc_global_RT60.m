function [irT60,ir] = calc_global_RT60(audio_in, fs)

% remove the silence before the IR
[clear_signal, signal_with_direct, rir_cut] = remove_direct_sound(audio_in, fs, size(audio_in,1));

ir = signal_with_direct';




  if nargin < 2, error('Not enough input arguments.'); end

  % =========================================================================

  % Find first reflection of impulse response
  [~, irInitSample] = max(abs(ir));

  % Calculate Schroeder curve of impulse response
  [irEDC, irEDCdB] = schroeder(ir);

  % =========================================================================

  % Predelay
  irDelay = irInitSample / fs;

  % T60 & EDT
  % T60 = Calculate T30 (time from -5 to -35 dB) and multiply by 2
  % EDT = Calculate time from 0 to -10 dB
  ir5dBSample = find(irEDCdB < -5, 1);
  if isempty(ir5dBSample), ir5dBSample = -Inf; end

  ir10dBSample = find(irEDCdB < -10, 1);
  if isempty(ir10dBSample), ir10dBSample = Inf; end

  ir35dBSample = find(irEDCdB < -35, 1);
  if isempty(ir35dBSample), ir35dBSample = Inf; end

  irT60 = (ir35dBSample - ir5dBSample) * 2 / fs;


end


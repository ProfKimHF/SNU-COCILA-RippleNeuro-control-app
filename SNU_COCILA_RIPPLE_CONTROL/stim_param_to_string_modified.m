function rt_str = stim_param_to_string_modified(elecs, train_length, freq, ...
    cath_duration, anod_duration, cath_amp, anod_amp, delay, pol,pulse_train)
% stim_param_to_string produces stimulation string for xippmex's stim
% command which produce symmetric biphasic pulses.
%   str = stim_param_to_string(elecs, train_length, freq, duration, 
%                              amp, delay, pos, [fs_elecs, fs_value])
%   The first five variables contain arrays of parameters wanted for
%   stimulation organized by electrode.  For example simulation parameters
%   for the first electrode will be elecs(1), train_length(1), etc.
%   
%   Arguments 1-7 are required and must be arrays of equal length.
%   
%   elecs - one indexed list of wanted electrodes - must be integers
%   train_length - length of pulse train (ms)
%   freq - frequency of pulse train (Hz)
%   duration - duration of single phase (ms)
%   amp - height of single phase's current (headstage steps - [0, 127]
%   delay - delay for interleaving (ms)
%   pol - polarity.  For bipolar stimulation.  1 - cathodic first, 
%     0 - anodic first

% Check that length of all arrays are equal
if pulse_train ==1
if length(unique([length(elecs), length(train_length), length(freq), ...
         length(cath_amp), length(anod_amp), length(cath_duration),...
         length(anod_duration), length(delay)])) ~= 1
    error('invalid stim parameters, check array lengths');
end
else
if length(unique([length(elecs), length(train_length), ...
         length(cath_amp), length(anod_amp), length(cath_duration),...
         length(anod_duration), length(delay)])) ~= 1
    error('invalid stim parameters, check array lengths');    
end
end

elect_str = 'Elect=';
tl_str = 'TL=';
freq_str = 'Freq=';
cathdur_str = 'CathDur=';
anoddur_str = 'AnodDur=';
cathamp_str = 'CathAmp=';
anodamp_str = 'AnodAmp=';
delay_str = 'TD=';
pol_str = 'PL=';

elect_str = strcat(elect_str, sprintf('%d,', elecs));
tl_str = strcat(tl_str, sprintf('%.3f,', train_length));
freq_str = strcat(freq_str, sprintf('%.0f,', freq));
cathdur_str = strcat(cathdur_str, sprintf('%.3f,', cath_duration));
anoddur_str = strcat(anoddur_str, sprintf('%.3f,', anod_duration));
cathamp_str = strcat(cathamp_str, sprintf('%.3f,', cath_amp));
anodamp_str = strcat(anodamp_str, sprintf('%.3f,', anod_amp));
delay_str = strcat(delay_str, sprintf('%.3f,', delay));
pol_str = strcat(pol_str, sprintf('%d,', pol));

if pulse_train ==1
rt_str = strcat(elect_str, ';', tl_str, ';', freq_str, ';',...
    cathdur_str, ';', anoddur_str, ';', cathamp_str, ';', anodamp_str, ';',...
    delay_str, ';', pol_str, ';');
else
rt_str = strcat(elect_str, ';', tl_str, ';', ...
    cathdur_str, ';', anoddur_str, ';', cathamp_str, ';', anodamp_str, ';',...
    delay_str, ';', pol_str, ';');    
end
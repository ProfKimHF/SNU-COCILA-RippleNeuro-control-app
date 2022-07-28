function [stimChans,recChans,stimFEs,recFEs] = xippmex_initialization(mTimer,~)
%% Initialization
status = xippmex; % xippmex initialization
if status ~= 1; error('Xippmex did not initialize. Check the Ripple-PC connection'); end % status check

xippmex('digin', 'bit-change', 1); % setting for digital input trigger

stimChans  = xippmex('elec','stim'); % Find all Stim channels and Corresponding FE's
stimFEs = unique(ceil(stimChans/32));

recChans   = [xippmex('elec','micro'), xippmex('elec','nano')];  % Find all Recording channels and Corresponding FE's
recFEs = unique(ceil(recChans/32));
if isempty(recChans) || isempty(stimChans)
    error('Either stim or recording channel is empty. Please check the configuration');
end

anlgChans = xippmex('elec','analog');

mTimer.UserData.recChans = recChans;
mTimer.UserData.stimChans = stimChans;
mTimer.UserData.anlgChans = anlgChans;

mTimer.UserData.recFEs = recFEs;
mTimer.UserData.stimFEs = stimFEs;

[~,~,~] = xippmex('digin'); %Reset DAQ
[~, ~, ~] = xippmex('spike', recChans(1:length(recChans)), zeros(length(recChans))); % neural spike data 받기
offset = length(mTimer.UserData.App.Rasters{mTimer.UserData.App.Raster_Source}.Children)-mTimer.UserData.App.Raster_index.reference;


 RI = cell2struct(num2cell([cellfun(@(x) x+offset, struct2cell(mTimer.UserData.App.Raster_index))]),...
       {'event_label','ch_num','plot_button','row','col','lock','play','file_open_config',...
                'file_save_config','file_save_data','file_open_data','kernel','neural','behavioral','stop','plotdim','data','config','plotopt','ch_label','DAQ','refresh_text','refresh','reference'}); %label for Children; offset accounted

mTimer.UserData.App.StatusLabel.Text = 'Xippmex is being initialized (~5 secs)...';
pause(0.1);
xippmex('signal', anlgChans(1:4), '1ksps', [ones(1,4)]);



mTimer.UserData.App.StatusLabel.Text = 'Xippmex is ready';
mTimer.UserData.App.Rasters{mTimer.UserData.App.Raster_Source}.Children(RI.event_label).Text = 'Scanning for START ECODE';



function trial_DAQ(mTimer,~)

%%% Innertimer
%%% Input: mTimer: reference to timer object
%%% This function processes and saves input data during the trial
%try
%% Background loop for data acquisition
outer_timer = mTimer.UserData.Outtimer;
eyeHorz_ind = 1;
eyeVert_ind = 2;
anlgChans = outer_timer.UserData.anlgChans; %recording channel
sampling_rate = 30; % 30khz
sma1_reason = 2;

parallel_reason = 1;

app = mTimer.UserData.Outtimer.UserData.App;
recChans = outer_timer.UserData.recChans; %recording channel

[anlgData_vert,anlgtime_vert]  = xippmex('cont', anlgChans(eyeVert_ind),1,'1ksps');
[anlgData_horz,anlgtime_horz]  = xippmex('cont', anlgChans(eyeHorz_ind),1,'1ksps');

anlgtime_vert = double((anlgtime_vert - mTimer.UserData.ts_time)/sampling_rate);
anlgtime_horz = double((anlgtime_horz - mTimer.UserData.ts_time)/sampling_rate);

outer_timer.UserData.Rasters{app.Raster_Source}.anlgData_vert{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = [outer_timer.UserData.Rasters{app.Raster_Source}.anlgData_vert{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} anlgData_vert];
outer_timer.UserData.Rasters{app.Raster_Source}.anlgData_horz{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = [outer_timer.UserData.Rasters{app.Raster_Source}.anlgData_horz{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} anlgData_horz];
outer_timer.UserData.Rasters{app.Raster_Source}.anlgTime_vert{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = [outer_timer.UserData.Rasters{app.Raster_Source}.anlgTime_vert{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} anlgtime_vert];
outer_timer.UserData.Rasters{app.Raster_Source}.anlgTime_horz{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = [outer_timer.UserData.Rasters{app.Raster_Source}.anlgTime_horz{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} anlgtime_horz];



outer_timer.UserData.Current_time = [outer_timer.UserData.Current_time xippmex('time')];


%        while (~trial_end) %trial이 끝나기 전까지
[~,timestamps,events] = xippmex('digin'); % digital input 계속 받으면서 대기
[~, spkTimestamps_tmp, ~] = xippmex('spike', recChans(1:length(recChans)), zeros(length(recChans))); % neural spike data 받기


if any([events.reason] == sma1_reason) && app.StimstandbyButton.UserData %&& Stim ready signal % stim digital 신호 들어오면 % Delay 를 최소화하기위해 digin 뒤에 바로 실행함.; if there is signal from sma1_reason & stim standby is pushed
    if mTimer.UserData.Outtimer.UserData.App.Singlepulse1Block333usCheckBox.Value %if single pulse is checked
        xippmex('stimseq',app.stimString); %stimseq is used for single pulse
    else
        xippmex('stim',app.stimString);
    end
end

parallel_tmp = [events.parallel];
sma1_tmp = [events.sma1];
sma2_tmp = [events.sma2];
sma3_tmp = [events.sma3];
reason_tmp = [events.reason];
ind = reason_tmp == parallel_reason;
parallel = parallel_tmp(ind); %finding ECODE
timestamps_parallel = timestamps(ind);
if any(parallel == mTimer.UserData.Stop_ECODE)
    end_ind = find([parallel]==mTimer.UserData.Stop_ECODE);
    %te_time = timestamps(end_ind);
    timestamps_parallel = timestamps_parallel(1:end_ind);
    %sma1_tmp(end_ind+1:end) = [];
    %sma2_tmp(end_ind+1:end) = [];
    %sma3_tmp(end_ind+1:end) = [];
    parallel = parallel(1:end_ind);
    timestamps_parallel = (timestamps_parallel-mTimer.UserData.ts_time)/sampling_rate;%Ripple sends timestamps by multiplying by sampling rate, so need to divide this
    spkTimestamps_tmp = cellfun(@(x) (x - mTimer.UserData.ts_time)/sampling_rate, spkTimestamps_tmp,'un',0); %ts_time=first startEcode time; calculates spkTimestamp from the startEcode timestamp
    spkTimestamps_tmp = cellfun(@(x) x(x<=timestamps_parallel(end_ind)),spkTimestamps_tmp,'UniformOutput',false);
    
    mTimer.UserData.trial_end = 1;
else
    spkTimestamps_tmp = cellfun(@(x) (x - mTimer.UserData.ts_time)/sampling_rate, spkTimestamps_tmp,'un',0);
    timestamps_parallel = (timestamps_parallel-mTimer.UserData.ts_time)/sampling_rate;
end


outer_timer.UserData.Rasters{app.Raster_Source}.Eventcode{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = [outer_timer.UserData.Rasters{app.Raster_Source}.Eventcode{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} parallel]; %add parallel(Ecode) to UserData.Eventcode{...UserData.Trial}
outer_timer.UserData.Rasters{app.Raster_Source}.Eventtime{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = [outer_timer.UserData.Rasters{app.Raster_Source}.Eventtime{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} timestamps_parallel]; %add timestamps_parallel(ECode Timestamps) to UserData.Eventtime{...UserData.Trial}
outer_timer.UserData.Rasters{app.Raster_Source}.Spiketime{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = cellfun(@horzcat,outer_timer.UserData.Rasters{app.Raster_Source}.Spiketime{outer_timer.UserData.Rasters{app.Raster_Source}.Trial}, spkTimestamps_tmp,'UniformOutput',false); %add spkTimestamps_tmp(spk Timestamps) to UserData.Eventtime{...UserData.Trial}

if mTimer.UserData.trial_end
    [anlgData_vert,anlgtime_vert]  = xippmex('cont', anlgChans(eyeVert_ind),1,'1ksps');
    [anlgData_horz,anlgtime_horz]  = xippmex('cont', anlgChans(eyeHorz_ind),1,'1ksps');
    
    anlgtime_vert = double((anlgtime_vert - mTimer.UserData.ts_time)/sampling_rate);
    anlgtime_horz = double((anlgtime_horz - mTimer.UserData.ts_time)/sampling_rate);
    
    outer_timer.UserData.Rasters{app.Raster_Source}.anlgData_vert{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = [outer_timer.UserData.Rasters{app.Raster_Source}.anlgData_vert{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} anlgData_vert];
    outer_timer.UserData.Rasters{app.Raster_Source}.anlgData_horz{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = [outer_timer.UserData.Rasters{app.Raster_Source}.anlgData_horz{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} anlgData_horz];
    outer_timer.UserData.Rasters{app.Raster_Source}.anlgTime_vert{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = [outer_timer.UserData.Rasters{app.Raster_Source}.anlgTime_vert{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} anlgtime_vert];
    outer_timer.UserData.Rasters{app.Raster_Source}.anlgTime_horz{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} = [outer_timer.UserData.Rasters{app.Raster_Source}.anlgTime_horz{outer_timer.UserData.Rasters{app.Raster_Source}.Trial} anlgtime_horz];
    
    
    % mTimer.UserData.Outtimer.UserData.Trial = mTimer.UserData.Outtimer.UserData.Trial+1;
    offset = length(outer_timer.UserData.App.Rasters{app.Raster_Source}.Children)-app.Raster_index.reference;
    RI = cell2struct(num2cell([cellfun(@(x) x+offset, struct2cell(app.Raster_index))]),...
        {'event_label','ch_num','plot_button','row','col','lock','play','file_open_config',...
        'file_save_config','file_save_data','file_open_data','kernel','neural','behavioral','stop','plotdim','data','config','plotopt','ch_label','DAQ','refresh_text','refresh','reference'}); %label for Children; offset accounted
    
    app.Rasters{app.Raster_Source}.Children(RI.event_label).Text= 'END ECODE found';
    plot_raster(mTimer.UserData.Outtimer)
    
    stop(mTimer);
end

end%catch exception
%    stop(mTimer);
%end







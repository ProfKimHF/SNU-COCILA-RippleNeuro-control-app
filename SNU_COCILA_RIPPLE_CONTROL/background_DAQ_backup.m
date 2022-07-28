function background_DAQ(mTimer,~)

eyeHorz_ind = 1;
eyeVert_ind = 2;
sampling_rate = 30;
anlgChans = mTimer.UserData.anlgChans; %recording channel

if strcmp(mTimer.UserData.innertimer.Running,'off')
    sampling_rate = 30; % 30khz
    
    parallel_reason = 1;
    

    
    app = mTimer.UserData.App;

    offset = length(app.Rasters{mTimer.UserData.App.Raster_Source}.Children)-app.Raster_index.reference; %when Children is added, the index is shifted. This offset accounts for that shift.
    RI = cell2struct(num2cell([cellfun(@(x) x+offset, struct2cell(app.Raster_index))]),...
        {'event_label','ch_num','plot_button','row','col','lock','play','file_open_config',...
        'file_save_config','file_save_data','file_open_data','kernel','neural','behavioral','stop','plotdim','data','config','plotopt','ch_label','DAQ','refresh_text','refresh','reference'}); %label for Children; offset accounted
    
    if app.new_Raster
        index=  length(mTimer.UserData.Rasters);
        mTimer.UserData.Rasters{index+1}.Trial = 0;
        mTimer.UserData.Rasters{index+1}.Eventcode = {};
        mTimer.UserData.Rasters{index+1}.Eventtime = {};
        mTimer.UserData.Rasters{index+1}.Spiketime = {};
        mTimer.UserData.Rasters{index+1}.anlgData_vert = {};
        mTimer.UserData.Rasters{index+1}.anlgData_horz = {};
        mTimer.UserData.Rasters{index+1}.anlgTime_vert = {};
        mTimer.UserData.Rasters{index+1}.anlgTime_horz = {};
        app.new_Raster = 0;
    end

    if mTimer.UserData.App.update_plottingtools
        mTimer.UserData.Rasters{app.Raster_Source }.histo = cell(1,...
            app.Rasters{app.Raster_Source }.UserData.row*app.Rasters{app.Raster_Source }.UserData.col);
        mTimer.UserData.Rasters{app.Raster_Source }.event_plot = cell(1,...
            app.Rasters{app.Raster_Source }.UserData.row*app.Rasters{app.Raster_Source }.UserData.col);
        mTimer.UserData.Rasters{app.Raster_Source }.spike_plot = cell(1,...
            app.Rasters{app.Raster_Source }.UserData.row*app.Rasters{app.Raster_Source }.UserData.col);
        mTimer.UserData.Rasters{app.Raster_Source }.ref_plot =cell(1,...
            app.Rasters{app.Raster_Source }.UserData.row*app.Rasters{app.Raster_Source }.UserData.col);
        mTimer.UserData.App.update_plottingtools = 0;
    end



    if app.Rasters{app.Raster_Source}.UserData.inst_save == 1 && ~isempty(app.Image_fileopen_2.UserData) && ~mTimer.UserData.plotting && mTimer.UserData.App.Rasters{mTimer.UserData.App.Raster_Source}.UserData.PlotRasterButton.UserData.firstplot==1 %file save icon clicked & saved

        if app.Rasters{app.Raster_Source}.UserData.overwrite
            currentFolder = app.def_dir;
            inst_data.Eventtime = mTimer.UserData.Rasters{app.Raster_Source}.Eventtime;
            inst_data.Eventcode = mTimer.UserData.Rasters{app.Raster_Source}.Eventcode;
            inst_data.Spiketime = mTimer.UserData.Rasters{app.Raster_Source}.Spiketime;
            inst_data.anlgData_vert = mTimer.UserData.Rasters{app.Raster_Source}.anlgData_vert;
            inst_data.anlgData_horz = mTimer.UserData.Rasters{app.Raster_Source}.anlgData_horz;
            inst_data.anlgTime_vert = mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_vert;
            inst_data.anlgTime_horz = mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_horz;

            
            inst_data.Trial = mTimer.UserData.Rasters{app.Raster_Source}.Trial;
            inst_data.app_tmp = app.save_config(app.Rasters{app.Raster_Source}.UserData);
            cd (app.Image_fileopen_2.UserData.dir);
            save(app.Image_fileopen_2.UserData.name,'inst_data');

            cd(currentFolder);
            app.Rasters{app.Raster_Source}.UserData.inst_save = 0;
        elseif app.Rasters{app.Raster_Source}.UserData.append
            
            currentFolder = app.def_dir;
            new_data.Eventtime = mTimer.UserData.Rasters{app.Raster_Source}.Eventtime;
            new_data.Eventcode = mTimer.UserData.Rasters{app.Raster_Source}.Eventcode;
            new_data.Spiketime = mTimer.UserData.Rasters{app.Raster_Source}.Spiketime;
            inst_data.anlgData_vert = mTimer.UserData.Rasters{app.Raster_Source}.anlgData_vert;
            inst_data.anlgData_horz = mTimer.UserData.Rasters{app.Raster_Source}.anlgData_horz;
            inst_data.anlgTime_vert = mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_vert;
            inst_data.anlgTime_horz = mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_horz;
            
            
            new_data.Trial = mTimer.UserData.Rasters{app.Raster_Source}.Trial;
            new_data.app_tmp = app.save_config(app.Rasters{app.Raster_Source}.UserData);
            cd(app.Image_fileopen_2.UserData.dir);
            
            old_data = load([app.Image_fileopen_2.UserData.name]);
            
            inst_data.Eventtime = [old_data.inst_data.Eventtime new_data.Eventtime];
            inst_data.Eventcode = [old_data.inst_data.Eventcode new_data.Eventcode];
            inst_data.Spiketime = [old_data.inst_data.Spiketime new_data.Spiketime];
            inst_data.anlgData_vert = [old_data.inst_data.anlgData_vert new_data.anlgData_vert];
            inst_data.anlgData_horz = [old_data.inst_data.anlgData_horz new_data.anlgData_horz];
            inst_data.anlgTime_vert = [old_data.inst_data.anlgData_time new_data.anlgTime_vert];
            inst_data.anlgTime_horz = [old_data.inst_data.anlgData_time new_data.anlgTime_horz];
            
            inst_data.Trial = [new_data.Trial];
            inst_data.app_tmp = [new_data.app_tmp];

            save(app.Image_fileopen_2.UserData.name,'inst_data');



            cd(currentFolder);
            app.Rasters{app.Raster_Source}.UserData.inst_save = 0;
        else
            
            currentFolder = app.def_dir;
            inst_data.Eventtime = mTimer.UserData.Rasters{app.Raster_Source}.Eventtime;
            inst_data.Eventcode = mTimer.UserData.Rasters{app.Raster_Source}.Eventcode;
            inst_data.Spiketime = mTimer.UserData.Rasters{app.Raster_Source}.Spiketime;
            inst_data.anlgData_vert = mTimer.UserData.Rasters{app.Raster_Source}.anlgData_vert;
            inst_data.anlgData_horz = mTimer.UserData.Rasters{app.Raster_Source}.anlgData_horz;
            inst_data.anlgTime_vert = mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_vert;
            inst_data.anlgTime_horz = mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_horz;
            
            
            
            
            inst_data.Trial = mTimer.UserData.Rasters{app.Raster_Source}.Trial;
            inst_data.app_tmp = app.save_config(app.Rasters{app.Raster_Source}.UserData);
            cd (app.Image_fileopen_2.UserData.dir);
            save(app.Image_fileopen_2.UserData.name,'inst_data');

            cd(currentFolder);
            app.Rasters{app.Raster_Source}.UserData.inst_save = 0;

        end
        app.StatusLabel.Text = [app.Image_fileopen_2.UserData.name ' saved'];
        app.StatusLabel.FontColor = [0.39,0.83,0.07];
        app.Rasters{app.Raster_Source}.Children(RI.file_save_data).ImageSource = "file_save_icon.PNG";

    end

    for i = 1: length(mTimer.UserData.App.Rasters)
        if app.Raster_Source == i
            app.Rasters{i}.ForegroundColor = [0 0 1]; %selected(current) raster color - blue
        else
            app.Rasters{i}.ForegroundColor = [0 0 0]; %other raster(nonselected)
        end
    end

    if app.Rasters{mTimer.UserData.App.Raster_Source}.UserData.PlotRasterButton.UserData.newplot==1 ||  app.Rasters{app.Raster_Source}.UserData.Refresh == 1 && ~mTimer.UserData.plotting %initialization for new raster plot

        mTimer.UserData.Rasters{app.Raster_Source}.Eventcode = {};
        mTimer.UserData.Rasters{app.Raster_Source}.Eventtime = {};
        mTimer.UserData.Rasters{app.Raster_Source}.Spiketime = {};
        mTimer.UserData.Rasters{app.Raster_Source}.anlgData_vert = {};
        mTimer.UserData.Rasters{app.Raster_Source}.anlgData_horz = {};
        mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_vert = {};
        mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_horz = {};
        
        
        mTimer.UserData.Rasters{app.Raster_Source}.Trial = 0;
        mTimer.UserData.Rasters{app.Raster_Source}.UserData.PlotRasterButton.UserData.newplot=0;
        mTimer.UserData.Rasters{app.Raster_Source}.Children(RI.event_label).Text = 'Scanning for START ECODE';
        if app.Rasters{app.Raster_Source}.UserData.Refresh == 1%initialization for new raster plot
            app.Rasters{app.Raster_Source}.UserData.Refresh = 0;
        end
    end

    if  ~app.Rasters{app.Raster_Source}.UserData.Image_play.UserData %when image playbutton is selected
        app.Rasters{app.Raster_Source}.Children(RI.event_label).Text = 'Scanning for START ECODE';
    end

    if app.Anti_running
        app.first_time_anti = 1;
        [~,~,~,~] = xippmex('spike',app.RecChSpinner.Value);
        start(mTimer.UserData.antitimer);
        app.Anti_running = 0;
        app.Rasters{app.Raster_Source}.UserData.Image_play.UserData = 0;
        app.Rasters{app.Raster_Source}.UserData.Image_play.ImageSource = 'play_icon.PNG';
        app.Rasters{app.Raster_Source}.UserData.Image_stop.ImageSource = 'stop_select.PNG';
    end

    if app.Anti_refresh
        app.Anti_refresh=0;
        app.Image8_2.ImageSource = "refresh_icon.PNG";
        delete(app.UIAxes_2.Children)
        xline(app.UIAxes_2,0,'--');
        xline(app.UIAxes_2,app.ReferenceSlider.Value);
        xline(app.UIAxes_2,app.SliderforStimDelay.Value)
    end



    if (mTimer.UserData.App.Rasters{mTimer.UserData.App.Raster_Source}.UserData.load) && ~mTimer.UserData.plotting && ~mTimer.UserData.App.Rasters{mTimer.UserData.App.Raster_Source}.UserData.Image_play.UserData%if the user loads data
            for i = 1: length(mTimer.UserData.Rasters{app.Raster_Source}.spike_plot)
            if ~isempty(mTimer.UserData.Rasters{app.Raster_Source}.spike_plot{i})
                delete(mTimer.UserData.Rasters{app.Raster_Source}.spike_plot{i});
            end
            if ~isempty(mTimer.UserData.Rasters{app.Raster_Source}.event_plot{i})
                delete(mTimer.UserData.Rasters{app.Raster_Source}.event_plot{i});
            end
            if ~isempty(mTimer.UserData.Rasters{app.Raster_Source}.histo{i})
                delete(mTimer.UserData.Rasters{app.Raster_Source}.histo{i});
            end
            end

        mTimer.UserData.Rasters{app.Raster_Source}.Eventtime =  app.input_data.inst_data.Eventtime;
        mTimer.UserData.Rasters{app.Raster_Source}.Eventcode =  app.input_data.inst_data.Eventcode;
        mTimer.UserData.Rasters{app.Raster_Source}.Spiketime =  app.input_data.inst_data.Spiketime;
        mTimer.UserData.Rasters{app.Raster_Source}.anlgData_vert =  app.input_data.inst_data.anlgData_vert;
        mTimer.UserData.Rasters{app.Raster_Source}.anlgData_horz =  app.input_data.inst_data.anlgData_horz;
        mTimer.UserData.Rasters{app.Raster_Source}.anlgData_time =  app.input_data.inst_data.anlgData_time;
        
        
        mTimer.UserData.Rasters{app.Raster_Source}.Trial =  app.input_data.inst_data.Trial;
        app.Rasters{app.Raster_Source}.UserData.load = 0;
    end

    
    
    
    mTimer.UserData.Rasters{app.Raster_Source}.Eventcode{mTimer.UserData.Rasters{app.Raster_Source}.Trial+1} = []; % as this is added by trial by trial, adds onto the loaded data or the previous data (thus the +1)
    mTimer.UserData.Rasters{app.Raster_Source}.Eventtime{mTimer.UserData.Rasters{app.Raster_Source}.Trial+1} = [];
    mTimer.UserData.Rasters{app.Raster_Source}.Spiketime{mTimer.UserData.Rasters{app.Raster_Source}.Trial+1} = cell(length(mTimer.UserData.recChans),1);
    mTimer.UserData.Rasters{app.Raster_Source}.anlgData_vert{mTimer.UserData.Rasters{app.Raster_Source}.Trial+1} = []; % as this is added by trial by trial, adds onto the loaded data or the previous data (thus the +1)
    mTimer.UserData.Rasters{app.Raster_Source}.anlgData_horz{mTimer.UserData.Rasters{app.Raster_Source}.Trial+1} = [];
    mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_vert{mTimer.UserData.Rasters{app.Raster_Source}.Trial+1} = [];
    mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_horz{mTimer.UserData.Rasters{app.Raster_Source}.Trial+1} = [];

    
    
    [~, spkTimestamps_tmp, ~] = xippmex('spike', mTimer.UserData.recChans(1:length(mTimer.UserData.recChans)), zeros(length(mTimer.UserData.recChans))); % neural spike data 받기
    [~,timestamps,events] = xippmex('digin'); % digital input 계속 받으면서 대기, events include reason,sma1~4,parallel

    app.Raster_Source = app.Raster_Source_tmp;
    if app.Rasters{app.Raster_Source}.UserData.Image_play.UserData==1 && (app.Rasters{app.Raster_Source}.UserData.PlotRasterButton.UserData.firstplot==1)


        parallel_tmp = [events.parallel];
        ind = [events.reason]==parallel_reason; %find parallels(get Ecode, which reason == parallel_reason)
        parallel = parallel_tmp(ind);
        parallel_time = timestamps(ind);
        trial_start_ind = find(parallel == mTimer.UserData.Start_ECODE);
        
        if (any(parallel==mTimer.UserData.Start_ECODE)) % trial 이 시작 되면(if there is any start Ecode)
            
            [anlgData_vert,anlgtime_vert]  = xippmex('cont', anlgChans(eyeVert_ind),1,'1ksps');
            [anlgData_horz,anlgtime_horz]  = xippmex('cont', anlgChans(eyeHorz_ind),1,'1ksps');
            
     
            
            mTimer.UserData.Rasters{app.Raster_Source}.Trial = mTimer.UserData.Rasters{app.Raster_Source}.Trial+1; % next trial
            offset = length(app.Rasters{app.Raster_Source}.Children)-app.Raster_index.reference;
            RI = cell2struct(num2cell([cellfun(@(x) x+offset, struct2cell(app.Raster_index))]),...
                {'event_label','ch_num','plot_button','row','col','lock','play','file_open_config',...
                'file_save_config','file_save_data','file_open_data','kernel','neural','behavioral','stop','plotdim','data','config','plotopt','ch_label','DAQ','refresh_text','refresh','reference'}); %label for Children; offset accounted
            app.Rasters{app.Raster_Source}.Children(RI.event_label).Text = 'START ECODE found';
            ts_time = parallel_time(trial_start_ind(1)); %ts_time=first startEcode time
            
                   anlgtime_vert = double((anlgtime_vert - ts_time)/sampling_rate);
            anlgtime_horz = double((anlgtime_horz - ts_time)/sampling_rate);

            mTimer.UserData.Rasters{app.Raster_Source}.anlgData_vert{mTimer.UserData.Rasters{app.Raster_Source}.Trial} = [mTimer.UserData.Rasters{app.Raster_Source}.anlgData_vert{mTimer.UserData.Rasters{app.Raster_Source}.Trial} anlgData_vert];
            mTimer.UserData.Rasters{app.Raster_Source}.anlgData_horz{mTimer.UserData.Rasters{app.Raster_Source}.Trial} = [mTimer.UserData.Rasters{app.Raster_Source}.anlgData_horz{mTimer.UserData.Rasters{app.Raster_Source}.Trial} anlgData_horz];
            mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_vert{mTimer.UserData.Rasters{app.Raster_Source}.Trial} = [mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_vert{mTimer.UserData.Rasters{app.Raster_Source}.Trial} anlgtime_vert];
            mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_horz{mTimer.UserData.Rasters{app.Raster_Source}.Trial} = [mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_horz{mTimer.UserData.Rasters{app.Raster_Source}.Trial} anlgtime_horz];
            
          
            
            spkTimestamps = cellfun(@(x) (x(x>=ts_time)-ts_time)/sampling_rate, spkTimestamps_tmp, 'UniformOutput', false); %from spkTimestamps_tmp, find timestamp after startEcode; Ripple sends timestamps by multiplying by sampling rate, so need to divide this
            mTimer.UserData.Rasters{app.Raster_Source}.Spiketime{mTimer.UserData.Rasters{app.Raster_Source}.Trial}...
                =  cellfun(@horzcat, mTimer.UserData.Rasters{app.Raster_Source}.Spiketime{mTimer.UserData.Rasters{app.Raster_Source} ...
                .Trial}, spkTimestamps, 'UniformOutput',false); %add spkTimestamps to UserData.Trial
            mTimer.UserData.Rasters{app.Raster_Source}.Eventcode{mTimer.UserData.Rasters{app.Raster_Source}.Trial}...
                = [ mTimer.UserData.Rasters{app.Raster_Source}.Eventcode{mTimer.UserData.Rasters{app.Raster_Source}.Trial} parallel(trial_start_ind(1):end)]; %add ECodes from first start Ecode to UserData.Trial
            mTimer.UserData.Rasters{app.Raster_Source}.Eventtime{mTimer.UserData.Rasters{app.Raster_Source}.Trial}...
                = [ mTimer.UserData.Rasters{app.Raster_Source}.Eventtime{mTimer.UserData.Rasters{app.Raster_Source}.Trial} (parallel_time(trial_start_ind(1):end)-ts_time)/sampling_rate]; %to above, add timestamps since first start Ecode
            mTimer.UserData.innertimer.UserData.ts_time = ts_time;
            mTimer.UserData.innertimer.UserData.Stop_ECODE = mTimer.UserData.Stop_ECODE;
      
            [anlgData_vert,anlgtime_vert]  = xippmex('cont', anlgChans(eyeVert_ind),1,'1ksps');
            [anlgData_horz,anlgtime_horz]  = xippmex('cont', anlgChans(eyeHorz_ind),1,'1ksps');
            
            
            anlgtime_vert = double((anlgtime_vert - ts_time)/sampling_rate);
            anlgtime_horz = double((anlgtime_horz - ts_time)/sampling_rate);
            
            mTimer.UserData.Rasters{app.Raster_Source}.anlgData_vert{mTimer.UserData.Rasters{app.Raster_Source}.Trial} = [mTimer.UserData.Rasters{app.Raster_Source}.anlgData_vert{mTimer.UserData.Rasters{app.Raster_Source}.Trial} anlgData_vert];
            mTimer.UserData.Rasters{app.Raster_Source}.anlgData_horz{mTimer.UserData.Rasters{app.Raster_Source}.Trial} = [mTimer.UserData.Rasters{app.Raster_Source}.anlgData_horz{mTimer.UserData.Rasters{app.Raster_Source}.Trial} anlgData_horz];
            mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_vert{mTimer.UserData.Rasters{app.Raster_Source}.Trial} = [mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_vert{mTimer.UserData.Rasters{app.Raster_Source}.Trial} anlgtime_vert];
            mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_horz{mTimer.UserData.Rasters{app.Raster_Source}.Trial} = [mTimer.UserData.Rasters{app.Raster_Source}.anlgTime_horz{mTimer.UserData.Rasters{app.Raster_Source}.Trial} anlgtime_horz];
            
            
            

            start(mTimer.UserData.innertimer); %start inner timer
        end
    end
end
end

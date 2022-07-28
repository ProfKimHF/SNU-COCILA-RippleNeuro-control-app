function t = create_DAQ_timer(inner_timer,anti_timer,start_ecode,stop_ecode,app) %outer timer
period_seconds = 0.001;

t=timer;
t.UserData.Trial = 0;
t.UserData.innertimer = inner_timer;
t.UserData.antitimer = anti_timer;
t.UserData.Start_ECODE = start_ecode;
t.UserData.Stop_ECODE = stop_ecode;
%t.UserData.Rasters=cell(1,1);
t.UserData.Rasters{1}.Trial = 0;
t.UserData.Rasters{1}.Eventcode = {};
t.UserData.Rasters{1}.Eventtime = {};
t.UserData.Rasters{1}.Spiketime = {};
t.UserData.Rasters{1}.histo = cell(1,1);
t.UserData.Rasters{1}.event_plot = cell(1,1);
t.UserData.Rasters{1}.spike_plot = cell(1,1);
t.UserData.Rasters{1}.ref_plot =cell(1,1);
t.UserData.Rasters{1}.anlgData_vert = cell(1,1);
t.UserData.Rasters{1}.anlgData_horz = cell(1,1);

t.UserData.Rasters{1}.anlgData_time = cell(1,1);
%t.UserData.Rasters{1}.anlgTime_vert = cell(1,1);
%t.UserData.Rasters{1}.anlgTime_horz = cell(1,1);
t.UserData.Current_time = [];
t.UserData.plotting = 0;

t.UserData.App = app; %app의 모든 객체들이 여기 들어감
t.StartFcn = @xippmex_initialization;
t.TimerFcn = @background_DAQ;
t.Period = period_seconds;
t.ExecutionMode = 'fixedSpacing';
end


function [] = anti_stim(mTimer,~)

app =mTimer.UserData.Outtimer.UserData.App;
disp('anti_stim')
%xippmex('stim',[]);
app.anti_stim_ready = 0;
app.anti_stim_time = xippmex('time')/30;
start(mTimer.UserData.spiketimer);

end
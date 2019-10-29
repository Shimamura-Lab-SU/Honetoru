%
%	Open Lab で使う骨導音声取得用アプリケーション
%	「ほねとる」
%
%	[使い方]
%	・起動後，インプットデバイスを選択
%	・「Record」ボタンでステレオ録音
%	・波形，スペクトルをクリックすると再生
%
% ----------------------------------------
%	[更新履歴]
%	・2016/11/18 ver. 1.0	by Y. Sugiura	：基本的なUIを実装
%	・2016/11/19 ver. 1.1	by Y. Sugiura	：uifigureで実装しようとして断念
%	・2016/11/21 ver. 1.2	by Y. Sugiura	：スペクトログラムを実装
% ----------------------------------------

function Honetoru


	%%	Sound Settings
	
	% ** ARBITRALY **
	Fs			= 16000;						% Sampling Frequency
	Bit			= 16;							% Quantization Bit
	PrepareTime = 1;% [s]						% Preparing Time [s] for Playing Noise
	
	% -- Devices --
	info		= audiodevinfo;							% Get Device Information 

	% -- Input Device --
	InputNum			= audiodevinfo(1);				% Get Input Device Information
	InputDeviceName		= cell(InputNum+1,1);
	InputDeviceName{1}	= ' - none -';
	if InputNum > 0
		for i= 1:InputNum
			InputDeviceName{i+1} = info.input(i).Name;	% Get Deivce Name
		end
	end
	
	% -- Output Device --
	OutputNum			= audiodevinfo(0);
	OutputDeviceName	= cell(OutputNum,1);
	for i= 1:OutputNum
		OutputDeviceName{i} = info.output(i).Name;		% Get Deivce Name
	end
	
	% -- Noises --
	path		= 'noise_data\';				% Noise Folder Path
	[g2,fs2]	= audioread([path,'white.wav']);% White Noise
	%[g3,fs3]	= audioread([path,'pink.wav']);	% Pink Noise
	%[g3,fs3]	= audioread([path,'highnoise.wav']);	% Hifi Noise
	[g3,fs3]	= audioread([path,'babble.wav']);	% Hifi Noise
	[g4,fs4]	= audioread([path,'train.wav']);% Train Noise
	% Fade In Effect
	g2			= [(11.^(0:1/fs2:PrepareTime)-1)./10, ones(1,length(g2)-round(PrepareTime*fs2)-1)]'.* g2;
	g3			= [(11.^(0:1/fs3:PrepareTime)-1)./10, ones(1,length(g3)-round(PrepareTime*fs3)-1)]'.* g3;
	g4			= [(11.^(0:1/fs4:PrepareTime)-1)./10, ones(1,length(g4)-round(PrepareTime*fs4)-1)]'.* g4;
	% Normalization Effect
	g2			= 0.8*g2./max(abs(g2));
	g3			= 0.8*g3./max(abs(g3));
	g4			= 0.8*g4./max(abs(g4));
	
	% -- Sound --
	ch1			= 0;							% Channel 1
	ch2			= 0;							% Channel 2
	ch3			= 0;							% Channel 3
	ch4			= 0;							% Channel 4
	
	% -- Spectrogram --
	N			= 1024;
	Shift		= floor(256*0.25);
	spectra(0,N,Shift);							% Initialized

	% -- Player --
	Recorder1	= 0;							% Sound Recorder 1 (Dummy)
	Recorder2	= 0;							% Sound Recorder 2 (Dummy)
	g			= g2;
	fs			= fs2;
	NoisePlayer = audioplayer(g2,fs2);			% Sound Player for Noise (Initial:White)
	Player1		= audioplayer(ch1,Fs);			% Sound Player for Channel 1 (Dummy)
	Player2		= audioplayer(ch2,Fs);			% Sound Player for Channel 2 (Dummy)
	

	%%	UI Settings
	
	% ----------------------------
	%	Figure Settings
	% ----------------------------
    f = figure('Visible','off',...				% Display
		'Name',' Noise Reduction Demo ver.1',...		% Title
		'NumberTitle','off',...					% Title Number
		'MenuBar','none',...					% Menu bar
		'ToolBar','none',...
		'CloseRequestFcn',@CloseALL);
		f.Color	= [.99,.99,.99];
	
	% ----------------------------
	%	Create Input Device 1 menu
	% ----------------------------
	% Panel
	SettingTab	= uipanel(f,'Position',[.025 .82 .95 .175],...
				'Title','Settings');
	% Create Text
	TXT_In1		= uicontrol(SettingTab,'Style','text',...
				'Position',[15 33 100 20],...
				'String','Input Device 1',...
				'HorizontalAlignment','left',...
				'FontSize',10);
	% Create Pop-up
	POP_In1		= uicontrol(SettingTab,'Style', 'popup',...
				'String',InputDeviceName,...
				'Position', [100 25 150 30],...
				'FontSize',10,...
				'Callback', @SelectInput);
			
	% ----------------------------
	%	Create Input Device 2 menu
	% ----------------------------
	% Panel
	%SettingTab	= uipanel(f,'Position',[.025 .82 .95 .175],...
	%			'Title','Settings');
	% Create Text
	TXT_In2		= uicontrol(SettingTab,'Style','text',...
				'Position',[15 5 100 20],...
				'String','Input Device 2',...
				'HorizontalAlignment','left',...
				'FontSize',10);
	% Create Pop-up
	POP_In2		= uicontrol(SettingTab,'Style', 'popup',...
				'String',InputDeviceName,...
				'Position', [100 -3 150 30],...
				'FontSize',10,...
				'Callback', @SelectInput);
			
	% ----------------------------
	%	Create Noise Type Menu
	% ----------------------------
	% Text
% 	TXT_Noise	= uicontrol(SettingTab,'Style','text',...
% 				'Position',[270 33 100 20],...
% 				'String','Noise Type',...
% 				'HorizontalAlignment','left',...
% 				'FontSize',10);
% 	% Pop-up
% 	POP_Noise	= uicontrol(SettingTab,'Style', 'popup',...
% 				'String',{' No Noise',' White Noise',' Kaiwa Noise',' Train Noise'},...
% 				'Position', [345 25 120 30],...
% 				'FontSize',10,...
% 				'Callback', @SelectNoise);
% 	POP_Noise.Value = 2;							% Initial : White Noise

	% ----------------------------
	%	Create Output Device 1 Menu
	% ----------------------------
	% Create Text
	TXT_Out		= uicontrol(SettingTab,'Style','text',...
				'Position',[270 33 100 20],...
				'String','Output Device',...
				'HorizontalAlignment','left',...
				'FontSize',10);
	% Create Pop-up
	POP_Out		= uicontrol(SettingTab,'Style', 'popup',...
				'String',OutputDeviceName,...
				'Value',1,...
				'Position', [365 25 150 30],...
				'FontSize',10);

	% ----------------------------
	%	Create Display Tabs
	% ----------------------------
	tabgp = uitabgroup(f,'Position',[.025 .23 .95 .56]);
	tab1 = uitab(tabgp,'Title',' Waveform ');
	tab2 = uitab(tabgp,'Title',' Spectrogram ');

	% ----------------------------
	%	Create Channel 1 Waveform
	% ----------------------------
	% Cleate Outline
	PNL_In_Wav	= uipanel(tab1,'Title','Original Sound',...
				'ForegroundColor',[.2 .7 .2],...
				'BackgroundColor',[.92 .94 .92],...
				'FontWeight','bold',...
				'Position',[0 0 0.5 1],...
				'FontSize',11,...
				'ButtonDownFcn',@PlaySound1);
	% Figure Option	
	Wave1		= axes('Parent',PNL_In_Wav);
				Wave1.Position		= [.1 .16 .85 .75];
				Wave1.Box			= 'on';
				Wave1.FontSize		= 6.5;
				Wave1.XLabel.String = 'Time [s]';
				Wave1.YLim			= [-1 1];
	% Line Object
     L1			= line('YData',ch1,...
				'XData',(1:length(ch1))./Fs,...
				'Parent',Wave1,...
				'Color',[.2 .6 .2],...
				'ButtonDownFcn',@PlaySound1);
	% Normalization Switch
	TXT_Nrm1_Wav = uicontrol(PNL_In_Wav,...
				'Style','checkbox',...
				'String',' Normalization',...
				'BackgroundColor',[.92 .94 .92],...
				'Position', [155 176 95 16],...
				'HorizontalAlignment','left',...
				'FontSize',10,...
				'Value',1,...
				'Callback',@Normalization_Wav);
				
	% ----------------------------
	%	Create Channel 2 Waveform
	% ----------------------------
	% Cleate Outline
	PNL_Out_Wav	= uipanel(tab1,'Title','Enhanced Sound',...
				'ForegroundColor',[.2 .2 .7],...
				'BackgroundColor',[.92 .92 .94],...
				'FontWeight','bold',...
				'Position',[0.5, 0, 0.5, 1],...
				'FontSize',11,...
				'ButtonDownFcn',@PlaySound2);
	% Figure Option
	Wave2		= axes('Parent',PNL_Out_Wav);
				Wave2.Position		= [.1 .16 .85 .75];
				Wave2.Box			= 'on';
				Wave2.FontSize		= 6.5;
				Wave2.XLabel.String = 'Time [s]';
				Wave2.YLim			= [-1 1];
	% Line Object
     L2			= line('YData',ch2,...
				'XData',(1:length(ch2))./Fs,...
				'Parent',Wave2,...
				'Color',[.2 .2 .6],...
				'ButtonDownFcn',@PlaySound2);
	% Normalization Switch
	TXT_Nrm2_Wav = uicontrol(PNL_Out_Wav,...
				'Style','checkbox',...
				'String',' Normalization',...
				'BackgroundColor',[.92 .92 .94],...
				'Position', [155 176 95 16],...
				'HorizontalAlignment','left',...
				'FontSize',10,...
				'Value',1,...
				'Callback',@Normalization_Wav);
	% Create Speech Enhancement Check Box
% 	TXT_Imp_Wav	= uicontrol(PNL_Out_Wav,'Style','togglebutton',...
% 				'String', 'ENH',...
% 				'ForegroundColor',[.0 .0 .0],...
% 				'BackgroundColor',[.9 .95 .95],...
% 				'Position', [33 145 55 27],...
% 				'FontSize',14,...
% 				'Enable','off',...
% 				'Callback',@Improvement);
			
	% ----------------------------
	%	Create Channel 1 Spectrogram
	% ----------------------------
	% Cleate Outline
	PNL_In_Spc	= uipanel(tab2,'Title','Original Sound',...
				'ForegroundColor',[.2 .7 .2],...
				'BackgroundColor',[.92 .94 .92],...
				'FontWeight','bold',...
				'Position',[0 0 0.5 1],...
				'FontSize',11,...
				'ButtonDownFcn',@PlaySound1);
	% Figure Option	
	Spc1		= axes('Parent',PNL_In_Spc);
				Spc1.Position		= [.1 .16 .85 .75];
	% Line Object
    I1			= image(zeros(N/2,N),...
				'ButtonDownFcn',@PlaySound1);
				I1.CDataMapping = 'scaled';
				
				% Redifinition
				Spc1.Box			= 'on';
				Spc1.FontSize		= 6.5;
				Spc1.XLabel.String	= 'Frames';
				Spc1.YLabel.String	= 'Frequency [Hz]';
				Spc1.XLim			= [1 100];
				Spc1.YTick			= [1 N/8 2*N/8 3*N/8 N/2];
				Spc1.YTickLabel		= strcat(num2str(floor(Fs/1000/N.*fliplr(Spc1.YTick)')),vertcat(repmat({'k'},[4,1]), ' ') );

	% Normalization Switch
	TXT_Nrm1_Spc = uicontrol(PNL_In_Spc,...
				'Style','checkbox',...
				'String',' Normalization',...
				'BackgroundColor',[.92 .94 .92],...
				'Position', [155 176 95 16],...
				'HorizontalAlignment','left',...
				'FontSize',10);
				TXT_Nrm1_Spc.UserData  = 1;
				% Normalization case
				TXT_Nrm1_Spc.Value		= 1;
				TXT_Nrm1_Spc.Position	= [155 176 95 16];
				TXT_Nrm1_Spc.String	= ' Normalization';
				TXT_Nrm1_Spc.Callback	= @Normalization_Spc;
				% Expansion case
% 				TXT_Nrm1_Spc.Value		= 0;
% 				TXT_Nrm1_Spc.Position = [170 176 95 16];
% 				TXT_Nrm1_Spc.String = ' Expansion';
% 				TXT_Nrm1_Spc.Callback = @Expansion_Spc;
	% ----------------------------
	%	Create Channel 2 Spectrogram
	% ----------------------------
	% Cleate Outline
	PNL_Out_Spc	= uipanel(tab2,'Title','Enhanced Sound',...
				'ForegroundColor',[.2 .2 .7],...
				'BackgroundColor',[.92 .92 .94],...
				'FontWeight','bold',...
				'Position',[0.5 0 0.5 1],...
				'FontSize',11,...
				'ButtonDownFcn',@PlaySound1);
	% Figure Option	
	Spc2		= axes('Parent',PNL_Out_Spc);
				Spc2.Position		= [.1 .16 .85 .75];
				
	% Line Object
    I2			= image(zeros(N/2,N),...
				'ButtonDownFcn',@PlaySound1);
				I2.CDataMapping = 'scaled';
				
				% Redifinition
				Spc2.Box			= 'on';
				Spc2.FontSize		= 6.5;
				Spc2.XLabel.String	= 'Frames';
				Spc2.YLabel.String	= 'Frequency [Hz]';
				Spc2.XLim			= [1 100];
				Spc2.YTick			= [1 N/8 2*N/8 3*N/8 N/2];
				Spc2.YTickLabel		= strcat(num2str(floor(Fs/1000/N.*fliplr(Spc1.YTick)')),vertcat(repmat({'k'},[4,1]), ' ') );

	% Normalization Switch
	TXT_Nrm2_Spc = uicontrol(PNL_Out_Spc,...
				'Style','checkbox',...
				'String',' Normalization',...
				'BackgroundColor',[.92 .92 .94],...
				'HorizontalAlignment','left',...
				'FontSize',10);
				TXT_Nrm2_Spc.UserData	= 1;
				% Normalization case
				TXT_Nrm2_Spc.Value		= 1;
				TXT_Nrm2_Spc.Position	= [155 176 95 16];
				TXT_Nrm2_Spc.String	= ' Normalization';
				TXT_Nrm2_Spc.Callback	= @Normalization_Spc;
				% Expansion case
% 				TXT_Nrm2_Spc.Value		= 0;
% 				TXT_Nrm2_Spc.Position = [170 176 95 16];
% 				TXT_Nrm2_Spc.String = ' Expansion';
% 				TXT_Nrm2_Spc.Callback = @Expansion_Spc;
			
	% Create Speech Enhancement Check Box
% 	TXT_Imp_Spc	= uicontrol(PNL_Out_Spc,'Style','togglebutton',...
% 				'String', 'ENH',...
% 				'ForegroundColor',[.0 .0 .0],...
% 				'BackgroundColor',[.9 .95 .95],...
% 				'Position', [33 145 55 27],...
% 				'FontSize',14,...
% 				'Enable','off',...
% 				'Callback',@Improvement);
	
	% ----------------------------
	%	Create Recording Bottum
	% ----------------------------
	% Push Bottum
	btn_pos		= [25 20 110 50];					% Position
	BTN_Record	= uicontrol('Style', 'togglebutton',...
				'String', 'Record',...
				'Position', btn_pos,...
				'FontSize',16,...
				'Interruptible','on',...			% !! Enable Interrupt !!
				'BusyAction','cancel',...
				'Callback', @Recording_OnOff);
	% State Panel
	pnl_pos		= [150, 20, 100, 57]; % Position
	PNL_State	= uipanel('Title','State:',...
				'BusyAction','cancel',...
				'BackgroundColor',[.99 .99 .99],...
				'FontSize',10);
	setpixelposition(PNL_State, pnl_pos);
	% Display - Stop or Preparnig or Recording
	txt_size	= 12;
	TXT_State	= uicontrol('Parent',PNL_State,...
				'Style','text',...	
				'Position',[0 0 100 55*0.6],...
				'String','Ready',...
				'FontWeight','bold',...
				'BackgroundColor',[.99 .99 .99],...
				'BusyAction','cancel',...
				'FontSize',txt_size);
			
	% ----------------------------
	%	Create Level Slider
	% ----------------------------
	Tab_Vol		= uipanel(f,'Position',[.5 .025 .46 .18],...
				'Title','Volume  (Not real-time)');
% 	TXT_NV1		= uicontrol(Tab_Vol,'Style','text',...	
% 				'Position',[15 37 100 18],...
% 				'String','Output Vol.',...
% 				'BusyAction','cancel',...
% 				'HorizontalAlignment','left',...
% 				'FontSize',10.5);
% 	TXT_NV2		= uicontrol(Tab_Vol,'Style','text',...	
% 				'Position',[80 37 25 18],...
% 				'String','100',...
% 				'BusyAction','cancel',...
% 				'HorizontalAlignment','left',...
% 				'FontSize',10.5);
% 	VOL_Noise	= uicontrol(Tab_Vol,'Style', 'slider',...
% 				'Min',1,'Max',100,'Value',100,...
% 				'Position', [110 40 130 18],...
% 				'BackgroundColor',[.935 .935 .935],...
% 				'Callback',@NoiseVol);
	TXT_SV1		= uicontrol(Tab_Vol,'Style','text',...	
				'Position',[10 32 100 18],...
				'String','Output Vol.',...
				'BusyAction','cancel',...
				'HorizontalAlignment','left',...
				'FontSize',10.5);
	TXT_SV2		= uicontrol(Tab_Vol,'Style','text',...	
				'Position',[85 32 25 18],...
				'String','100',...
				'BusyAction','cancel',...
				'HorizontalAlignment','left',...
				'FontSize',10.5);
				TXT_SV1.ForegroundColor		= [.6 .6 .6];
				TXT_SV2.ForegroundColor		= [.6 .6 .6];
	VOL_Speech	= uicontrol(Tab_Vol,'Style', 'slider',...
				'Min',1,'Max',100,'Value',100,...
				'Position', [115 35 132 16],...
				'BackgroundColor',[.935 .935 .935],...
				'Callback',@SpeechVol);

	% ----------------------------
	%	Create Normalization Check Box
	% ----------------------------
	TXT_Norm3	= uicontrol(Tab_Vol,'Style','checkbox',...
				'String', '  Automatic Output Volume Control',...
				'Value',1,...
				'Position', [10 9 250 16],...
				'HorizontalAlignment','left',...
				'FontSize',10,...
				'Callback',@NormalizedVol);
	
    % Make figure visble after adding all components
    f.Visible = 'on';
            
	%% Sub Functions
	
	% Select Input Device
	function SelectInput(source,callbackdata)
		if POP_In1.value <= 1 || POP_In2.value <= 1
			msgbox('  Please Select Input Deivce !!','Caution','warn','replace');
		elseif POP_In1.value == POP_In2.value
			msgbox('  Please Select Different Deivces Between Input Device 1 and Input Device 2 !!','Caution','warn','replace');
		else
			Recorder1 = audiorecorder(Fs,Bit,2,info.input(POP_In1.Value-1).ID);
			Recorder2 = audiorecorder(Fs,Bit,2,info.input(POP_In2.Value-1).ID);
		end
	end

	% Select Noise
% 	function SelectNoise(source,callbackdata)
% 		% Set Noise Data to g, fs
% 		switch POP_Noise.Value
% 			case 1									% No Noise
% 				g		= 0.*g2;					% 0 signal
% 				fs		= fs2;
% 			case 2									% White Noise
% 				g		= g2;
% 				fs		= fs2;
% 			case 3									% Pink Noise
% 				g		= g3;
% 				fs		= fs3;
% 			case 4									% Train Noise
% 				g		= g4;
% 				fs		= fs4;
% 		end
% 		if ~BTN_Record.Value						% If Not in running Recorder
% 			NoisePlayer = audioplayer(g,fs);
% 		else
% 			
% 		end
% 	end
	
	% Recording
	function Recording_OnOff(source,callbackdata)
		% Bottun On
		if POP_In1.Value <= 1 || POP_In2.Value <= 1
			msgbox('  Please Select Input Deivce !!','Caution','warn','replace');
			return
		end
		if BTN_Record.Value
			% Stop process
			%TXT_Imp_Wav.Enable = 'off';
			%TXT_Imp_Spc.Enable = 'off';
			stop(NoisePlayer)
			stop(Player1)
			stop(Player2)
			PNL_In_Wav.BackgroundColor	= [.92 .94 .92];
			PNL_Out_Wav.BackgroundColor	= [.92 .92 .94];
			% Interrupt
			POP_In1.Enable				= 'off';	% NOT ALLOW to interrupt to Device Select
			POP_In2.Enable				= 'off';	% NOT ALLOW to interrupt to Device Select
			POP_Out.Enable				= 'off';	% NOT ALLOW to interrupt to Device Select
			%POP_Noise.Enable			= 'off';	% NOT ALLOW to interrupt to Noise Select
			% == Prepare State ==
			% -- Bottun --
			BTN_Record.String			= 'Stop';
			BTN_Record.ForegroundColor	= [1 1 1];
			BTN_Record.BackgroundColor	= [0.8 0.8 0.8];
			% -- State --
			TXT_State.String			= 'Wait...';
			TXT_State.ForegroundColor	= [.3 .65 .3];
			TXT_State.FontSize			= txt_size; 
			% wait... preparing time
			Gain_N = A_Volume(0.01*VOL_Noise.Value);
			NoisePlayer = audioplayer(Gain_N.*g,fs, Bit, info.output(POP_Out.Value).ID);
			play(NoisePlayer)						% Playing
			pause(PrepareTime+0.3)
			% == Recording State ==
			if exist('BTN_Record','var') ~= 0 && BTN_Record.Value		% push stop --> stop callback 
				% -- State --
				TXT_State.String		= 'Record';
				TXT_State.ForegroundColor = [.9 0 0];
				TXT_State.FontSize		= txt_size*1.2;
				record(Recorder1)
				record(Recorder2)
			end
		% Bottun Off
		else
			POP_In1.Enable				= 'on';		% ALLOW to interrupt to Device Select
			POP_In2.Enable				= 'on';		% ALLOW to interrupt to Device Select
			POP_Out.Enable				= 'on';		% ALLOW to interrupt to Device Select
			%POP_Noise.Enable			= 'on';		% ALLOW to interrupt to Noise Select
			%TXT_Imp_Wav.Enable			= 'on';		% ALLOW Enhancement
			%TXT_Imp_Spc.Enable			= 'on';
			% == Stop State ==
			stop(NoisePlayer)
			stop(Recorder1)
			stop(Recorder2)
			SaveWave();
			% -- Bottun --
			BTN_Record.String = 'Record';
			BTN_Record.ForegroundColor	= [0 0 0];
			BTN_Record.BackgroundColor	= [0.9 0.9 0.9];
			% -- State --
			TXT_State.String = 'Ready';
			TXT_State.ForegroundColor	= [0 0 0];
			TXT_State.FontSize			= txt_size;
		end
	end
    
    function SaveWave()
		if Recorder1.TotalSamples ~= 0 && Recorder2.TotalSamples ~= 0
			% Extract Data
			data1				= getaudiodata(Recorder1);
			data2				= getaudiodata(Recorder2);
			ch1					= data1(:,1);
			ch2					= data1(:,2);
			ch3					= data2(:,1);
			ch4					= data2(:,2);
            
            % Speech Enhance
			% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			ch2_imp				= SpeechEnhancement(ch2);
			% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			
			% Save data
			audiowrite('Mic1.wav',ch1,Fs);
			audiowrite('Mic2.wav',ch2,Fs);
			audiowrite('Mic3.wav',ch3,Fs);
			audiowrite('Mic4.wav',ch4,Fs);
			
% 			if ~TXT_Imp_Wav.Value						% Processing or Not
% 				ch2		= ch2;
% 			else
% 				ch2		= ch2_imp;
% 			end
			
			% Plot
			PlotWave();
			PlotSpectra();
		end
	end

	function PlotWave()
		% -- Replot Channel 1 --
		L1.YData			= ch1;
		L1.XData			= (1:length(ch1))./Fs;
		L1.ButtonDownFcn	= @PlaySound1; 
 		Wave1.ButtonDownFcn = @PlaySound1;		% We need redefine !! (I dont know why)
 		Wave1.XLim			= [0 length(ch1)./Fs];
		if ~TXT_Nrm1_Wav.Value
			Wave1.YLim			= [-1 1];
		else
			Wave1.YLim			= 1.5 * max(abs(ch1)).*[-1 1];
		end
		% -- Replot Channel 2 --
		L2.YData			= ch2;
		L2.XData			= (1:length(ch2))./Fs;
		L2.ButtonDownFcn	= @PlaySound2; 
 		Wave2.ButtonDownFcn = @PlaySound2;		% We need redefine !! (I dont know why)
 		Wave2.XLim			= [0 length(ch2)./Fs];
		if ~TXT_Nrm2_Wav.Value
			Wave2.YLim			= [-1 1];
		else
			Wave2.YLim			= 1.5 * max(abs(ch2)) .* [-1 1];
		end
	end

	function PlotSpectra()
		% -- Replot Channel 1 --
		[s, len]			= spectra(ch1,N,Shift);
		I1.CData			= flipud(s);
		I1.ButtonDownFcn	= @PlaySound1;
		Spc1.XLim			= [1 len];
 		Spc1.ButtonDownFcn	= @PlaySound1;		% We need redefine !! (I dont know why)
		if ~TXT_Nrm1_Spc.UserData
			I1.CDataMapping = 'direct';
		else
			I1.CDataMapping = 'scaled';
		end
		% -- Replot Channel 2 --
		[s, len]			= spectra(ch2,N,Shift);
		I2.CData			= flipud(s);
		I2.ButtonDownFcn	= @PlaySound2; 
		Spc2.XLim			= [1 len];
 		Spc2.ButtonDownFcn = @PlaySound2;		% We need redefine !! (I dont know why)
		if ~TXT_Nrm2_Spc.UserData
			I2.CDataMapping	= 'direct';
		else
			I2.CDataMapping	= 'scaled';
		end
	end


	function PlaySound1(source,callbackdata)
		if BTN_Record.Value						% not allow to play during recording
			return
		end
		if strcmp(Player1.Running,'off')		% Play on
			% UI
			PNL_Out_Wav.BackgroundColor	= [.92 .92 .94];
			PNL_Out_Spc.BackgroundColor	= [.92 .92 .94];
			TXT_Nrm2_Wav.BackgroundColor= [.92 .92 .94];
			TXT_Nrm2_Spc.BackgroundColor= [.92 .92 .94];
			PNL_In_Wav.BackgroundColor	= [1 1 .65];
			PNL_In_Spc.BackgroundColor	= [1 1 .65];
			TXT_Nrm1_Wav.BackgroundColor= [1 1 .65];
			TXT_Nrm1_Spc.BackgroundColor= [1 1 .65];
			
			% Stop Channel 2
			stop(Player2)
			
			% Play Channel 1
			Gain = PlayNormalization(ch1);				% Gain
			vol = A_Volume(0.01*VOL_Speech.Value);		% Volume
			Player1		= audioplayer(vol*Gain.*ch1,Fs, Bit, info.output(POP_Out.Value).ID);			% Sound Player for Channel 1 (Dummy)
			play(Player1)								% Play
			
			pause(length(ch1)./Fs)
			if isprop(PNL_In_Wav,'BackgroundColor')
				PNL_In_Wav.BackgroundColor	= [.92 .94 .92];
				TXT_Nrm1_Wav.BackgroundColor= [.92 .94 .92];
				PNL_In_Spc.BackgroundColor	= [.92 .94 .92];
				TXT_Nrm1_Spc.BackgroundColor= [.92 .94 .92];
			end
		else									% Play off
			PNL_In_Wav.BackgroundColor	= [.92 .94 .92];
			TXT_Nrm1_Wav.BackgroundColor= [.92 .94 .92];
			PNL_In_Spc.BackgroundColor	= [.92 .94 .92];
			TXT_Nrm1_Spc.BackgroundColor= [.92 .94 .92];
			stop(Player1)
		end
	end

	function PlaySound2(source,callbackdata)
		if BTN_Record.Value 					% not allow to play during recording
			return
		end
		if strcmp(Player2.Running,'off')
			% UI
			PNL_In_Wav.BackgroundColor	= [.92 .94 .92];
			PNL_In_Spc.BackgroundColor	= [.92 .94 .92];
			TXT_Nrm1_Wav.BackgroundColor= [.92 .94 .92];
			TXT_Nrm1_Spc.BackgroundColor= [.92 .94 .92];
			PNL_Out_Wav.BackgroundColor	= [1 1 .65];
			PNL_Out_Spc.BackgroundColor	= [1 1 .65];
			TXT_Nrm2_Wav.BackgroundColor= [1 1 .65];
			TXT_Nrm2_Spc.BackgroundColor= [1 1 .65];
			
			% Stop Channel 1
			stop(Player1)
			
			% Play Channel 2
			Gain		= PlayNormalization(ch2);				% Gain
			vol			= A_Volume(0.01*VOL_Speech.Value);	% Volume
			Player2		= audioplayer(vol*Gain.*ch2,Fs, Bit, info.output(POP_Out.Value).ID);			% Sound Player for Channel 1 (Dummy)
			play(Player2)									% Play

			pause(length(ch2)./Fs)
			if isprop(PNL_Out_Wav,'BackgroundColor')
				PNL_Out_Wav.BackgroundColor	= [.92 .92 .94];
				TXT_Nrm2_Wav.BackgroundColor= [.92 .92 .94];
				PNL_Out_Spc.BackgroundColor	= [.92 .92 .94];
				TXT_Nrm2_Spc.BackgroundColor= [.92 .92 .94];
			end
		else
			stop(Player2)
			PNL_Out_Wav.BackgroundColor	= [.92 .92 .94];
			PNL_Out_Spc.BackgroundColor	= [.92 .92 .94];
			TXT_Nrm2_Wav.BackgroundColor= [.92 .92 .94];
			TXT_Nrm2_Spc.BackgroundColor= [.92 .92 .94];
		end
	end

	function Normalization_Wav(source,callbackdata)
		if Recorder1 ~= 0 && Recorder1.TotalSamples ~= 0	
			PlotWave();
		end
	end

	function Normalization_Spc(source,callbackdata)
		TXT_Nrm1_Spc.UserData = TXT_Nrm1_Spc.Value;
		TXT_Nrm2_Spc.UserData = TXT_Nrm2_Spc.Value;
		if Recorder1 ~= 0 && Recorder1.TotalSamples ~= 0	
			if ~TXT_Nrm1_Spc.UserData
				I1.CDataMapping = 'direct';
			else
				I1.CDataMapping = 'scaled';
			end
			if ~TXT_Nrm2_Spc.UserData
				I2.CDataMapping	= 'direct';
			else
				I2.CDataMapping	= 'scaled';
			end
		end
	end

% 	function Expansion_Spc(source,callbackdata)
% 		if source.Value
% 			source.ForegroundColor = [0 0 0];
% 		else
% 			source.ForegroundColor = [.5 .5 .5];
% 		end
% 		if Recorder1 ~= 0 && Recorder1.TotalSamples ~= 0	
% 			if ~TXT_Nrm1_Spc.Value
% 				Spc1.YLim			= [1 N/2];
% 				PlotSpectra()
% 			else
% 				Spc1.YLim			= [N/4 N/2];
% 				PlotSpectra()
% 			end
% 			if ~TXT_Nrm2_Spc.Value
% 				Spc2.YLim			= [1 N/2];
% 				PlotSpectra()
% 			else
% 				Spc2.YLim			= [N/4 N/2];
% 				PlotSpectra()
% 			end
% 		end
% 	end
	
	
% 	function Improvement(source,callbackdata)
% 		if Recorder1 ~= 0 && Recorder1.TotalSamples ~= 0
% 			% ON
% 			if source.Value
% 				%TXT_Imp_Wav.ForegroundColor		= [.85 .2 .2];
% 				%TXT_Imp_Wav.BackgroundColor		= [.95 .9 .9];
% 				%TXT_Imp_Wav.FontWeight			= 'bold';
% 				
% 				TXT_Imp_Spc.ForegroundColor		= [.85 .2 .2];
% 				TXT_Imp_Spc.BackgroundColor		= [.95 .9 .9];
% 				TXT_Imp_Spc.FontWeight			= 'bold';
% 
% 				%ch2								= ch2_imp;			
% 			% OFF
% 			else
% 				%TXT_Imp_Wav.ForegroundColor		= [.4 .4 .4];
% 				%TXT_Imp_Wav.BackgroundColor		= [.9 .95 .95];
% 				%TXT_Imp_Wav.FontWeight			= 'normal';
% 				
% 				TXT_Imp_Spc.ForegroundColor		= [.4 .4 .4];
% 				TXT_Imp_Spc.BackgroundColor		= [.9 .95 .95];
% 				TXT_Imp_Spc.FontWeight			= 'normal';
% 				
% 				%ch2								= ch2;
% 			end
% 			val = source.Value;
% 			%TXT_Imp_Wav.Value = val;
% 			TXT_Imp_Spc.Value = val;
% 				
% 			PlotWave();
% 			PlotSpectra();
% 		end
% 	end

	function Gain = PlayNormalization(s)
		if ~TXT_Norm3.Value
			Gain	= 1;
		else
			Gain	= 0.7/max(abs(s));
		end
	end

% 	function NoiseVol(source,callbackdata)
% 		TXT_NV2.String = num2str(round(source.Value));
% 	end

	function SpeechVol(source,callbackdata)
		TXT_SV2.String		= num2str(round(source.Value));
		TXT_Norm3.Value		= 0;
		
		TXT_SV1.ForegroundColor		= [0 0 0];
		TXT_SV2.ForegroundColor		= [0 0 0];
	end

	function NormalizedVol(source,callbackdata)
		if TXT_Norm3.Value == 1
			TXT_SV1.ForegroundColor		= [.6 .6 .6];
			TXT_SV2.ForegroundColor		= [.6 .6 .6];
		else
			TXT_SV1.ForegroundColor		= [0 0 0];
			TXT_SV2.ForegroundColor		= [0 0 0];
		end
	end

	function G = A_Volume(val)
		a = 0.8;				% A-curve (like an exponent)
		G = (1./(1 - a.*val) - 1) .* (1-a)/a;
	end

	function CloseALL(source,callbackdata)
		stop(NoisePlayer)
		stop(Player1)
		stop(Player2)
		delete(f)
	end

 end

 
 
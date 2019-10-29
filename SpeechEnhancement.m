function out = SpeechEnhancement(in)
%	!! �ȉ��ɂɉ���������@���L�q !!
%

temp	= in;									% Input

% Speech Enhancement
temp	= AdaptiveNotch(temp);					% Adaptive Notch Filter (Line Noise Reduction)
temp	= JointMAP20161006(temp, 512, 128);		% Joint MAP (Noise Reduction)
temp	= filter([1 -0.95],1,temp);				% HPF (Enhance)
%temp	= DNNf(temp);							% DNN (Enhance)
%temp	= filter(0.9.*[1 -1],[1 -0.9],temp);	% LPF (cut around Nyquist Frequency (?) )

out		= temp;									% Output
audiowrite('BC_imp.wav',out,16000);

end

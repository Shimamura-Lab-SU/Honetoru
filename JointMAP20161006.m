function out = JointMAP20161006( in, FRAME, FSHIFT )
% JointMAP による雑音除去
%   詳細説明をここに記述

%%
len			= length(in);
G   		= zeros(FRAME,1);
out			= zeros(len,1);
gamma		= ones(FRAME,1);
lambda		= zeros(FRAME,1);
R			= 0;
gamma_b		= gamma;

persistent W nyu rz thz alpha mu
% initialize persistent variables
if ~numel(W)
	
	% パラメータ
	rz    = 30;
	thz   = rz*0.1;
	alpha = 0.95;
	mu    = 2.7;
	nyu	  = ones(FRAME,1)*1;
	
	n	= 0:1:FRAME-1;
	W	= (0.54-0.46.*cos(2*pi*n'./(FRAME-1))).*(FSHIFT/FRAME*4);
	
end

%% 処理
x_n = zeros(FRAME,4);
for loop=1:4
	x_n(:,loop)	= W .* in((loop-1)*FSHIFT+1:(loop-1)*FSHIFT+FRAME,1);	% 入力
end
pow		= abs(fft(x_n,FRAME,1)).^2;
lambda 	= mean(pow,2);
var		= mean( (pow - repmat(lambda,1,4)).^2, 2 );

a		= log10(mean(var./lambda));
alpha	= max( 0.9, min(0.96 + 0.01*a,0.999) );

% a		= log(mean(var./lambda));
% alpha	= max( 0.9, min(0.96 + 0.01*a,0.995) );

%disp()


for loop=2:floor((len-FRAME)/FSHIFT)
	x		= W .* in((loop-1)*FSHIFT+1:(loop-1)*FSHIFT+FRAME,1);	% 入力
	X		= fft(x,FRAME);
	pow		= abs(X).^2;
	
	% Estimation of lambda(n) of noise 
	gamma_t = pow./lambda;
	h		= 10.*log10(gamma_t+0.00001);		% ゼロ割防止
	
	% - Calculation of Gain Function H
	% h(k)<0   : H=1
	% h(k)>thz : H=0
	% otherwise: H = -1/rz .* h + 1;
	H = (h<0).*1 + (h>0 & h<=thz) .* (1 - 1/rz.* h);
	
	% - Calculation of lambda 
	% H<=0	: lambda = lambda
	% H>0	: lambda = alpha*lambda + (1-alpha).*H.*pow 
	lambda = ((H<=0) +(H>0).*alpha).*lambda + (1-alpha).*H.*pow;
	
	% PDF形状の決定
	% nyuの決定
	%R = beta*R + (1-beta)*sum(pow)/sum(lambda);
	%nyu = 0.1*(1+10*log10(R+0.000001)).*F;
	%nyu(nyu<0.5) = 0.5;
	%nyu(nyu>1.5) = 1.5;
	
	% Estimation of gamma
	gamma = pow./lambda;

	% Estimation of gzai
	P = (1-alpha).*(gamma -1);
	gzai = alpha.*gamma_b.* (G.^2) + P.*(P>0);
	gamma_b = gamma;

	% Estimation of G
	K = gamma.*gzai;
	u = 0.5 - mu./(4*sqrt(K+0.00001));
	G = u + sqrt(u.^2 + nyu./(2.*gamma+0.00001));
	%G = (G>0 & G<1).*G + (G>=1);
	G(G<0.01) = 0.01;
	G(G>1) = 1;
	% 低域除去１
	G(1) = 0; G(2) = 0; G(FRAME/2+1)=0;
	G = Symmetry(G);
	
	Y = G.*X;

	% IFFT
	out_f = real(ifft(Y));

	out((loop-1)*FSHIFT+1:(loop-1)*FSHIFT+FRAME,1) = out((loop-1)*FSHIFT+1:(loop-1)*FSHIFT+FRAME,1) + out_f;

end

end


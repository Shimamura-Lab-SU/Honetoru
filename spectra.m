function [s, l] = spectra(x,N,OL)

	persistent ind W
	% initialize persistent variables
	if ~numel(ind)
		w	= 1:N;
		L   = 3000;
		
		ind = zeros(N,3000);
		W	= zeros(N,3000);
		han = hann(N)';
		for i=1:L
			ind(:,i)	= w + OL*(i-1);
			W(:,i)		= han;
		end
	end

	l = floor((length(x)-N)./OL);
	if l>0
		S = abs(fft( W(:,1:l).*x(ind(:,1:l)) )).^2;
		s = log10(S(1:N/2,:));
		s = s - min(0,mean(mean(s)));
	else
		s = 0;
	end

end
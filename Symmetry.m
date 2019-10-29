function out_x = Symmetry( in_x )
%UNTITLED この関数の概要をここに記述
%   詳細説明をここに記述
	
	num = floor(length(in_x)/2);
	n = num:-1:2;
	out_x = [in_x(1:num+1); in_x(n)];

end


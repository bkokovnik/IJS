	epr = evalin('base','epr');
	indices = get(handles.lbFiles, 'Value');
	
	for i = 1:numel(indices)
		idx = indices(i);
	
		H = epr.data{idx}.H; % in mT
		Y = epr.data{idx}.Y;
		H = reshape(H, [], 1);
	
		% Select the first few and last few points
		numPoints = 10; % Number of points to select
		firstPoints = H(1:numPoints);
		lastPoints = H(end-numPoints+1:end);
		selectedPoints = [firstPoints; lastPoints];
		selectedData = [Y(1:numPoints); Y(end-numPoints+1:end)];
	
		% Fit a line to the selected points
		fitResult = polyfit(selectedPoints, selectedData, 1);
	
		% Subtract the line from the data
		baseline = polyval(fitResult, H);
		epr.data{idx}.Y = Y - baseline;
	end
	
	assignin('base', 'epr', epr);
	eprplot(handles);


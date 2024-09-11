function stop = myCustomOptimPlotFval(x, optimValues, state)
    % Custom plot function based on optimplotfval, using diamond markers and magenta color
    persistent plotObj
    
    stop = false;
    
    switch state
        case 'init'
            % Initialization: Create a new plot
            plotObj = plot(optimValues.iteration, optimValues.fval, 'dm'); % Diamond marker, magenta color
            xlabel('Iteration');
            ylabel('Function Value');
            title('Optimization Progress');
            set(plotObj, 'Tag', 'optimplotfval');
        case 'iter'
            % Iteration: Update the plot with new data
            newX = get(plotObj, 'XData');
            newY = get(plotObj, 'YData');
            set(plotObj, 'XData', [newX optimValues.iteration], 'YData', [newY optimValues.fval]);
        case 'done'
            % Finalization: No changes needed
    end
    
    drawnow;
end


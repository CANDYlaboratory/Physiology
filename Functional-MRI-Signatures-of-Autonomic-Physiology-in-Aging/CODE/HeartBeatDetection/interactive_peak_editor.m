function interactive_peak_editor(ppg, peaks, input_file_name, output_dir)
% INTERACTIVE_PEAK_EDITOR visually inspects and edits detected peaks in PPG data.
%
% This function provides a graphical user interface for the manual inspection and
% editing of peaks detected in photoplethysmogram (PPG) data. Users can add or 
% remove peaks by interactively clicking and dragging on the plot.
%
% Inputs:
%   ppg - Vector of PPG data points.
%   peaks - Vector containing the indices of the initially detected peaks within the PPG data.
%   input_file_name - String specifying the name of the input file (expected to have a '.txt' extension).
%   output_dir - String specifying the directory where the outputs will be saved.
%
% Outputs:
%   A figure window displaying the PPG data and the detected peaks.
%   Upon closing the figure window:
%     - Saves the updated peaks locations to a MAT-file ('*_peaks_loc.mat') in the specified output directory.
%     - Saves the final state of the figure to a FIG-file ('*_peaks_loc.fig') in the specified output directory.
%
% Usage:
%   interactive_peak_editor(ppg_data, detected_peaks, 'sample_data.txt', 'output_directory/')
%
% Note:
%   Left click and drag to create a selection box to add peaks; drag right to add peaks,
%   and drag left to remove peaks within the selected area. Use arrow keys for navigating
%   the plot (left/right to move, up/down to zoom).



% Plot the PPG trace and peaks
figure;

h_ppg = plot(ppg, '-b');
hold on;
h_peaks = plot(peaks, ppg(peaks), 'or', 'MarkerSize', 10, 'LineWidth', 2);
title('Drag right to add peaks or drag left to remove peaks');

% Set the ButtonDownFcn, ButtonUpFcn, WindowButtonMotionFcn, and CloseRequestFcn
set(gca, 'ButtonDownFcn', {@button_down_callback, ppg});
set(gcf, 'WindowButtonUpFcn', @button_up_callback);
set(gcf, 'WindowButtonMotionFcn', @button_motion_callback);
set(gcf, 'CloseRequestFcn', @close_request_callback);
set(gcf, 'KeyPressFcn', @key_press_callback);

startPos = [];
h_rect = [];
dragDirection = [];

    function button_down_callback(~, ~, ppg)
        curr_pt = get(gca, 'CurrentPoint');
        startPos = round(curr_pt(1, 1));
    end

    function button_motion_callback(~, ~)
        if ~isempty(startPos)
            curr_pt = get(gca, 'CurrentPoint');
            endPos = round(curr_pt(1, 1));
            
            width = endPos - startPos;
            
            if width > 0
                dragDirection = 'right';
                if isempty(h_rect)
                    h_rect = rectangle('Position', [startPos 0 width max(ppg)], ...
                    'EdgeColor', 'r', 'FaceColor', [1 0 0 0.3]);
                else
                    set(h_rect, 'Position', [startPos 0 width max(ppg)], ...
                    'EdgeColor', 'r', 'FaceColor', [1 0 0 0.3]);
                end
            else
                dragDirection = 'left';
                if isempty(h_rect)
                    h_rect = rectangle('Position', [endPos 0 abs(width) max(ppg)], ...
                    'EdgeColor', 'b', 'FaceColor', [0 0 1 0.3]);
                else
                    set(h_rect, 'Position', [endPos 0 abs(width) max(ppg)], ...
                    'EdgeColor', 'b', 'FaceColor', [0 0 1 0.3]);
                end
            end
        end
    end


    function button_up_callback(~, ~)
    curr_pt = get(gca, 'CurrentPoint');
    endPos = round(curr_pt(1, 1));

    left = min(startPos, endPos);
    right = max(startPos, endPos);

    if strcmp(dragDirection, 'right')
        newPeaks = find_peaks_within(ppg, left, right);
        disp(size(newPeaks))
        disp(size(peaks))
        peaks = sort([peaks; newPeaks]);
    else
        % Remove peaks that are within the selected range
        indices_to_remove = (peaks >= left & peaks <= right);
        peaks(indices_to_remove) = [];
    end

    % Update the plot
    refresh_plot(ppg);

    % Save the updated peaks to a .mat file
    save([output_dir, '/', extractBefore(input_file_name, '.txt'), '_peaks_loc.mat'], 'peaks');

    delete(h_rect);
    startPos = [];
    h_rect = [];
    dragDirection = [];
end


    function refresh_plot(ppg)
        delete(findobj(gca, 'Color', 'r'));
        plot(peaks, ppg(peaks), 'or', 'MarkerSize', 10, 'LineWidth', 2);
    end

    function newPeaks = find_peaks_within(signal, left, right)
        [~, idx] = max(signal(left:right));
        newPeaks = left + idx - 1;
    end

    
    
    function close_request_callback(~, ~)
        refresh_plot(ppg);  % though the figure should already be updated
        % Save the current figure
        saveas(gcf, [output_dir, '/', extractBefore(input_file_name, '.txt'), '_peaks_loc.fig']);
         % Clear the callbacks
        set(gca, 'ButtonDownFcn', []);
        set(gcf, 'WindowButtonUpFcn', []);
        set(gcf, 'WindowButtonMotionFcn', []);
        set(gcf, 'CloseRequestFcn', []);
        set(gcf, 'KeyPressFcn', []);
        % Delete the figure
        delete(gcf);
    end










    function key_press_callback(~, event)
    % Handle key presses (left, right, up, and down arrow keys)
    switch event.Key
        case 'leftarrow'
            % Shift the viewing window to the left
            current_xlim = get(gca, 'XLim');
            new_xlim = current_xlim -400;
            set(gca, 'XLim', new_xlim);
        case 'rightarrow'
            % Shift the viewing window to the right
            current_xlim = get(gca, 'XLim');
            new_xlim = current_xlim + 400;
            set(gca, 'XLim', new_xlim);
        case 'uparrow'
            % Zoom in by halving the x-axis limits
            current_xlim = get(gca, 'XLim');
            new_xlim = current_xlim * 0.5;
            set(gca, 'XLim', new_xlim);
        case 'downarrow'
            % Zoom out by doubling the x-axis limits
            current_xlim = get(gca, 'XLim');
            new_xlim = current_xlim * 2;
            set(gca, 'XLim', new_xlim);
    end
end


end
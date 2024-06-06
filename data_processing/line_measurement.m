% Evaluation script for comparing the positioning data between Loco and
% Optitrack for flying a line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import Datasets
clear all;
clf;
close all;

% Position Data read in
% Dataset 02.05.2024, make sure the file path is correct
file_path_xyz_optitrack_1 = 'line_measurement_8a_020524_op.csv';
file_path_xyz_loco_1 = 'line_measurement_8a_020524_lo.csv';


%Extract Data of 1m flight
data_xyz_l_1 = readmatrix(file_path_xyz_loco_1)';   %Loco Positioning Data

x_l_1 = data_xyz_l_1(1,:);
y_l_1 = data_xyz_l_1(2,:);
z_l_1 = data_xyz_l_1(3,:);

data_xyz_o_1 = readmatrix(file_path_xyz_optitrack_1);   %Optitrack Positioning Data
x_o_1= data_xyz_o_1(:,5)';
y_o_1 = data_xyz_o_1(:,3)';
z_o_1 = data_xyz_o_1(:,4)';



offset = 1880; % read from graph

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x_o_1_sync = x_o_1(offset: offset + length(x_l_1)-1);
y_o_1_sync = y_o_1(offset: offset + length(y_l_1)-1);
z_o_1_sync = z_o_1(offset: offset + length(z_l_1)-1);
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Plotting the Tracks
T = 1/100;
t = T:T:T*length(x_o_1_sync);
figure();
plotting(t,x_o_1_sync,x_l_1,"x [m]", "Comparison height 1m X")
figure();
plotting(t,y_o_1_sync,y_l_1,"y [m]", "Comparison height 1m Y")
figure();
plotting(t,z_o_1_sync,z_l_1,"z [m]", "Comparison height 1m Z")


% Error
% measured value (loco) - real value (optitrack)
error_x = x_l_1 - x_o_1_sync;
error_y = y_l_1 - y_o_1_sync;
error_z = z_l_1 - z_o_1_sync;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% next Steps --> Calculate STDV, Mean, RMS, Maximum Error

[mean_x, rms_x, max_x, stdv_x] = statisticalMeasures(error_x);
[mean_y, rms_y, max_y, stdv_y] = statisticalMeasures(error_y);
[mean_z, rms_z, max_z, stdv_z] = statisticalMeasures(error_z);


%Display Error
disp('Error in X');
disp(['Mean value: ', num2str(mean_x)]); 
disp(['RMS value: ', num2str(rms_x)]);  
disp(['Max value: ', num2str(max_x)]); 
disp(['Standard Deviation value: ', num2str(stdv_x)]);

disp('Error in Y');
disp(['Mean value: ', num2str(mean_y)]); 
disp(['RMS value: ', num2str(rms_y)]);  
disp(['Max value: ', num2str(max_y)]); 
disp(['Standard Deviation value: ', num2str(stdv_y)]);

disp('Error in Z');
disp(['Mean value: ', num2str(mean_z)]); 
disp(['RMS value: ', num2str(rms_z)]);  
disp(['Max value: ', num2str(max_z)]); 
disp(['Standard Deviation value: ', num2str(stdv_z)]);


% Optimization with adjusting a offset
disp("Optimization for X");

[offset_x_optimized] = optimize(error_x);
disp(['Offset: ', num2str(offset_x_optimized)]);
[mean_x, rms_x, max_x, stdv_x] = statisticalMeasures(error_x+offset_x_optimized);
disp(['Mean value: ', num2str(mean_x)]); 
disp(['RMS value: ', num2str(rms_x)]);  
disp(['Max value: ', num2str(max_x)]); 
disp(['Standard Deviation value: ', num2str(stdv_x)]);

disp("Optimization for Y");

[offset_y_optimized] = optimize(error_y);
disp("Offset: ", num2str(offset_y_optimized));
[mean_y, rms_y, max_y, stdv_y] = statisticalMeasures(error_y+offset_y_optimized);
disp(['Mean value: ', num2str(mean_y)]); 
disp(['RMS value: ', num2str(rms_y)]);  
disp(['Max value: ', num2str(max_y)]); 
disp(['Standard Deviation value: ', num2str(stdv_y)]);

disp("Optimization for Z");

[offset_z_optimized] = optimize(error_z);
disp("Offset: ", num2str(offset_z_optimized));
[mean_z, rms_z, max_z, stdv_z] = statisticalMeasures(error_z+offset_z_optimized);
disp(['Mean value: ', num2str(mean_z)]); 
disp(['RMS value: ', num2str(rms_z)]);  
disp(['Max value: ', num2str(max_z)]); 
disp(['Standard Deviation value: ', num2str(stdv_z)]);

x_l = x_l_1 + offset_x_optimized;
y_l = y_l_1 + offset_y_optimized;
z_l = z_l_1 + offset_z_optimized;
x_o = x_o_1_sync;
y_o = y_o_1_sync;
z_o = z_o_1_sync;

figure(1);
subplot(3,1,1);
plotting(t,x_o,x_l,"x[m] optimized", "Comparison at height 1m, x-axis")
subplot(3,1,2);
plotting(t,y_o,y_l,"y[m] optimized", "Comparison at height 1m, y-axis")
subplot(3,1,3);
plotting(t,z_o,z_l,"z[m] optimized", "Comparison at height 1m, z-axis")




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% error calculation for each subareas over all heights with offset
% used flying environment [3m x 2.5m x3m] --> divided into 6x5 [0.5m x 0.5 m]


heatMapSet_x = cell(1,30);
heatMapSet_y = cell(1,30);
rms_x=zeros(6,5);
rms_y=zeros(6,5);

cB_x = [-1.5, -1, -0.5, 0, 0.5, 1, 1.5];
cB_y = [-1.25, -0.75, -0.25, 0.25, 0.75, 1.25];
 
%Generate and store 30 vectors for x
k=1;
for i = 1:6
    for j = 1:5
    matchingIndices = find(x_l >=cB_x(i)  & x_l < cB_x(i+1) & y_l >= cB_y(j) & y_l < cB_y(j+1));
    extractedValues_x = x_l(matchingIndices) - x_o(matchingIndices);
    extractedValues_y = y_l(matchingIndices) - y_o(matchingIndices);
    heatMapSet_x{k} = extractedValues_x;
    heatMapSet_y{k} = extractedValues_y;
    rms_x(i,j) = sqrt(mean(extractedValues_x.^2));
    rms_y(i,j) = sqrt(mean(extractedValues_y.^2));
    k = k+1;
    end
end
rms_x = rot90(rms_x, 1);
rms_y = rot90(rms_y, 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plotting function
function plotting(t, optitrack, loco, y_label,titel)
    %figure;
    plot(t, optitrack,'LineWidth', 2.5, 'LineStyle','-','Color','green')
    hold on
    plot(t, loco, 'LineWidth', 2.5,'LineStyle',':','Color','blue')
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    xlabel('t [s]','FontSize',12,'FontWeight','bold') 
    ylabel(y_label,'FontSize',12,'FontWeight','bold') 
    title(titel)
    legend({'Optitrack','Loco'},'Location','best')
    box off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate statistical averages
% next Steps --> Calculate STDV, Mean, RMS, Maximum Error
function [Mean, rms, Max, stdv] = statisticalMeasures(x)
Mean = mean(abs(x));
rms = sqrt(mean(x.^2));  % Calculate RMS 
stdv = std(x);
if (max(x) < abs(min(x)))
    Max = min(x);
else 
    Max = max(x);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate optimal offset with respect to optimize some statistical average

function offset_optimized = optimize(error)
RMS_min = 100;
offset_optimized = 0;
for offset = -400 : 400
    error_offset = error + offset/1000;
    [mean, RMS, max, std] = statisticalMeasures(error_offset);
    if (RMS < RMS_min)
        RMS_min = RMS;
        offset_optimized = offset/1000;
    end

end

end





        






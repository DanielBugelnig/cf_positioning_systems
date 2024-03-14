% Evaluation script for comparing the positioning data between Loco and
% Optitrack for autonomous flight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import Datasets
clear all;
clf;

% Position Data read in
file_path_xyz_loco_075 = "C:\Users\danie\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take_09012024_square\square_h_075\take_square_h075_lo.csv";
file_path_xyz_optitrack_075 = "C:\Users\danie\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take_09012024_square\square_h_075\take_square_h075_op.csv";
file_path_xyz_loco_1 = "C:\Users\danie\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take_09012024_square\square_h_1\take_square_h1_lo.csv";
file_path_xyz_optitrack_1 = "C:\Users\danie\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take_09012024_square\square_h_1\take_square_h1_op.csv";
file_path_xyz_loco_15 = "C:\Users\danie\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take_09012024_square\square_h_15\take_square_h15_lo.csv";
file_path_xyz_optitrack_15 = "C:\Users\danie\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take_09012024_square\square_h_15\take_square_h15_op.csv";


%Extract Data of 0.75m flight
data_xyz_l_075 = readmatrix(file_path_xyz_loco_075)';   %Loco Positioning Data

x_l_075 = data_xyz_l_075(1,:);
y_l_075 = data_xyz_l_075(2,:);
z_l_075 = data_xyz_l_075(3,:);

data_xyz_o_075 = readmatrix(file_path_xyz_optitrack_075);   %Optitrack Positioning Data
x_o_075 = data_xyz_o_075(:,5)';
y_o_075 = data_xyz_o_075(:,3)';
z_o_075 = data_xyz_o_075(:,4)';


%Extract Data of 1m flight
data_xyz_l_1 = readmatrix(file_path_xyz_loco_1)';   %Loco Positioning Data

x_l_1 = data_xyz_l_1(1,:);
y_l_1 = data_xyz_l_1(2,:);
z_l_1 = data_xyz_l_1(3,:);

data_xyz_o_1 = readmatrix(file_path_xyz_optitrack_1);   %Optitrack Positioning Data
x_o_1 = data_xyz_o_1(:,5)';
y_o_1 = data_xyz_o_1(:,3)';
z_o_1 = data_xyz_o_1(:,4)';


%Extract Data of 1.5m flight
data_xyz_l_15 = readmatrix(file_path_xyz_loco_15)';   %Loco Positioning Data

x_l_15 = data_xyz_l_15(1,:);
y_l_15 = data_xyz_l_15(2,:);
z_l_15 = data_xyz_l_15(3,:);

data_xyz_o_15 = readmatrix(file_path_xyz_optitrack_15);   %Optitrack Positioning Data
x_o_15 = data_xyz_o_15(:,5)';
y_o_15 = data_xyz_o_15(:,3)';
z_o_15 = data_xyz_o_15(:,4)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Synchronize optitrack dataset with loco-dataset
x_o_075_sync = synchronize(x_l_075, x_o_075);
y_o_075_sync = synchronize(y_l_075, y_o_075);
z_o_075_sync = synchronize(z_l_075, z_o_075);
 
x_o_1_sync = synchronize(x_l_1, x_o_1);
y_o_1_sync = synchronize(y_l_1, y_o_1);
z_o_1_sync = synchronize(z_l_1, z_o_1);

x_o_15_sync = synchronize(x_l_15, x_o_15);
y_o_15_sync = synchronize(y_l_15, y_o_15);
z_o_15_sync = synchronize(z_l_15, z_o_15);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Combine synchronized tracks together
x_o = [x_o_075_sync, x_o_1_sync, x_o_15_sync];
x_l = [x_l_075, x_l_1,x_l_15];

y_o = [y_o_075_sync, y_o_1_sync, y_o_15_sync];
y_l = [y_l_075, y_l_1,y_l_15];

z_o = [z_o_075_sync, z_o_1_sync, z_o_15_sync];
z_l = [z_l_075, z_l_1,z_l_15];


% Plotting the Tracks
T = 1/100;
t = T:T:T*length(x_o);

%plotting(t,x_o,x_l,"X")
%plotting(t,y_o,y_l,"Y")
%plotting(t,z_o,z_l,"Z")

%Error
% measured value (loco) - real value (optitrack)
error_x = x_l - x_o;
error_y = y_l - y_o;
error_z = z_l - z_o;


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

x_l = x_l + offset_x_optimized;
y_l = y_l + offset_y_optimized;
z_l = z_l + offset_z_optimized;

%plotting(t,x_o,x_l,"X")
%plotting(t,y_o,y_l,"Y")
%plotting(t,z_o,z_l,"Z")


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% synchronize function, to synchronize the optitrack data with loco data
function [optitrack_synchronized, min_error, min_offset] = synchronize(loco, optitrack)
N = length(loco);
min_error=100000;
    for offset_t = 1 : length(optitrack) - N 
        error = 0;
        for n = 1 : N 
            error = error + abs((loco(n) - optitrack(n+offset_t)));
        end
        if abs(error) < abs(min_error)
            min_error = error;
            min_offset = offset_t;
        end
    end
    optitrack_synchronized = optitrack(1+min_offset : min_offset + N);     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plotting function
function plotting(t, optitrack, loco, y_label)
    figure;
    plot(t, optitrack,'LineWidth', 2.5, 'LineStyle','-','Color','green')
    hold on
    plot(t, loco, 'LineWidth', 2.5,'LineStyle',':','Color','blue')
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    xlabel('t [s]','FontSize',12,'FontWeight','bold') 
    ylabel(y_label,'FontSize',12,'FontWeight','bold') 
    title('Positioning Data Comparison')
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
for offset = -400 : 400
    error_offset = error + offset/1000;
    [mean, RMS, max, std] = statisticalMeasures(error_offset);
    if (RMS < RMS_min)
        RMS_min = RMS;
        offset_optimized = offset/1000;
    end

end

end




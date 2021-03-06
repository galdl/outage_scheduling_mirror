% close all;
KNN = params.KNN;
% KNN = 2;
%% plot KNN stats and decide on label using NN

if(KNN>1)
    std_max_vec = [0.05,0.1,0.15,0.35,0.45,1];
    xHandles=zeros(length(std_max_vec),1);
    figure(1);
    for i_std_max = 1:6
        max_std_thresh = std_max_vec(i_std_max);
        KNN_samples = final_db_test(:,4:4+KNN-1);
        NN_std_full = std(KNN_samples,0,2);
        %retain only samples with std below max_std_thresh. Used both for removing nans, and better understaing the plot
        retain_idx = (NN_std_full<max_std_thresh);
        KNN_samples = KNN_samples(retain_idx,:);
        NN_std = NN_std_full(retain_idx);
        NN_mean = mean(KNN_samples,2);
        
        [v,errb_idx] = sort(NN_mean);
        %     last_non_nan = find((isnan(v)),1)-1;
        xHandles(i_std_max)=subplot(2,3,i_std_max);
        errorbar(NN_mean(errb_idx),NN_std(errb_idx));
        title(['max std: ',num2str(std_max_vec(i_std_max))]);
    end
    linkaxes(xHandles,'xy');
    figure(2);
    hist(NN_std,50);
    title('Histogram of std of NN');
end
%% draw histograms
std_max_thresh = 1;
idx_low_std = (NN_std_full<max_std_thresh);
xHandles2 = zeros(1,4);
figure(3);

xHandles2(1) = subplot(2,2,1);
reli_diff = final_db_test(idx_low_std,1);
hist(reli_diff,50);

xHandles2(2) =subplot(2,2,2);
reli_diff_rand = final_db_test(idx_low_std,4+params.KNN);
hist(reli_diff_rand,50);

xHandles2(3) =subplot(2,2,3);
N1_diff = final_db_test(idx_low_std,2);
hist(N1_diff,50);

xHandles2(4) =subplot(2,2,4);
N1_diff_rand = final_db_test(idx_low_std,6);
hist(N1_diff_rand,50);

title('Reliability and N1 matrix: NN vs random');


linkaxes(xHandles2,'xy');

% figure(2);
% boxplot(final_db_test(idx_low_std,[1,5]));
% title('Reliability: NN vs random');

%% plot reliability scatter of exact vs. NN
Z=0.000;
S=3;

max_std_thresh = 1;
KNN_samples = final_db_test(:,4:4+KNN-1);
NN_std_full = std(KNN_samples,0,2);
%retain only samples with std below max_std_thresh. Used both for removing nans, and better understaing the plot
retain_idx = (NN_std_full<max_std_thresh);
KNN_samples_full = final_db_test(retain_idx,:);

reliability_orig = KNN_samples_full(:,3);
% reliability_NN = mean(KNN_samples_full(:,4:4+KNN-1),2);
reliability_NN = KNN_samples_full(:,4);

% reliability_orig = reliability_orig(~isnan(reliability_orig));
% reliability_NN = reliability_NN(~isnan(reliability_NN));

figure(4);
scatter(reliability_orig+Z*randn(size(reliability_orig)),reliability_NN+Z*randn(size(reliability_orig)),S);
[r,p]=corr(reliability_orig,reliability_NN)

reliability_orig_rand = KNN_samples_full(:,6+params.KNN);
reliability_NN_rand = KNN_samples_full(:,7+params.KNN);

% reliability_orig_rand = reliability_orig_rand(~isnan(reliability_orig_rand));
% reliability_NN_rand = reliability_NN_rand(~isnan(reliability_NN_rand));
[r,p]=corr(reliability_orig_rand,reliability_NN_rand)

%% identify bad samples
figure(5);
reli_dist = sqrt((reliability_orig-reliability_NN).^2);
        hist(reli_dist,50);
bad_idx = (reli_dist>0.2);
scatter(reliability_orig+Z*randn(size(reliability_orig)),reliability_NN+Z*randn(size(reliability_orig)),S,bad_idx);

%% filter according to decreasing std of NN and plot correlation
figure(6);
std_max_vec = fliplr([0.001,0.005,0.01,0.03,0.05,0.1,0.15,0.35,0.45,1]);
N_std = length(std_max_vec);
corr_vec = zeros(N_std,1);
samples_left = zeros(N_std,1);
xHandles3 = zeros(1,N_std);
for j=1:N_std
    retain_idx = (NN_std_full<std_max_vec(j));
    samples_left(j) = length(find(retain_idx))/length(~isnan(final_db_test(:,1)));
    reliability_orig = final_db_test(retain_idx,3);
    reliability_NN = final_db_test(retain_idx,4);
    
    xHandles3(j) = subplot(2,N_std/2,j);
    reli_dist = sqrt((reliability_orig-reliability_NN).^2);
    %     hist(reli_dist,50);
    scatter(reliability_orig+Z*randn(size(reliability_orig)),reliability_NN+Z*randn(size(reliability_orig)),S);
    title(['max std: ',num2str(std_max_vec(j))]);
    
    [r,p]=corr(reliability_orig,reliability_NN);
    corr_vec(j)=r;
end
figure(7);
subplot(211);
plot(corr_vec);
title('correlation as a function of max NN std filter');
subplot(212);
plot(samples_left);
title('remaining samples as a function of max NN std filter');
% linkaxes(xHandles3,'xy');





%%
figure(8);
scatter(reliability_orig_rand+Z*randn(size(reliability_orig_rand)),reliability_NN_rand+Z*randn(size(reliability_NN_rand)),S);
%% plot cost scatter of exact vs. NN
Z=0.000;
S=3;

max_std_thresh = 1;
KNN_samples = final_db_test(:,4:4+KNN-1);
NN_std_full = std(KNN_samples,0,2);
%retain only samples with std below max_std_thresh. Used both for removing nans, and better understaing the plot
retain_idx = (NN_std_full<max_std_thresh);

KNN_samples_full = final_db_test(retain_idx,:);
retain_idx_loc = find(retain_idx);

cost_orig = zeros(length(retain_idx_loc),1);
cost_nn = zeros(length(retain_idx_loc),1);
cost_nn_rand = zeros(length(retain_idx_loc),1);
for i_sample = 1:length(retain_idx_loc)
    uc_sample_orig = uc_samples{retain_idx_loc(i_sample),1};
    uc_sample_nn = uc_samples{retain_idx_loc(i_sample),2}{1};
    uc_sample_nn_rand = uc_samples{retain_idx_loc(i_sample),3};
    cost_orig(i_sample) = uc_sample_orig.objective;
    cost_nn(i_sample) = uc_sample_nn.objective;
    cost_nn_rand(i_sample) = uc_sample_nn_rand.objective;
end


figure(9);
scatter(cost_orig+Z*randn(size(cost_orig)),cost_nn+Z*randn(size(cost_nn)),S);
[r,p]=corr(cost_orig,cost_nn)

title('cost scatter of exact vs. NN');


figure(10);
scatter(cost_orig+Z*randn(size(cost_orig)),cost_nn_rand+Z*randn(size(cost_nn_rand)),S);
[r,p]=corr(cost_orig,cost_nn_rand)

title('cost scatter of exact vs. rand NN');

%% draw dependence in reliability
% reliability_orig = final_db_test(idx_low_std,4);
% [reliability_orig_sorted,idx] = sort(reliability_orig);
% reliability_diff = final_db_test(idx_low_std,1);
% reliability_diff_rand = final_db_test(idx_low_std,5);
% 
% figure(31);
% clf;
% N_filt = 45;
% plot(reliability_orig_sorted,medfilt1(reliability_diff(idx),N_filt));
% hold on;
% plot(reliability_orig_sorted,medfilt1(reliability_diff_rand(idx),N_filt));
% 
% 
% figure(41);
% clf;
% b = 1/N_filt*ones(1,N_filt);
% a=1;
% plot(reliability_orig_sorted,filter(b,a,reliability_diff(idx)));
% hold on;
% plot(reliability_orig_sorted,filter(b,a,reliability_diff_rand(idx)));
% 
% %%
% N1_diff = final_db_test(idx_low_std,2);
% N1_diff_rand = final_db_test(idx_low_std,6);
% 
% figure(51);
% clf;
% N_filt = 45;
% plot(reliability_orig_sorted,medfilt1(N1_diff(idx),N_filt));
% hold on;
% plot(reliability_orig_sorted,medfilt1(N1_diff_rand(idx),N_filt));
% 
% figure(61);
% clf;
% b = 1/N_filt*ones(1,N_filt);
% a=1;
% plot(reliability_orig_sorted,filter(b,a,N1_diff(idx)));
% hold on;
% plot(reliability_orig_sorted,filter(b,a,N1_diff_rand(idx)));
% 
% % hold on;
% plot(reliability_diff_rand(idx));
% figure(3);
% subplot(2,1,1);
% hist(final_db_test(idx_low_std,2),50);
% subplot(2,1,2);
% hist(final_db_test(idx_low_std,4),50);
% title('N1 matrix: NN vs random');

% figure(5);
% boxplot(final_db_test(idx_low_std,[2,6]));
% title('N1 matrix: NN vs random');

%% test how feasible NN solutions are
% N_test = 1000;
% feasbility_test = zeros(N_test,1);
% mod_interval=50;
% state = getInitialState(params);
% isStochastic=1;
% for j=1:N_test
%     if(mod(j,mod_interval)==1)
%         display(['Test iteration ',num2str(j),' out of ',num2str(N_test)]);
%         tic
%     end
%     uc_sample.windScenario = generateWind(1:params.horizon,params,state,isStochastic);
%     uc_sample.demandScenario = generateDemand(1:params.horizon,params,state,isStochastic);
%     params.windScenario = uc_sample.windScenario;
%     params.demandScenario = uc_sample.demandScenario;
%     NN_uc_sample = get_uc_NN(final_db,sample_matrix,uc_sample);
%     feasbility_test(j) = check_uc_feasibility(NN_uc_sample.onoff,params);
%     if(mod(j,mod_interval)==0)
%         toc
%     end
% end
% mean(feasbility_test)
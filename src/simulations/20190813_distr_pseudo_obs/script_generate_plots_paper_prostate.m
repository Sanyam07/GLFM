%% script generate plots paper

clear
%addpath(genpath('../../'));

% % load('./results_APR2/prostateRed_bias1_simId2_Niter10000_s2Y0.00_s2B1.00_alpha1.mat');
% % %tmp = params.t; params.t = params.t_1; params.t_1 = tmp;
% % %params.dt_1 = cell(1,size(data.X,2)); params.dt_1{5} = @(x) 1./(1+x);
% % %data.X(:,5) = params.t_1{5}(data.X(:,5));
% % params.ext_dataType = cell(1,size(data.X,2));
% % params.ext_dataType{5} = 'p';

% OPTION A)
load('./results/prostateRed_bias1_simId2_Niter10000_s2Y0.00_s2B1.00_alpha1.00.mat')

% OPTION B)
% load('./results/prostateRed_bias0_simId1_Niter10000_s2Y0.00_s2B1.00_alpha1.mat');

% 
%%
idx_featD = 3;
sum(hidden.Z)
    feat_toRemove = find(sum(hidden.Z) < N*0.03);
    hidden = remove_dims(hidden, feat_toRemove);
    sum(hidden.Z)
    [patterns, C] = get_feature_patterns_sorted(hidden.Z);

    order = [1 5 4 3 2];
    hidden.Z = hidden.Z(:,order);
    hidden.B = hidden.B(:,order,:);

    Kest = size(hidden.B,2);
    Zp = eye(Kest);
    %Zp(3,1) = 1;
    %Zp = [Zp; 0 1 1];
    Zp(:,1) = 1; % bias active
    Zp = Zp(1:min(5,Kest),:);
    leg_tmp = num2str(Zp(:,2:end));
    leg_tmp = mat2cell(leg_tmp, ones(size(Zp,1),1), size(leg_tmp,2))';

    leg = [{' Empirical'}, leg_tmp]; % ' F0',' F1', ' F2', ' F3', ' F4', ' F5'};
    colors = [ 0 102 255; ...
            153 51  255; ...
            204 204 0; ...
            255 102  102; ...
            0   204 102];
    colors = colors ./ 255; %repmat(sum(colors,2),1,3);
    colors(3,:) = [0.9290    0.6940    0.1250];
    colors(5,:) = [0.4660    0.6740    0.1880];

    % change order of colors
    colors = colors([1 2 4 3 5],:);
    %colors = colors([3 5 4 1 2],:);

%     colors = [  0    0.4470    0.7410; ...
%         0.8500    0.3250    0.0980; ...
%         0.9290    0.6940    0.1250; ...
%         0.4940    0.1840    0.5560; ...
%         0.4660    0.6740    0.1880];

Nhist = [100, 1000];
for k=4:5
figure(k); hold off;
[h xx] = hist(data.X(:,k),Nhist(k-3));
%xx(1) = 0.01;
%h = histogram(data.X(:,k),100);
h = h ./ sum(h * (xx(2) - xx(1)));
bar(h);
set(get(gca,'child'),'FaceColor',[0.8784 0.8784 0.8784], ...
    'EdgeColor',[0.7529 0.7529 0.7529]);
hold on;
end
set(gca,'xscale','log')

    for d=1:size(data.X,2)
            figure(d);
      %  subplot(2,1,1);
        [xd, pdf] = GLFM_PDF(data, Zp, hidden, params, d);
        if (data.C(d) == 'c') || (data.C(d) == 'o')
            mask = ~isnan(data.X(:,d));
            tmp = hist(data.X(mask,d), unique(data.X(mask,d)));
            tmp = tmp / sum(tmp);
            h = bar([tmp' pdf']);

            h(1).FaceColor = [0.8784 0.8784 0.8784];
            for k=1:length(colors)
                h(k+1).FaceColor = colors(k,:);
                if (k == idx_featD)
                    h(k+1).LineWidth = 2;
                    h(k+1).EdgeColor = [0.4016 0 0]; %[0.8 0 0]; %'red';
                end
            end

        elseif (data.C(d) == 'n')
            h = stem(xd, pdf');
            for k=1:length(colors)
                h(k).Color
                h(k).Color = colors(k,:);
            end
        else
            if ~isempty(params.t{d})
                h = semilogx(xd,pdf','Linewidth', 2);
            else
                h = plot(xd,pdf','Linewidth', 2);
            end
            for k=1:length(colors)
                h(k).Color
                h(k).Color = colors(k,:);
            end
        end

        title(data.ylabel_long{d});
        if (data.C(d) == 'c') || (data.C(d) == 'o')
            set(gca,'XTickLabel',data.cat_labels{d});
            %set(gca,'XTickLabelRotation',45);
        end
        legend(leg);
        grid;
    end

    sort(sum(hidden.Z),'descend')

    for k=1:5
        figure(k);
        title('');
        if (k==1)
            xticklabels({'stage 3', 'stage 4'});
        end
        if (k==2)
            xticklabels({'\leq 0.2mg', '1mg', '5mg'});
        end
        if (k==3)
            xticklabels({'alive', 'vascular', 'prostatic', 'others'});
        end
        if (k == 4)
            xlim([0 80]);
        end
        if (k ==5)
            ylim([0 0.7]);
            %xlim([10^(-1) 10^2]);
        end
        if (k == 1)
            legend('Location','Westoutside');
        else
            legend off
        end
        cleanfigure;
        matlab2tikz(sprintf('./figs/prostate/bias%d/fig%d_simId%d.tex', params.bias, k, params.simId));
        saveas(gca,sprintf('./figs/prostate/bias%d/fig%d_simId%d.fig', params.bias, k, params.simId) );
        figurapdf(7,7)
        print(sprintf('./figs/prostate/bias%d/fig%d_simId%d.pdf', params.bias, k, params.simId),['-d','pdf'],'-r300');
    end

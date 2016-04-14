analyze_scratch

%% Bit of old analysis programs to be put back later.


%% For Making Movies (skip this for now). 
    % make movie
    modelopt.movie_filename=['movie_',filestring];
    n.tracer=length(tracer.center);
    n.obst=length(obst.center);
    modelopt.movie_timestep=10;
    movie_diffusion(obst,obst_cen_rec,tracer,tracer_cen_rec,const,n,...
        modelopt.movie_timestep,...
        modelopt.movie_filename);
    %%
    
  

% %do the fit
%     fo = fitoptions;
%     fo.Weights=sqrt(tracer.msd(2:end,3))./(1e-4+tracer.msd(2:end,2));
%     tracer.fit=fit(tracer.time(2:end),tracer.msd(2:end,1),'power1',fo);
%     ci=confint(tracer.fit);
%     tracer.Deff=0.5*(ci(1,1)+ci(2,1));
%     tracer.Deff_err=tracer.Deff-ci(1,1);
%     tracer.beta=0.5*(ci(1,2)+ci(2,2));
%     tracer.beta_err=tracer.beta-ci(1,2);
%     
%     fname=['anal_',filestring,'.mat'];
%     save(fname, 'pvec','tracer','obst','const','modelopt');

    %     figure; %fit
%     plot(tracer.fit,tracer.time,tracer.msd(:,1));
%     title(['FF=',num2str(ffvec(j)),', D_{eff}=',num2str(tracer.Deff),...
%         ', \beta=',num2str(tracer.beta)]);
% %     saveas(gca,['data_',filestring,'_fit.png'],'png');
    
%     Deff(j)=tracer.Deff;
%     Deff_err(j)=tracer.Deff_err;
%     beta(j)=tracer.beta;
%     beta_err(j)=tracer.beta_err;
%     [ffvec(j) tracer.Deff tracer.Deff_err tracer.beta tracer.beta_err]

%% OLD figure making code
  % plots and analysis
    %     figure;
%     plot(1:const.ntimesteps,squeeze(tracer.cen_rec_nomod(:,1,:)),'-')
%     title(['Barrier=',num2str(slidevec(j))]);
%     
%     figure;
%     plot(tracer.bound_frac,'o');
%     title(['Barrier=',num2str(slidevec(j))]);
    
%     figure;%mean r^2/t
%     errorbar(tracer.time,tracer.msd(:,1)./tracer.time,tracer.msd(:,2)./sqrt(tracer.msd(:,3)),'o');
%     hold all
%     plot(tracer.time,tracer.msd(:,1)./tracer.time,'LineWidth',3);
%     hold off
%     title(['FF=',num2str(ffvec(j))]);
%     axis([0 max(tracer.time) 0 2]);
% %     saveas(gca,['data_',filestring,'_r2t.png'],'png');
%     
%     figure; %r^2 vs t
%     loglog(tracer.time,tracer.msd(:,1));
%     title(['FF=',num2str(ffvec(j))]);
% %     saveas(gca,['data_',filestring,'_log.png'],'png');
    
%     figure;
%     plot(tracer.msd(:,2))
%     figure;
%     plot(sqrt(tracer.msd(:,3)))
    



%% More old figure making code
% figure;
% errorbar(ffvec,Deff,Deff_err,'o');
% hold all;
% errorbar(ffvec,beta,beta_err,'o');
% % plot(ffvec,exp(-slidevec),'-');
% % plot(ffvec,ones(size(slidevec)),'-');
% hold off;
% % set(gca,'yscale','log'); 
% set(gca,'FontSize',12);
% xlabel('Obstacle filling fraction');
% ylabel('Fit results')
% legend('D_{eff}','\beta','Location','SouthWest');
% axis([0 1 0 1]);
% saveas(gca,'ff_inert_results','png'); 
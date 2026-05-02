%% BALLE_REBONDISSANTE_FFT.M — Simulation physique + Analyse spectrale FFT
%
%   ETAPE 1 : Animation en temps reel des balles rebondissantes
%   ETAPE 2 : Analyse FFT sur les signaux enregistres pendant la simulation
%
%   USAGE :
%       balle_rebondissante_fft          % parametres par defaut
%       balle_rebondissante_fft(3, 0.85) % 3 balles, restitution 0.85

function balle_rebondissante_fft(n_balles, restitution)

if nargin < 1; n_balles    = 4;    end
if nargin < 2; restitution = 0.85; end

%% ================================================================
%  PARAMETRES PHYSIQUES
%% ================================================================
g         = 9.81;
dt        = 0.016;   % ~60 FPS pour l'animation
Fe        = 1/dt;    % Frequence d'echantillonnage
T_sim     = 12;      % Duree simulation (s)
N         = round(T_sim / dt);
drag      = 0.999;
W         = 20;
H_box     = 15;
trail_len = 25;


%% ================================================================
%  INITIALISATION DES BALLES
%% ================================================================
rng(42);
rayons = 0.4 + rand(1, n_balles) * 0.5;
masses = (4/3) * pi * rayons.^3;

pos_x = zeros(1, n_balles);
pos_y = zeros(1, n_balles);
for i = 1:n_balles
    valide = false; tentatives = 0;
    while ~valide && tentatives < 1000
        tentatives = tentatives + 1;
        px = rayons(i) + rand()*(W - 2*rayons(i));
        py = H_box*0.4 + rand()*H_box*0.5;
        valide = true;
        for j = 1:i-1
            if sqrt((px-pos_x(j))^2+(py-pos_y(j))^2) < rayons(i)+rayons(j)+0.1
                valide = false; break;
            end
        end
    end
    pos_x(i) = px; pos_y(i) = py;
end

vit_x = (rand(1,n_balles)-0.5)*8;
vit_y = (rand(1,n_balles)-0.5)*4;

couleurs = [
    1.00 0.30 0.30;
    0.30 0.70 1.00;
    0.30 1.00 0.30;
    1.00 0.85 0.10;
    1.00 0.50 0.10;
    0.80 0.30 1.00;
    0.10 0.90 0.80;
    1.00 0.40 0.70;
];
while size(couleurs,1) < n_balles
    couleurs = [couleurs; rand(1,3)*0.5+0.5];
end
couleurs = couleurs(1:n_balles,:);

hist_x = repmat(pos_x', 1, trail_len);
hist_y = repmat(pos_y', 1, trail_len);

% Pre-allocation des signaux pour la FFT
y_signal  = zeros(n_balles, N);
vy_signal = zeros(n_balles, N);

%% ================================================================
%  CREATION DE LA FIGURE D'ANIMATION
%% ================================================================
fig = figure('Name', 'Balles Rebondissantes + FFT', ...
    'Position',    [80 60 1050 780], ...
    'Color',       [0.05 0.05 0.10], ...
    'NumberTitle', 'off', ...
    'KeyPressFcn', @(~,~) assignin('base','stop_sim',true));

% Axe simulation
ax_main = axes('Parent', fig, ...
    'Position',  [0.05 0.18 0.63 0.78], ...
    'Color',     [0.08 0.08 0.14], ...
    'XColor',    [0.4 0.4 0.5], 'YColor', [0.4 0.4 0.5], ...
    'GridColor', [0.2 0.2 0.3], 'GridAlpha', 0.3, ...
    'Box', 'on', 'XGrid', 'on', 'YGrid', 'on');
hold(ax_main,'on');
xlim(ax_main,[0 W]); ylim(ax_main,[0 H_box]);
xlabel(ax_main,'Position X (m)','Color',[0.7 0.7 0.8],'FontSize',10);
ylabel(ax_main,'Position Y (m)','Color',[0.7 0.7 0.8],'FontSize',10);
title(ax_main,'Simulation en cours — enregistrement pour FFT...', ...
    'Color','white','FontSize',11,'FontWeight','bold');
plot(ax_main,[0 W],[0.02 0.02],'-','Color',[0.3 0.9 0.3],'LineWidth',2.5);

% Axe energie
ax_energy = axes('Parent', fig, ...
    'Position',  [0.73 0.55 0.25 0.40], ...
    'Color',     [0.06 0.06 0.12], ...
    'XColor',    [0.5 0.5 0.6], 'YColor', [0.5 0.5 0.6], ...
    'GridColor', [0.2 0.2 0.3], 'GridAlpha', 0.4, ...
    'XGrid','on','YGrid','on','Box','on');
hold(ax_energy,'on');
title(ax_energy,'Energie (J)','Color','white','FontSize',9,'FontWeight','bold');
xlabel(ax_energy,'Temps (s)','Color',[0.6 0.6 0.7],'FontSize',8);

% Axe vitesses
ax_vitesse = axes('Parent', fig, ...
    'Position',  [0.73 0.08 0.25 0.38], ...
    'Color',     [0.06 0.06 0.12], ...
    'XColor',    [0.5 0.5 0.6], 'YColor', [0.5 0.5 0.6], ...
    'GridColor', [0.2 0.2 0.3], 'GridAlpha', 0.4, ...
    'XGrid','on','YGrid','on','Box','on');
hold(ax_vitesse,'on');
title(ax_vitesse,'Vitesses (m/s)','Color','white','FontSize',9,'FontWeight','bold');
xlabel(ax_vitesse,'Temps (s)','Color',[0.6 0.6 0.7],'FontSize',8);

% Axe info bas
ax_info = axes('Parent',fig,'Position',[0.05 0.02 0.63 0.13],'Visible','off');

%% ================================================================
%  OBJETS GRAPHIQUES
%% ================================================================
theta = linspace(0,2*pi,40);

h_trail  = gobjects(n_balles,1);
h_balle  = gobjects(n_balles,1);
h_reflet = gobjects(n_balles,1);

for i = 1:n_balles
    h_trail(i) = plot(ax_main, hist_x(i,:), hist_y(i,:), ...
        '-','Color',[couleurs(i,:),0.15],'LineWidth',1.5);
    h_balle(i) = fill(ax_main, ...
        pos_x(i)+rayons(i)*cos(theta), pos_y(i)+rayons(i)*sin(theta), ...
        couleurs(i,:),'EdgeColor',min(couleurs(i,:)*1.3,1),'LineWidth',1.5,'FaceAlpha',0.92);
    r_ref=rayons(i)*0.28; ox=rayons(i)*0.25; oy=rayons(i)*0.30;
    h_reflet(i) = fill(ax_main, ...
        pos_x(i)+ox+r_ref*cos(theta), pos_y(i)+oy+r_ref*sin(theta), ...
        'white','EdgeColor','none','FaceAlpha',0.45);
end

h_info_txt = text(ax_info,0.01,0.5,'','Color',[0.8 0.8 0.9],'FontSize',9, ...
    'FontName','Courier New','VerticalAlignment','middle','Units','normalized');

max_hist = 200;
t_hist  = nan(1,max_hist); Ec_hist = nan(1,max_hist);
Ep_hist = nan(1,max_hist); Et_hist = nan(1,max_hist);

h_Ec = plot(ax_energy,t_hist,Ec_hist,'-','Color',[1.0 0.5 0.2],'LineWidth',1.8);
h_Ep = plot(ax_energy,t_hist,Ep_hist,'-','Color',[0.3 0.7 1.0],'LineWidth',1.8);
h_Et = plot(ax_energy,t_hist,Et_hist,'-','Color',[0.3 1.0 0.5],'LineWidth',2.0);
legend(ax_energy,{'Ec','Ep','Et'},'TextColor','white','Color',[0.1 0.1 0.15], ...
    'EdgeColor',[0.3 0.3 0.4],'FontSize',7.5);

h_vit = gobjects(min(n_balles,5),1);
vit_hist = nan(min(n_balles,5),max_hist);
for i = 1:min(n_balles,5)
    h_vit(i) = plot(ax_vitesse,t_hist,nan(1,max_hist),'-','Color',couleurs(i,:),'LineWidth',1.5);
end

%% ================================================================
%  BOUCLE DE SIMULATION + ENREGISTREMENT
%% ================================================================
assignin('base','stop_sim',false);
t = 0; frame = 0; n_rebonds = 0;
fprintf('Simulation en cours... (fermer la fenetre ou appuyer une touche pour passer a la FFT)\n\n');

while ishandle(fig) && ~evalin('base','stop_sim') && frame < N

    frame = frame + 1;
    t     = t + dt;

    % Physique
    vit_y = vit_y - g*dt;
    vit_x = vit_x * drag;
    vit_y = vit_y * drag;
    pos_x = pos_x + vit_x*dt;
    pos_y = pos_y + vit_y*dt;

    % Collisions parois
    for i = 1:n_balles
        if pos_x(i)-rayons(i) < 0
            pos_x(i)=rayons(i); vit_x(i)=abs(vit_x(i))*restitution; n_rebonds=n_rebonds+1;
        end
        if pos_x(i)+rayons(i) > W
            pos_x(i)=W-rayons(i); vit_x(i)=-abs(vit_x(i))*restitution; n_rebonds=n_rebonds+1;
        end
        if pos_y(i)-rayons(i) < 0
            pos_y(i)=rayons(i); vit_y(i)=abs(vit_y(i))*restitution; n_rebonds=n_rebonds+1;
            if abs(vit_y(i)) < 0.15; vit_y(i)=0; pos_y(i)=rayons(i); end
        end
        if pos_y(i)+rayons(i) > H_box
            pos_y(i)=H_box-rayons(i); vit_y(i)=-abs(vit_y(i))*restitution; n_rebonds=n_rebonds+1;
        end
    end

    % Collisions entre balles
    for i = 1:n_balles-1
        for j = i+1:n_balles
            dx=pos_x(j)-pos_x(i); dy=pos_y(j)-pos_y(i);
            dist=sqrt(dx^2+dy^2); min_dist=rayons(i)+rayons(j);
            if dist < min_dist && dist > 1e-8
                overlap=min_dist-dist; nx=dx/dist; ny=dy/dist;
                m_tot=masses(i)+masses(j);
                pos_x(i)=pos_x(i)-nx*overlap*masses(j)/m_tot;
                pos_y(i)=pos_y(i)-ny*overlap*masses(j)/m_tot;
                pos_x(j)=pos_x(j)+nx*overlap*masses(i)/m_tot;
                pos_y(j)=pos_y(j)+ny*overlap*masses(i)/m_tot;
                dvx=vit_x(i)-vit_x(j); dvy=vit_y(i)-vit_y(j);
                dot_p=dvx*nx+dvy*ny;
                if dot_p < 0
                    J=-(1+restitution)*dot_p/(1/masses(i)+1/masses(j));
                    vit_x(i)=vit_x(i)+J/masses(i)*nx; vit_y(i)=vit_y(i)+J/masses(i)*ny;
                    vit_x(j)=vit_x(j)-J/masses(j)*nx; vit_y(j)=vit_y(j)-J/masses(j)*ny;
                    n_rebonds=n_rebonds+1;
                end
            end
        end
    end

    % Enregistrement des signaux
    y_signal(:,frame)  = pos_y';
    vy_signal(:,frame) = vit_y';

    % Trainee
    hist_x = [pos_x', hist_x(:,1:end-1)];
    hist_y = [pos_y', hist_y(:,1:end-1)];

    % Energies
    vitesses = sqrt(vit_x.^2+vit_y.^2);
    Ec = 0.5*sum(masses.*vitesses.^2);
    Ep = sum(masses*g.*pos_y);
    Et = Ec+Ep;
    t_hist  = [t_hist(2:end),  t];
    Ec_hist = [Ec_hist(2:end), Ec];
    Ep_hist = [Ep_hist(2:end), Ep];
    Et_hist = [Et_hist(2:end), Et];
    for i = 1:min(n_balles,5)
        vit_hist(i,:) = [vit_hist(i,2:end), vitesses(i)];
    end

    % Rendu graphique
    for i = 1:n_balles
        set(h_trail(i),'XData',hist_x(i,:),'YData',hist_y(i,:));
        set(h_balle(i),'XData',pos_x(i)+rayons(i)*cos(theta), ...
                        'YData',pos_y(i)+rayons(i)*sin(theta));
        r_ref=rayons(i)*0.28; ox=rayons(i)*0.25; oy=rayons(i)*0.30;
        set(h_reflet(i),'XData',pos_x(i)+ox+r_ref*cos(theta), ...
                         'YData',pos_y(i)+oy+r_ref*sin(theta));
    end

    if mod(frame,3)==0
        set(h_Ec,'XData',t_hist,'YData',Ec_hist);
        set(h_Ep,'XData',t_hist,'YData',Ep_hist);
        set(h_Et,'XData',t_hist,'YData',Et_hist);
        if ~all(isnan(Et_hist))
            xlim(ax_energy,[max(0,t-max_hist*dt), t+0.1]);
            v=Et_hist(~isnan(Et_hist));
            if ~isempty(v); ylim(ax_energy,[0,max(v)*1.15+1]); end
        end
        for i = 1:min(n_balles,5)
            set(h_vit(i),'XData',t_hist,'YData',vit_hist(i,:));
        end
        if ~all(isnan(vit_hist(:)))
            xlim(ax_vitesse,[max(0,t-max_hist*dt),t+0.1]);
            vv=vit_hist(~isnan(vit_hist));
            if ~isempty(vv); ylim(ax_vitesse,[0,max(vv)*1.15+0.5]); end
        end
        [~,bi]=max(vitesses);
        info_str = sprintf('t = %6.2f s  |  Rebonds: %4d  |  Frame: %d/%d\nEc = %7.1f J  |  Ep = %7.1f J  |  Et = %7.1f J\nBalle la plus rapide: #%d  (%.1f m/s)', ...
            t,n_rebonds,frame,N,Ec,Ep,Et,bi,vitesses(bi));
        set(h_info_txt,'String',info_str);
    end

    drawnow limitrate;
    pause(dt*0.3);
end

N_enregistre = frame;
fprintf('OK - Simulation terminee : %d echantillons enregistres sur %d prevus.\n\n', N_enregistre, N);

if N_enregistre < 64
    fprintf('Pas assez de donnees pour la FFT. Relancer avec une duree plus longue.\n');
    return;
end

%% ================================================================
%  ANALYSE FFT — SUR LES DONNEES ENREGISTREES
%% ================================================================
fprintf('Lancement de l''analyse spectrale FFT...\n\n');

% Adapter aux donnees reellement enregistrees
y_sig = y_signal(:, 1:N_enregistre);
N_fft = N_enregistre;
t_vec = (0:N_fft-1)*dt;
f_vec = (0:floor(N_fft/2)-1)*(Fe/N_fft);
N_half = floor(N_fft/2);

fprintf('+-----------------------------------------------+\n');
fprintf('|  Parametres FFT                               |\n');
fprintf('+-----------------------------------------------+\n');
fprintf('|  N  = %-6d  |  Fe = %.1f Hz              |\n', N_fft, Fe);
fprintf('|  Df = %.5f Hz  |  Nyquist = %.1f Hz      |\n', Fe/N_fft, Fe/2);
fprintf('+-----------------------------------------------+\n\n');

fft_amplitude  = zeros(n_balles, N_half);
fft_phase      = zeros(n_balles, N_half);
dsp_mat        = zeros(n_balles, N_half);
f_fondamentale = zeros(1, n_balles);

for i = 1:n_balles
    signal        = y_sig(i,:);
    signal_centre = signal - mean(signal);
    fenetre_hann  = 0.5*(1-cos(2*pi*(0:N_fft-1)/(N_fft-1)));
    signal_fen    = signal_centre .* fenetre_hann;
    X             = fft(signal_fen, N_fft);
    amplitude     = (2/N_fft)*abs(X(1:N_half));
    fft_amplitude(i,:) = amplitude;
    fft_phase(i,:)     = angle(X(1:N_half));
    dsp_mat(i,:)       = (abs(X(1:N_half)).^2)/N_fft;
    idx_min = find(f_vec >= 0.05, 1);
    if isempty(idx_min); idx_min=1; end
    [~,idx_max]    = max(amplitude(idx_min:end));
    f_fondamentale(i) = f_vec(idx_min+idx_max-1);
    fprintf('  Balle %d : f_rebond = %.3f Hz  (T = %.2f s)\n', ...
        i, f_fondamentale(i), 1/f_fondamentale(i));
end

% Spectrogramme (balle 1)
L_fen    = min(512, floor(N_fft/4));
L_fen    = 2^floor(log2(L_fen));
overlap  = floor(L_fen/2);
hop      = L_fen - overlap;
n_frames = floor((N_fft-L_fen)/hop)+1;
f_stft   = (0:L_fen/2-1)*(Fe/L_fen);
t_stft   = ((0:n_frames-1)*hop+L_fen/2)*dt;
sig_b1   = y_sig(1,:)-mean(y_sig(1,:));
specto   = zeros(L_fen/2, n_frames);
w_hann   = 0.5*(1-cos(2*pi*(0:L_fen-1)/(L_fen-1)));
for fi = 1:n_frames
    d=( fi-1)*hop+1; fn=d+L_fen-1;
    if fn>N_fft; break; end
    seg=sig_b1(d:fn).*w_hann;
    Xs=fft(seg,L_fen);
    specto(:,fi)=abs(Xs(1:L_fen/2)).^2;
end
specto_dB = 10*log10(specto+eps);

% Comparaison fenetres
sig_t     = y_sig(1,:)-mean(y_sig(1,:));
win_rect  = ones(1,N_fft);
win_hann2 = 0.5*(1-cos(2*pi*(0:N_fft-1)/(N_fft-1)));
win_hamm  = 0.54-0.46*cos(2*pi*(0:N_fft-1)/(N_fft-1));
X_rect    = (2/N_fft)*abs(fft(sig_t.*win_rect,   N_fft));
X_hann    = (2/N_fft)*abs(fft(sig_t.*win_hann2,  N_fft));
X_hamming = (2/N_fft)*abs(fft(sig_t.*win_hamm,   N_fft));

%% ================================================================
%  FIGURE FFT
%% ================================================================
leg_str = arrayfun(@(i) sprintf('Balle %d (f=%.2f Hz)',i,f_fondamentale(i)), ...
    1:n_balles,'UniformOutput',false);

fig2 = figure('Name','Analyse Spectrale FFT', ...
    'Position',[50 30 1400 900],'Color',[0.06 0.06 0.10]);

f_max_aff = min(5, Fe/2*0.8);
idx_fmax  = find(f_vec <= f_max_aff);

% -- Signal temporel
ax1 = subplot(3,4,1:2);
set(ax1,'Color',[0.10 0.10 0.16],'XColor',[0.7 0.7 0.8],'YColor',[0.7 0.7 0.8], ...
    'GridColor',[0.2 0.2 0.3],'GridAlpha',0.4);
hold(ax1,'on'); grid(ax1,'on');
for i=1:n_balles
    plot(ax1,t_vec,y_sig(i,:),'Color',couleurs(i,:),'LineWidth',1.2);
end
xlabel(ax1,'Temps t (s)','Color',[0.7 0.7 0.8],'FontSize',9);
ylabel(ax1,'Position y(t) (m)','Color',[0.7 0.7 0.8],'FontSize',9);
title(ax1,'Signal temporel enregistre : y(t)','Color','white','FontSize',10,'FontWeight','bold');
legend(ax1,leg_str,'TextColor','white','Color',[0.1 0.1 0.15],'EdgeColor',[0.3 0.3 0.4],'FontSize',8);

% -- Centrage + fenetrage
ax2 = subplot(3,4,3:4);
set(ax2,'Color',[0.10 0.10 0.16],'XColor',[0.7 0.7 0.8],'YColor',[0.7 0.7 0.8], ...
    'GridColor',[0.2 0.2 0.3],'GridAlpha',0.4);
hold(ax2,'on'); grid(ax2,'on');
sig_r = y_sig(1,:)-mean(y_sig(1,:));
sig_f = sig_r.*(0.5*(1-cos(2*pi*(0:N_fft-1)/(N_fft-1))));
plot(ax2,t_vec,sig_r,'Color',[0.7 0.7 0.9],'LineWidth',0.8,'DisplayName','Signal centre');
plot(ax2,t_vec,sig_f,'Color',couleurs(1,:),'LineWidth',1.2,'DisplayName','Apres fenetre Hann');
plot(ax2,t_vec,0.5*(1-cos(2*pi*(0:N_fft-1)/(N_fft-1)))*max(abs(sig_r)), ...
    '--','Color',[1 0.8 0.2],'LineWidth',0.8,'DisplayName','Fenetre Hann');
xlabel(ax2,'Temps t (s)','Color',[0.7 0.7 0.8],'FontSize',9);
ylabel(ax2,'Amplitude','Color',[0.7 0.7 0.8],'FontSize',9);
title(ax2,'Centrage + Fenetrage Hann avant FFT','Color','white','FontSize',10,'FontWeight','bold');
legend(ax2,'TextColor','white','Color',[0.1 0.1 0.15],'EdgeColor',[0.3 0.3 0.4],'FontSize',8);

% -- Spectre amplitude
ax3 = subplot(3,4,5:6);
set(ax3,'Color',[0.10 0.10 0.16],'XColor',[0.7 0.7 0.8],'YColor',[0.7 0.7 0.8], ...
    'GridColor',[0.2 0.2 0.3],'GridAlpha',0.4);
hold(ax3,'on'); grid(ax3,'on');
for i=1:n_balles
    plot(ax3,f_vec(idx_fmax),fft_amplitude(i,idx_fmax),'Color',couleurs(i,:),'LineWidth',1.8);
    [amp_max,~]=max(fft_amplitude(i,idx_fmax));
    plot(ax3,f_fondamentale(i),amp_max,'v','Color',couleurs(i,:),'MarkerSize',10,'MarkerFaceColor',couleurs(i,:));
    text(ax3,f_fondamentale(i)+0.05,amp_max*0.95, ...
        sprintf('f%d=%.2f Hz',i,f_fondamentale(i)),'Color',couleurs(i,:),'FontSize',8,'FontWeight','bold');
end
xlabel(ax3,'Frequence f (Hz)','Color',[0.7 0.7 0.8],'FontSize',9);
ylabel(ax3,'|X(f)| (m)','Color',[0.7 0.7 0.8],'FontSize',9);
title(ax3,'Spectre d''amplitude : |X(f)| = FFT de y(t)','Color','white','FontSize',10,'FontWeight','bold');

% -- DSP
ax4 = subplot(3,4,7:8);
set(ax4,'Color',[0.10 0.10 0.16],'XColor',[0.7 0.7 0.8],'YColor',[0.7 0.7 0.8], ...
    'GridColor',[0.2 0.2 0.3],'GridAlpha',0.4);
hold(ax4,'on'); grid(ax4,'on');
for i=1:n_balles
    dsp_dB=10*log10(dsp_mat(i,idx_fmax)+eps);
    plot(ax4,f_vec(idx_fmax),dsp_dB,'Color',couleurs(i,:),'LineWidth',1.5);
end
xlabel(ax4,'Frequence f (Hz)','Color',[0.7 0.7 0.8],'FontSize',9);
ylabel(ax4,'DSP (dB)','Color',[0.7 0.7 0.8],'FontSize',9);
title(ax4,'Densite Spectrale de Puissance (dB)','Color','white','FontSize',10,'FontWeight','bold');
legend(ax4,leg_str,'TextColor','white','Color',[0.1 0.1 0.15],'EdgeColor',[0.3 0.3 0.4],'FontSize',8);

% -- Spectrogramme
ax5 = subplot(3,4,9:10);
set(ax5,'Color',[0.10 0.10 0.16],'XColor',[0.7 0.7 0.8],'YColor',[0.7 0.7 0.8]);
f_stft_max = find(f_stft <= min(8, Fe/2));
imagesc(ax5,t_stft,f_stft(f_stft_max),specto_dB(f_stft_max,:));
axis(ax5,'xy'); colormap(ax5,hot);
cb=colorbar(ax5); cb.Color=[0.7 0.7 0.8];
cb.Label.String='Puissance (dB)'; cb.Label.Color=[0.7 0.7 0.8];
xlabel(ax5,'Temps (s)','Color',[0.7 0.7 0.8],'FontSize',9);
ylabel(ax5,'Frequence (Hz)','Color',[0.7 0.7 0.8],'FontSize',9);
title(ax5,'Spectrogramme STFT (Balle 1)','Color','white','FontSize',10,'FontWeight','bold');
yline(ax5,f_fondamentale(1),'--','Color',[0.2 1.0 0.5],'LineWidth',1.5);

% -- Comparaison fenetres
ax6 = subplot(3,4,11);
set(ax6,'Color',[0.10 0.10 0.16],'XColor',[0.7 0.7 0.8],'YColor',[0.7 0.7 0.8], ...
    'GridColor',[0.2 0.2 0.3],'GridAlpha',0.4);
hold(ax6,'on'); grid(ax6,'on');
idx_f2=find(f_vec<=f_max_aff);
plot(ax6,f_vec(idx_f2),20*log10(X_rect(idx_f2)+eps),'Color',[1.0 0.4 0.4],'LineWidth',1.2,'DisplayName','Rect.');
plot(ax6,f_vec(idx_f2),20*log10(X_hann(idx_f2)+eps),'Color',[0.3 0.8 1.0],'LineWidth',1.5,'DisplayName','Hann');
plot(ax6,f_vec(idx_f2),20*log10(X_hamming(idx_f2)+eps),'Color',[0.6 1.0 0.4],'LineWidth',1.2,'DisplayName','Hamming');
xlabel(ax6,'Frequence (Hz)','Color',[0.7 0.7 0.8],'FontSize',8);
ylabel(ax6,'dB','Color',[0.7 0.7 0.8],'FontSize',8);
title(ax6,'Fenetrages : fuite spectrale','Color','white','FontSize',9,'FontWeight','bold');
legend(ax6,'TextColor','white','Color',[0.1 0.1 0.15],'EdgeColor',[0.3 0.3 0.4],'FontSize',7,'Location','southwest');

% -- Phase
ax7 = subplot(3,4,12);
set(ax7,'Color',[0.10 0.10 0.16],'XColor',[0.7 0.7 0.8],'YColor',[0.7 0.7 0.8], ...
    'GridColor',[0.2 0.2 0.3],'GridAlpha',0.4);
hold(ax7,'on'); grid(ax7,'on');
idx_f3=find(f_vec<=f_max_aff);
for i=1:n_balles
    plot(ax7,f_vec(idx_f3),fft_phase(i,idx_f3)*(180/pi),'.','Color',couleurs(i,:),'MarkerSize',3);
end
xlabel(ax7,'Frequence (Hz)','Color',[0.7 0.7 0.8],'FontSize',8);
ylabel(ax7,'Phase (deg)','Color',[0.7 0.7 0.8],'FontSize',8);
title(ax7,'Spectre de phase','Color','white','FontSize',9,'FontWeight','bold');
yticks(ax7,[-180 -90 0 90 180]);

sgtitle('Analyse Spectrale FFT - Signaux enregistres pendant la simulation', ...
    'Color','white','FontSize',13,'FontWeight','bold');

%% ================================================================
%  RESUME CONSOLE
%% ================================================================
fprintf('\n============================================\n');
fprintf('  RESULTATS ANALYSE SPECTRALE\n');
fprintf('============================================\n');
fprintf('  Fe = %.1f Hz  |  N = %d  |  Df = %.4f Hz\n', Fe, N_fft, Fe/N_fft);
fprintf('  Nyquist = %.1f Hz\n\n', Fe/2);
for i=1:n_balles
    fprintf('  Balle %d : f1 = %.4f Hz  |  T = %.3f s  |  E = %.2f J\n', ...
        i, f_fondamentale(i), 1/f_fondamentale(i), sum(y_sig(i,:).^2)*dt);
end
fprintf('============================================\n');
fprintf('OK - Analyse FFT terminee.\n\n');

end
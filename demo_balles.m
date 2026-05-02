%% DEMO_BALLES.M — Demonstration des differentes configurations
%
%   Lance balle_rebondissante_fft avec differents parametres
%   pour illustrer les effets physiques + analyse FFT automatique.
%
%   USAGE : demo_balles

fprintf('\n');
fprintf('+----------------------------------------------------------+\n');
fprintf('|  DEMO - Balles Rebondissantes + Analyse FFT              |\n');
fprintf('|  Choisissez une configuration a lancer                   |\n');
fprintf('+----------------------------------------------------------+\n');
fprintf('|  1. Configuration par defaut     (4 balles,  e=0.85)    |\n');
fprintf('|  2. Rebond parfait               (5 balles,  e=1.00)    |\n');
fprintf('|  3. Rebond tres amorti           (6 balles,  e=0.50)    |\n');
fprintf('|  4. Beaucoup de balles           (10 balles, e=0.75)    |\n');
fprintf('|  5. Une seule balle              (1 balle,   e=0.90)    |\n');
fprintf('+----------------------------------------------------------+\n');
fprintf('|  >> Fermez la fenetre ou appuyez une touche              |\n');
fprintf('|     pour declencher l''analyse FFT automatiquement        |\n');
fprintf('+----------------------------------------------------------+\n');

choix = input('\nEntrez votre choix (1-5, defaut=1) : ');
if isempty(choix); choix = 1; end

switch choix
    case 1
        fprintf('\n>> Configuration par defaut : 4 balles, restitution=0.85\n');
        balle_rebondissante_fft(4, 0.85);

    case 2
        fprintf('\n>> Rebond parfait : 5 balles, restitution=1.00 (energie conservee !)\n');
        balle_rebondissante_fft(5, 1.00);

    case 3
        fprintf('\n>> Rebond amorti : 6 balles, restitution=0.50 (balles qui s''arretent vite)\n');
        balle_rebondissante_fft(6, 0.50);

    case 4
        fprintf('\n>> Foule de balles : 10 balles, restitution=0.75\n');
        balle_rebondissante_fft(10, 0.75);

    case 5
        fprintf('\n>> Solo : 1 balle, restitution=0.90\n');
        balle_rebondissante_fft(1, 0.90);

    otherwise
        fprintf('\n>> Choix invalide, lancement par defaut.\n');
        balle_rebondissante_fft(4, 0.85);
end
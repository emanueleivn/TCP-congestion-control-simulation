function congestione_TCP
    running = false;
    lossTriggered = false;
    timeoutTriggered = false;
    
    %% Creazione della finestra principale
    fig = figure('Name','TCP Congestion Control','NumberTitle','off',...
                 'Units','normalized','Position',[0.1,0.1,0.75,0.75]);
             
    % Creazione legenda
    mainAx = axes('Parent', fig, ...
                  'Units','normalized', ...
                  'Position',[0.08,0.15,0.60,0.75]);
    hold(mainAx,'on');
    title(mainAx,'Evoluzione della Congestion Window (CongWind)','FontWeight','bold');
    xlabel(mainAx,'Tempo (Pacchetti trasmessi)','FontWeight','bold');
    ylabel(mainAx,'CongWind','FontWeight','bold');
    grid(mainAx,'on');
    
    % Etichette
    rtt_label = uicontrol('Parent', fig, ...
        'Style','text','String','RTT: 0.20 s',...
        'Units','normalized','Position',[0.73,0.80,0.25,0.05],...
        'FontSize',10,'HorizontalAlignment','left','FontWeight','bold');
    
    ack_label = uicontrol('Parent', fig, ...
        'Style','text','String','ACK: -',...
        'Units','normalized','Position',[0.73,0.73,0.25,0.05],...
        'FontSize',10,'HorizontalAlignment','left','FontWeight','bold');
    
    dup_ack_label = uicontrol('Parent', fig, ...
        'Style','text','String','Dup ACK: 0',...
        'Units','normalized','Position',[0.73,0.66,0.25,0.05],...
        'FontSize',10,'HorizontalAlignment','left','FontWeight','bold');
    
    technique_label = uicontrol('Parent', fig, ...
        'Style','text','String','Tecnica attuale: -',...
        'Units','normalized','Position',[0.73,0.59,0.25,0.05],...
        'FontSize',10,'HorizontalAlignment','left','FontWeight','bold');
    
    buffer_label = uicontrol('Parent', fig, ...
        'Style','text','String','Buffer: 0 / 50',...
        'Units','normalized','Position',[0.73,0.52,0.25,0.05],...
        'FontSize',10,'HorizontalAlignment','left','FontWeight','bold');
    
    cwnd_label = uicontrol('Parent', fig, ...
        'Style','text','String','CWND: 1   Threshold: 16',...
        'Units','normalized','Position',[0.73,0.45,0.25,0.05],...
        'FontSize',10,'HorizontalAlignment','left','FontWeight','bold');
    
    % Pulsanti
    uicontrol('Parent', fig, ...
        'Style','pushbutton','String','Start',...
        'Units','normalized','Position',[0.73,0.35,0.25,0.06],...
        'FontSize',10,'FontWeight','bold','Callback',@startSimulation);
    
    uicontrol('Parent', fig, ...
        'Style','pushbutton','String','Stop',...
        'Units','normalized','Position',[0.73,0.28,0.25,0.06],...
        'FontSize',10,'FontWeight','bold','Callback',@stopSimulation);
    
    uicontrol('Parent', fig, ...
        'Style','pushbutton','String','Loss',...
        'Units','normalized','Position',[0.73,0.21,0.25,0.06],...
        'FontSize',10,'FontWeight','bold','Callback',@triggerLoss);
    
    uicontrol('Parent', fig, ...
        'Style','pushbutton','String','Timeout',...
        'Units','normalized','Position',[0.73,0.14,0.25,0.06],...
        'FontSize',10,'FontWeight','bold','Callback',@triggerTimeout);
    
    %% CALLBACKS
    function startSimulation(~, ~)
        if ~running
            running = true;
            disp('[+] Simulazione avviata...');
            runSimulation();
        end
    end

    function stopSimulation(~, ~)
        running = false;
        disp('[-] Simulazione interrotta.');
    end

    function triggerLoss(~, ~)
        lossTriggered = true;
        disp('[!] Bottone Loss premuto: simulazione di 3 duplicate ACK.');
    end

    function triggerTimeout(~, ~)
        timeoutTriggered = true;
        disp('[!] Bottone Timeout premuto: simulazione di Timeout.');
    end

    %% Main
    function runSimulation()
        % Parametri TCP iniziali
        CongWind = 1;         % Congestion Window iniziale
        treshold = 16;        % Soglia iniziale sstresh
        time = 1;             
        CongWind_history = CongWind;
        
        % Impostazione del buffer
        bufferCapacity = 50;
        
        % Parametri per il RTT
        baseRTT = 0.2;
        
        % Gestione Fast Recovery
        fast_recovery = false;
        fr_iterations = 0;
        FR_MAX_ITERS = 3;
        
        % Contatore per duplicate ACK
        dupACKCount = 0;
        
        while running
            % Salva i valori precedenti
            old_time = time;
            old_CongWind = CongWind;
            
            % Genera un RTT casuale (baseRTT + variazione)
            currentRTT = baseRTT + 0.3 * rand;
            set(rtt_label, 'String', ['RTT: ' num2str(currentRTT, '%.2f') ' s']);
            
            %--------------------------------------------------------------
            % Se il pulsante Loss è stato premuto, forziamo 3 duplicate ACK
            %--------------------------------------------------------------
            if lossTriggered
                disp('[!] Loss triggered: forzo 3 duplicate ACK');
                fast_recovery = true;
                fr_iterations = FR_MAX_ITERS;
                treshold = max(floor(CongWind / 2), 1);
                CongWind = treshold + 3;
                dupACKCount = 0;          
                set(ack_label, 'String', 'ACK: dup (Loss triggered)');
                set(dup_ack_label, 'String', 'Dup ACK: 3');
                lossTriggered = false;
            else
                %--------------------------------------------------------------
                % Simula il ricevimento di un ACK in condizioni normali
                % In modalità normale, la probabilità di ricevere un nuovo ACK è alta
                % In Fast Recovery, aumenta la probabilità di duplicati
                %--------------------------------------------------------------
                if fast_recovery
                    p_new = 0.3;  % 30% di probabilità di nuovo ACK-fast recovery
                else
                    p_new = 0.9;  % 90% di probabilità di nuovo ACK 
                end
                if rand < p_new
                    ackType = 'new';
                else
                    ackType = 'dup';
                end
                set(ack_label, 'String', ['ACK: ' ackType]);
                
                %--------------------------------------------------------------
                % Gestione dell'ACK ricevuto
                %--------------------------------------------------------------
                if strcmp(ackType, 'new')
                    dupACKCount = 0;
                    set(dup_ack_label, 'String', 'Dup ACK: 0');
                    if fast_recovery
                        fast_recovery = false;
                        CongWind = treshold;  % uscita da Fast Recovery
                    else
                        if CongWind < treshold
                            % Slow Start: crescita esponenziale
                            CongWind = CongWind * 2;
                        else
                            % Congestion Avoidance: crescita lineare
                            CongWind = CongWind + 1;
                        end
                    end
                else 
                    if ~fast_recovery
                        dupACKCount = dupACKCount + 1;
                        set(dup_ack_label, 'String', ['Dup ACK: ' num2str(dupACKCount)]);
                        if dupACKCount >= 3
                            fast_recovery = true;
                            fr_iterations = FR_MAX_ITERS;
                            treshold = max(floor(CongWind / 2), 1);
                            CongWind = treshold + 3;
                            dupACKCount = 0;
                        end
                    else
                        CongWind = CongWind + 1;
                    end
                end
            end
            
            %--------------------------------------------------------------
            % Gestione Timeout: se timeoutTriggered è attivo
            %--------------------------------------------------------------
            if timeoutTriggered
                disp('[!] Timeout triggered: riportiamo a Slow Start');
                treshold = max(floor(CongWind / 2), 1);
                CongWind = 1; % Ripartiamo da Slow Start
                timeoutTriggered = false;
                fast_recovery = false;
                pause(3); % attesa di 3 secondi per simulare il timeout
            end
            
            %--------------------------------------------------------------
            % Gestione Fast Recovery: decremento delle iterazioni
            %--------------------------------------------------------------
            if fast_recovery
                fr_iterations = fr_iterations - 1;
                if fr_iterations <= 0
                    fast_recovery = false;
                    disp('[+] Uscita da Fast Recovery => Congestion Avoidance.');
                end
            end
            
            %--------------------------------------------------------------
            % Verifica overflow del buffer (trigger automatico Fast Recovery)
            %--------------------------------------------------------------
            if ~fast_recovery && (CongWind > bufferCapacity)
                disp('[!] Buffer overflow => Attivazione Fast Recovery');
                treshold = max(floor(CongWind / 2), 1);
                CongWind = treshold;
                fast_recovery = true;
                fr_iterations = FR_MAX_ITERS;
            end
            
            %--------------------------------------------------------------
            % Aggiornamento etichette 
            %--------------------------------------------------------------
            if fast_recovery
                techniqueStr = 'Fast Recovery';
            elseif CongWind < treshold
                techniqueStr = 'Slow Start';
            else
                techniqueStr = 'Congestion Avoidance';
            end
            set(technique_label, 'String', ['Tecnica attuale: ' techniqueStr]);
            set(cwnd_label, 'String', ['CWND: ' num2str(CongWind) '   Threshold: ' num2str(treshold)]);
            
            bufferOccupancy = min(CongWind, bufferCapacity);
            set(buffer_label, 'String', ['Buffer: ' num2str(bufferOccupancy) ' / ' num2str(bufferCapacity)]);
            
            %--------------------------------------------------------------
            % Aggiornamento grafico
            %--------------------------------------------------------------
            plot(mainAx, [old_time, old_time+1], [old_CongWind, CongWind], 'Color','r','LineWidth',2);
            
            time = time + 1;
            CongWind_history = [CongWind_history, CongWind];
            
            max_CongWind = max(CongWind_history);
            ylim(mainAx, [0, max(50, max_CongWind * 1.2)]);
            xlim(mainAx, [0, time + 10]);
            drawnow;
            
            pause(currentRTT);
        end
        
        disp('[+] Simulazione completata.');
    end
end

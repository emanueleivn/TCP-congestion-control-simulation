### 📡 TCP Congestion Control Simulator  

Benvenuto nel repository **TCP Congestion Control Simulator**, un'implementazione MATLAB per la simulazione e la visualizzazione dell'evoluzione della finestra di congestione (Congestion Window - CWND) in un ambiente TCP.

---

## 📌 Caratteristiche

✅ Simulazione dei meccanismi di controllo della congestione TCP, tra cui:
- **Slow Start**
- **Congestion Avoidance**
- **Fast Recovery**
- **Timeout Handling**

✅ **Interfaccia Grafica Interattiva**, con:
- Grafico dell'andamento della Congestion Window (CWND)
- Controlli per avviare/arrestare la simulazione
- Pulsanti per simulare **perdita di pacchetti** e **timeout**

✅ **Parametri aggiornati in tempo reale**, come:
- Round Trip Time (**RTT**)
- Acknowledgment (**ACK** e **Dup ACK**)
- Stato del **buffer** e **soglia di congestione**

---

## 📂 Struttura del Repository

📁 **TCP_Congestion_Simulator**  
├── `congestione_TCP.m` → Script MATLAB principale  
├── `README.md` → Documentazione  
└── `LICENSE` → Licenza MIT  

---

## 🚀 Installazione e Esecuzione

### 1️⃣ Prerequisiti  
🔹 **MATLAB** (versione R2018 o successiva consigliata)  

### 2️⃣ Clonazione del Repository  
```bash
git clone https://github.com/tuo-username/TCP_Congestion_Simulator.git
cd TCP_Congestion_Simulator
```

### 3️⃣ Avvio della Simulazione  
Apri MATLAB e naviga nella cartella del progetto, quindi esegui:  
```matlab
congestione_TCP
```

---

## 🎛️ Interfaccia Utente  

La GUI fornisce:  
- **Grafico** dell'andamento della Congestion Window (CWND)  
- **Etichette informative** su RTT, ACK ricevuti, stato della finestra  
- **Pulsanti interattivi** per controllare la simulazione  

🔹 **Start** → Avvia la simulazione  
🔹 **Stop** → Interrompe la simulazione  
🔹 **Loss** → Simula la perdita di pacchetti (3 duplicati ACK)  
🔹 **Timeout** → Simula un timeout (CWND reset a 1)  

---

## 🔬 Principio di Funzionamento  

Il codice implementa una simulazione della **congestione TCP** basata su:  
✔ **Slow Start:** crescita esponenziale di CWND fino alla soglia (`threshold`)  
✔ **Congestion Avoidance:** crescita lineare della CWND oltre la soglia  
✔ **Fast Recovery:** se si ricevono 3 duplicate ACK, CWND è ridotto e aumentato progressivamente  
✔ **Timeout Handling:** CWND è resettato a 1 e riparte in **Slow Start**  

La simulazione gestisce inoltre **RTT variabile**, **buffer overflow** e l'uscita da **Fast Recovery**.

---

## 🛠️ Possibili Estensioni  

✅ Aggiunta del supporto per **TCP Reno** e **TCP Tahoe**  
✅ Implementazione della **trasmissione selettiva** (SACK)  
✅ Simulazione di **reti con più flussi TCP concorrenti**  

Se vuoi contribuire, sentiti libero di aprire una **Pull Request**!

---

## 📜 Licenza  

Distribuito sotto licenza **MIT**. Vedi il file [`LICENSE`](LICENSE) per dettagli.  

📌 **TCP Congestion Control Simulator – Esplora il comportamento della congestione TCP in MATLAB!** 🚀

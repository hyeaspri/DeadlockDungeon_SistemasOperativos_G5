# Genera la musica y los efectos de sonido de Deadlock Dungeon (originales, estilo chiptune).
# Requiere Python 3 y numpy. Uso: python recursos/generar_audio.py -> crea los WAV en recursos/sonidos/
import numpy as np, wave, os
SR=22050
OUT=os.path.join(os.path.dirname(os.path.abspath(__file__)),'sonidos')+os.sep
os.makedirs(OUT,exist_ok=True)
NOTAS={'C':0,'C#':1,'D':2,'D#':3,'E':4,'F':5,'F#':6,'G':7,'G#':8,'A':9,'A#':10,'B':11}
def hz(n):
    nom,o=n[:-1],int(n[-1]); return 440*2**((NOTAS[nom]+12*(o+1)-69)/12)
def onda(tipo,f,dur,duty=0.5):
    t=np.arange(int(SR*dur))/SR; ph=(t*f)%1
    if tipo=='sq': return np.where(ph<duty,1.0,-1.0)
    if tipo=='tri': return 4*np.abs(ph-0.5)-1
    if tipo=='saw': return 2*ph-1
    if tipo=='sin': return np.sin(2*np.pi*f*t)
def env(x,a=0.005,d=0.08,s=0.6,r=0.04):
    n=len(x); e=np.ones(n)*s; A=int(a*SR); D=int(d*SR); Rr=int(r*SR)
    e[:A]=np.linspace(0,1,A) if A>0 else e[:A]
    e[A:A+D]=np.linspace(1,s,len(e[A:A+D]))
    if Rr>0: e[-Rr:]*=np.linspace(1,0,Rr)
    return x*e
def guardar(nombre,x,vol=0.8):
    x=x/ (np.max(np.abs(x))+1e-9)*vol
    d=(x*32767).astype(np.int16)
    with wave.open(OUT+nombre+'.wav','wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(d.tobytes())
def mezclar(base,x,pos):
    i=int(pos*SR); base[i:i+len(x)]+=x[:len(base)-i]

# ---------------- MUSICA ----------------
BPM=108; CORCHEA=60/BPM/2; COMPAS=CORCHEA*8; NB=8
total=np.zeros(int(SR*COMPAS*NB)+1)
acordes=[('A',['A','C','E']),('F',['F','A','C']),('D',['D','F','A']),('E',['E','G#','B']),
         ('A',['A','C','E']),('F',['F','A','C']),('E',['E','G#','B']),('A',['A','C','E'])]
melodia=[[('A4',2),('C5',1),('E5',1),('A5',2),('G5',1),('E5',1)],
         [('F5',2),('E5',1),('C5',1),('A4',3),(None,1)],
         [('D5',2),('F5',1),('A5',1),('G5',1),('F5',1),('E5',1),('D5',1)],
         [('E5',3),('G#4',1),('B4',2),('E5',2)],
         [('A4',2),('C5',1),('E5',1),('A5',2),('B5',1),('C6',1)],
         [('A5',2),('G5',1),('F5',1),('E5',2),('C5',2)],
         [('B4',2),('G#4',1),('B4',1),('E5',2),('D5',1),('B4',1)],
         [('A4',6),(None,2)]]
for b,(raiz,notas) in enumerate(acordes):
    t0=b*COMPAS
    # bajo (triangulo)
    for i in range(8):
        n=raiz+('2' if i%2==0 else '3')
        mezclar(total,0.55*env(onda('tri',hz(n),CORCHEA*0.9),d=0.05,s=0.7),t0+i*CORCHEA)
    # arpegio (cuadrada 25%)
    for i in range(16):
        n=notas[i%3]+'4'
        mezclar(total,0.10*env(onda('sq',hz(n),CORCHEA/2*0.8,0.25),d=0.03,s=0.4),t0+i*CORCHEA/2)
    # percusion
    for i in range(8):
        if i%4==0:
            tt=np.arange(int(SR*0.12))/SR; k=np.sin(2*np.pi*(110*np.exp(-tt*25))*tt)*np.exp(-tt*20)
            mezclar(total,0.6*k,t0+i*CORCHEA)
        if i%2==1:
            nz=np.random.RandomState(b*8+i).uniform(-1,1,int(SR*0.04))*np.exp(-np.arange(int(SR*0.04))/SR*90)
            mezclar(total,0.12*nz,t0+i*CORCHEA)
    # melodia (cuadrada 50%)
    pos=0
    for n,l in melodia[b]:
        if n: mezclar(total,0.30*env(onda('sq',hz(n),CORCHEA*l*0.92,0.5),d=0.1,s=0.55,r=0.05),t0+pos*CORCHEA)
        pos+=l
guardar('snd_musica',total[:int(SR*COMPAS*NB)],0.7)

# ---------------- EFECTOS ----------------
guardar('snd_clic',env(onda('sq',1320,0.045,0.25),a=0.001,d=0.03,s=0.2,r=0.01),0.5)
a=np.concatenate([env(onda('sq',hz('E5'),0.07),d=0.04,s=0.5,r=0.01),env(onda('sq',hz('B5'),0.11),d=0.06,s=0.5,r=0.04)])
guardar('snd_asignar',a,0.55)
e=np.concatenate([env(onda('sq',140,0.11,0.5),d=0.05,s=0.6,r=0.02),np.zeros(int(SR*0.03)),env(onda('sq',105,0.16,0.5),d=0.05,s=0.6,r=0.05)])
guardar('snd_error',e,0.55)
blo=np.zeros(int(SR*1.1))
for i,n in enumerate(['A4','F4','D4','G#3']):
    x=env(onda('saw',hz(n),0.28 if i<3 else 0.5),d=0.1,s=0.5,r=0.08)
    trem=1+0.35*np.sin(2*np.pi*9*np.arange(len(x))/SR); mezclar(blo,x*trem,i*0.2)
guardar('snd_bloqueo',blo,0.65)
vic=np.zeros(int(SR*1.3))
for i,n in enumerate(['C5','E5','G5']): mezclar(vic,env(onda('sq',hz(n),0.12),d=0.05,s=0.6),i*0.11)
mezclar(vic,env(onda('sq',hz('C6'),0.7),d=0.2,s=0.5,r=0.3)+0.5*env(onda('sq',hz('G5'),0.7,0.25),d=0.2,s=0.5,r=0.3),0.35)
guardar('snd_victoria',vic,0.6)
print('ok')

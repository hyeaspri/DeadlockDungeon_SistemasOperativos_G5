# Genera los sprites pixel art de Deadlock Dungeon (requiere Python 3 y Pillow: pip install pillow)
# Uso: python recursos/generar_sprites.py   -> crea los PNG en recursos/imagenes/
import random, math, os
from PIL import Image, ImageDraw
OUT=os.path.join(os.path.dirname(os.path.abspath(__file__)),'imagenes')+os.sep
os.makedirs(OUT,exist_ok=True)
K=(24,16,28,255); T=(0,0,0,0)
def C(r,g,b): return (r,g,b,255)
def outline(img):
    w,h=img.size; s=img.load(); o=img.copy(); d=o.load()
    for y in range(h):
        for x in range(w):
            if s[x,y][3]==0:
                for dx,dy in((1,0),(-1,0),(0,1),(0,-1)):
                    nx,ny=x+dx,y+dy
                    if 0<=nx<w and 0<=ny<h and s[nx,ny][3]>0 and s[nx,ny]!=K: d[x,y]=K;break
    return o
def R(d,x0,y0,x1,y1,c): d.rectangle([x0,y0,x1,y1],fill=c)
def E(d,x0,y0,x1,y1,c): d.ellipse([x0,y0,x1,y1],fill=c)
def P(d,x,y,c): d.point((x,y),fill=c)
def save(img,name,s): img.resize((img.width*s,img.height*s),Image.NEAREST).save(OUT+name+'.png')

# paletas
S1=C(232,236,245);S2=C(178,186,204);S3=C(122,130,154);S4=C(78,82,108)
SK1=C(255,222,196);SK2=C(240,184,152);SK3=C(206,140,120)
RE1=C(240,80,60);RE2=C(196,40,40);RE3=C(130,22,34)
GO1=C(255,230,120);GO2=C(238,182,52);GO3=C(176,112,30)
BR1=C(150,96,56);BR2=C(104,62,36);BR3=C(66,38,26)
EY=C(30,22,40);WH=C(255,255,255);CH=C(250,150,150)

def cara(d,cx,y):  # ojos grandes estilo chibi
    for ex in (cx-5,cx+3):
        R(d,ex,y,ex+1,y+2,EY); P(d,ex,y,WH)
    P(d,cx-7,y+3,CH);P(d,cx-6,y+3,CH);P(d,cx+5,y+3,CH);P(d,cx+6,y+3,CH)
    R(d,cx-1,y+4,cx,y+4,SK3)

# ================= CABALLERO 38x40 =================
im=Image.new('RGBA',(38,40),T); d=ImageDraw.Draw(im)
# espada (detras, mano izquierda del personaje)
R(d,4,6,6,27,S1); R(d,6,6,6,27,S3); R(d,5,4,5,5,S1); P(d,4,8,WH)
R(d,1,27,9,28,GO2); R(d,1,28,9,28,GO3); R(d,4,29,6,32,BR2); R(d,4,33,6,34,GO2)
# piernas y botas
R(d,13,32,17,36,S3); R(d,20,32,24,36,S3); R(d,13,32,14,35,S2); R(d,20,32,21,35,S2)
R(d,12,36,17,38,BR2); R(d,20,36,25,38,BR2); R(d,12,38,17,38,BR3); R(d,20,38,25,38,BR3)
# torso
R(d,11,22,26,32,S3); R(d,11,22,13,32,S2)
R(d,14,22,23,31,RE2); R(d,14,22,15,31,RE1); R(d,22,22,23,31,RE3)
R(d,18,24,19,28,GO2); R(d,16,25,21,26,GO2); P(d,18,24,GO1)
R(d,11,29,26,30,BR2); R(d,17,29,20,30,GO2)
# hombreras
E(d,6,20,14,27,S2); E(d,7,21,11,24,S1); E(d,23,20,31,27,S3); E(d,25,21,29,24,S2)
# brazos y guantes
R(d,7,26,10,30,S3); R(d,6,30,10,33,S4); R(d,27,26,30,30,S3); R(d,27,30,31,33,S4)
# casco grande
E(d,8,2,29,23,S2); E(d,9,3,22,14,S1); E(d,18,10,29,23,S3)
R(d,10,20,27,23,S3)
# visera abierta / cara
E(d,11,9,26,22,SK2); E(d,12,9,24,20,SK1)
R(d,11,8,26,10,S4); R(d,11,8,26,8,S3)
cara(d,19,13)
# protectores de mejillas
R(d,9,11,11,21,S3); R(d,26,11,28,21,S4); P(d,9,12,S2)
# cresta roja
d.polygon([(17,0),(20,0),(24,3),(21,5),(18,3)],fill=RE2); R(d,17,0,19,6,RE2); R(d,17,0,17,5,RE1); P(d,22,2,RE1)
R(d,16,6,20,7,S4)
im=outline(im); save(im,'spr_caballero',3)

# ================= MAGO 38x40 =================
im=Image.new('RGBA',(38,40),T); d=ImageDraw.Draw(im)
H1=C(120,110,250);H2=C(84,70,214);H3=C(52,40,150);H4=C(34,24,100)
B1=C(96,126,255);B2=C(60,84,220);B3=C(38,52,160)
PL1=C(190,120,230);PL2=C(140,70,190)
CY1=C(200,250,255);CY2=C(90,210,255);CY3=C(40,140,220)
# baculo
R(d,32,9,33,38,BR1); R(d,33,9,33,38,BR2); E(d,30,3,35,8,CY2); R(d,31,4,32,5,CY1); P(d,34,7,CY3)
R(d,31,9,34,10,GO2)
# botas
R(d,12,36,17,38,BR2); R(d,20,36,25,38,BR2)
# tunica
d.polygon([(12,24),(25,24),(28,36),(9,36)],fill=B2); d.polygon([(21,24),(25,24),(28,36),(23,36)],fill=B3)
d.polygon([(12,24),(15,24),(13,36),(9,36)],fill=B1)
R(d,9,35,28,36,H3); R(d,12,30,25,31,GO2); R(d,17,30,20,31,GO1); P(d,18,25,GO2); P(d,18,27,GO2)
# mangas y manos
d.polygon([(11,24),(14,25),(10,32),(6,31)],fill=B2); R(d,5,31,8,33,SK2)
d.polygon([(26,24),(23,25),(28,31),(31,30)],fill=B3); R(d,29,29,32,31,SK2)
# pelo (detras)
E(d,9,13,28,27,PL2); R(d,9,18,12,26,PL2); R(d,25,18,28,26,PL2)
# cara
E(d,11,13,26,26,SK2); E(d,12,13,24,24,SK1)
cara(d,19,18)
# flequillo
d.polygon([(11,14),(26,14),(25,18),(21,16),(17,18),(13,17)],fill=PL1)
# sombrero: ala
E(d,3,11,34,18,H3); E(d,4,11,30,16,H2)
# --- pasar a un lienzo mas alto para el cono ---
big=Image.new('RGBA',(38,48),T); big.alpha_composite(im,(0,8)); im=big; d=ImageDraw.Draw(im)
d.polygon([(11,21),(26,21),(24,12),(22,6),(25,2),(30,1),(33,4),(29,4),(26,6),(25,12)],fill=H2)
d.polygon([(11,21),(16,21),(18,12),(20,6),(22,6)],fill=H1)
d.polygon([(21,21),(26,21),(25,12),(26,6),(29,4),(33,4),(24,9)],fill=H3)
d.polygon([(11,21),(20,6),(22,6),(19,12),(16,21)],fill=H1)
R(d,11,18,26,20,GO2); R(d,11,20,26,20,GO3); R(d,17,18,20,20,GO1)
P(d,16,13,GO1);P(d,22,10,GO1);P(d,31,2,GO1)
im=outline(im); save(im,'spr_mago',3)

# ================= LLAVE 22x22 =================
im=Image.new('RGBA',(22,22),T); d=ImageDraw.Draw(im)
E(d,1,3,10,12,GO2); E(d,2,4,7,9,GO1); E(d,4,6,7,9,T); E(d,6,8,10,12,GO3)
E(d,4,6,7,9,T)
R(d,9,7,20,9,GO2); R(d,9,7,20,7,GO1); R(d,9,9,20,9,GO3)
R(d,15,10,16,13,GO2); R(d,18,10,19,14,GO2); R(d,19,10,19,14,GO3)
P(d,3,5,WH)
im=outline(im); save(im,'spr_llave',3)

# ================= ESCUDO 22x24 =================
im=Image.new('RGBA',(22,24),T); d=ImageDraw.Draw(im)
SH=[(1,2),(6,1),(11,0),(16,1),(20,2),(20,11),(16,18),(11,23),(10,23),(5,18),(1,11)]
d.polygon(SH,fill=S2)
IN=[(3,4),(11,2),(18,4),(18,11),(14,17),(11,20),(10,20),(7,17),(3,11)]
d.polygon(IN,fill=B2 if False else C(60,110,220))
d.polygon([(11,2),(18,4),(18,11),(14,17),(11,20)],fill=C(40,76,170))
d.polygon([(4,5),(8,4),(5,11)],fill=C(120,170,255))
R(d,10,5,11,16,S1); R(d,6,8,15,9,S1); R(d,11,5,11,16,S3); R(d,6,9,15,9,S3)
R(d,1,2,2,10,S1); P(d,6,1,S1)
im=outline(im); save(im,'spr_escudo',3)

# ================= PUERTA 34x38 =================
im=Image.new('RGBA',(34,38),T); d=ImageDraw.Draw(im)
ST1=C(150,140,150);ST2=C(112,102,116);ST3=C(74,66,82)
E(d,0,0,33,30,ST2); R(d,0,15,33,37,ST2)
# dovelas del arco
for a in range(0,181,20):
    r=math.radians(180+a); x=16.5+14*math.cos(r); y=15+14*math.sin(r)
    E(d,int(x)-2,int(y)-2,int(x)+2,int(y)+2,ST1); P(d,int(x)+1,int(y)+1,ST3)
for y in range(17,36,5):
    R(d,0,y,3,y+3,ST1); R(d,30,y,33,y+3,ST1); R(d,0,y+3,3,y+3,ST3); R(d,30,y+3,33,y+3,ST3)
WD1=C(150,92,50);WD2=C(116,68,36);WD3=C(78,44,24)
E(d,5,4,28,26,WD2); R(d,5,15,28,37,WD2)
for x in (8,12,16,20,24): R(d,x,5,x,37,WD3); R(d,x+1,5,x+1,37,WD1)
R(d,5,13,28,14,ST3); R(d,5,28,28,29,ST3)
for x in (7,26): P(d,x,13,ST1);P(d,x,28,ST1)
# candado
R(d,14,17,19,23,GO2); R(d,14,17,19,17,GO1); R(d,19,17,19,23,GO3); R(d,15,14,18,16,T)
R(d,14,14,14,17,GO3); R(d,19,14,19,17,GO3); R(d,15,13,18,13,GO3)
R(d,16,19,17,21,BR3)
R(d,4,37,29,37,ST3)
im=outline(im); save(im,'spr_puerta',3)

# ================= FONDO 320x165 x4 =================
random.seed(11)
W,H=320,165; WALL=72
im=Image.new('RGB',(W,H)); p=im.load()
def brick(x0,y0,w,h,base,rnd):
    b=rnd.randint(-12,12); col=(base[0]+b,base[1]+b,base[2]+b)
    for y in range(y0,y0+h):
        for x in range(x0,x0+w):
            if 0<=x<W and 0<=y<H:
                c=col
                if y==y0: c=(col[0]+18,col[1]+14,col[2]+12)
                elif y==y0+h-1 or x==x0+w-1: c=(col[0]-16,col[1]-14,col[2]-12)
                elif x==x0: c=(col[0]+8,col[1]+6,col[2]+6)
                if rnd.random()<0.04: c=(c[0]-10,c[1]-10,c[2]-8)
                p[x,y]=c
for y in range(H):
    for x in range(W): p[x,y]=(26,18,26)
rnd=random.Random(5)
for row in range(WALL//9+1):
    off=-8 if row%2 else 0
    for i in range(-1,W//16+2):
        brick(i*16+off,row*9,15,8,(76,54,66),rnd)
for x in range(W):
    for y in range(WALL,WALL+4): p[x,y]=(40,28,36) if y<WALL+3 else (22,16,22)
for row in range((H-WALL)//14+1):
    off=-12 if row%2 else 0
    for i in range(-1,W//24+2):
        brick(i*24+off,WALL+4+row*14,23,13,(62,48,60),rnd)
torches=[(40,34),(120,34),(200,34),(280,34)]
img=im.copy(); q=img.load()
for y in range(H):
    for x in range(W):
        r,g,b=p[x,y]; L=0
        for tx,ty in torches:
            dd=math.hypot(x-tx,(y-ty)*1.15); L+=max(0,1-dd/62)**2
        L=min(L,1.25)
        r=r*(1+1.1*L)+38*L; g=g*(1+0.6*L)+16*L; b=b*(1+0.05*L)
        v=math.hypot((x-W/2)/(W/2),(y-H/2)/(H/2)); f=max(0.4,1-0.4*v*v)
        q[x,y]=(min(255,int(r*f)),min(255,int(g*f)),min(255,int(b*f)))
d=ImageDraw.Draw(img)
for tx,ty in torches:
    R(d,tx-3,ty+3,tx+3,ty+5,(70,52,40)); R(d,tx-2,ty+5,tx+2,ty+6,(50,36,30))
    R(d,tx-1,ty+6,tx+1,ty+14,(96,60,34)); R(d,tx-2,ty+14,tx+2,ty+15,(50,36,30))
    d.polygon([(tx-4,ty+3),(tx+4,ty+3),(tx+3,ty-3),(tx+1,ty-6),(tx,ty-10),(tx-1,ty-5),(tx-3,ty-3)],fill=(236,110,30))
    d.polygon([(tx-3,ty+3),(tx+3,ty+3),(tx+2,ty-2),(tx,ty-7),(tx-2,ty-2)],fill=(255,180,50))
    R(d,tx-1,ty-1,tx+1,ty+2,(255,240,170))
for cx in (80,240):
    for i in range(0,26,3):
        R(d,cx,i,cx+1,i+1,(44,38,48)); R(d,cx,i+2,cx+1,i+2,(96,88,100))
img.resize((W*4,H*4),Image.NEAREST).save(OUT+'spr_fondo.png')

prev=Image.open(OUT+'spr_fondo.png').convert('RGBA')
for n,(x,y) in {'spr_puerta':(589,10),'spr_caballero':(225,280),'spr_mago':(940,256),'spr_llave':(520,220),'spr_escudo':(700,215)}.items():
    prev.alpha_composite(Image.open(OUT+n+'.png'),(x,y))
prev.save(OUT+'vista_previa.png')
